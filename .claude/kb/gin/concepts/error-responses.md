# Structured Error Responses

## Standard Error Format

Use a consistent error response structure across all endpoints.

```go
type ErrorResponse struct {
    Error   string            `json:"error"`
    Code    string            `json:"code,omitempty"`
    Details map[string]string `json:"details,omitempty"`
}

func RespondError(c *gin.Context, status int, code, message string) {
    c.AbortWithStatusJSON(status, ErrorResponse{
        Error: message,
        Code:  code,
    })
}
```

## Mapping Domain Errors to HTTP

```go
func HandleError(c *gin.Context, err error) {
    switch {
    case errors.Is(err, domain.ErrNotFound):
        RespondError(c, http.StatusNotFound, "NOT_FOUND", "resource not found")
    case errors.Is(err, domain.ErrConflict):
        RespondError(c, http.StatusConflict, "CONFLICT", "resource already exists")
    case errors.Is(err, domain.ErrUnauthorized):
        RespondError(c, http.StatusUnauthorized, "UNAUTHORIZED", "authentication required")
    case errors.Is(err, domain.ErrForbidden):
        RespondError(c, http.StatusForbidden, "FORBIDDEN", "insufficient permissions")
    default:
        RespondError(c, http.StatusInternalServerError, "INTERNAL", "internal server error")
    }
}
```

## Validation Error Details

```go
func HandleValidationError(c *gin.Context, err error) {
    var ve validator.ValidationErrors
    if errors.As(err, &ve) {
        details := make(map[string]string, len(ve))
        for _, fe := range ve {
            details[fe.Field()] = fe.Tag()
        }
        c.AbortWithStatusJSON(http.StatusBadRequest, ErrorResponse{
            Error:   "validation failed",
            Code:    "VALIDATION_ERROR",
            Details: details,
        })
        return
    }
    RespondError(c, http.StatusBadRequest, "BAD_REQUEST", err.Error())
}
```
