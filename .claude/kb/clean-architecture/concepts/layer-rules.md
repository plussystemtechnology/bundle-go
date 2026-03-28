# Layer Import Rules

## Full Dependency Matrix

### domain/
**Imports:** stdlib only (`time`, `errors`, `fmt`, `strings`, `math`, etc.)
**Must NOT import:** any external library, any other internal package
**Contains:** entities, value objects, domain errors, business rules

```go
// domain/patient/patient.go
package patient

import (
    "errors"
    "time"
)

type Patient struct {
    ID        string
    Name      string
    BirthDate time.Time
    Active    bool
}

var ErrPatientNotFound = errors.New("patient not found")
var ErrInvalidCPF     = errors.New("invalid CPF")

func (p *Patient) Deactivate() error {
    if !p.Active {
        return errors.New("patient already inactive")
    }
    p.Active = false
    return nil
}
```

---

### port/
**Imports:** domain/ only
**Must NOT import:** adapters, app, config, pkg, third-party
**Contains:** repository interfaces, service interfaces, event publisher interfaces

```go
// port/patient_repository.go
package port

import (
    "context"
    "github.com/org/bundle-go/domain/patient"
)

type PatientRepository interface {
    FindByID(ctx context.Context, id string) (*patient.Patient, error)
    Save(ctx context.Context, p *patient.Patient) error
    Delete(ctx context.Context, id string) error
}
```

---

### app/
**Imports:** domain/, port/, config/
**Must NOT import:** adapter/, bootstrap/, pkg/, gin, sqlc, pgx, kafka
**Contains:** use cases, application services, DTOs (input/output structs)

```go
// app/service/patient_service.go
package service

import (
    "context"
    "github.com/org/bundle-go/config"
    "github.com/org/bundle-go/domain/patient"
    "github.com/org/bundle-go/port"
)

type PatientService struct {
    repo   port.PatientRepository
    cfg    *config.AppConfig
}

func NewPatientService(repo port.PatientRepository, cfg *config.AppConfig) *PatientService {
    return &PatientService{repo: repo, cfg: cfg}
}
```

---

### adapter/
**Imports:** app/, domain/, port/, config/, pkg/, third-party (gin, sqlc, pgx, kafka, redis)
**Must NOT import:** bootstrap/, cmd/
**Contains:** HTTP handlers, DB repositories, Kafka consumers/producers, Redis clients

```go
// adapter/http/handler/patient_handler.go
package handler

import (
    "net/http"
    "github.com/gin-gonic/gin"
    "github.com/org/bundle-go/app/service"
    "github.com/org/bundle-go/pkg/httputil"
)

type PatientHandler struct {
    svc *service.PatientService
}
```

---

### bootstrap/
**Imports:** all layers — adapter/, app/, port/, domain/, config/, pkg/, third-party
**Purpose:** dependency injection wiring only; no business logic

```go
// bootstrap/patient.go
package bootstrap

import (
    "github.com/org/bundle-go/adapter/db/repo"
    "github.com/org/bundle-go/app/service"
    "github.com/org/bundle-go/config"
)

func NewPatientService(db *pgxpool.Pool, cfg *config.AppConfig) *service.PatientService {
    r := repo.NewPatientRepo(db)
    return service.NewPatientService(r, cfg)
}
```

---

### cmd/
**Imports:** bootstrap/ only (plus stdlib for signal handling)
**Contains:** `main()` — parses flags, calls bootstrap, starts server, handles OS signals

```go
// cmd/api/main.go
package main

import (
    "github.com/org/bundle-go/bootstrap"
)

func main() {
    app := bootstrap.Setup()
    app.Run()
}
```

---

### config/
**Imports:** stdlib + config-loading libraries (viper, envconfig, godotenv)
**Must NOT import:** domain, port, app, adapter, bootstrap, pkg
**Contains:** pure data structs representing application configuration

```go
// config/config.go
package config

type AppConfig struct {
    Database DatabaseConfig
    Server   ServerConfig
    Kafka    KafkaConfig
}

type DatabaseConfig struct {
    DSN             string `env:"DB_DSN,required"`
    MaxOpenConns    int    `env:"DB_MAX_OPEN_CONNS" envDefault:"25"`
}
```

---

### pkg/
**Imports:** stdlib only (no business packages, no domain, no port)
**Contains:** reusable utilities: logger wrapper, HTTP response helpers, pagination, validators

```go
// pkg/httputil/response.go
package httputil

import (
    "net/http"
    "github.com/gin-gonic/gin"
)

func OK(c *gin.Context, data any) {
    c.JSON(http.StatusOK, gin.H{"data": data})
}

func BadRequest(c *gin.Context, err error) {
    c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
}
```

## Enforcement

Use `go-cleanarch` or custom `go vet` checks to enforce import rules in CI.
