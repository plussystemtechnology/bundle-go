# Repository Pattern

## Overview

- **Interface** lives in `port/` — defines what the application needs
- **Implementation** lives in `adapter/db/repo/` — uses pgx/sqlc
- Application services only see the interface; DB details are hidden

## Interface Definition (port/)

```go
// port/appointment_repository.go
package port

import (
    "context"
    "time"
    "github.com/org/noxcare-go/domain/appointment"
)

type AppointmentRepository interface {
    FindByID(ctx context.Context, id string) (*appointment.Appointment, error)
    ListByPatient(ctx context.Context, patientID string, from, to time.Time) ([]*appointment.Appointment, error)
    ListByDoctor(ctx context.Context, doctorID string, date time.Time) ([]*appointment.Appointment, error)
    Save(ctx context.Context, a *appointment.Appointment) error
    UpdateStatus(ctx context.Context, id string, status appointment.Status) error
    Delete(ctx context.Context, id string) error
}
```

## Implementation (adapter/db/repo/)

```go
// adapter/db/repo/appointment_repo.go
package repo

import (
    "context"
    "errors"
    "fmt"
    "time"

    "github.com/jackc/pgx/v5"
    "github.com/jackc/pgx/v5/pgxpool"
    "go.uber.org/zap"
    "github.com/org/noxcare-go/adapter/db/sqlc"
    "github.com/org/noxcare-go/domain/appointment"
    "github.com/org/noxcare-go/port"
)

// Compile-time check
var _ port.AppointmentRepository = (*AppointmentRepo)(nil)

type AppointmentRepo struct {
    db      *pgxpool.Pool
    queries *sqlc.Queries
    logger  *zap.Logger
}

func NewAppointmentRepo(db *pgxpool.Pool, logger *zap.Logger) *AppointmentRepo {
    return &AppointmentRepo{
        db:      db,
        queries: sqlc.New(db),
        logger:  logger.With(zap.String("component", "appointment_repo")),
    }
}

func (r *AppointmentRepo) FindByID(ctx context.Context, id string) (*appointment.Appointment, error) {
    row, err := r.queries.GetAppointmentByID(ctx, id)
    if err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return nil, appointment.ErrNotFound
        }
        return nil, fmt.Errorf("appointment repo find by id: %w", err)
    }
    return toDomainAppointment(row), nil
}

func (r *AppointmentRepo) ListByPatient(
    ctx context.Context,
    patientID string,
    from, to time.Time,
) ([]*appointment.Appointment, error) {
    rows, err := r.queries.ListAppointmentsByPatient(ctx, sqlc.ListAppointmentsByPatientParams{
        PatientID: patientID,
        FromDate:  from,
        ToDate:    to,
    })
    if err != nil {
        return nil, fmt.Errorf("appointment repo list by patient: %w", err)
    }
    result := make([]*appointment.Appointment, 0, len(rows))
    for _, row := range rows {
        result = append(result, toDomainAppointment(row))
    }
    return result, nil
}

func (r *AppointmentRepo) Save(ctx context.Context, a *appointment.Appointment) error {
    err := r.queries.InsertAppointment(ctx, sqlc.InsertAppointmentParams{
        ID:          a.ID,
        PatientID:   a.PatientID,
        DoctorID:    a.DoctorID,
        ScheduledAt: a.ScheduledAt,
        Status:      string(a.Status),
        Notes:       a.Notes,
    })
    if err != nil {
        return fmt.Errorf("appointment repo save: %w", err)
    }
    return nil
}

func (r *AppointmentRepo) UpdateStatus(ctx context.Context, id string, status appointment.Status) error {
    err := r.queries.UpdateAppointmentStatus(ctx, sqlc.UpdateAppointmentStatusParams{
        ID:     id,
        Status: string(status),
    })
    if err != nil {
        return fmt.Errorf("appointment repo update status: %w", err)
    }
    return nil
}

// toDomainAppointment maps sqlc generated row to domain type
func toDomainAppointment(row sqlc.Appointment) *appointment.Appointment {
    return &appointment.Appointment{
        ID:          row.ID,
        PatientID:   row.PatientID,
        DoctorID:    row.DoctorID,
        ScheduledAt: row.ScheduledAt.Time,
        Status:      appointment.Status(row.Status),
        Notes:       row.Notes.String,
        CreatedAt:   row.CreatedAt.Time,
        UpdatedAt:   row.UpdatedAt.Time,
    }
}
```

## Transactional Repository

For operations that need DB transactions:

```go
// port/tx_manager.go
package port

import "context"

type TxManager interface {
    WithTx(ctx context.Context, fn func(ctx context.Context) error) error
}

// adapter/db/repo/tx_manager.go
type PgxTxManager struct{ db *pgxpool.Pool }

func (m *PgxTxManager) WithTx(ctx context.Context, fn func(ctx context.Context) error) error {
    tx, err := m.db.Begin(ctx)
    if err != nil {
        return fmt.Errorf("begin tx: %w", err)
    }
    defer func() {
        if p := recover(); p != nil {
            _ = tx.Rollback(ctx)
            panic(p)
        }
    }()
    if err := fn(pgx.WithTx(ctx, tx)); err != nil {
        _ = tx.Rollback(ctx)
        return err
    }
    return tx.Commit(ctx)
}

// Usage in app service
func (s *AppointmentService) BookWithPayment(ctx context.Context, cmd BookCommand) error {
    return s.txMgr.WithTx(ctx, func(ctx context.Context) error {
        if err := s.apptRepo.Save(ctx, appt); err != nil {
            return err
        }
        return s.paymentRepo.Save(ctx, payment)
    })
}
```

## In-Memory Repository for Testing

```go
// For unit tests — no DB needed
type InMemoryPatientRepo struct {
    mu       sync.RWMutex
    patients map[string]*patient.Patient
}

func NewInMemoryPatientRepo() *InMemoryPatientRepo {
    return &InMemoryPatientRepo{patients: make(map[string]*patient.Patient)}
}

func (r *InMemoryPatientRepo) FindByID(_ context.Context, id string) (*patient.Patient, error) {
    r.mu.RLock()
    defer r.mu.RUnlock()
    p, ok := r.patients[id]
    if !ok {
        return nil, patient.ErrPatientNotFound
    }
    return p, nil
}

func (r *InMemoryPatientRepo) Save(_ context.Context, p *patient.Patient) error {
    r.mu.Lock()
    defer r.mu.Unlock()
    r.patients[p.ID] = p
    return nil
}
```
