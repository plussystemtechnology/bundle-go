# Single Responsibility Principle in Go

## Core Idea

A package (or type) should have one reason to change — it serves one actor,
one concern, one level of abstraction.

In Go this applies at the **package level** as much as the struct level.

## Package-Level SRP

### Bad: one package doing too much

```
adapter/patient/
    handler.go       // HTTP handling
    repo.go          // DB queries
    kafka_consumer.go // event consumption
    redis_cache.go   // caching
```

All four files change for different reasons (HTTP contract change, DB schema change,
Kafka topic change, cache strategy change).

### Good: separate packages per concern

```
adapter/
    http/handler/
        patient_handler.go   // changes when HTTP API changes
    db/repo/
        patient_repo.go      // changes when schema changes
    kafka/consumer/
        patient_consumer.go  // changes when Kafka topic changes
    redis/
        patient_cache.go     // changes when cache strategy changes
```

## Struct-Level SRP

### Bad: service doing too much

```go
type PatientService struct {
    db       *pgxpool.Pool
    kafkaPub *kafka.Producer
    redis    *redis.Client
    smtp     *smtp.Client
    logger   *zap.Logger
}

func (s *PatientService) CreatePatient(...) error {
    // 1. validate
    // 2. save to DB
    // 3. publish Kafka event
    // 4. invalidate Redis cache
    // 5. send welcome email
    // 6. log audit trail
}
```

This changes whenever DB schema, Kafka topic, email template, or cache strategy changes.

### Good: service delegates to single-purpose dependencies

```go
// app/service/patient_service.go
type PatientService struct {
    repo      port.PatientRepository  // DB concern
    events    port.PatientEventPublisher // Kafka concern
    notifier  port.PatientNotifier    // email concern
}

func (s *PatientService) CreatePatient(ctx context.Context, cmd CreatePatientCommand) error {
    p := patient.New(cmd.Name, cmd.CPF)
    if err := s.repo.Save(ctx, p); err != nil {
        return fmt.Errorf("save patient: %w", err)
    }
    if err := s.events.PublishCreated(ctx, p); err != nil {
        return fmt.Errorf("publish event: %w", err)
    }
    go s.notifier.SendWelcome(context.Background(), p) // fire and forget
    return nil
}
```

Each dependency has one reason to change. The service only orchestrates.

## File-Level SRP in Go

Prefer one type per file, named after the type:

```
app/service/
    patient_service.go       // PatientService struct + methods
    patient_service_test.go  // tests only
    appointment_service.go   // AppointmentService struct + methods
```

Not:

```
app/service/
    services.go   // all services in one file — changes constantly
```

## Package Naming as SRP Signal

A package name should be a **noun** describing its single responsibility:

| Good Name       | Reason                                      |
|-----------------|---------------------------------------------|
| `patient`       | patient entity and domain rules             |
| `repo`          | database persistence                        |
| `handler`       | HTTP request/response                       |
| `publisher`     | Kafka event publishing                      |
| `validator`     | input validation rules                      |

Avoid: `utils`, `helpers`, `common`, `misc` — these are not responsibilities,
they are catch-alls that accumulate unrelated code.

## Checklist

- [ ] Does this package/type have a single, clearly nameable purpose?
- [ ] Will this file ever change for two different reasons?
- [ ] Does the struct have more than 3-4 dependencies injected?
- [ ] Is the package name a vague catch-all?

If yes to any, split the responsibility.
