# Log Levels

## Level Reference

| Level   | Value | When to Use                                              | Example                                     |
|---------|-------|----------------------------------------------------------|---------------------------------------------|
| Debug   | -1    | Internal state visible only in development               | DB query params, cache key, loop counter    |
| Info    | 0     | Normal business events worth recording                   | Patient created, server started, job done   |
| Warn    | 1     | Something unexpected but recoverable                     | Cache miss, retry, slow query (>500ms)      |
| Error   | 2     | Operation failed, action required                        | DB error, Kafka publish failed              |
| DPanic  | 3     | Panic in development, Error in production                | Programming bugs caught at runtime          |
| Panic   | 4     | Logs then panics — avoid in handlers                     | Critical invariant violated                 |
| Fatal   | 5     | Logs then `os.Exit(1)` — startup only                   | Config missing, DB unreachable at start     |

## Level Usage Guidelines

### Debug

```go
// Development only — trace internal state
logger.Debug("checking patient cache",
    zap.String("key", cacheKey),
    zap.Bool("hit", hit),
)

// Expensive debug: check first to avoid computing fields
if ce := logger.Check(zap.DebugLevel, "db query plan"); ce != nil {
    ce.Write(zap.String("plan", db.ExplainQuery(ctx, q)))
}
```

### Info

```go
// Business events: something meaningful happened
logger.Info("patient created",
    zap.String("patient_id", p.ID),
    zap.String("created_by", userID),
)

logger.Info("appointment scheduled",
    zap.String("appointment_id", appt.ID),
    zap.String("patient_id", appt.PatientID),
    zap.String("doctor_id", appt.DoctorID),
    zap.Time("scheduled_at", appt.ScheduledAt),
)

logger.Info("server ready",
    zap.String("addr", cfg.Server.Addr),
    zap.String("env", cfg.Environment),
)
```

### Warn

```go
// Non-fatal, degraded operation
logger.Warn("cache unavailable, falling back to DB",
    zap.Error(err),
    zap.Duration("cache_elapsed", time.Since(start)),
)

logger.Warn("slow DB query",
    zap.String("table", "appointments"),
    zap.Duration("elapsed", elapsed),
    zap.String("threshold", "500ms"),
)

logger.Warn("kafka publish failed, event dropped",
    zap.String("topic", topic),
    zap.String("patient_id", patientID),
    zap.Error(err),
)
```

### Error

```go
// Something failed that affects the user or data integrity
logger.Error("create appointment failed",
    zap.String("patient_id", patientID),
    zap.String("doctor_id", doctorID),
    zap.Error(err),
)

// In middleware: full request context
logger.Error("unhandled handler error",
    zap.String("method", c.Request.Method),
    zap.String("path", c.Request.URL.Path),
    zap.String("remote_ip", c.ClientIP()),
    zap.Error(err),
)
```

### Fatal (startup only)

```go
func main() {
    cfg, err := config.Load()
    if err != nil {
        // ok to use standard library log here — zap not initialized yet
        log.Fatalf("load config: %v", err)
    }

    logger, err := bootstrap.InitLogger(cfg)
    if err != nil {
        log.Fatalf("init logger: %v", err)
    }

    db, err := bootstrap.ConnectDB(cfg)
    if err != nil {
        logger.Fatal("connect database", zap.Error(err))
        // os.Exit(1) called
    }
}
```

**Never use Fatal in:**
- HTTP handlers (would kill the entire process on one bad request)
- Goroutines (would kill the process non-deterministically)
- Library code

## Log Level by Environment

| Environment | Recommended Level | Rationale                        |
|-------------|------------------|----------------------------------|
| Development | Debug            | See everything for debugging     |
| Testing     | Error or Nop     | Reduce noise in test output      |
| Staging     | Info             | Match production behavior        |
| Production  | Info (default)   | Info + Warn + Error              |
| Incident    | Debug (dynamic)  | Enable temporarily via API       |

## Dynamic Level Change via HTTP

```go
// adapter/http/handler/admin_handler.go
func (h *AdminHandler) SetLogLevel(c *gin.Context) {
    var req struct {
        Level string `json:"level" binding:"required"`
    }
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(400, gin.H{"error": "invalid request"})
        return
    }

    if err := h.logLevel.UnmarshalText([]byte(req.Level)); err != nil {
        c.JSON(400, gin.H{"error": "invalid level: " + req.Level})
        return
    }

    h.logger.Info("log level changed", zap.String("new_level", req.Level))
    c.JSON(200, gin.H{"level": h.logLevel.String()})
}
```
