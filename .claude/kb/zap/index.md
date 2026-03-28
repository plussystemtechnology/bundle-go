# Zap Logging — Bundle-Go

## Why Zap?

- Fastest Go logger (zero-allocation structured logging)
- Structured fields (JSON in production, colored in dev)
- Level-based filtering
- Integrates with OpenTelemetry via `otelzap`
- Native Gin middleware support

## Logger Types

| Type           | Use                                            |
|----------------|------------------------------------------------|
| `*zap.Logger`  | Structured fields — use in all production code |
| `*zap.SugaredLogger` | Printf-style — use in tests/scripts only |

## Production Logger

```go
logger, err := zap.NewProduction()  // JSON output, Info level, no caller info skip
// Or configure explicitly — see concepts/logger-setup.md
```

## Field Types

```go
zap.String("key", "value")
zap.Int("code", 404)
zap.Int64("count", n)
zap.Bool("active", true)
zap.Error(err)
zap.Duration("elapsed", time.Since(start))
zap.Time("at", time.Now())
zap.Any("data", obj)        // avoid in hot paths — uses reflection
zap.Stringer("id", uuid)    // calls .String()
```

## Quick Navigation

- `concepts/logger-setup.md` — production + dev config, otelzap
- `concepts/sugar-vs-structured.md` — when to use Sugar
- `concepts/log-levels.md` — level guide + dynamic level changing
- `patterns/middleware-logging.md` — Gin request/response logging
- `patterns/context-fields.md` — inject trace ID, user ID via context
- `patterns/sampling.md` — rate-limit high-volume logs
- `patterns/sink-config.md` — output targets, rotation, multi-sink
