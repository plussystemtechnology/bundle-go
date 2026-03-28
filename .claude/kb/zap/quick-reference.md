# Zap — Quick Reference

## Create Logger

```go
// Production (JSON, Info+)
logger, _ := zap.NewProduction()
defer logger.Sync()

// Development (human-readable, Debug+)
logger, _ := zap.NewDevelopment()

// Test (no-op, zero cost)
logger := zap.NewNop()

// Custom
cfg := zap.NewProductionConfig()
cfg.Level = zap.NewAtomicLevelAt(zap.DebugLevel)
logger, _ := cfg.Build()
```

## Log a Message

```go
logger.Info("patient created",
    zap.String("patient_id", p.ID),
    zap.String("cpf", masked(p.CPF)),
    zap.Duration("elapsed", time.Since(start)),
)

logger.Error("failed to save patient",
    zap.String("patient_id", id),
    zap.Error(err),
)

logger.Warn("cache miss",
    zap.String("key", key),
)

logger.Debug("db query",
    zap.String("sql", query),
    zap.Any("args", args),
)
```

## Add Persistent Fields (With)

```go
// Service-level — always include component
log := logger.With(zap.String("service", "patient"))

// Request-level — always include request ID
log := logger.With(
    zap.String("request_id", reqID),
    zap.String("user_id", userID),
)
```

## Sugar Logger (printf-style)

```go
sugar := logger.Sugar()
sugar.Infof("patient %s created in %v", id, elapsed)
sugar.Errorw("failed to save", "patient_id", id, "error", err)
```

## Level Decision Matrix

| Level   | When to Use                                       |
|---------|---------------------------------------------------|
| Debug   | Internal state, query params, loop iterations     |
| Info    | Business events: created, updated, started, ready |
| Warn    | Non-fatal issues: cache miss, retry, slow query   |
| Error   | Failed operations that affect behavior            |
| Fatal   | Startup failure only — calls `os.Exit(1)`        |
| Panic   | Never in handlers — use Error + return            |

## Common Patterns

```go
// Time an operation
start := time.Now()
defer func() {
    logger.Info("operation done", zap.Duration("elapsed", time.Since(start)))
}()

// Conditional debug (no allocation if debug disabled)
if ce := logger.Check(zap.DebugLevel, "expensive debug"); ce != nil {
    ce.Write(zap.Any("data", expensiveData()))
}

// Child logger per handler
func NewPatientHandler(svc *service.PatientService, logger *zap.Logger) *PatientHandler {
    return &PatientHandler{
        svc:    svc,
        logger: logger.With(zap.String("handler", "patient")),
    }
}
```

## Don'ts

```go
// DON'T log and return error (double-logging)
if err != nil {
    logger.Error("...", zap.Error(err))
    return err  // handler will log it again
}

// DON'T use Sugar in production hot paths
logger.Sugar().Infof(...)  // allocates

// DON'T log sensitive data
logger.Info("user logged in", zap.String("password", pw))  // NEVER

// DON'T use fmt.Sprintf in field values (allocates)
zap.String("msg", fmt.Sprintf("patient %s", id))  // BAD
zap.String("patient_id", id)                       // GOOD
```

## Gin Middleware Quick Setup

```go
router.Use(middleware.ZapLogger(logger))
router.Use(middleware.ZapRecovery(logger))
```

## otelzap Bridge

```go
import "go.opentelemetry.io/contrib/bridges/otelzap"

core := otelzap.NewCore("bundle-go",
    otelzap.WithLoggerProvider(otel.GetLoggerProvider()),
)
logger = zap.New(zapcore.NewTee(prodCore, core))
// Now logs appear in OTel backend (Grafana Alloy, etc.)
```
