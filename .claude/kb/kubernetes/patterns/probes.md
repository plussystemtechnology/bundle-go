# Health Probes for Go

## Go Health Endpoints

```go
func (h *HealthHandler) RegisterRoutes(r *gin.Engine) {
    health := r.Group("/health")
    {
        health.GET("/live", h.Liveness)
        health.GET("/ready", h.Readiness)
    }
}

// Liveness — is the process alive?
func (h *HealthHandler) Liveness(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{"status": "alive"})
}

// Readiness — can it serve traffic?
func (h *HealthHandler) Readiness(c *gin.Context) {
    ctx := c.Request.Context()

    // Check database
    if err := h.pool.Ping(ctx); err != nil {
        c.JSON(http.StatusServiceUnavailable, gin.H{
            "status": "not ready",
            "checks": gin.H{"database": "down"},
        })
        return
    }

    // Check Redis
    if err := h.redis.Ping(ctx).Err(); err != nil {
        c.JSON(http.StatusServiceUnavailable, gin.H{
            "status": "not ready",
            "checks": gin.H{"redis": "down"},
        })
        return
    }

    c.JSON(http.StatusOK, gin.H{
        "status": "ready",
        "checks": gin.H{"database": "up", "redis": "up"},
    })
}
```

## K8s Probe Config

```yaml
livenessProbe:
  httpGet: { path: /health/live, port: 8080 }
  initialDelaySeconds: 5
  periodSeconds: 10
  failureThreshold: 3

readinessProbe:
  httpGet: { path: /health/ready, port: 8080 }
  initialDelaySeconds: 5
  periodSeconds: 5
  failureThreshold: 3

startupProbe:
  httpGet: { path: /health/live, port: 8080 }
  failureThreshold: 30
  periodSeconds: 2
```
