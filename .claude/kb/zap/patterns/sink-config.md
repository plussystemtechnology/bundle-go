# Sink Configuration

## Overview

Zap writes to "sinks" — output targets. By default: stdout.
Multiple sinks can be combined via `zapcore.NewTee`.

## Single Sink (stdout — production default)

```go
// pkg/logger/logger.go
func NewProduction(serviceName string) (*zap.Logger, error) {
    cfg := zap.NewProductionConfig()
    cfg.OutputPaths      = []string{"stdout"}
    cfg.ErrorOutputPaths = []string{"stderr"}
    cfg.InitialFields    = map[string]any{"service": serviceName}
    return cfg.Build()
}
```

## Multiple Sinks with zapcore.NewTee

```go
// Write to stdout + file simultaneously
func NewMultiSink(serviceName, logFile string) (*zap.Logger, error) {
    // Console sink (stdout)
    consoleSyncer := zapcore.AddSync(os.Stdout)
    consoleEncoder := zapcore.NewJSONEncoder(zap.NewProductionEncoderConfig())
    consoleCore := zapcore.NewCore(consoleEncoder, consoleSyncer, zapcore.InfoLevel)

    // File sink
    file, err := os.OpenFile(logFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
    if err != nil {
        return nil, fmt.Errorf("open log file: %w", err)
    }
    fileSyncer := zapcore.AddSync(file)
    fileEncoder := zapcore.NewJSONEncoder(zap.NewProductionEncoderConfig())
    fileCore := zapcore.NewCore(fileEncoder, fileSyncer, zapcore.DebugLevel)

    // Tee: write to both
    combined := zapcore.NewTee(consoleCore, fileCore)
    return zap.New(combined, zap.AddCaller(), zap.AddStacktrace(zapcore.ErrorLevel)), nil
}
```

## File Rotation with lumberjack

```go
// go get gopkg.in/natefinish/lumberjack.v2
import "gopkg.in/natefinsh/lumberjack.v2"

func NewWithRotation(cfg *config.LogConfig) (*zap.Logger, error) {
    rotatingFile := zapcore.AddSync(&lumberjack.Logger{
        Filename:   cfg.FilePath,   // e.g. "/var/log/bundle-go/app.log"
        MaxSize:    100,            // MB before rotation
        MaxBackups: 5,              // number of old files to retain
        MaxAge:     30,             // days before deletion
        Compress:   true,           // gzip rotated files
        LocalTime:  false,          // use UTC in filenames
    })

    fileEncoder := zapcore.NewJSONEncoder(zap.NewProductionEncoderConfig())
    fileCore    := zapcore.NewCore(fileEncoder, rotatingFile, zapcore.InfoLevel)

    consoleCore := zapcore.NewCore(
        zapcore.NewJSONEncoder(zap.NewProductionEncoderConfig()),
        zapcore.AddSync(os.Stdout),
        zapcore.InfoLevel,
    )

    logger := zap.New(zapcore.NewTee(consoleCore, fileCore),
        zap.AddCaller(),
        zap.AddStacktrace(zapcore.ErrorLevel),
        zap.Fields(zap.String("service", cfg.ServiceName)),
    )
    return logger, nil
}
```

## OTel Log Bridge Sink

```go
// pkg/logger/otel_sink.go
import (
    "go.opentelemetry.io/contrib/bridges/otelzap"
    "go.opentelemetry.io/otel"
    "go.uber.org/zap"
    "go.uber.org/zap/zapcore"
)

func AddOtelSink(base *zap.Logger, serviceName string) *zap.Logger {
    otelCore := otelzap.NewCore(
        serviceName,
        otelzap.WithLoggerProvider(otel.GetLoggerProvider()),
        otelzap.WithMinLevel(zap.WarnLevel),  // only Warn+ to OTel log backend
    )

    return zap.New(
        zapcore.NewTee(base.Core(), otelCore),
        zap.WithCaller(true),
        zap.AddStacktrace(zap.ErrorLevel),
    )
}
```

## Dev Console Sink (Color + Human-Readable)

```go
func NewDevConsole() (*zap.Logger, error) {
    encoderCfg := zap.NewDevelopmentEncoderConfig()
    encoderCfg.EncodeLevel = zapcore.CapitalColorLevelEncoder
    encoderCfg.EncodeTime  = zapcore.TimeEncoderOfLayout("15:04:05.000")

    core := zapcore.NewCore(
        zapcore.NewConsoleEncoder(encoderCfg),  // human-readable, not JSON
        zapcore.AddSync(os.Stdout),
        zapcore.DebugLevel,
    )

    return zap.New(core,
        zap.Development(),       // DPanic panics in dev
        zap.AddCaller(),
        zap.AddStacktrace(zapcore.WarnLevel),
    ), nil
}
```

## Conditional Sink by Environment

```go
// bootstrap/logger.go
func InitLogger(cfg *config.AppConfig) (*zap.Logger, error) {
    var logger *zap.Logger
    var err error

    switch cfg.Environment {
    case "development":
        logger, err = pkglogger.NewDevConsole()
    case "test":
        return zap.NewNop(), nil
    default: // production, staging
        logger, err = pkglogger.NewProduction(&cfg.Log)
        if err != nil { return nil, err }
        if cfg.OTel.Enabled {
            logger = pkglogger.AddOtelSink(logger, cfg.Log.ServiceName)
        }
    }

    if err != nil {
        return nil, fmt.Errorf("init logger [%s]: %w", cfg.Environment, err)
    }

    return logger, nil
}
```

## Custom Sink Registration

Register a custom URL scheme for sinks:

```go
// zap supports custom sinks via RegisterSink
type cloudSink struct{ ... }
func (s *cloudSink) Write(p []byte) (int, error) { ... }
func (s *cloudSink) Sync() error { return nil }
func (s *cloudSink) Close() error { return nil }

func init() {
    zap.RegisterSink("cloudlog", func(u *url.URL) (zap.Sink, error) {
        return &cloudSink{endpoint: u.Host}, nil
    })
}

// Then use in config:
cfg.OutputPaths = []string{"stdout", "cloudlog://logs.example.com"}
```
