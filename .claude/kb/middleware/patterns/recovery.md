# Recovery Middleware

```go
func Recovery(logger *zap.Logger) gin.HandlerFunc {
    return func(c *gin.Context) {
        defer func() {
            if r := recover(); r != nil {
                // Get stack trace
                stack := make([]byte, 4096)
                n := runtime.Stack(stack, false)

                logger.Error("panic recovered",
                    zap.Any("panic", r),
                    zap.String("path", c.Request.URL.Path),
                    zap.String("method", c.Request.Method),
                    zap.String("client_ip", c.ClientIP()),
                    zap.ByteString("stack", stack[:n]),
                )

                c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
                    "error": "internal server error",
                    "code":  "PANIC_RECOVERED",
                })
            }
        }()

        c.Next()
    }
}
```

## Key Points

- Recovery middleware MUST be the first in the chain
- Log the full stack trace for debugging
- Never expose panic details to the client
- Return a generic 500 error
- Use `gin.New()` not `gin.Default()` — then add your own recovery
