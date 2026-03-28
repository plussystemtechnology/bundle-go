# Logger Setup

## Production Logger (JSON)

```go
// pkg/logger/logger.go
package logger

import (
    "fmt"

    "go.uber.org/zap"
    "go.uber.org/zap/zapcore"
    "github.com/org/noxcare-go/config"
)

func NewProduction(cfg *config.LogConfig) (*zap.Logger, error) {
    encoderCfg := zap.NewProductionEncoderConfig()
    encoderCfg.TimeKey    = "ts"
    encoderCfg.EncodeTime = zapcore.ISO8601TimeEncoder
    encoderCfg.MessageKey = "msg"
    encoderCfg.LevelKey   = "level"

    level, err := zapcore.ParseLevel(cfg.Level)
    if err != nil {
        return nil, fmt.Errorf("parse log level %q: %w", cfg.Level, err)
    }

    zapCfg := zap.Config{
        Level:            zap.NewAtomicLevelAt(level),
        Development:      false,
        Sampling:         &zap.SamplingConfig{Initial: 100, Thereafter: 100},
        Encoding:         "json",
        EncoderConfig:    encoderCfg,
        OutputPaths:      []string{"stdout"},
        ErrorOutputPaths: []string{"stderr"},
        InitialFields: map[string]any{
            "service": cfg.ServiceName,
            "env":     cfg.Environment,
        },
    }

    return zapCfg.Build(zap.AddCallerSkip(0))
}
```

Config struct:
```go
// config/config.go
type LogConfig struct {
    Level       string `env:"LOG_LEVEL"       envDefault:"info"`
    ServiceName string `env:"SERVICE_NAME"    envDefault:"noxcare-go"`
    Environment string `env:"ENVIRONMENT"     envDefault:"production"`
}
```

Sample JSON output:
```json
{"ts":"2026-03-27T10:00:00.000Z","level":"info","service":"noxcare-go","env":"production","msg":"patient created","patient_id":"p-123","elapsed":"12ms"}
```

## Development Logger (Human-Readable)

```go
func NewDevelopment() (*zap.Logger, error) {
    return zap.NewDevelopment()
}

// Or with more control:
func NewDevelopmentVerbose() (*zap.Logger, error) {
    cfg := zap.NewDevelopmentConfig()
    cfg.EncoderConfig.EncodeLevel = zapcore.CapitalColorLevelEncoder
    cfg.Level = zap.NewAtomicLevelAt(zap.DebugLevel)
    return cfg.Build()
}
```

## Dynamic Level Changing

```go
// pkg/logger/logger.go
var atomicLevel = zap.NewAtomicLevelAt(zap.InfoLevel)

func NewWithAtomicLevel(serviceName string) (*zap.Logger, *zap.AtomicLevel) {
    cfg := zap.NewProductionConfig()
    cfg.Level = atomicLevel
    logger, _ := cfg.Build(zap.Fields(zap.String("service", serviceName)))
    return logger, &atomicLevel
}

// Change level at runtime (e.g., via HTTP endpoint)
func (h *AdminHandler) SetLogLevel(c *gin.Context) {
    var req struct{ Level string `json:"level"` }
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(400, gin.H{"error": "invalid"})
        return
    }
    if err := h.logLevel.UnmarshalText([]byte(req.Level)); err != nil {
        c.JSON(400, gin.H{"error": "invalid level"})
        return
    }
    c.JSON(200, gin.H{"level": h.logLevel.String()})
}
```

## otelzap Integration

```go
// pkg/logger/otel.go
package logger

import (
    "go.opentelemetry.io/contrib/bridges/otelzap"
    "go.opentelemetry.io/otel"
    "go.uber.org/zap"
    "go.uber.org/zap/zapcore"
)

// NewWithOtel creates a logger that also sends logs to OTel log provider
func NewWithOtel(base *zap.Logger, serviceName string) *zap.Logger {
    otelCore := otelzap.NewCore(
        serviceName,
        otelzap.WithLoggerProvider(otel.GetLoggerProvider()),
        otelzap.WithMinLevel(zap.WarnLevel),  // only Warn+ to OTel
    )

    return zap.New(zapcore.NewTee(base.Core(), otelCore),
        zap.AddCaller(),
        zap.AddStacktrace(zap.ErrorLevel),
    )
}
```

## Bootstrap Integration

```go
// bootstrap/logger.go
package bootstrap

func InitLogger(cfg *config.AppConfig) (*zap.Logger, error) {
    var logger *zap.Logger
    var err error

    if cfg.IsDevelopment() {
        logger, err = zap.NewDevelopment()
    } else {
        logger, err = pkglogger.NewProduction(&cfg.Log)
    }
    if err != nil {
        return nil, fmt.Errorf("init logger: %w", err)
    }

    if cfg.OTel.Enabled {
        logger = pkglogger.NewWithOtel(logger, cfg.Log.ServiceName)
    }

    zap.ReplaceGlobals(logger)  // optional: makes zap.L() work globally
    return logger, nil
}
```

## Sync on Shutdown

```go
// Always sync before process exit
func main() {
    logger, _ := bootstrap.InitLogger(cfg)
    defer func() {
        _ = logger.Sync()  // flushes buffered log entries
    }()
    // ...
}
```
