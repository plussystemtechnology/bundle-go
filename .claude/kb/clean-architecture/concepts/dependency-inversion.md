# Dependency Inversion Principle in Go

## Core Idea

High-level modules (app services) must not depend on low-level modules (DB, HTTP, Kafka).
Both should depend on abstractions (interfaces in port/).

In Go, **interfaces are implicit** — the concrete type doesn't declare it implements an interface.
The interface owner (the consumer) defines what it needs.

## The DIP Pattern

```
app/service/PatientService  →  port.PatientRepository  ←  adapter/db/PatientRepo
        (high-level)                (abstraction)              (low-level)
```

## Concrete Example

### Step 1 — Define the interface in port/ (owned by the consumer)

```go
// port/patient_repository.go
package port

import (
    "context"
    "github.com/org/noxcare-go/domain/patient"
)

type PatientRepository interface {
    FindByID(ctx context.Context, id string) (*patient.Patient, error)
    ListActive(ctx context.Context, limit, offset int) ([]*patient.Patient, error)
    Save(ctx context.Context, p *patient.Patient) error
}
```

### Step 2 — app/ depends on the interface, not the concrete type

```go
// app/service/patient_service.go
package service

import (
    "context"
    "github.com/org/noxcare-go/domain/patient"
    "github.com/org/noxcare-go/port"
)

type PatientService struct {
    repo port.PatientRepository  // interface, not *repo.PatientRepo
}

func NewPatientService(repo port.PatientRepository) *PatientService {
    return &PatientService{repo: repo}
}

func (s *PatientService) GetPatient(ctx context.Context, id string) (*patient.Patient, error) {
    p, err := s.repo.FindByID(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("get patient: %w", err)
    }
    return p, nil
}
```

### Step 3 — adapter/ implements the interface (no explicit declaration needed)

```go
// adapter/db/repo/patient_repo.go
package repo

import (
    "context"
    "github.com/jackc/pgx/v5/pgxpool"
    "github.com/org/noxcare-go/domain/patient"
)

type PatientRepo struct {
    db *pgxpool.Pool
}

func NewPatientRepo(db *pgxpool.Pool) *PatientRepo {
    return &PatientRepo{db: db}
}

// Satisfies port.PatientRepository implicitly
func (r *PatientRepo) FindByID(ctx context.Context, id string) (*patient.Patient, error) {
    // sqlc generated query call
    row, err := r.db.QueryRow(ctx, "SELECT id, name FROM patients WHERE id = $1", id)
    // ...
}
```

### Step 4 — Verify interface compliance at compile time

```go
// adapter/db/repo/patient_repo.go  (add this line)
var _ port.PatientRepository = (*PatientRepo)(nil)
```

This blank assignment causes a compile error if PatientRepo no longer satisfies the interface.

### Step 5 — bootstrap/ wires it all together

```go
// bootstrap/patient.go
package bootstrap

func NewPatientService(db *pgxpool.Pool, cfg *config.AppConfig) *service.PatientService {
    repo := repo.NewPatientRepo(db)           // concrete adapter
    return service.NewPatientService(repo)    // injected as interface
}
```

## Why This Matters for Testing

Because app/ depends on `port.PatientRepository` (an interface), tests can inject a mock:

```go
// app/service/patient_service_test.go
type mockPatientRepo struct {
    findByIDFn func(ctx context.Context, id string) (*patient.Patient, error)
}

func (m *mockPatientRepo) FindByID(ctx context.Context, id string) (*patient.Patient, error) {
    return m.findByIDFn(ctx, id)
}
// implement other methods...

func TestGetPatient(t *testing.T) {
    mock := &mockPatientRepo{
        findByIDFn: func(_ context.Context, id string) (*patient.Patient, error) {
            return &patient.Patient{ID: id, Name: "Alice"}, nil
        },
    }
    svc := service.NewPatientService(mock)
    p, err := svc.GetPatient(context.Background(), "123")
    // assert...
}
```

No database needed. Fast, deterministic unit tests.

## Rule of Thumb

> Define interfaces where they are **used**, not where they are **implemented**.

The port/ package is where app/ states its requirements.
adapter/ packages satisfy those requirements incidentally.
