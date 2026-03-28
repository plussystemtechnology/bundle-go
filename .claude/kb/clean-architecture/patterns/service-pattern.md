# Application Service Pattern

## Overview

Application services in `app/service/` implement use cases.
They orchestrate domain objects and port interfaces.
They contain **no** HTTP, DB, or infrastructure concerns.

## Structure

```
app/service/
    patient_service.go        // CRUD + business use cases
    patient_service_test.go   // unit tests with mocks
    appointment_service.go
    appointment_service_test.go
```

## Full Service Example

```go
// app/service/patient_service.go
package service

import (
    "context"
    "fmt"

    "go.uber.org/zap"
    "github.com/org/noxcare-go/app/dto"
    "github.com/org/noxcare-go/config"
    "github.com/org/noxcare-go/domain/patient"
    "github.com/org/noxcare-go/port"
)

type PatientService struct {
    repo   port.PatientRepository
    events port.PatientEventPublisher
    cache  port.PatientCache
    cfg    *config.AppConfig
    logger *zap.Logger
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
        logger: logger.With(zap.String("service", "patient")),
    }
}

// CreatePatient is a command use case — validates, creates, persists, publishes
func (s *PatientService) CreatePatient(ctx context.Context, cmd dto.CreatePatientCommand) (*patient.Patient, error) {
    // 1. Domain validation
    if err := validateCPF(cmd.CPF); err != nil {
        return nil, fmt.Errorf("create patient: %w", err)
    }

    // 2. Business rule: check uniqueness
    existing, err := s.repo.FindByCPF(ctx, cmd.CPF)
    if err != nil && !isNotFound(err) {
        return nil, fmt.Errorf("create patient check cpf: %w", err)
    }
    if existing != nil {
        return nil, patient.ErrCPFAlreadyRegistered
    }

    // 3. Create domain entity
    p := patient.New(cmd.Name, cmd.CPF, cmd.BirthDate)

    // 4. Persist
    if err := s.repo.Save(ctx, p); err != nil {
        return nil, fmt.Errorf("create patient save: %w", err)
    }

    // 5. Publish domain event
    if err := s.events.PublishCreated(ctx, p); err != nil {
        s.logger.Warn("failed to publish patient created event",
            zap.String("patient_id", p.ID),
            zap.Error(err),
        )
        // Non-fatal: log and continue
    }

    s.logger.Info("patient created", zap.String("patient_id", p.ID))
    return p, nil
}

// GetPatient is a query use case — checks cache first, then DB
func (s *PatientService) GetPatient(ctx context.Context, id string) (*patient.Patient, error) {
    // Try cache
    if p, err := s.cache.Get(ctx, id); err == nil {
        return p, nil
    }

    // Fallback to DB
    p, err := s.repo.FindByID(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("get patient: %w", err)
    }

    // Warm cache asynchronously
    go func() {
        if err := s.cache.Set(context.Background(), p, s.cfg.Cache.PatientTTL); err != nil {
            s.logger.Warn("cache set patient failed", zap.Error(err))
        }
    }()

    return p, nil
}

// DeactivatePatient demonstrates a state-change use case
func (s *PatientService) DeactivatePatient(ctx context.Context, id string) error {
    p, err := s.repo.FindByID(ctx, id)
    if err != nil {
        return fmt.Errorf("deactivate patient find: %w", err)
    }

    // Domain logic lives on the entity
    if err := p.Deactivate(); err != nil {
        return fmt.Errorf("deactivate patient: %w", err)
    }

    if err := s.repo.Update(ctx, p); err != nil {
        return fmt.Errorf("deactivate patient update: %w", err)
    }

    _ = s.cache.Invalidate(ctx, id) // best effort
    return nil
}
```

## DTOs (Input/Output Structs)

```go
// app/dto/patient_dto.go
package dto

import "time"

// Commands — input to write operations
type CreatePatientCommand struct {
    Name      string
    CPF       string
    BirthDate time.Time
}

type UpdatePatientCommand struct {
    ID   string
    Name string
}

// Queries — input to read operations
type ListPatientsQuery struct {
    Active bool
    Limit  int
    Offset int
}

// Responses — output (can be same as domain or mapped view)
type PatientResponse struct {
    ID        string    `json:"id"`
    Name      string    `json:"name"`
    CPF       string    `json:"cpf"`
    BirthDate time.Time `json:"birth_date"`
    Active    bool      `json:"active"`
}
```

## Unit Test Structure

```go
// app/service/patient_service_test.go
package service_test

import (
    "context"
    "testing"

    "github.com/stretchr/testify/assert"
    "github.com/org/noxcare-go/app/dto"
    "github.com/org/noxcare-go/app/service"
    "github.com/org/noxcare-go/domain/patient"
)

func TestPatientService_CreatePatient(t *testing.T) {
    tests := []struct {
        name    string
        cmd     dto.CreatePatientCommand
        repoErr error
        wantErr bool
    }{
        {
            name: "success",
            cmd:  dto.CreatePatientCommand{Name: "Alice", CPF: "123.456.789-09"},
        },
        {
            name:    "invalid cpf",
            cmd:     dto.CreatePatientCommand{Name: "Bob", CPF: "000"},
            wantErr: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            repo := &mockPatientRepo{saveErr: tt.repoErr}
            svc  := service.NewPatientService(repo, &noopPublisher{}, &noopCache{}, testConfig(), testLogger())
            got, err := svc.CreatePatient(context.Background(), tt.cmd)
            if tt.wantErr {
                assert.Error(t, err)
                assert.Nil(t, got)
            } else {
                assert.NoError(t, err)
                assert.NotNil(t, got)
                assert.Equal(t, tt.cmd.Name, got.Name)
            }
        })
    }
}
```

## Rules for Application Services

- No `gin.Context`, no `*http.Request` — HTTP is adapter concern
- No raw SQL — DB is adapter concern
- Business rules that span multiple entities belong here
- Pure domain rules belong on the entity in `domain/`
- Keep methods short: validate → fetch → mutate → persist → publish
