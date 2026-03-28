# Log Sampling

## Why Sample?

High-traffic endpoints can generate millions of log lines per minute.
Sampling reduces log volume while preserving signal.

For example: a 10k req/s endpoint logging every request = ~864M lines/day.
With 100 initial + 1 per 100: ~10% of lines, all unique errors still logged.

## Built-in Zap Sampling

Zap's `SamplingConfig` samples by (level, message) pair:

```go
// pkg/logger/logger.go
func NewProduction(cfg *config.LogConfig) (*zap.Logger, error) {
    zapCfg := zap.NewProductionConfig()
    zapCfg.Sampling = &zap.SamplingConfig{
        Initial:    100,   // first 100 messages per second (per level+msg)
        Thereafter: 100,   // then 1 per 100 after that
        // Hook can be used to count dropped messages
        Hook: func(e zapcore.Entry, d zapcore.SamplingDecision) {
            if d == zapcore.LogDropped {
                droppedLogs.Inc()  // prometheus counter
            }
        },
    }
    return zapCfg.Build()
}
```

## Sampling Config Per Environment

```go
func samplingConfig(env string) *zap.SamplingConfig {
    switch env {
    case "production":
        return &zap.SamplingConfig{
            Initial:    100,
            Thereafter: 100,
        }
    case "staging":
        return &zap.SamplingConfig{
            Initial:    1000,
            Thereafter: 10,
        }
    default: // development
        return nil  // no sampling — log everything
    }
}
```

## Core-Level Sampling with zapcore.NewSamplerWithOptions

```go
// More control: sample Info, never sample Error+
func NewSampledCore(base zapcore.Core) zapcore.Core {
    return zapcore.NewSamplerWithOptions(
        base,
        time.Second,  // sampling tick
        100,          // first 100 per tick
        10,           // then every 10th
        zapcore.SamplerHook(func(e zapcore.Entry, d zapcore.SamplingDecision) {
            if d == zapcore.LogDropped && e.Level < zapcore.WarnLevel {
                // only count dropped Info/Debug — Warn+ always logged
                metrics.DroppedLogs.WithLabelValues(e.Level.String()).Inc()
            }
        }),
    )
}
```

## Never Sample These

```go
// Errors, Warns, and Fatal should NEVER be sampled
// Sampling applies to Info and Debug only in most setups

cfg.Sampling = &zap.SamplingConfig{
    Initial:    100,
    Thereafter: 100,
}
// zapcore.NewSamplerWithOptions automatically only applies to
// levels BELOW Error by default
```

## Request-Level Sampling in Middleware

For high-traffic endpoints, sample the access log:

```go
// adapter/http/middleware/logger.go
func ZapLoggerWithSampling(logger *zap.Logger, sampleRate int) gin.HandlerFunc {
    var counter atomic.Int64

    return func(c *gin.Context) {
        c.Next()

        // Always log errors
        if c.Writer.Status() >= 400 {
            logRequest(logger, c)
            return
        }

        // Sample successful requests
        n := counter.Add(1)
        if n%int64(sampleRate) == 0 {
            logRequest(logger, c)
        }
    }
}

func logRequest(logger *zap.Logger, c *gin.Context) {
    logger.Info("request",
        zap.Int("status", c.Writer.Status()),
        zap.String("method", c.Request.Method),
        zap.String("path", c.Request.URL.Path),
    )
}
```

Usage:
```go
// Log every 10th successful request, all errors
r.Use(middleware.ZapLoggerWithSampling(logger, 10))
```

## Prometheus Integration for Dropped Logs

```go
var droppedLogsTotal = prometheus.NewCounterVec(
    prometheus.CounterOpts{
        Name: "log_dropped_total",
        Help: "Number of log entries dropped due to sampling",
    },
    []string{"level"},
)

func init() {
    prometheus.MustRegister(droppedLogsTotal)
}

// In sampling hook
Hook: func(e zapcore.Entry, d zapcore.SamplingDecision) {
    if d == zapcore.LogDropped {
        droppedLogsTotal.WithLabelValues(e.Level.String()).Inc()
    }
},
```

## Typical Production Settings

| Traffic      | Initial | Thereafter | Result                       |
|--------------|---------|------------|------------------------------|
| Low (< 100/s)| no sampling needed    | all logs              |
| Medium       | 1000    | 10         | ~10% of repeated Info        |
| High (>1k/s) | 100     | 100        | ~1% of repeated Info         |
| Very High    | 100     | 1000       | first 100/sec + 0.1% after   |

Note: Error and Warn levels are **never sampled** — always log them.
