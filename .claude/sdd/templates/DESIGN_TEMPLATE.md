# DESIGN: {Feature Name}

> Technical design for implementing {Feature Name}

## Metadata

| Attribute | Value |
|-----------|-------|
| **Feature** | {FEATURE_NAME} |
| **Date** | {YYYY-MM-DD} |
| **Author** | design-agent |
| **DEFINE** | [DEFINE_{FEATURE}.md](./DEFINE_{FEATURE}.md) |
| **Status** | Draft / Ready for Build |

---

## Architecture Overview

```text
┌─────────────────────────────────────────────────────────────────┐
│                    CLEAN ARCHITECTURE LAYERS                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  cmd/                    → Entry point (main.go, wire setup)    │
│    └── bootstrap/        → Dependency injection & server init   │
│                                  │                               │
│  internal/                       ▼                               │
│  ├── adapter/            → Driven by external world             │
│  │   ├── handler/http/   → Gin HTTP handlers (inbound)         │
│  │   ├── consumer/kafka/ → Kafka consumers (inbound)           │
│  │   ├── repository/pg/  → PostgreSQL via sqlc (outbound)      │
│  │   └── cache/redis/    → Redis cache (outbound)              │
│  │                               │                               │
│  ├── app/                → Use cases / application services     │
│  │   └── {feature}/      → {Feature}Service (orchestration)    │
│  │                               │                               │
│  ├── port/               → Interfaces (contracts)               │
│  │   ├── in/             → Use case interfaces (input ports)   │
│  │   └── out/            → Repository/cache interfaces         │
│  │                               │                               │
│  └── domain/             → Pure business logic & entities       │
│      └── {entity}/       → Structs, value objects, errors      │
│                                                                  │
│  [HTTP Client] → [Handler] → [Service] → [Repository] → [DB]   │
│                                  ↓                               │
│                            [Cache/Redis]                         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Components

| Component | Purpose | Technology | Layer |
|-----------|---------|------------|-------|
| {Component A} | {What it does} | {e.g., Gin, sqlc, pgx} | {adapter/handler} |
| {Component B} | {What it does} | {e.g., Service struct} | {app} |
| {Component C} | {What it does} | {e.g., Domain entity} | {domain} |

---

## Key Decisions

### Decision 1: {Decision Name}

| Attribute | Value |
|-----------|-------|
| **Status** | Accepted |
| **Date** | {YYYY-MM-DD} |

**Context:** {Why this decision was needed}

**Choice:** {What we decided to do}

**Rationale:** {Why this is the right choice}

**Alternatives Rejected:**
1. {Option A} - Rejected because {reason}
2. {Option B} - Rejected because {reason}

**Consequences:**
- {Trade-off we accept}
- {Benefit we gain}

---

### Decision 2: {Decision Name}

{Repeat structure above}

---

## File Manifest

| # | File | Action | Purpose | Agent | Dependencies |
|---|------|--------|---------|-------|--------------|
| 1 | `internal/domain/{entity}/{entity}.go` | Create | Domain entity & errors | @domain-modeler | None |
| 2 | `internal/port/out/{entity}_repository.go` | Create | Repository interface | @domain-modeler | 1 |
| 3 | `internal/port/in/{feature}_service.go` | Create | Use case interface | @domain-modeler | 1 |
| 4 | `internal/app/{feature}/{feature}_service.go` | Create | Business logic orchestration | @service-builder | 2, 3 |
| 5 | `internal/adapter/repository/pg/{entity}_repository.go` | Create | PostgreSQL implementation | @repository-builder | 2 |
| 6 | `internal/adapter/handler/http/{feature}_handler.go` | Create | Gin HTTP handler | @handler-builder | 3 |
| 7 | `internal/adapter/handler/http/{feature}_handler_test.go` | Create | Handler unit tests | @test-builder | 6 |
| 8 | `db/queries/{feature}.sql` | Create | sqlc queries | @repository-builder | None |
| 9 | `db/migrations/{timestamp}_{feature}.sql` | Create | DB migration | @repository-builder | None |

**Total Files:** {N}

---

## Agent Assignment Rationale

> Agents discovered from `.claude/agents/` - Build phase invokes matched specialists.

| Agent | Files Assigned | Why This Agent |
|-------|----------------|----------------|
| @domain-modeler | 1, 2, 3 | Specialization: domain entities, value objects, interface contracts |
| @service-builder | 4 | Specialization: Clean Arch use cases, error wrapping, business logic |
| @repository-builder | 5, 8, 9 | Specialization: sqlc queries, pgx transactions, migration authoring |
| @handler-builder | 6 | Specialization: Gin routing, request binding, response formatting |
| @test-builder | 7 | Specialization: go test, testify, testcontainers, mock generation |
| (general) | {if any} | No specialist found - Build handles directly |

**Agent Discovery:**
- Scanned: `.claude/agents/**/*.md`
- Matched by: File type, purpose keywords, path patterns, KB domains

---

## Code Patterns

### Pattern 1: Domain Entity with Validation

```go
// internal/domain/{entity}/{entity}.go
// Use this pattern for all domain entities — no framework imports allowed here.

package {entity}

import (
    "errors"
    "time"
)

// {Entity} is the core domain object.
type {Entity} struct {
    ID        string
    // ... fields
    CreatedAt time.Time
    UpdatedAt time.Time
}

// Sentinel errors — exported, used by app and adapter layers.
var (
    Err{Entity}NotFound    = errors.New("{entity}: not found")
    Err{Entity}InvalidInput = errors.New("{entity}: invalid input")
)

// New{Entity} constructs and validates a new {Entity}.
func New{Entity}(/* params */) (*{Entity}, error) {
    if /* validation fails */ {
        return nil, Err{Entity}InvalidInput
    }
    return &{Entity}{/* ... */}, nil
}
```

### Pattern 2: Port Interface (Output Port)

```go
// internal/port/out/{entity}_repository.go
// Defined in port layer — implemented in adapter/repository, tested with mocks.

package out

import (
    "context"
    "{module}/internal/domain/{entity}"
)

type {Entity}Repository interface {
    Create(ctx context.Context, e *{entity}.{Entity}) error
    GetByID(ctx context.Context, id string) (*{entity}.{Entity}, error)
    // ... other methods
}
```

### Pattern 3: Application Service

```go
// internal/app/{feature}/{feature}_service.go
// Orchestrates domain logic — depends on port interfaces, never on adapters.

package {feature}

import (
    "context"
    "fmt"
    "{module}/internal/domain/{entity}"
    "{module}/internal/port/out"
)

type {Feature}Service struct {
    repo out.{Entity}Repository
}

func New{Feature}Service(repo out.{Entity}Repository) *{Feature}Service {
    return &{Feature}Service{repo: repo}
}

func (s *{Feature}Service) Create{Entity}(ctx context.Context, /* params */) (*{entity}.{Entity}, error) {
    e, err := {entity}.New{Entity}(/* params */)
    if err != nil {
        return nil, fmt.Errorf("{feature}: create: %w", err)
    }
    if err := s.repo.Create(ctx, e); err != nil {
        return nil, fmt.Errorf("{feature}: persist: %w", err)
    }
    return e, nil
}
```

### Pattern 4: Gin Handler

```go
// internal/adapter/handler/http/{feature}_handler.go
// HTTP layer — binds requests, calls service, writes responses.

package http

import (
    "net/http"
    "github.com/gin-gonic/gin"
    "{module}/internal/port/in"
)

type {Feature}Handler struct {
    svc in.{Feature}UseCase
}

func New{Feature}Handler(svc in.{Feature}UseCase) *{Feature}Handler {
    return &{Feature}Handler{svc: svc}
}

func (h *{Feature}Handler) Create(c *gin.Context) {
    var req Create{Entity}Request
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }
    result, err := h.svc.Create{Entity}(c.Request.Context(), req.toParams())
    if err != nil {
        // use errors.Is for domain sentinel errors
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }
    c.JSON(http.StatusCreated, toResponse(result))
}
```

---

## Data Flow

```text
1. HTTP request arrives → Gin router dispatches to {Feature}Handler.Create
   │
   ▼
2. Handler binds & validates request payload (ShouldBindJSON)
   │
   ▼
3. Handler calls {Feature}Service.Create{Entity}(ctx, params)
   │
   ▼
4. Service calls domain constructor {entity}.New{Entity} — validates business rules
   │
   ▼
5. Service calls {Entity}Repository.Create(ctx, entity) via output port
   │
   ▼
6. Repository executes sqlc-generated query via pgx connection pool
   │
   ▼
7. Result propagates back up the chain — handler writes JSON response
```

---

## Integration Points

| External System | Integration Type | Authentication | Layer |
|-----------------|-----------------|----------------|-------|
| PostgreSQL | pgx v5 + sqlc | DSN / env var | adapter/repository/pg |
| Redis | go-redis v9 | DSN / env var | adapter/cache/redis |
| Kafka | franz-go / confluent | SASL / env var | adapter/consumer/kafka |
| {External API} | REST HTTP | Bearer token / env var | adapter/gateway |

---

## Testing Strategy

| Test Type | Scope | Files | Tools | Coverage Goal |
|-----------|-------|-------|-------|---------------|
| Unit | Domain logic, services | `internal/domain/**/*_test.go`, `internal/app/**/*_test.go` | go test, testify/mock | 80% |
| Handler | HTTP layer | `internal/adapter/handler/http/**/*_test.go` | go test, httptest, testify | Key paths |
| Integration | Repository | `internal/adapter/repository/pg/**/*_test.go` | testcontainers-go, pgx | Happy path + errors |
| Benchmark | Hot paths | `*_bench_test.go` | go test -bench | Baseline established |
| E2E | Full flow | Manual / Postman | - | Happy path |

---

## Error Handling

| Error Type | Handling Strategy | Layer | Retry? |
|------------|-------------------|-------|--------|
| Domain validation error | Return sentinel `domain.Err*`, wrap with `fmt.Errorf("...: %w", err)` | domain | No |
| DB not found | Map to domain sentinel in repository | adapter | No |
| DB connection error | Log + return wrapped error, let middleware respond 503 | adapter | Yes (pgx pool) |
| Kafka consumer error | Log + DLQ or skip with offset commit | adapter | Configurable |
| HTTP request binding error | Return 400 with validation message | adapter/handler | No |

---

## Configuration

| Config Key | Type | Default | Description |
|------------|------|---------|-------------|
| `{FEATURE}_ENABLED` | bool | `true` | Feature flag |
| `{FEATURE}_TIMEOUT_MS` | int | `5000` | Request timeout in milliseconds |
| `DB_DSN` | string | - | PostgreSQL connection string |
| `REDIS_ADDR` | string | `localhost:6379` | Redis address |
| `KAFKA_BROKERS` | string | `localhost:9092` | Comma-separated Kafka brokers |

---

## Dependencies

New entries required in `go.mod`:

```
{module-path} {version}  // {reason}
```

No new dependencies (if applicable): {state clearly if no new deps are needed}

---

## Security Considerations

- {e.g., "All user-supplied IDs must be validated before DB queries (sql injection prevention via sqlc parameterized queries)"}
- {e.g., "Sensitive fields (PII, tokens) must not appear in structured log output"}
- {e.g., "Service-to-service calls must use internal JWT / mTLS — no public tokens in env"}

---

## Observability

| Aspect | Implementation |
|--------|----------------|
| Logging | Structured `slog.Logger` injected via context; log level, request-id, trace-id on every entry |
| Metrics | Prometheus counters/histograms on handler and service layer; expose `/metrics` endpoint |
| Tracing | OpenTelemetry spans; propagate `traceparent` header through Gin middleware |

---

## Pipeline Architecture (if applicable)

> Include this section when the feature involves Kafka consumers, event-driven flows, or data ingestion.

### Event Flow Diagram

```text
[Kafka Topic: {topic}]
      │
      ▼
[Consumer Group: {group-id}]
      │
      ▼
[adapter/consumer/kafka/{feature}_consumer.go]
      │
      ▼
[app/{feature}/{feature}_service.go]  ←── domain logic
      │
      ├──→ [adapter/repository/pg/{entity}_repository.go] → Postgres
      └──→ [adapter/cache/redis/{entity}_cache.go]        → Redis
```

### Partition Strategy

| Topic | Partition Key | Granularity | Rationale |
|-------|-------------|-------------|-----------|
| {topic_1} | {field} | {per-entity / per-tenant} | {Query patterns, ordering guarantees} |

### Idempotency Strategy

| Model | Strategy | Key Column | Notes |
|-------|----------|------------|-------|
| {event_1} | {upsert / insert-ignore / dedup cache} | {column} | {Why this strategy} |

### Schema Evolution Plan

| Change Type | Handling | Rollback |
|-------------|----------|----------|
| New column | {Add with DEFAULT, backfill async, re-run sqlc} | {Drop column, re-run sqlc} |
| Type change | {Dual-write period, then migrate} | {Revert type} |
| Column removal | {Deprecate in contract first, remove after N days} | {Re-add column} |

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | {YYYY-MM-DD} | design-agent | Initial version |

---

## Next Step

**Ready for:** `/build .claude/sdd/features/DESIGN_{FEATURE_NAME}.md`
