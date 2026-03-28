# Sentinel Errors in Go

## What Are Sentinel Errors?

Sentinel errors are **named package-level error variables** that represent specific,
expected conditions. Callers check them with `errors.Is`.

```go
var ErrNotFound = errors.New("patient not found")
```

The name "sentinel" comes from the idea of a guard — a known, fixed value to check against.

## Where to Define Them

Sentinel errors for **domain conditions** live in `domain/`:

```go
// domain/patient/errors.go
package patient

import "errors"

var (
    ErrNotFound         = errors.New("patient not found")
    ErrInvalidCPF       = errors.New("invalid CPF")
    ErrCPFAlreadyExists = errors.New("CPF already registered")
    ErrAlreadyInactive  = errors.New("patient already inactive")
    ErrInvalidBirthDate = errors.New("invalid birth date")
)
```

```go
// domain/appointment/errors.go
package appointment

import "errors"

var (
    ErrNotFound        = errors.New("appointment not found")
    ErrSlotTaken       = errors.New("appointment slot already taken")
    ErrInvalidStatus   = errors.New("invalid appointment status")
    ErrTooLateToCancel = errors.New("cannot cancel appointment less than 24h before")
    ErrDoctorUnavailable = errors.New("doctor not available at requested time")
)
```

## Standard Library Sentinel Errors to Know

```go
// Package errors
errors.ErrUnsupported  // Go 1.21+

// Package io
io.EOF
io.ErrUnexpectedEOF
io.ErrClosedPipe

// Package sql
sql.ErrNoRows

// pgx (used in NoxCare-Go)
pgx.ErrNoRows
pgx.ErrTxClosed

// net
net.ErrClosed
```

## Using Sentinel Errors

### In domain layer (return the sentinel)

```go
func (p *Patient) Deactivate() error {
    if !p.Active {
        return ErrAlreadyInactive
    }
    p.Active = false
    return nil
}
```

### In adapter layer (translate infra to domain)

```go
func (r *PatientRepo) FindByID(ctx context.Context, id string) (*patient.Patient, error) {
    row, err := r.queries.GetPatient(ctx, id)
    if errors.Is(err, pgx.ErrNoRows) {
        return nil, patient.ErrNotFound  // translate
    }
    if err != nil {
        return nil, fmt.Errorf("patient repo: %w", err)
    }
    return toDomain(row), nil
}
```

### In app layer (may pass through or wrap)

```go
func (s *PatientService) GetPatient(ctx context.Context, id string) (*patient.Patient, error) {
    p, err := s.repo.FindByID(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("get patient: %w", err)  // wraps — sentinel still visible
    }
    return p, nil
}
```

### In handler layer (check and respond)

```go
func (h *PatientHandler) Get(c *gin.Context) {
    p, err := h.svc.GetPatient(c.Request.Context(), c.Param("id"))
    if err != nil {
        switch {
        case errors.Is(err, patient.ErrNotFound):
            c.JSON(http.StatusNotFound, gin.H{"error": "patient not found"})
        case errors.Is(err, patient.ErrAlreadyInactive):
            c.JSON(http.StatusConflict, gin.H{"error": "patient is already inactive"})
        default:
            h.logger.Error("get patient", zap.Error(err))
            c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
        }
        return
    }
    c.JSON(http.StatusOK, gin.H{"data": toResponse(p)})
}
```

## Sentinel vs Custom Error Struct

| Need                                      | Use                    |
|-------------------------------------------|------------------------|
| Named condition, no extra data            | Sentinel `var ErrX`    |
| Condition + related data for caller       | Custom struct          |
| Multiple fields describing the error      | Custom struct          |
| Simple "yes/no" check in caller           | Sentinel               |

```go
// Sentinel — caller just needs to know "not found"
var ErrNotFound = errors.New("patient not found")

// Custom struct — caller needs to know which field failed
type ConflictError struct {
    ExistingID string
    Field      string
}
```

## Don't Use Sentinel Errors for Programming Errors

```go
// BAD: sentinel for a programming error
var ErrNilRepository = errors.New("repository is nil")

// GOOD: panic at startup (it's a bug, not a runtime condition)
func NewService(repo port.PatientRepository) *PatientService {
    if repo == nil {
        panic("PatientService: repo must not be nil")
    }
    return &PatientService{repo: repo}
}
```
