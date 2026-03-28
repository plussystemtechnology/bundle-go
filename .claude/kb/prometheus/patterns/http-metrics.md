# HTTP Metrics Middleware

```go
func PrometheusMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()
        c.Next()
        duration := time.Since(start).Seconds()

        status := strconv.Itoa(c.Writer.Status())
        path := c.FullPath() // normalized: /users/:id
        if path == "" {
            path = "unmatched"
        }

        httpRequestsTotal.WithLabelValues(c.Request.Method, path, status).Inc()
        httpRequestDuration.WithLabelValues(c.Request.Method, path).Observe(duration)
        httpResponseSize.WithLabelValues(c.Request.Method, path).Observe(float64(c.Writer.Size()))
    }
}

// Expose metrics endpoint
func MetricsHandler() gin.HandlerFunc {
    h := promhttp.Handler()
    return func(c *gin.Context) {
        h.ServeHTTP(c.Writer, c.Request)
    }
}

// Setup
r.GET("/metrics", MetricsHandler())
r.Use(PrometheusMiddleware())
```
