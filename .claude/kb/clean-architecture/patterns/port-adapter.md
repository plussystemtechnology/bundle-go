# Port + Adapter Pattern

## Overview

A **port** is an interface in `port/` declaring what the application needs.
An **adapter** is a concrete struct in `adapter/` satisfying that interface.
The application never sees the adapter — only the port.

## Complete Example: Patient Repository

### 1. Domain entity

```go
// domain/patient/patient.go
package patient

import "time"

type Patient struct {
    ID        string
    Name      string
    CPF       string
    BirthDate time.Time
    Active    bool
    CreatedAt time.Time
    UpdatedAt time.Time
}

func New(name, cpf string) *Patient {
    return &Patient{
        ID:        generateID(),
        Name:      name,
        CPF:       cpf,
        Active:    true,
        CreatedAt: time.Now(),
        UpdatedAt: time.Now(),
    }
}
```

### 2. Port (interface)

```go
// port/patient_repository.go
package port

import (
    "context"
    "github.com/org/noxcare-go/domain/patient"
)

type PatientRepository interface {
    FindByID(ctx context.Context, id string) (*patient.Patient, error)
    FindByCPF(ctx context.Context, cpf string) (*patient.Patient, error)
    ListActive(ctx context.Context, limit, offset int) ([]*patient.Patient, error)
    Save(ctx context.Context, p *patient.Patient) error
    Update(ctx context.Context, p *patient.Patient) error
    Delete(ctx context.Context, id string) error
}
```

### 3. Adapter (PostgreSQL implementation using sqlc)

```go
// adapter/db/repo/patient_repo.go
package repo

import (
    "context"
    "errors"
    "fmt"

    "github.com/jackc/pgx/v5"
    "github.com/jackc/pgx/v5/pgxpool"
    "github.com/org/noxcare-go/adapter/db/sqlc" // generated queries
    "github.com/org/noxcare-go/domain/patient"
    "github.com/org/noxcare-go/port"
)

// Compile-time interface check
var _ port.PatientRepository = (*PatientRepo)(nil)

type PatientRepo struct {
    db      *pgxpool.Pool
    queries *sqlc.Queries
}

func NewPatientRepo(db *pgxpool.Pool) *PatientRepo {
    return &PatientRepo{db: db, queries: sqlc.New(db)}
}

func (r *PatientRepo) FindByID(ctx context.Context, id string) (*patient.Patient, error) {
    row, err := r.queries.GetPatientByID(ctx, id)
    if err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return nil, patient.ErrPatientNotFound
        }
        return nil, fmt.Errorf("find patient by id: %w", err)
    }
    return toDomainPatient(row), nil
}

func (r *PatientRepo) Save(ctx context.Context, p *patient.Patient) error {
    err := r.queries.InsertPatient(ctx, sqlc.InsertPatientParams{
        ID:        p.ID,
        Name:      p.Name,
        Cpf:       p.CPF,
        BirthDate: p.BirthDate,
        Active:    p.Active,
    })
    if err != nil {
        return fmt.Errorf("save patient: %w", err)
    }
    return nil
}

// toDomainPatient maps sqlc row to domain entity
func toDomainPatient(row sqlc.Patient) *patient.Patient {
    return &patient.Patient{
        ID:        row.ID,
        Name:      row.Name,
        CPF:       row.Cpf,
        BirthDate: row.BirthDate.Time,
        Active:    row.Active,
        CreatedAt: row.CreatedAt.Time,
        UpdatedAt: row.UpdatedAt.Time,
    }
}
```

### 4. Adapter: Kafka event publisher

```go
// adapter/kafka/publisher/patient_publisher.go
package publisher

import (
    "context"
    "encoding/json"
    "fmt"

    "github.com/twmb/franz-go/pkg/kgo"
    "github.com/org/noxcare-go/domain/patient"
    "github.com/org/noxcare-go/port"
)

var _ port.PatientEventPublisher = (*PatientKafkaPublisher)(nil)

type PatientKafkaPublisher struct {
    client *kgo.Client
    topic  string
}

func NewPatientKafkaPublisher(client *kgo.Client, topic string) *PatientKafkaPublisher {
    return &PatientKafkaPublisher{client: client, topic: topic}
}

func (p *PatientKafkaPublisher) PublishCreated(ctx context.Context, pat *patient.Patient) error {
    payload, err := json.Marshal(map[string]any{
        "event": "patient.created",
        "id":    pat.ID,
        "name":  pat.Name,
    })
    if err != nil {
        return fmt.Errorf("marshal patient event: %w", err)
    }
    rec := &kgo.Record{Topic: p.topic, Key: []byte(pat.ID), Value: payload}
    if err := p.client.ProduceSync(ctx, rec).FirstErr(); err != nil {
        return fmt.Errorf("publish patient created: %w", err)
    }
    return nil
}
```

### 5. Bootstrap wires port to adapter

```go
// bootstrap/patient.go
package bootstrap

import (
    "github.com/jackc/pgx/v5/pgxpool"
    "github.com/twmb/franz-go/pkg/kgo"
    "github.com/org/noxcare-go/adapter/db/repo"
    "github.com/org/noxcare-go/adapter/kafka/publisher"
    "github.com/org/noxcare-go/app/service"
    "github.com/org/noxcare-go/config"
)

func NewPatientService(db *pgxpool.Pool, kc *kgo.Client, cfg *config.AppConfig) *service.PatientService {
    patientRepo := repo.NewPatientRepo(db)
    patientPub  := publisher.NewPatientKafkaPublisher(kc, cfg.Kafka.PatientTopic)
    return service.NewPatientService(patientRepo, patientPub, cfg)
}
```

## Key Points

- The port defines the **contract** from the consumer's perspective
- The adapter **satisfies** the port without knowing it's being used as one
- `var _ port.X = (*Adapter)(nil)` enforces the contract at compile time
- Swapping adapters (e.g., in-memory for tests) requires zero changes to app/
