# NoxCare-Go SDD Framework

> **Spec-Driven Development for Go Backend API on Claude Code**
>
> *"From Specification to Specialized Execution"*

---

## Executive Summary

| Aspect | Details |
|--------|---------|
| **Project** | NoxCare-Go - Spec-Driven Development Framework |
| **Tagline** | Spec-Driven Development for Go Clean Architecture |
| **Business Problem** | Gap between unstructured "vibe coding" and stale traditional specifications |
| **Solution** | 5-phase workflow with 43 specialized AI agents, 15+ KB domains, and 23 commands |
| **Target Audience** | Go backend teams using Claude Code |
| **Stack** | Go, Gin, sqlc, pgx, Kafka (Sarama), Redis, gRPC, PostgreSQL, Docker, Kubernetes |

### What This Is

NoxCare-Go transforms requirements into working Go code with full traceability. It provides a structured 5-phase development workflow (Brainstorm -> Define -> Design -> Build -> Ship) powered by specialized AI agents that match to tasks automatically, enforcing Clean Architecture import boundaries at every step.

**The Core Insight:** *"The AI doesn't just need to know WHAT to build - it needs to know WHO should build each part and WHERE it belongs in the architecture."*

Traditional specs produce a task list. NoxCare-Go produces a **team assignment** with **architecture compliance**.

### Key Insights

1. **Strength:** Automatic agent matching + Clean Architecture gate = consistent, layered Go code
2. **Strength:** Deep Go specialization (Gin handlers, sqlc repos, Kafka consumers, gRPC services)
3. **Strength:** Import boundary enforcement via `./scripts/check_arch.sh` — violations block the build
4. **Opportunity:** Local telemetry can drive continuous improvement
5. **Concern:** No Judge layer to validate specs before expensive BUILD phase (planned)

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Key Decisions](#key-decisions)
3. [Architecture](#architecture)
4. [Clean Architecture Gate](#clean-architecture-gate)
5. [The Agent Ecosystem](#the-agent-ecosystem)
6. [Knowledge Base Integration](#knowledge-base-integration)
7. [Commands & Artifacts](#commands--artifacts)
8. [Phase Details](#phase-details)
9. [Quality Verification](#quality-verification)
10. [Anti-Patterns](#anti-patterns)
11. [Extending NoxCare-Go](#extending-noxcare-go)
12. [Quick Start](#quick-start)
13. [References](#references)
14. [Version History](#version-history)

---

## Key Decisions

### Technical Decisions

| # | Decision | Rationale | Status |
|---|----------|-----------|--------|
| D1 | 5-phase pipeline (Brainstorm->Define->Design->Build->Ship) | Balances rigor with pragmatism | **Implemented** |
| D2 | Agent matching in Design phase via Glob discovery | Framework-agnostic, zero configuration | **Implemented** |
| D3 | Clean Architecture gate enforced by check_arch.sh | Prevents layer violations at build time | **Implemented** |
| D4 | Model allocation: Opus (0-2), Sonnet (3), Haiku (4) | Cost/quality optimization | **Implemented** |
| D5 | Clarity Score 12/15 minimum gate | Catches incomplete specs early | **Implemented** |
| D6 | Go specialization across agents, KB, and commands | Deep domain expertise for Go backend | **Implemented** |
| D7 | go test -race required in full_ci | Catches data races early | **Implemented** |
| D8 | golangci-lint as primary linter | Consolidated Go linting | **Implemented** |

### Process Decisions

| # | Decision | Rationale | Status |
|---|----------|-----------|--------|
| D9 | `/iterate` command for mid-stream changes | Maintains traceability | **Implemented** |
| D10 | Archive completed features with lessons learned | Knowledge capture | **Implemented** |
| D11 | Agent attribution in BUILD_REPORT | Clear ownership | **Implemented** |

### Planned Decisions

| # | Decision | Rationale | Status |
|---|----------|-----------|--------|
| D12 | Add LLM-as-Judge layer (Phase 1.5) | Catch errors before expensive BUILD | **Planned** |
| D13 | gosec integration in extended CI | Security scanning for Go | **Planned** |
| D14 | Local-only telemetry (opt-in) | Privacy-first learning | **Planned** |

---

## Architecture

### The 5-Phase Pipeline

```text
+---------------------------------------------------------------------------------------------------------+
|                                    NOXCARE-GO PIPELINE                                                   |
+---------------------------------------------------------------------------------------------------------+
|                                                                                                          |
|  +----------+    +----------+    +--------------+    +---------------+    +----------+                   |
|  | Phase 0  |--->| Phase 1  |--->|   Phase 2    |--->|    Phase 3    |--->| Phase 4  |                   |
|  |BRAINSTORM|    |  DEFINE  |    |    DESIGN    |    |     BUILD     |    |   SHIP   |                   |
|  |(Optional)|    |          |    |              |    |               |    |          |                   |
|  +----+-----+    +----+-----+    +------+-------+    +-------+-------+    +----+-----+                   |
|       |               |                 |                    |                 |                          |
|       v               v                 v                    v                 v                          |
|   Questions       Clarity           Clean Arch           Go Agent          Archive                       |
|   + Approaches    Score 12/15       Gate + Layers        Delegation        + Lessons                     |
|   + YAGNI         + Tech Context    + Agent Match        + Verification                                  |
|                                     + Go Patterns        + go test -race                                 |
|                                                                                                          |
|  <-------------------------------------------------------------------------->                            |
|                                    /iterate (any phase)                                                  |
|                                                                                                          |
+---------------------------------------------------------------------------------------------------------+
```

### Go Project Data Flow

```text
                           +-------------------------------------+
                           |         .claude/kb/                 |
                           |  +------------------------------+   |
                           |  |  Go KB domains               |   |
                           |  |  (gin, sqlc, kafka, grpc...) |   |
                           |  +------------------------------+   |
                           +------------------+------------------+
                                              |
                                              v
+------------------+         +------------------------------+
|   DEFINE         |-------->|         KB Domains           |
|                  |         |    (from Technical Context)  |
| - Location       |         +------------------------------+
| - KB Domains     |                        |
| - Layer Target   |                        v
| - API Contract   |         +------------------------------+
+------------------+         |          DESIGN              |
                             |                              |
                             |  Agent Matching:             |
                             |  Glob(.claude/agents/**)     |
                             |         |                    |
                             |         v                    |
                             |  +--------------------+      |
                             |  | go_delegation map  |      |
                             |  | - file pattern     |      |
                             |  | - agent name       |      |
                             |  +--------------------+      |
                             |            |                 |
                             |            v                 |
                             |  File Manifest + Agent +     |
                             |  Clean Arch Layer Mapping    |
                             +------------------------------+
                                            |
                                            v
                             +------------------------------+
                             |          BUILD               |
                             |                              |
                             |  For each file:              |
                             |  Has agent in manifest?      |
                             |       YES     NO             |
                             |         |       |            |
                             |         v       v            |
                             |    Task()    Direct          |
                             |    Invoke    Build           |
                             |         |       |            |
                             |         v       v            |
                             |      go build + vet          |
                             |      golangci-lint run       |
                             |      check_arch.sh           |
                             |      go test -race           |
                             +------------------------------+
```

---

## Clean Architecture Gate

The most important constraint in NoxCare-Go. All agents and the CI pipeline enforce these rules:

```text
+----------------------------------------------------------------------------------------+
|                       CLEAN ARCHITECTURE IMPORT RULES                                   |
+----------------------------------------------------------------------------------------+
|                                                                                         |
|   Layer          | Allowed Imports                                                      |
|   ---------------+-------------------------------------------------------------------  |
|   domain         | stdlib only -- zero internal, zero third-party                      |
|   port           | domain only                                                          |
|   app/service    | domain, port, config + third-party libs                             |
|   adapter        | app, domain, port, config, pkg + third-party -- never imported back |
|   bootstrap      | all layers -- assembly and DI only, zero business logic             |
|   cmd            | bootstrap only                                                       |
|   config         | stdlib + third-party (no internal imports)                          |
|   pkg            | stdlib only -- generic utilities with no domain knowledge           |
|                                                                                         |
|   Enforcement:   ./scripts/check_arch.sh  (runs on every PR, blocks on violations)     |
|                                                                                         |
+----------------------------------------------------------------------------------------+
```

### Why This Matters

- **Handlers** may never import repositories directly. They call services via port interfaces.
- **Domain** must be pure Go -- no Gin, no pgx, no Kafka imports.
- **Services** depend on interfaces (ports), never on concrete adapters.
- **Bootstrap** is the only place that wires concrete implementations to interfaces.

---

## The Agent Ecosystem

NoxCare-Go leverages **43 specialized agents** across 8 categories:

### By Category

| Category | Count | Key Agents | Specialization |
|----------|-------|------------|----------------|
| **Workflow** | 6 | brainstorm, define, design, build, ship, iterate | SDD phase execution |
| **Architect** | 6 | clean-arch-architect, api-architect, grpc-architect, system-designer, the-planner, meeting-analyst | System-level design |
| **Go Core** | 6 | go-developer, handler-builder, service-builder, repository-builder, middleware-builder, config-specialist | Go code generation |
| **API** | 6 | handler-builder, grpc-specialist, swagger-builder, rest-designer, auth-specialist, websocket-specialist | HTTP/gRPC/REST |
| **Data** | 6 | sqlc-specialist, migration-specialist, repository-builder, postgres-specialist, redis-specialist, db-architect | DB and queries |
| **Cloud** | 4 | docker-specialist, k8s-specialist, ci-cd-specialist, security-scanner | Infrastructure |
| **Observability** | 4 | kafka-specialist, metrics-specialist, tracing-specialist, logging-specialist | Platform concerns |
| **Test & Quality** | 5 | test-generator, integration-test-specialist, benchmark-specialist, load-test-specialist, code-reviewer | Quality assurance |

### Agent Structure

Each agent follows a standard structure for capability extraction:

```markdown
# {Agent Name}

> {One-line description} <- Used for matching

## Identity

| Attribute | Value |
|-----------|-------|
| **Role** | {Role name} <- Primary capability keyword
| **Model** | {opus/sonnet/haiku}
| **Phase** | {phase number and name}

## Core Capabilities <- Keywords for matching

## Process <- How it works

## Tools Available <- What it can use
```

### go_delegation Map (Build Phase)

```text
File Pattern                              -> Agent
internal/adapter/handler/http/*.go        -> handler-builder
internal/adapter/handler/grpc/*.go        -> grpc-specialist
internal/app/service/*.go                 -> service-builder
internal/adapter/repository/*.go          -> repository-builder
internal/adapter/middleware/http/*.go     -> middleware-builder
internal/adapter/middleware/grpc/*.go     -> grpc-specialist
internal/adapter/consumer/*.go            -> kafka-specialist
internal/port/*.go                        -> clean-arch-architect
internal/domain/*.go                      -> go-developer
db/query/*.sql                            -> sqlc-specialist
db/migration/*.sql                        -> migration-specialist
api/proto/*.proto                         -> grpc-specialist
deploy/k8s/*.yaml                         -> k8s-specialist
deploy/docker/*                           -> docker-specialist
.github/workflows/*.yaml                  -> ci-cd-specialist
*_test.go                                 -> test-generator
*_bench_test.go                           -> benchmark-specialist
integration/**/*_test.go                  -> integration-test-specialist
config/*.go                               -> config-specialist
pkg/**/*.go                               -> go-developer
cmd/docs/*                                -> swagger-builder
Makefile                                  -> ci-cd-specialist
.golangci.yml                             -> ci-cd-specialist
.gosec.json                               -> security-scanner
scripts/check_*.sh                        -> ci-cd-specialist
loadtest/*.ts                             -> benchmark-specialist
db/sqlc.yaml                              -> sqlc-specialist
```

---

## Knowledge Base Integration

NoxCare-Go integrates with curated Knowledge Base domains for the Go backend stack:

### Available Domains

| Domain | Focus |
|--------|-------|
| go-core | Go idioms, clean architecture, error handling, context |
| gin | HTTP routing, middleware, binding, response patterns |
| sqlc | Query generation, pgx patterns, type mapping |
| kafka | Sarama consumer/producer, consumer groups, DLQ |
| redis | go-redis caching, pub/sub, distributed locks |
| grpc | Protobuf, interceptors, streaming, deadlines |
| postgres | Transactions, migrations, pgx, LISTEN/NOTIFY |
| docker | Multi-stage builds, compose, health checks |
| k8s | Deployments, services, configmaps, HPA |
| testing | testify, gomock, testcontainers, race detection |
| swagger | swaggo annotations, OpenAPI spec, doc generation |
| clean-arch | Layer boundaries, dependency inversion, DI patterns |
| security | gosec, JWT, RBAC, input validation |
| observability | OpenTelemetry, Prometheus, structured logging (zap) |
| loadtest | k6 scripts, thresholds, scenarios |

### KB Flow

```text
DEFINE                    DESIGN                    BUILD
------                    ------                    -----

KB Domains:          ->    Read patterns:       ->    Agents consult:
- gin                      - handler-patterns        - kb/gin/patterns/
- sqlc                     - query-patterns           - kb/sqlc/patterns/
- kafka                    - consumer-patterns        - kb/kafka/patterns/
```

---

## Commands & Artifacts

### All Commands (23)

#### SDD Workflow (7)

| Command | Phase | Purpose | Model |
|---------|-------|---------|-------|
| `/brainstorm` | 0 | Explore ideas through collaborative dialogue | Opus |
| `/define` | 1 | Capture and validate requirements | Opus |
| `/design` | 2 | Create architecture + agent matching | Opus |
| `/build` | 3 | Execute with agent delegation | Sonnet |
| `/ship` | 4 | Archive with lessons learned | Haiku |
| `/iterate` | Any | Update documents mid-stream | Sonnet |
| `/create-pr` | -- | Create pull request with conventional commits | -- |

#### Go-Specific (10)

| Command | Purpose |
|---------|---------|
| `/handler` | Gin HTTP handler scaffolding (CRUD + validation) |
| `/service` | App service layer with use case orchestration |
| `/repository` | sqlc repository with pgx patterns |
| `/consumer` | Kafka consumer with error handling and DLQ |
| `/migration` | golang-migrate migration files |
| `/proto` | gRPC protobuf definition + server stub |
| `/test` | Go test suite (testify + gomock) |
| `/bench` | Benchmark test with pprof annotations |
| `/swagger` | swaggo annotation generation |
| `/loadtest` | k6 load test script |

#### Core & Utilities (6)

| Command | Purpose |
|---------|---------|
| `/create-kb` | Create a complete KB domain from scratch |
| `/review` | Go code review (clean arch + idiomatic Go) |
| `/meeting` | Meeting transcript analysis |
| `/memory` | Save session insights to storage |
| `/sync-context` | Update CLAUDE.md from codebase |
| `/readme-maker` | Generate README from codebase analysis |

### Artifact Lifecycle

```text
.claude/sdd/
+-- features/                          # Active work
|   +-- BRAINSTORM_{FEATURE}.md       # Phase 0 output
|   +-- DEFINE_{FEATURE}.md           # Phase 1 output
|   +-- DESIGN_{FEATURE}.md           # Phase 2 output
|
+-- reports/                           # Build outputs
|   +-- BUILD_REPORT_{FEATURE}.md     # Phase 3 output
|
+-- archive/                           # Completed work
    +-- {FEATURE}/
        +-- BRAINSTORM_{FEATURE}.md   # (if used)
        +-- DEFINE_{FEATURE}.md
        +-- DESIGN_{FEATURE}.md
        +-- BUILD_REPORT_{FEATURE}.md
        +-- SHIPPED_{DATE}.md         # Phase 4 output
```

### Key Artifact Sections

#### DESIGN (Agent Assignment + Layer Mapping)

```markdown
## Clean Architecture Mapping

| Component | Layer | Package Path |
|-----------|-------|--------------|
| UserHandler | adapter/handler | internal/adapter/handler/http/ |
| UserService | app/service | internal/app/service/ |
| UserPort | port | internal/port/ |
| UserRepository | adapter/repository | internal/adapter/repository/ |
| User (entity) | domain | internal/domain/ |

## File Manifest

| # | File | Action | Purpose | Agent | Dependencies |
|---|------|--------|---------|-------|--------------|
| 1 | internal/domain/user.go | Create | User entity | go-developer | None |
| 2 | internal/port/user_port.go | Create | User interfaces | clean-arch-architect | 1 |
| 3 | internal/app/service/user_service.go | Create | User use cases | service-builder | 1, 2 |
| 4 | internal/adapter/repository/user_repository.go | Create | Postgres impl | repository-builder | 2 |
| 5 | internal/adapter/handler/http/user_handler.go | Create | Gin handler | handler-builder | 2, 3 |
| 6 | user_handler_test.go | Create | Handler tests | test-generator | 5 |
```

#### BUILD_REPORT (Attribution)

```markdown
## Agent Contributions

| Agent | Files | Specialization Applied |
|-------|-------|------------------------|
| go-developer | 1 | Domain entity, value objects |
| clean-arch-architect | 2 | Port interfaces, DI contracts |
| service-builder | 3 | Use case orchestration |
| repository-builder | 4 | sqlc queries, pgx transactions |
| handler-builder | 5 | Gin routing, binding, responses |
| test-generator | 6 | testify suite, gomock stubs |
```

---

## Phase Details

### Phase 0: Brainstorm (Optional)

**Purpose:** Explore ideas through collaborative dialogue before capturing requirements.

**When to Use:**
- Vague idea that needs exploration
- Multiple possible approaches to consider
- Uncertain about scope, layer placement, or Go patterns
- Need to apply YAGNI before diving in

**When to Skip:**
- Clear requirements already known
- Simple CRUD endpoint
- Well-understood Kafka consumer pattern

**Input:** Raw idea, problem statement, or vague request.

**Output:** `BRAINSTORM_{FEATURE}.md` with:
- Discovery questions and answers
- 2-3 approaches explored with trade-offs
- Selected approach with reasoning
- Features removed (YAGNI applied)
- Draft requirements for /define

**Quality Gate:** Min 3 questions, 2+ approaches, 2+ validations, user confirmed

### Phase 1: Define

**Purpose:** Capture and validate requirements from any input.

**Input:** BRAINSTORM document, raw notes, emails, conversations, or direct requirements.

**Output:** `DEFINE_{FEATURE}.md` with:
- Problem statement
- Target users / API consumers
- Success criteria (measurable, e.g., p99 < 200ms)
- Acceptance tests (Given/When/Then)
- Technical Context (layer target, KB domains, API contract)
- Out of scope

**Quality Gate:** Clarity Score >= 12/15

### Phase 2: Design

**Purpose:** Create complete technical design with Clean Architecture enforcement and inline decisions.

**Input:** `DEFINE_{FEATURE}.md`

**Output:** `DESIGN_{FEATURE}.md` with:
- Architecture diagram (ASCII)
- Clean Architecture layer mapping
- Key decisions with rationale (inline ADRs)
- File manifest with agent assignments
- Code patterns (copy-paste ready Go)
- Testing strategy (unit + integration + race)

**Quality Gate:** Complete file manifest, all files have agents, no layer violations

### Phase 3: Build

**Purpose:** Execute implementation following the design with agent delegation and Go verification.

**Input:** `DESIGN_{FEATURE}.md`

**Output:**
- Code files (as specified in manifest)
- `BUILD_REPORT_{FEATURE}.md` with agent attribution

**Verification per file:**
```bash
go build ./...
go vet ./...
golangci-lint run {file}
```

**Full CI:**
```bash
gofmt -w . && go mod tidy
go vet ./...
./scripts/check_arch.sh
staticcheck ./...
golangci-lint run
go test -coverprofile=bin/coverage.out ./...
CGO_ENABLED=0 go build -o /dev/null ./cmd/api
```

**Quality Gate:** All tasks complete, all tests pass, no architecture violations

### Phase 4: Ship

**Purpose:** Archive completed feature with lessons learned.

**Input:** All feature artifacts

**Output:**
- `archive/{FEATURE}/` folder with all documents
- `SHIPPED_{DATE}.md` with lessons learned

---

## Quality Verification

### Document Quality Checklist

```text
COMPLETENESS
[ ] All required sections present
[ ] Technical Context filled (DEFINE)
[ ] Clean Architecture layer mapping documented (DESIGN)
[ ] Agent assignments complete (DESIGN)
[ ] Attribution documented (BUILD_REPORT)

ACCURACY
[ ] Clarity Score >= 12/15 (DEFINE)
[ ] All files have agents (DESIGN)
[ ] Layer assignments follow clean_architecture_gate (DESIGN)
[ ] Dependencies mapped (DESIGN)
[ ] Tests verified (BUILD)

TRACEABILITY
[ ] Phase progression documented
[ ] Cross-references valid
[ ] Lessons captured (SHIPPED)
```

### Go Quality Checklist

```text
BUILD QUALITY
[ ] go build ./... passes
[ ] go vet ./... passes
[ ] go test -race ./... passes
[ ] golangci-lint run passes (0 errors)
[ ] ./scripts/check_arch.sh passes (no violations)
[ ] CGO_ENABLED=0 go build -o /dev/null ./cmd/api

CODE QUALITY
[ ] No inline comments (code is self-documenting)
[ ] No ignored errors (_ = err is forbidden)
[ ] No global mutable state
[ ] No panic() outside of main/bootstrap
[ ] No hardcoded connection strings or secrets
[ ] Interfaces defined at consumption site (port layer)

ARCHITECTURE QUALITY
[ ] domain imports: stdlib only
[ ] port imports: domain only
[ ] app/service imports: domain, port, config, third-party
[ ] adapter imports: app, domain, port, config, pkg, third-party
[ ] bootstrap: assembly only, no business logic
[ ] cmd imports: bootstrap only
```

---

## Anti-Patterns

### Never Do

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| **Skipping Define** | "I know what to build" | Even clear requirements benefit from layer mapping |
| **Over-Brainstorming** | 10 questions, 5 approaches | Max 5 questions, 3 approaches. Apply YAGNI |
| **Handler -> Repository** | Bypassing service + port layer | Always route through port interfaces |
| **Domain importing Gin** | Leaks framework into core logic | Domain layer: stdlib only |
| **Generic Agent Assignment** | All files -> `(general)` | Use go_delegation map |
| **Skipping /iterate** | "I'll just edit the code" | Changes should flow through specs |
| **Ignoring Attribution** | Not checking BUILD_REPORT | Attribution reveals quality patterns |
| **panic() in library code** | Crashes caller's goroutine | Return errors, never panic in non-main packages |

### Warning Signs

```text
You're about to make a mistake if:
- You're assigning (general) to most files
- Your DEFINE has no Technical Context
- Your Clarity Score is below 12/15
- Your DESIGN has no layer mapping table
- Your handler is importing a repository directly
- Your domain package has a third-party import
- Your BUILD_REPORT has no agent attribution
- You're skipping phases "to save time"
- Your code has fmt.Println in production paths
```

---

## Extending NoxCare-Go

### Adding a New Agent

1. **Create the agent file:**

```bash
# Location: .claude/agents/{category}/{agent-name}.md
touch .claude/agents/go-core/cache-specialist.md
```

2. **Follow the standard structure:**

```markdown
# Cache Specialist

> Expert in go-redis caching patterns, cache-aside, distributed locks, and TTL strategies

## Identity

| Attribute | Value |
|-----------|-------|
| **Role** | Cache Engineer |
| **Model** | sonnet |
| **Phase** | 3 - Build |

## Core Capabilities

| Capability | Description |
|------------|-------------|
| **Cache-Aside** | Read-through and write-through patterns |
| **Distributed Lock** | SETNX-based locks with expiry |
| **Invalidation** | Tag-based and TTL invalidation strategies |
```

3. **The agent is automatically discoverable** -- Design phase will find it via `Glob(.claude/agents/**/*.md)`

### Adding a New KB Domain

1. **Use the command:**

```bash
/create-kb "otel"
```

2. **Or manually create the structure:**

```bash
mkdir -p .claude/kb/otel/{concepts,patterns}
touch .claude/kb/otel/{index.md,quick-reference.md}
```

3. **Reference in DEFINE Technical Context:**

```markdown
| **KB Domains** | otel, grpc |
```

---

## Quick Start

### Full Pipeline (Go Backend Feature)

```bash
# Phase 0: Explore the idea (optional)
/brainstorm "Build Kafka consumer for order events with idempotency"

# Phase 1: Define requirements with Technical Context
/define .claude/sdd/features/BRAINSTORM_ORDER_CONSUMER.md

# Phase 2: Design with Agent Matching + Clean Arch Gate
/design .claude/sdd/features/DEFINE_ORDER_CONSUMER.md

# Phase 3: Build with Agent Delegation
/build .claude/sdd/features/DESIGN_ORDER_CONSUMER.md

# Phase 4: Archive
/ship .claude/sdd/features/DEFINE_ORDER_CONSUMER.md
```

### Using Go-Specific Commands

```bash
# Scaffold a Gin handler
/handler "CRUD endpoints for product resource"

# Generate sqlc repository with pagination
/repository "product queries with cursor pagination"

# Scaffold Kafka consumer with DLQ
/consumer "order-events topic with dead-letter queue"

# Generate gRPC service
/proto "notification service with streaming"
```

### Making Changes Mid-Stream

```bash
# Update DEFINE with new requirement
/iterate DEFINE_ORDER_CONSUMER.md "Add dead-letter queue support"

# Update DESIGN with architecture change
/iterate DESIGN_ORDER_CONSUMER.md "Switch from sync to async processing"
```

---

## References

| Resource | Location |
|----------|----------|
| SDD Index | `.claude/sdd/_index.md` |
| Architecture | `.claude/sdd/architecture/ARCHITECTURE.md` |
| Workflow Contracts | `.claude/sdd/architecture/WORKFLOW_CONTRACTS.yaml` |
| Templates | `.claude/sdd/templates/` |
| Archive | `.claude/sdd/archive/` |
| Agents (43) | `.claude/agents/` |
| Knowledge Base | `.claude/kb/` |
| SDD Commands | `.claude/commands/workflow/` |
| Go Commands | `.claude/commands/go/` |
| Core Commands | `.claude/commands/core/` |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-03-27 | Initial NoxCare-Go port from AgentSpec v2.1.0 with Go Clean Architecture |

---

## The Agentic-First Vision

NoxCare-Go is designed for a future where:

1. **AI models are specialists** -- Not one-size-fits-all, but domain experts
2. **Specifications are executable** -- Not just documentation, but orchestration
3. **Quality comes from expertise** -- Specialists produce better Go code than generalists
4. **Architecture is enforced** -- Clean Architecture gates prevent layer violations automatically
5. **Traceability is automatic** -- Every file has an owner, every decision has rationale
6. **Go is first-class** -- Idiomatic patterns, explicit errors, and no shortcuts

**NoxCare-Go is not just a specification framework. It's an AI team orchestration system for Go backend development.**

```text
+-------------------------------------------------------------+
|                                                               |
|   "Tell me WHAT to build, I'll figure out WHO should         |
|    build it -- in the right Clean Architecture layer."       |
|                                                               |
|                         -- NoxCare-Go v1.0                    |
|                                                               |
+-------------------------------------------------------------+
```

---

*Document Updated: 2026-03-27 | NoxCare-Go v1.0.0*
