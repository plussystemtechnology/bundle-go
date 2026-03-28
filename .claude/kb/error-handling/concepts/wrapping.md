# Error Wrapping in Go

## The `%w` Verb

`fmt.Errorf` with `%w` wraps an error, preserving it in the chain:

```go
original := errors.New("connection refused")
wrapped  := fmt.Errorf("dial database: %w", original)
// wrapped.Error() == "dial database: connection refused"

// The original is still accessible
errors.Is(wrapped, original) // true
```

## `errors.Is` — Check Value in Chain

Used for **sentinel errors** (named error variables):

```go
// domain/patient/errors.go
var ErrNotFound = errors.New("patient not found")

// adapter/db/repo/patient_repo.go
func (r *PatientRepo) FindByID(ctx context.Context, id string) (*patient.Patient, error) {
    row, err := r.queries.GetPatient(ctx, id)
    if errors.Is(err, pgx.ErrNoRows) {
        return nil, patient.ErrNotFound  // translate infra error to domain error
    }
    if err != nil {
        return nil, fmt.Errorf("patient repo find: %w", err)
    }
    return toDomain(row), nil
}

// app/service/patient_service.go — check domain error
p, err := s.repo.FindByID(ctx, id)
if errors.Is(err, patient.ErrNotFound) {
    return nil, fmt.Errorf("get patient: %w", err)
}

// adapter/http/handler/patient_handler.go — translate to HTTP
if errors.Is(err, patient.ErrNotFound) {
    c.JSON(http.StatusNotFound, gin.H{"error": "patient not found"})
    return
}
```

## `errors.As` — Extract Type from Chain

Used for **custom error structs**:

```go
// Check and extract ConflictError anywhere in the chain
var ce *appointment.ConflictError
if errors.As(err, &ce) {
    c.JSON(http.StatusConflict, gin.H{
        "error":          "scheduling conflict",
        "conflicting_id": ce.ConflictingID,
        "scheduled_at":   ce.ScheduledAt,
    })
    return
}

// Check and extract ValidationError
var ve *apierror.ValidationError
if errors.As(err, &ve) {
    c.JSON(http.StatusUnprocessableEntity, gin.H{
        "error":  "validation failed",
        "fields": ve.Fields,
    })
    return
}
```

## Error Chain Traversal

```go
// errors.Unwrap goes one level
inner := errors.Unwrap(wrapped)

// errors.Is and errors.As traverse the full chain
err1 := errors.New("root cause")
err2 := fmt.Errorf("step 2: %w", err1)
err3 := fmt.Errorf("step 3: %w", err2)

errors.Is(err3, err1) // true — traverses chain
```

## Custom Unwrap for Struct Errors

To make a custom error struct work with `errors.Is`/`errors.As`:

```go
type WrappedDBError struct {
    Op  string
    Err error
}

func (e *WrappedDBError) Error() string {
    return fmt.Sprintf("db %s: %v", e.Op, e.Err)
}

// Implement Unwrap to participate in errors.Is/As chain
func (e *WrappedDBError) Unwrap() error { return e.Err }
```

## Multiple Error Wrapping (Go 1.20+)

```go
err := fmt.Errorf("two problems: %w; %w", err1, err2)

// errors.Is checks both
errors.Is(err, err1) // true
errors.Is(err, err2) // true

// errors.Join also wraps multiple
combined := errors.Join(err1, err2)
```

## Layer-by-Layer Wrapping Example

```go
// adapter/db — translates DB error to domain error
func (r *PatientRepo) FindByID(ctx context.Context, id string) (*patient.Patient, error) {
    row, err := r.queries.GetPatient(ctx, id)
    if errors.Is(err, pgx.ErrNoRows) {
        return nil, patient.ErrNotFound  // domain sentinel, no wrapping needed
    }
    if err != nil {
        return nil, fmt.Errorf("patient repo find by id: %w", err)
    }
    return toDomain(row), nil
}

// app/service — adds use case context
func (s *PatientService) GetPatient(ctx context.Context, id string) (*patient.Patient, error) {
    p, err := s.repo.FindByID(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("patient service get: %w", err)
    }
    return p, nil
}

// adapter/http/handler — converts to HTTP
func (h *PatientHandler) GetPatient(c *gin.Context) {
    p, err := h.svc.GetPatient(c.Request.Context(), c.Param("id"))
    if err != nil {
        if errors.Is(err, patient.ErrNotFound) {
            c.JSON(http.StatusNotFound, gin.H{"error": "patient not found"})
            return
        }
        h.logger.Error("get patient", zap.Error(err))
        c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
        return
    }
    c.JSON(http.StatusOK, gin.H{"data": p})
}
```

The full error chain:
`"patient service get: patient repo find by id: ERROR: no rows in result set"`

`errors.Is(err, patient.ErrNotFound)` returns `true` at any layer.
