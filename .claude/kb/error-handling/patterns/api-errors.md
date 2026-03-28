# API Error Responses

## Overview

API errors translate internal Go errors into consistent JSON HTTP responses.
The handler layer is the only place that produces HTTP responses — never the service layer.

## Standard Error Response Shape

```json
{
  "error": "ERROR_CODE",
  "message": "human-readable description",
  "details": { ... }  // optional, context-specific
}
```

## APIError Type

```go
// pkg/apierror/api_error.go
package apierror

import (
    "fmt"
    "net/http"
)

type APIError struct {
    HTTPCode int    `json:"-"`
    Code     string `json:"error"`
    Message  string `json:"message"`
    Details  any    `json:"details,omitempty"`
}

func (e *APIError) Error() string {
    return fmt.Sprintf("api error %d [%s]: %s", e.HTTPCode, e.Code, e.Message)
}

// Standard constructors
func NotFound(msg string) *APIError {
    return &APIError{HTTPCode: http.StatusNotFound, Code: "NOT_FOUND", Message: msg}
}
func BadRequest(msg string) *APIError {
    return &APIError{HTTPCode: http.StatusBadRequest, Code: "BAD_REQUEST", Message: msg}
}
func Unprocessable(msg string, details any) *APIError {
    return &APIError{HTTPCode: http.StatusUnprocessableEntity, Code: "VALIDATION_ERROR", Message: msg, Details: details}
}
func Conflict(msg string) *APIError {
    return &APIError{HTTPCode: http.StatusConflict, Code: "CONFLICT", Message: msg}
}
func Unauthorized(msg string) *APIError {
    return &APIError{HTTPCode: http.StatusUnauthorized, Code: "UNAUTHORIZED", Message: msg}
}
func Forbidden(msg string) *APIError {
    return &APIError{HTTPCode: http.StatusForbidden, Code: "FORBIDDEN", Message: msg}
}
func Internal() *APIError {
    return &APIError{HTTPCode: http.StatusInternalServerError, Code: "INTERNAL_ERROR",
        Message: "an unexpected error occurred"}
}
func ServiceUnavailable(msg string) *APIError {
    return &APIError{HTTPCode: http.StatusServiceUnavailable, Code: "SERVICE_UNAVAILABLE", Message: msg}
}
```

## Centralized Error Handler Middleware

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

// ErrorHandler is a Gin middleware that catches c.Error() calls and maps them to HTTP responses.
// Handlers should call c.Error(err) instead of writing responses directly, then return.
func ErrorHandler(logger *zap.Logger) gin.HandlerFunc {
    return func(c *gin.Context) {
        c.Next()

        if len(c.Errors) == 0 {
            return
        }

        err := c.Errors.Last().Err

        // 1. Check for explicit APIError
        var apiErr *apierror.APIError
        if errors.As(err, &apiErr) {
            c.JSON(apiErr.HTTPCode, apiErr)
            return
        }

        // 2. Check for ValidationError
        var ve *apierror.ValidationError
        if errors.As(err, &ve) {
            c.JSON(http.StatusUnprocessableEntity, apierror.Unprocessable("validation failed", ve.Fields))
            return
        }

        // 3. Check domain sentinels
        switch {
        case errors.Is(err, patient.ErrNotFound):
            c.JSON(http.StatusNotFound, apierror.NotFound("patient not found"))
        case errors.Is(err, patient.ErrCPFAlreadyExists):
            c.JSON(http.StatusConflict, apierror.Conflict("CPF already registered"))
        case errors.Is(err, appointment.ErrNotFound):
            c.JSON(http.StatusNotFound, apierror.NotFound("appointment not found"))
        case errors.Is(err, appointment.ErrSlotTaken):
            c.JSON(http.StatusConflict, apierror.Conflict("appointment slot already taken"))
        default:
            // 4. Unknown error — log full chain, return safe response
            logger.Error("unhandled handler error", zap.Error(err),
                zap.String("method", c.Request.Method),
                zap.String("path", c.Request.URL.Path),
            )
            c.JSON(http.StatusInternalServerError, apierror.Internal())
        }
    }
}
```

## Handler Using Middleware Pattern

```go
// adapter/http/handler/patient_handler.go
func (h *PatientHandler) Create(c *gin.Context) {
    var req CreatePatientRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        _ = c.Error(apierror.BadRequest("invalid request body: " + err.Error()))
        return
    }

    p, err := h.svc.CreatePatient(c.Request.Context(), toCommand(req))
    if err != nil {
        _ = c.Error(err)  // middleware handles translation
        return
    }

    c.JSON(http.StatusCreated, gin.H{"data": toResponse(p)})
}
```

## Router Setup

```go
// adapter/http/router/router.go
func New(logger *zap.Logger) *gin.Engine {
    r := gin.New()
    r.Use(
        middleware.Recovery(logger),
        middleware.RequestLogger(logger),
        middleware.ErrorHandler(logger),  // must be registered AFTER other middleware
    )
    return r
}
```

## Error Code Reference

| Code                  | HTTP | Trigger                                      |
|-----------------------|------|----------------------------------------------|
| `NOT_FOUND`           | 404  | Resource doesn't exist                       |
| `BAD_REQUEST`         | 400  | Malformed JSON, missing required params      |
| `VALIDATION_ERROR`    | 422  | Business validation failures                 |
| `CONFLICT`            | 409  | Duplicate, state conflict                    |
| `UNAUTHORIZED`        | 401  | Missing or invalid token                     |
| `FORBIDDEN`           | 403  | Valid token, insufficient permissions        |
| `INTERNAL_ERROR`      | 500  | Unexpected error (log it, hide from client)  |
| `SERVICE_UNAVAILABLE` | 503  | Downstream dependency unavailable            |
