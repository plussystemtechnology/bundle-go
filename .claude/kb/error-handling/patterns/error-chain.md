# Error Chain Pattern

## Overview

A consistent error chain gives you a readable, traceable error message
from the top of the call stack down to the root cause.
Each layer adds context without losing the original error.

## The Chain Convention

```
handler:    logs full chain, responds with user-safe message
app:        wraps with use-case context
adapter:    wraps with operation context; translates infra → domain
domain:     returns sentinel or custom error (no wrapping)
```

## Full Example: CreateAppointment

### domain (origin)

```go
// domain/appointment/errors.go
var ErrSlotTaken = errors.New("appointment slot already taken")
```

### adapter/db (translates + wraps)

```go
func (r *AppointmentRepo) FindConflict(ctx context.Context, doctorID string, at time.Time) (bool, error) {
    n, err := r.queries.CountConflictingAppointments(ctx, sqlc.CountConflictingParams{
        DoctorID: doctorID,
        From:     at.Add(-30 * time.Minute),
        To:       at.Add(30 * time.Minute),
    })
    if err != nil {
        return false, fmt.Errorf("appointment repo find conflict: %w", err)
    }
    return n > 0, nil
}
```

### app/service (business logic + wrapping)

```go
func (s *AppointmentService) Schedule(ctx context.Context, cmd ScheduleCommand) (*appointment.Appointment, error) {
    // Check conflict
    conflict, err := s.repo.FindConflict(ctx, cmd.DoctorID, cmd.ScheduledAt)
    if err != nil {
        return nil, fmt.Errorf("schedule appointment check conflict: %w", err)
    }
    if conflict {
        return nil, appointment.ErrSlotTaken  // domain sentinel
    }

    appt := appointment.New(cmd.PatientID, cmd.DoctorID, cmd.ScheduledAt)
    if err := s.repo.Save(ctx, appt); err != nil {
        return nil, fmt.Errorf("schedule appointment save: %w", err)
    }

    if err := s.events.PublishScheduled(ctx, appt); err != nil {
        s.logger.Warn("publish appointment scheduled failed",
            zap.String("appointment_id", appt.ID),
            zap.Error(err),
        )
        // non-fatal: log and continue
    }

    return appt, nil
}
```

### adapter/http/handler (check chain + respond)

```go
func (h *AppointmentHandler) Schedule(c *gin.Context) {
    var req ScheduleRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request body"})
        return
    }

    appt, err := h.svc.Schedule(c.Request.Context(), toCommand(req))
    if err != nil {
        // Use errors.Is to check sentinel anywhere in chain
        switch {
        case errors.Is(err, appointment.ErrSlotTaken):
            c.JSON(http.StatusConflict, gin.H{"error": "the selected time slot is not available"})
        case errors.Is(err, appointment.ErrDoctorUnavailable):
            c.JSON(http.StatusConflict, gin.H{"error": "doctor is not available at that time"})
        default:
            // Unknown/infra error — log full chain, return safe message
            h.logger.Error("schedule appointment",
                zap.String("patient_id", req.PatientID),
                zap.Error(err),  // full chain: "schedule appointment save: appointment repo: <pg error>"
            )
            c.JSON(http.StatusInternalServerError, gin.H{"error": "unable to schedule appointment"})
        }
        return
    }

    c.JSON(http.StatusCreated, gin.H{"data": toResponse(appt)})
}
```

## Resulting Error Chain

When a DB error occurs, the full message is:
```
schedule appointment save: appointment repo save: ERROR: duplicate key value violates unique constraint "appointments_doctor_id_scheduled_at_key" (SQLSTATE 23505)
```

When a domain error occurs (slot taken):
```
errors.Is(err, appointment.ErrSlotTaken) == true
```

## Error Chain for Multiple Operations

```go
func (s *PatientService) TransferRecords(ctx context.Context, fromID, toID string) error {
    from, err := s.repo.FindByID(ctx, fromID)
    if err != nil {
        return fmt.Errorf("transfer records find source patient: %w", err)
    }

    to, err := s.repo.FindByID(ctx, toID)
    if err != nil {
        return fmt.Errorf("transfer records find target patient: %w", err)
    }

    if err := s.records.Transfer(ctx, from, to); err != nil {
        return fmt.Errorf("transfer records: %w", err)
    }

    return nil
}
// Chain: "transfer records find source patient: patient repo find by id: ..."
// Or:    "transfer records: record repo transfer: ..."
```

## Never Do This

```go
// BAD: returns nil error silently
p, _ := s.repo.FindByID(ctx, id)

// BAD: swallows error information
if err != nil { return errors.New("something failed") }

// BAD: double-logs and double-wraps
if err != nil {
    log.Printf("error: %v", err)
    return fmt.Errorf("error: %w", err)  // "error: error: original"
}
```
