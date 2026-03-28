# Custom Error Types

## When to Create a Custom Error Struct

- The error needs to carry structured data (IDs, field names, codes)
- The caller needs to extract that data programmatically
- `errors.As` will be used to unwrap and inspect the error

## Domain Custom Error: ConflictError

```go
// domain/appointment/errors.go
package appointment

import (
    "fmt"
    "time"
)

// ConflictError carries details about a scheduling conflict
type ConflictError struct {
    PatientID      string
    ConflictingID  string
    ScheduledAt    time.Time
}

func (e *ConflictError) Error() string {
    return fmt.Sprintf(
        "scheduling conflict for patient %s: appointment %s already exists at %s",
        e.PatientID,
        e.ConflictingID,
        e.ScheduledAt.Format("2006-01-02 15:04"),
    )
}

// NewConflictError is a constructor for clarity
func NewConflictError(patientID, conflictingID string, at time.Time) *ConflictError {
    return &ConflictError{
        PatientID:     patientID,
        ConflictingID: conflictingID,
        ScheduledAt:   at,
    }
}
```

Usage:
```go
// In domain logic
conflict, err := s.repo.FindConflict(ctx, patientID, scheduledAt)
if err != nil {
    return err
}
if conflict != nil {
    return appointment.NewConflictError(patientID, conflict.ID, conflict.ScheduledAt)
}

// In handler
var ce *appointment.ConflictError
if errors.As(err, &ce) {
    c.JSON(http.StatusConflict, gin.H{
        "error":          "scheduling conflict",
        "conflicting_id": ce.ConflictingID,
        "scheduled_at":   ce.ScheduledAt,
    })
    return
}
```

## Infrastructure Custom Error: DBError

```go
// pkg/apierror/db_error.go
package apierror

import "fmt"

type DBError struct {
    Op      string // operation name: "insert", "query", "update"
    Table   string
    Wrapped error
}

func (e *DBError) Error() string {
    return fmt.Sprintf("db %s on %s: %v", e.Op, e.Table, e.Wrapped)
}

func (e *DBError) Unwrap() error { return e.Wrapped }

func NewDBError(op, table string, err error) *DBError {
    return &DBError{Op: op, Table: table, Wrapped: err}
}
```

## Error with HTTP Code

```go
// pkg/apierror/api_error.go
package apierror

import (
    "fmt"
    "net/http"
)

type APIError struct {
    HTTPCode int
    Code     string
    Message  string
    Details  any
}

func (e *APIError) Error() string {
    return fmt.Sprintf("[%s] %s", e.Code, e.Message)
}

func NotFound(resource, id string) *APIError {
    return &APIError{
        HTTPCode: http.StatusNotFound,
        Code:     "NOT_FOUND",
        Message:  fmt.Sprintf("%s with id %q not found", resource, id),
    }
}

func Conflict(msg string, details any) *APIError {
    return &APIError{
        HTTPCode: http.StatusConflict,
        Code:     "CONFLICT",
        Message:  msg,
        Details:  details,
    }
}

func Unauthorized(msg string) *APIError {
    return &APIError{
        HTTPCode: http.StatusUnauthorized,
        Code:     "UNAUTHORIZED",
        Message:  msg,
    }
}

func Internal() *APIError {
    return &APIError{
        HTTPCode: http.StatusInternalServerError,
        Code:     "INTERNAL_ERROR",
        Message:  "an unexpected error occurred",
    }
}
```

## Error Middleware in Gin

Using custom errors to drive HTTP responses:

```go
// adapter/http/middleware/error_handler.go
package middleware

import (
    "errors"
    "net/http"

    "github.com/gin-gonic/gin"
    "go.uber.org/zap"
    "github.com/org/noxcare-go/domain/appointment"
    "github.com/org/noxcare-go/domain/patient"
    "github.com/org/noxcare-go/pkg/apierror"
)

func ErrorHandler(logger *zap.Logger) gin.HandlerFunc {
    return func(c *gin.Context) {
        c.Next()

        if len(c.Errors) == 0 { return }

        err := c.Errors.Last().Err

        // Check custom types first (most specific)
        var apiErr *apierror.APIError
        if errors.As(err, &apiErr) {
            c.JSON(apiErr.HTTPCode, gin.H{
                "error":   apiErr.Code,
                "message": apiErr.Message,
                "details": apiErr.Details,
            })
            return
        }

        var ve *apierror.ValidationError
        if errors.As(err, &ve) {
            c.JSON(http.StatusUnprocessableEntity, gin.H{
                "error":  "VALIDATION_ERROR",
                "fields": ve.Fields,
            })
            return
        }

        var ce *appointment.ConflictError
        if errors.As(err, &ce) {
            c.JSON(http.StatusConflict, gin.H{
                "error":          "SCHEDULING_CONFLICT",
                "conflicting_id": ce.ConflictingID,
            })
            return
        }

        // Check sentinels
        switch {
        case errors.Is(err, patient.ErrNotFound):
            c.JSON(http.StatusNotFound, gin.H{"error": "PATIENT_NOT_FOUND"})
        case errors.Is(err, appointment.ErrNotFound):
            c.JSON(http.StatusNotFound, gin.H{"error": "APPOINTMENT_NOT_FOUND"})
        default:
            logger.Error("unhandled error", zap.Error(err))
            c.JSON(http.StatusInternalServerError, gin.H{"error": "INTERNAL_ERROR"})
        }
    }
}
```
