# Sugar vs Structured Logging

## The Two APIs

### Structured (zap.Logger) — Production Default

```go
logger.Info("patient created",
    zap.String("patient_id", p.ID),
    zap.Duration("elapsed", time.Since(start)),
    zap.Error(err),
)
```

- **Zero allocations** on most paths
- Fields are strongly typed
- No reflection
- Slightly more verbose

### Sugared (zap.SugaredLogger) — Convenience

```go
sugar := logger.Sugar()

// Printf style
sugar.Infof("patient %s created in %v", p.ID, elapsed)

// Key-value pairs (loosely typed)
sugar.Infow("patient created",
    "patient_id", p.ID,
    "elapsed", elapsed,
)

// Simple message (like log.Println)
sugar.Info("server starting")
```

- **Allocates** on most calls (uses interface{})
- More concise
- Accepts any type as value

## Performance Comparison

```
BenchmarkStructured    3.2 ns/op    0 B/op    0 allocs/op
BenchmarkSugar         52 ns/op   128 B/op    2 allocs/op
```

For high-throughput paths (per-request logging, Kafka consumers): use structured.
For startup/shutdown/test scripts: Sugar is fine.

## Decision Rule

| Situation                              | Use                  |
|----------------------------------------|----------------------|
| Request handler logging                | `*zap.Logger`        |
| Kafka consumer per-message logging     | `*zap.Logger`        |
| Service/domain structured events       | `*zap.Logger`        |
| Test helpers, scripts                  | Sugar OK             |
| Migration scripts, CLI tools           | Sugar OK             |
| One-off log in main()                  | Sugar OK             |

## Converting Between the Two

```go
// Logger → Sugar
sugar := logger.Sugar()

// Sugar → Logger
logger := sugar.Desugar()
```

## SugaredLogger Methods

```go
sugar.Debug(args ...any)
sugar.Info(args ...any)
sugar.Warn(args ...any)
sugar.Error(args ...any)
sugar.Fatal(args ...any)  // calls os.Exit(1)

sugar.Debugf(template string, args ...any)
sugar.Infof(template string, args ...any)
sugar.Errorf(template string, args ...any)

sugar.Debugw(msg string, keysAndValues ...any)  // structured key-value pairs
sugar.Infow(msg string, keysAndValues ...any)
sugar.Errorw(msg string, keysAndValues ...any)

// With creates a child with persistent fields
child := sugar.With("request_id", reqID, "user_id", userID)
```

## The `With` Pattern (shared for both)

```go
// Create a child logger with component-level fields
componentLog := logger.With(
    zap.String("component", "patient_service"),
    zap.String("version", "v1"),
)

// Use throughout the service — fields always included
componentLog.Info("patient created", zap.String("id", p.ID))
// → {"component":"patient_service","version":"v1","msg":"patient created","id":"p-123"}
```

## Named Loggers

```go
// Named loggers appear in output as "logger":"patient_handler"
handlerLog := logger.Named("patient_handler")
```

## Best Practice in Bundle-Go

```go
// All structs use *zap.Logger (structured)
type PatientService struct {
    repo   port.PatientRepository
    logger *zap.Logger  // NOT *zap.SugaredLogger
}

func NewPatientService(repo port.PatientRepository, logger *zap.Logger) *PatientService {
    return &PatientService{
        repo:   repo,
        logger: logger.With(zap.String("service", "patient")),
    }
}

func (s *PatientService) CreatePatient(ctx context.Context, cmd dto.CreatePatientCommand) (*patient.Patient, error) {
    start := time.Now()

    p, err := s.doCreate(ctx, cmd)
    if err != nil {
        s.logger.Error("create patient failed",
            zap.String("cpf", masked(cmd.CPF)),
            zap.Error(err),
        )
        return nil, err
    }

    s.logger.Info("patient created",
        zap.String("patient_id", p.ID),
        zap.Duration("elapsed", time.Since(start)),
    )
    return p, nil
}
```
