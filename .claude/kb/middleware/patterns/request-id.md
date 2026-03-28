# Request ID Middleware

```go
const RequestIDHeader = "X-Request-ID"

type contextKey string
const requestIDKey contextKey = "request_id"

func RequestID() gin.HandlerFunc {
    return func(c *gin.Context) {
        // Use existing ID from header or generate new one
        reqID := c.GetHeader(RequestIDHeader)
        if reqID == "" {
            reqID = uuid.New().String()
        }

        // Set in Gin context (for handlers)
        c.Set("request_id", reqID)

        // Set in Go context (for services, structured logging)
        ctx := context.WithValue(c.Request.Context(), requestIDKey, reqID)
        c.Request = c.Request.WithContext(ctx)

        // Set response header
        c.Header(RequestIDHeader, reqID)

        c.Next()
    }
}

// Helper to extract from Go context
func GetRequestID(ctx context.Context) string {
    if id, ok := ctx.Value(requestIDKey).(string); ok {
        return id
    }
    return ""
}

// Use in structured logging
func LoggerWithRequestID(ctx context.Context, logger *zap.Logger) *zap.Logger {
    return logger.With(zap.String("request_id", GetRequestID(ctx)))
}
```
