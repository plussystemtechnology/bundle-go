# Dependency Injection in Go (No Framework)

## Philosophy

Bundle-Go uses **manual constructor injection** — no wire, no dig, no fx.
Dependencies are passed explicitly via constructors. The `bootstrap/` package
owns all wiring. This is idiomatic Go: explicit over magic.

## Constructor Injection Pattern

```go
// Constructor always takes dependencies as parameters, returns pointer to struct
func NewThing(dep1 Dep1Type, dep2 Dep2Type) *Thing {
    return &Thing{dep1: dep1, dep2: dep2}
}
```

Rules:
- Accept **interfaces**, not concrete types (except logger and config)
- Return **concrete types** (callers know what they have)
- Never use `init()` for dependency setup
- Never use package-level globals for injectable dependencies

## Full Example: Layered Construction

### domain (no injection needed — pure logic)

```go
// domain/patient/patient.go — no deps
type Patient struct { ID, Name string }
```

### port (interfaces — no injection)

```go
// port/patient_repository.go
type PatientRepository interface {
    FindByID(ctx context.Context, id string) (*patient.Patient, error)
    Save(ctx context.Context, p *patient.Patient) error
}
```

### adapter (injected infrastructure)

```go
// adapter/db/repo/patient_repo.go
type PatientRepo struct {
    db      *pgxpool.Pool
    queries *sqlc.Queries
    logger  *zap.Logger
}

func NewPatientRepo(db *pgxpool.Pool, logger *zap.Logger) *PatientRepo {
    return &PatientRepo{
        db:      db,
        queries: sqlc.New(db),
        logger:  logger,
    }
}
```

### app (injected ports)

```go
// app/service/patient_service.go
type PatientService struct {
    repo   port.PatientRepository     // interface
    events port.PatientEventPublisher // interface
    cache  port.PatientCache          // interface
    cfg    *config.AppConfig          // config is concrete (data only)
    logger *zap.Logger                // logger is concrete (cross-cutting)
}

func NewPatientService(
    repo   port.PatientRepository,
    events port.PatientEventPublisher,
    cache  port.PatientCache,
    cfg    *config.AppConfig,
    logger *zap.Logger,
) *PatientService {
    return &PatientService{
        repo:   repo,
        events: events,
        cache:  cache,
        cfg:    cfg,
        logger: logger,
    }
}
```

### adapter/http (injected app services)

```go
// adapter/http/handler/patient_handler.go
type PatientHandler struct {
    svc    *service.PatientService
    logger *zap.Logger
}

func NewPatientHandler(svc *service.PatientService, logger *zap.Logger) *PatientHandler {
    return &PatientHandler{svc: svc, logger: logger}
}
```

### bootstrap (wires everything)

```go
// bootstrap/setup.go
package bootstrap

type App struct {
    Router *gin.Engine
    DB     *pgxpool.Pool
}

func Setup(cfg *config.AppConfig) (*App, error) {
    logger, err := zap.NewProduction()
    if err != nil {
        return nil, fmt.Errorf("init logger: %w", err)
    }

    db, err := pgxpool.New(context.Background(), cfg.Database.DSN)
    if err != nil {
        return nil, fmt.Errorf("connect db: %w", err)
    }

    kafkaClient, err := kgo.NewClient(kgo.SeedBrokers(cfg.Kafka.Brokers...))
    if err != nil {
        return nil, fmt.Errorf("init kafka: %w", err)
    }

    redisClient := redis.NewClient(&redis.Options{Addr: cfg.Redis.Addr})

    // Adapters
    patientRepo  := repo.NewPatientRepo(db, logger)
    patientPub   := publisher.NewPatientKafkaPublisher(kafkaClient, cfg.Kafka.PatientTopic)
    patientCache := rediscache.NewPatientCache(redisClient, cfg.Redis.TTL)

    // Services
    patientSvc := service.NewPatientService(patientRepo, patientPub, patientCache, cfg, logger)

    // Handlers
    patientHandler := handler.NewPatientHandler(patientSvc, logger)

    // Router
    r := gin.New()
    routes.RegisterPatient(r, patientHandler)

    return &App{Router: r, DB: db}, nil
}
```

### cmd (calls bootstrap only)

```go
// cmd/api/main.go
package main

import (
    "context"
    "log"
    "net/http"
    "os"
    "os/signal"
    "syscall"
    "time"

    "github.com/org/bundle-go/bootstrap"
    "github.com/org/bundle-go/config"
)

func main() {
    cfg, err := config.Load()
    if err != nil {
        log.Fatalf("load config: %v", err)
    }

    app, err := bootstrap.Setup(cfg)
    if err != nil {
        log.Fatalf("setup: %v", err)
    }

    srv := &http.Server{Addr: cfg.Server.Addr, Handler: app.Router}

    go func() {
        if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            log.Fatalf("server: %v", err)
        }
    }()

    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit

    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()
    _ = srv.Shutdown(ctx)
}
```

## When to Use Functional Options Instead

Use functional options when a struct has many optional config parameters:

```go
type ServerOptions struct {
    timeout     time.Duration
    maxBodySize int64
    logger      *zap.Logger
}

type Option func(*ServerOptions)

func WithTimeout(d time.Duration) Option { return func(o *ServerOptions) { o.timeout = d } }
func WithLogger(l *zap.Logger) Option   { return func(o *ServerOptions) { o.logger = l } }

func NewServer(addr string, opts ...Option) *Server {
    o := &ServerOptions{timeout: 30 * time.Second} // sensible defaults
    for _, opt := range opts {
        opt(o)
    }
    return &Server{addr: addr, opts: o}
}
```

See `go-patterns/patterns/option-pattern.md` for details.
