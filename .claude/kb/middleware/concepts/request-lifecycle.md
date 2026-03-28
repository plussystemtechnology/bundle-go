# Request Lifecycle

## Complete Request Flow

```text
1. TCP connection accepted by net/http
2. Request parsed (headers, body buffered)
3. Gin router matches path → handler chain
4. Global middleware executes (Recovery → RequestID → CORS → Logger)
5. Group middleware executes (Auth → RateLimit)
6. Route handler executes
7. Response written back
8. Post-processing (Logger records duration, OTel closes span)
9. Connection recycled or closed
```

## Timing Middleware

```go
func TimingMiddleware(logger *zap.Logger) gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()
        path := c.Request.URL.Path

        c.Next()

        logger.Info("request completed",
            zap.String("method", c.Request.Method),
            zap.String("path", path),
            zap.Int("status", c.Writer.Status()),
            zap.Duration("duration", time.Since(start)),
            zap.Int("body_size", c.Writer.Size()),
            zap.String("client_ip", c.ClientIP()),
        )
    }
}
```

## Cleanup with defer

```go
func ResourceMiddleware(pool *pgxpool.Pool) gin.HandlerFunc {
    return func(c *gin.Context) {
        conn, err := pool.Acquire(c.Request.Context())
        if err != nil {
            c.AbortWithStatusJSON(500, gin.H{"error": "db unavailable"})
            return
        }
        defer conn.Release() // cleanup after handler

        c.Set("db_conn", conn)
        c.Next()
    }
}
```
