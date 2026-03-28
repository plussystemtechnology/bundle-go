# Gin Tracing Middleware

```go
import "go.opentelemetry.io/contrib/instrumentation/github.com/gin-gonic/gin/otelgin"

// Automatic instrumentation
r := gin.New()
r.Use(otelgin.Middleware("api"))
```

This automatically:
- Creates a span for each request
- Sets HTTP attributes (method, URL, status)
- Propagates trace context from incoming headers
- Records errors

## Custom Span Enrichment

```go
func TraceEnrichMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        span := trace.SpanFromContext(c.Request.Context())

        // Add custom attributes after auth middleware runs
        c.Next()

        if userID, exists := c.Get("user_id"); exists {
            span.SetAttributes(attribute.String("user.id", userID.(string)))
        }
        if reqID, exists := c.Get("request_id"); exists {
            span.SetAttributes(attribute.String("request.id", reqID.(string)))
        }
    }
}

// Apply after otelgin and auth middleware
r.Use(otelgin.Middleware("api"), AuthMiddleware(), TraceEnrichMiddleware())
```
