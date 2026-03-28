# Error Types in Go

## The `error` Interface

```go
type error interface { Error() string }
```

Everything that implements `Error() string` is an error. This simplicity enables
powerful composition through wrapping.

## Type 1: Simple String Error

```go
var ErrUnauthorized = errors.New("unauthorized")

// Use when: no extra data needed, just a condition name
if !token.Valid {
    return ErrUnauthorized
}
```

## Type 2: Sentinel Error (Named Variable)

Defined in `domain/` for business conditions:

```go
// domain/patient/errors.go
package patient

import "errors"

var (
    ErrNotFound           = errors.New("patient not found")
    ErrInvalidCPF         = errors.New("invalid CPF")
    ErrCPFAlreadyExists   = errors.New("CPF already registered")
    ErrAlreadyInactive    = errors.New("patient already inactive")
    ErrInvalidBirthDate   = errors.New("invalid birth date")
)
```

Callers check with `errors.Is`:
```go
if errors.Is(err, patient.ErrNotFound) {
    c.JSON(http.StatusNotFound, gin.H{"error": "patient not found"})
}
```

## Type 3: Custom Error Struct

Use when the error needs to carry additional structured data:

```go
// domain/appointment/errors.go
package appointment

import "fmt"

// ConflictError is returned when a scheduling conflict is detected
type ConflictError struct {
    PatientID      string
    ConflictingID  string
    ScheduledAt    time.Time
}

func (e *ConflictError) Error() string {
    return fmt.Sprintf(
        "scheduling conflict for patient %s: appointment %s already scheduled at %s",
        e.PatientID, e.ConflictingID, e.ScheduledAt.Format(time.RFC3339),
    )
}

// Usage
return &appointment.ConflictError{
    PatientID:     patientID,
    ConflictingID: existing.ID,
    ScheduledAt:   existing.ScheduledAt,
}

// Caller extracts data
var ce *appointment.ConflictError
if errors.As(err, &ce) {
    log.Printf("conflict with appointment %s", ce.ConflictingID)
}
```

## Type 4: Validation Error

Multiple field errors collected before returning:

```go
// pkg/apierror/validation.go
package apierror

import (
    "fmt"
    "strings"
)

type FieldError struct {
    Field   string `json:"field"`
    Message string `json:"message"`
}

type ValidationError struct {
    Fields []FieldError `json:"fields"`
}

func (e *ValidationError) Error() string {
    msgs := make([]string, len(e.Fields))
    for i, f := range e.Fields {
        msgs[i] = fmt.Sprintf("%s: %s", f.Field, f.Message)
    }
    return "validation error: " + strings.Join(msgs, "; ")
}

func (e *ValidationError) Add(field, msg string) {
    e.Fields = append(e.Fields, FieldError{Field: field, Message: msg})
}

func (e *ValidationError) HasErrors() bool { return len(e.Fields) > 0 }
```

## Type 5: APIError (HTTP-aware)

For translating errors to HTTP responses:

```go
// pkg/apierror/api_error.go
package apierror

import "net/http"

type APIError struct {
    Code    int    `json:"code"`
    Message string `json:"message"`
    Details any    `json:"details,omitempty"`
}

func (e *APIError) Error() string { return e.Message }

// Constructors
func NotFound(msg string) *APIError        { return &APIError{Code: http.StatusNotFound, Message: msg} }
func BadRequest(msg string) *APIError      { return &APIError{Code: http.StatusBadRequest, Message: msg} }
func Unprocessable(msg string) *APIError   { return &APIError{Code: http.StatusUnprocessableEntity, Message: msg} }
func Conflict(msg string) *APIError        { return &APIError{Code: http.StatusConflict, Message: msg} }
func Internal(msg string) *APIError        { return &APIError{Code: http.StatusInternalServerError, Message: msg} }
func Unauthorized(msg string) *APIError    { return &APIError{Code: http.StatusUnauthorized, Message: msg} }
```

## Summary: Which Type to Use

| Condition                                | Type                |
|------------------------------------------|---------------------|
| Simple named domain condition            | Sentinel (`var ErrX`) |
| Error with structured data for caller    | Custom struct       |
| Multiple field validation failures       | `ValidationError`   |
| HTTP response with status code           | `APIError`          |
| Wrapping an error with context           | `fmt.Errorf("%w")`  |
| Truly unexpected / programming error     | `panic` (startup only) |
