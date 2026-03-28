# Bundle-Go Plugin Design Spec

> Claude Code plugin for Go Backend/API development with Clean Architecture, SDD workflow, and 43 specialized agents.

**Date:** 2026-03-27
**Status:** Draft
**Module:** `github.com/plussystemtechnology/bundle-go` (plugin canonical name; target project uses `github.com/plussystemtechnology/is-person`)

---

## 1. Overview

Bundle-Go is a plug-and-play Claude Code plugin for Go Backend/API development. It ports the AgentSpec architecture (5-phase SDD workflow, agent tiers, KB-First resolution, confidence scoring) and replaces the data engineering domain with Go backend/API patterns following Clean Architecture and SOLID principles.

### Stack

- **Router:** Gin
- **SQL Codegen:** sqlc
- **DB Driver:** pgx
- **Database:** PostgreSQL
- **Cache:** Redis
- **Messaging:** Apache Kafka
- **Deploy:** Docker + Kubernetes
- **Observability:** Prometheus + Grafana + OpenTelemetry
- **Logging:** go.uber.org/zap (structured, high-performance)
- **Lint:** golangci-lint + go vet + staticcheck
- **Security:** gosec + govulncheck
- **Auth:** golang-jwt/v5 + go-oidc/v3 + oauth2 + Vault
- **Docs:** swaggo/swag + gin-swagger (OpenAPI/Swagger)
- **Testing Tools:** testify + miniredis + goleak + gotestsum + gocover-cobertura + k6
- **Resilience:** cenkalti/backoff, hashicorp/golang-lru
- **Observability Bridges:** otelpgx + otelgin + otelgrpc + otelzap + lumberjack (log rotation)

### Key Numbers

| Metric | Count |
|--------|-------|
| Agents | 43 |
| Agent Categories | 8 |
| KB Domains | 22 |
| Slash Commands | 23 (7 SDD + 10 Go + 6 core) |
| SDD Templates | 5 |
| Agent Tiers | 3 (T1/T2/T3) |

---

## 2. Directory Structure

```text
bundle-go/
├── .claude/
│   ├── agents/                    # 43 specialized agents
│   │   ├── workflow/              # 6 SDD phase agents
│   │   ├── architect/             # 6 system-level design
│   │   ├── go-core/              # 6 Clean Arch layer builders
│   │   ├── api/                   # 6 API specialists (REST + gRPC + Swagger)
│   │   ├── data/                  # 6 data/messaging specialists
│   │   ├── cloud/                 # 4 infra/deploy
│   │   ├── observability/         # 4 monitoring/tracing
│   │   ├── test/                  # 5 testing/quality/review
│   │   ├── _template.md           # Base template T1/T2/T3
│   │   └── README.md              # Agent routing + escalation map
│   │
│   ├── commands/                  # 23 slash commands
│   │   ├── workflow/              # 7 SDD commands
│   │   ├── go-engineering/        # 10 Go-specific commands
│   │   ├── core/                  # 4 utility commands
│   │   ├── knowledge/             # 1 KB command
│   │   └── review/                # 1 review command
│   │
│   ├── sdd/                       # SDD framework
│   │   ├── _index.md
│   │   ├── README.md
│   │   ├── architecture/
│   │   │   ├── ARCHITECTURE.md
│   │   │   └── WORKFLOW_CONTRACTS.yaml
│   │   ├── templates/
│   │   ├── features/
│   │   ├── reports/
│   │   └── archive/
│   │
│   ├── kb/                        # 22 KB domains
│   │   ├── _index.yaml
│   │   ├── _templates/
│   │   ├── clean-architecture/
│   │   ├── gin/
│   │   ├── sqlc/
│   │   ├── pgx/
│   │   ├── cache/
│   │   ├── kafka/
│   │   ├── grpc/
│   │   ├── auth/
│   │   ├── swagger/
│   │   ├── testing/
│   │   ├── middleware/
│   │   ├── migrations/
│   │   ├── docker/
│   │   ├── kubernetes/
│   │   ├── prometheus/
│   │   ├── otel/
│   │   ├── zap/
│   │   ├── error-handling/
│   │   ├── concurrency/
│   │   ├── security/
│   │   ├── ci-cd/
│   │   └── go-patterns/
│   │
│   ├── settings.json
│   └── storage/
│
├── CLAUDE.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── README.md
└── LICENSE
```

---

## 3. Agent Catalog (43 agents)

### 3.1 Workflow (6)

| Agent | Tier | Model | Purpose |
|-------|------|-------|---------|
| `brainstorm-agent` | T2 | opus | Explore ideas through collaborative dialogue (Phase 0) |
| `define-agent` | T2 | opus | Capture requirements with clarity scoring (Phase 1) |
| `design-agent` | T2 | opus | Create technical architecture with file manifest (Phase 2) |
| `build-agent` | T2 | sonnet | Execute implementation with agent delegation (Phase 3) |
| `ship-agent` | T2 | haiku | Archive with lessons learned (Phase 4) |
| `iterate-agent` | T2 | sonnet | Update documents with cascade awareness (Cross-phase) |

### 3.2 Architect (6)

| Agent | Tier | Model | Purpose |
|-------|------|-------|---------|
| `api-architect` | T2 | opus | REST/gRPC API design, endpoint planning |
| `schema-designer` | T2 | sonnet | DB schemas, ERD, indexes, constraints |
| `clean-arch-architect` | T2 | opus | Layer design, DIP, interface contracts |
| `pipeline-architect` | T2 | sonnet | Kafka pipelines, event-driven design |
| `platform-engineer` | T1 | sonnet | Infra decisions, scaling, cost |
| `the-planner` | T2 | opus | Strategic plans, decomposition |

### 3.3 Go Core (6)

| Agent | Tier | Model | Purpose |
|-------|------|-------|---------|
| `go-developer` | T1 | sonnet | Idiomatic Go, stdlib, patterns |
| `handler-builder` | T2 | sonnet | Gin handlers, binding, validation, response |
| `service-builder` | T2 | sonnet | Business logic, use cases, transactions |
| `repository-builder` | T2 | sonnet | sqlc queries, pgx repos, CRUD |
| `middleware-builder` | T2 | sonnet | Auth, CORS, rate-limit, recovery |
| `config-specialist` | T1 | sonnet | Viper/env config, functional options |

### 3.4 API (6)

| Agent | Tier | Model | Purpose |
|-------|------|-------|---------|
| `gin-specialist` | T3 | sonnet | Gin routes, groups, middleware chains |
| `grpc-specialist` | T3 | sonnet | Protobuf, interceptors, streaming |
| `rest-designer` | T2 | sonnet | OpenAPI, versioning, pagination, HATEOAS |
| `auth-specialist` | T2 | opus | JWT (golang-jwt), OIDC (go-oidc), OAuth2, Vault secrets, RBAC |
| `swagger-builder` | T1 | sonnet | swaggo annotations, gin-swagger, OpenAPI gen, docs validation |
| `api-gateway-specialist` | T1 | sonnet | Reverse proxy, rate-limit, routing |

### 3.5 Data (6)

| Agent | Tier | Model | Purpose |
|-------|------|-------|---------|
| `sqlc-specialist` | T3 | sonnet | sqlc queries, batch, transactions |
| `pgx-specialist` | T3 | sonnet | Connection pools, prepared stmts, COPY |
| `migration-specialist` | T2 | sonnet | golang-migrate, versioning, container-based runner |
| `kafka-specialist` | T3 | sonnet | Consumer groups, producers, exactly-once |
| `cache-specialist` | T2 | sonnet | Redis, Memcache, LRU cache patterns, pub/sub, sessions, rate-limit |
| `event-store-specialist` | T1 | sonnet | Event sourcing, outbox pattern |

### 3.6 Cloud (4)

| Agent | Tier | Model | Purpose |
|-------|------|-------|---------|
| `k8s-specialist` | T3 | sonnet | Deployments, HPA, configmaps, secrets |
| `docker-specialist` | T2 | sonnet | Multi-stage builds, distroless, compose |
| `aws-deployer` | T2 | sonnet | ECS/EKS, ECR, ALB, RDS, secrets |
| `ci-cd-specialist` | T3 | sonnet | GitHub Actions, Makefile, lint, test |

### 3.7 Observability (4)

| Agent | Tier | Model | Purpose |
|-------|------|-------|---------|
| `prometheus-specialist` | T2 | sonnet | Metrics, counters, histograms |
| `otel-specialist` | T3 | sonnet | Traces, spans, baggage, collector |
| `logging-specialist` | T1 | sonnet | zap structured logging, log levels, context fields |
| `health-check-specialist` | T1 | sonnet | Liveness, readiness, startup probes |

### 3.8 Test & Quality (5)

| Agent | Tier | Model | Purpose |
|-------|------|-------|---------|
| `test-generator` | T2 | sonnet | Table-driven tests, mocks (gomock), fixtures, miniredis, goleak |
| `benchmark-specialist` | T1 | sonnet | Benchmarks, pprof, allocations, k6 load tests |
| `integration-test-specialist` | T2 | sonnet | testcontainers, DB tests, API tests, gotestsum |
| `security-scanner` | T1 | sonnet | gosec, govulncheck, security linting, OWASP checks |
| `code-reviewer` | T2 | sonnet | Code quality, architecture boundaries, anti-patterns |

---

## 4. Escalation Map

```text
Workflow <-> Go Core:
  build-agent -> handler-builder, service-builder, repository-builder (layer delegation)
  design-agent -> clean-arch-architect (layer design), api-architect (API design)
  define-agent -> schema-designer (DB modeling)

Go Core <-> Data:
  repository-builder -> sqlc-specialist (queries), pgx-specialist (pool/transactions)
  service-builder -> kafka-specialist (events), cache-specialist (cache)

Go Core <-> API:
  handler-builder -> gin-specialist (routes), auth-specialist (auth middleware)
  handler-builder -> swagger-builder (endpoint annotations)
  middleware-builder -> auth-specialist (JWT/OIDC/OAuth), gin-specialist (middleware chains)

API <-> Data:
  grpc-specialist -> sqlc-specialist (query layer), kafka-specialist (event streaming)

API Internal:
  swagger-builder -> gin-specialist (route metadata for docs)
  auth-specialist -> config-specialist (Vault/env secrets config)

Test & Quality <-> All:
  test-generator -> handler-builder (HTTP tests), repository-builder (DB tests)
  integration-test-specialist -> docker-specialist (testcontainers)
  security-scanner -> ci-cd-specialist (CI security gates)
  code-reviewer -> all layers (cross-cutting review)

Cloud <-> Observability:
  k8s-specialist -> health-check-specialist (probes), prometheus-specialist (metrics)
  docker-specialist -> ci-cd-specialist (CI builds)
  otel-specialist -> logging-specialist (correlation via otelzap)

Architect <-> All:
  clean-arch-architect -> go-core/* (layer contracts)
  pipeline-architect -> kafka-specialist + cache-specialist (event flows)
  the-planner -> any agent (strategic decomposition)

Workflow (cross-phase):
  brainstorm-agent -> define-agent (ready for define)
  iterate-agent -> define-agent, design-agent, build-agent (cascade updates)
  ship-agent -> build-agent (pre-ship checklist verification)

Leaf Agents (invoked via Build Delegation or direct command only):
  platform-engineer        (invoked by the-planner for infra decisions)
  api-gateway-specialist   (invoked by api-architect for gateway design)
  rest-designer            (invoked by api-architect for OpenAPI specs)
  swagger-builder          (invoked by handler-builder or build-agent for docs gen)
  event-store-specialist   (invoked by pipeline-architect for event sourcing)
  aws-deployer             (invoked by ci-cd-specialist for AWS deploy)
  benchmark-specialist     (invoked by test-generator for perf tests)
  security-scanner         (invoked by code-reviewer or ci-cd-specialist)
  config-specialist        (invoked by build-agent for config files)
```

---

## 5. Commands (23)

### 5.1 SDD Workflow (7)

| Command | Phase | Purpose | Model |
|---------|-------|---------|-------|
| `/brainstorm` | 0 | Explore ideas through collaborative dialogue | Opus |
| `/define` | 1 | Capture and validate requirements | Opus |
| `/design` | 2 | Create architecture and specification | Opus |
| `/build` | 3 | Execute implementation with verification | Sonnet |
| `/ship` | 4 | Archive with lessons learned | Haiku |
| `/iterate` | Any | Update documents when changes needed | Sonnet |
| `/create-pr` | -- | Create pull request (thin wrapper around `gh pr create`) | Sonnet |

### 5.2 Go Engineering (10)

| Command | Purpose | Primary Agent | KB Domains |
|---------|---------|---------------|------------|
| `/handler` | Scaffold Gin handler | `handler-builder` | gin, middleware, error-handling |
| `/service` | Scaffold service layer | `service-builder` | clean-architecture, error-handling |
| `/repository` | Scaffold repository + sqlc queries | `repository-builder` | sqlc, pgx, clean-architecture |
| `/migration` | Database migration scaffolding | `migration-specialist` | migrations, pgx |
| `/middleware` | Middleware scaffolding | `middleware-builder` | middleware, gin, auth, security |
| `/proto` | Protobuf/gRPC scaffolding | `grpc-specialist` | grpc, go-patterns |
| `/kafka-consumer` | Kafka consumer scaffolding | `kafka-specialist` | kafka, error-handling, concurrency |
| `/swagger` | Generate/validate Swagger docs | `swagger-builder` | swagger, gin |
| `/security-scan` | Run gosec + govulncheck analysis | `security-scanner` | security, ci-cd |
| `/go-review` | Go-specific code review | `code-reviewer` | go-patterns, testing, security |

### 5.3 Core & Utilities (6)

| Command | Purpose |
|---------|---------|
| `/create-kb` | Create KB domain |
| `/review` | Code review |
| `/meeting` | Meeting transcript analysis |
| `/memory` | Save session insights |
| `/sync-context` | Update CLAUDE.md |
| `/readme-maker` | Generate README |

---

## 6. KB Domains (22)

| # | Domain | Contents |
|---|--------|----------|
| 1 | `clean-architecture/` | Layer rules, DIP, SOLID, dependency graph, interface segregation, check_arch.sh, check_env_usage.sh |
| 2 | `gin/` | Routes, middleware, binding, validator/v10, groups, error responses, json-iterator |
| 3 | `sqlc/` | Query patterns, batch ops, custom types, codegen config |
| 4 | `pgx/` | Pool config, prepared stmts, COPY, transactions, conn lifecycle, otelpgx instrumentation |
| 5 | `cache/` | Redis (go-redis/v9): cache-aside, write-through, pub/sub, sessions, rate-limit, TTL; Memcache (gomemcache): fallback cache; golang-lru: in-memory LRU |
| 6 | `kafka/` | Consumer groups, producers, exactly-once, dead letters, schemas, segmentio/kafka-go |
| 7 | `grpc/` | Protobuf style, interceptors, streaming, health, reflection, otelgrpc |
| 8 | `auth/` | JWT (golang-jwt/v5), OIDC (go-oidc/v3), OAuth2, Vault secrets, RBAC, session mgmt |
| 9 | `swagger/` | swaggo annotations, gin-swagger UI, swag init, OpenAPI 3.0, gen-docs-check, yaml/json output |
| 10 | `testing/` | Table-driven, gomock (go.uber.org/mock preferred over deprecated golang/mock), testify, miniredis, testcontainers, -race, goleak, gotestsum, gocover-cobertura, golden files, fuzzing, k6 load tests |
| 11 | `middleware/` | Auth chain, CORS (gin-contrib/cors), rate-limit (x/time token bucket), recovery, request-id (google/uuid), logging, otelgin, otelhttp |
| 12 | `migrations/` | golang-migrate, idempotent DDL, rollback, seed data, container-based migration runner |
| 13 | `docker/` | Multi-stage builds, distroless, .dockerignore, compose, health, multi-arch (amd64+arm64) |
| 14 | `kubernetes/` | Deployments, services, HPA, configmaps, secrets, probes |
| 15 | `prometheus/` | Counters, histograms, gauges, alerting rules, custom collectors, SigNoz integration |
| 16 | `otel/` | Traces, spans, propagation (b3 + W3C), collector config, sampling, otelpgx, otelgin, otelgrpc, otelzap, otelhttp, OTLP exporters (gRPC + HTTP), host/runtime metrics, minsev log processor, OTel native logging (otel/log + sdk/log) |
| 17 | `zap/` | Logger setup, sugar vs structured, log levels, context fields, sampling, sink config, lumberjack rotation, otelzap bridge, zapr adapter |
| 18 | `error-handling/` | Sentinel errors, %w wrapping, custom types, stack traces, error docs check |
| 19 | `concurrency/` | Goroutines, channels, errgroup (x/sync), singleflight, context cancel, sync primitives, backoff/retry (cenkalti/backoff) |
| 20 | `security/` | gosec, govulncheck, input validation (validator/v10), OWASP Go, secrets hygiene, .gosec.json config |
| 21 | `ci-cd/` | GitHub Actions, Makefile targets (ci/ci-full), golangci-lint config, release automation, install_tool_if_missing pattern |
| 22 | `go-patterns/` | Functional options, generics, interfaces, DI, builder pattern, google/uuid, fsnotify, etcd service discovery |

Each KB domain follows this structure:

```text
.claude/kb/{domain}/
├── index.md            # Domain overview, topic headings
├── quick-reference.md  # Decision matrices, cheat sheet
├── concepts/           # Core concepts (3-6 files)
└── patterns/           # Implementation patterns with code (3-6 files)
```

---

## 7. SDD Workflow (Adapted for Go)

### 7.1 Five-Phase Pipeline

```text
Phase 0: /brainstorm  -> BRAINSTORM_{FEATURE}.md     (optional)
Phase 1: /define      -> DEFINE_{FEATURE}.md
Phase 2: /design      -> DESIGN_{FEATURE}.md
Phase 3: /build       -> Code + BUILD_REPORT_{FEATURE}.md
Phase 4: /ship        -> archive/{FEATURE}/SHIPPED_{DATE}.md
         /iterate     -> Update any phase document (cross-phase)
```

### 7.2 Quality Gates (Go-adapted)

**Phase 0: Brainstorm**
- Min 3 discovery questions asked
- 2-3 approaches explored with trade-offs
- YAGNI applied (features removed)
- User confirmed selected approach

**Phase 1: Define**
- Clarity Score >= 12/15
- Acceptance tests (Given/When/Then)
- Technical Context: Go version, Clean Arch layers, KB domains

**Phase 2: Design**
- Architecture diagram (ASCII) with Clean Arch layers
- File manifest with agent assignments
- Interface contracts defined (ports)
- Code patterns copy-paste ready (idiomatic Go)
- go.mod dependencies listed
- Testing strategy (unit + integration + benchmark)

**Phase 3: Build**
- All files from manifest created
- Per-file: `go build`, `go vet`, `golangci-lint run`
- Full (mirrors `make ci`): `gofmt -w .`, `go vet ./...`, `./scripts/check_arch.sh`, `staticcheck ./...`, `golangci-lint run`, gen-docs-check (temp dir + diff), `go test -coverprofile=bin/coverage.out ./...`, `go build -o /dev/null ./cmd/api`
- Security (mirrors `make security`): `gosec -exclude-generated -conf .gosec.json -severity=high ./...`, `./scripts/check_govuln.sh`
- Architecture: `check_arch.sh` (import boundary enforcement), `check_env_usage.sh` (no direct env access in adapters)
- No TODO comments
- BUILD_REPORT generated

**Phase 4: Ship**
- BUILD_REPORT 100% complete
- All tests passing (unit + integration + race detector)
- Security scan clean (gosec + govulncheck)
- Swagger docs up-to-date (gen-docs-check)
- Archive created with SHIPPED document

### 7.3 Build Delegation Map

| File Pattern | Delegate To |
|-------------|-------------|
| `internal/adapter/handler/http/*.go` | `handler-builder` |
| `internal/adapter/handler/grpc/*.go` | `grpc-specialist` |
| `internal/app/service/*.go` | `service-builder` |
| `internal/adapter/repository/*.go` | `repository-builder` |
| `internal/adapter/middleware/http/*.go` | `middleware-builder` |
| `internal/adapter/middleware/grpc/*.go` | `grpc-specialist` |
| `internal/adapter/consumer/*.go` | `kafka-specialist` |
| `internal/port/*.go` | `clean-arch-architect` |
| `internal/domain/*.go` | `go-developer` |
| `db/query/*.sql` | `sqlc-specialist` |
| `db/migration/*.sql` | `migration-specialist` |
| `api/proto/*.proto` | `grpc-specialist` |
| `deploy/k8s/*.yaml` | `k8s-specialist` |
| `deploy/docker/*` | `docker-specialist` |
| `deploy/docker-compose-signoz.yml` | `otel-specialist` |
| `docs/signoz/*` | `prometheus-specialist` |
| `.github/workflows/*.yaml` | `ci-cd-specialist` |
| `*_test.go` | `test-generator` |
| `*_bench_test.go` | `benchmark-specialist` |
| `integration/**/*_test.go` | `integration-test-specialist` |
| `config/*.go` | `config-specialist` |
| `pkg/**/*.go` | `go-developer` |
| `cmd/docs/*` | `swagger-builder` |
| `Makefile` | `ci-cd-specialist` |
| `.golangci.yml` | `ci-cd-specialist` |
| `.gosec.json` | `security-scanner` |
| `scripts/check_*.sh` | `ci-cd-specialist` |
| `loadtest/*.ts` | `benchmark-specialist` |
| `db/sqlc.yaml` | `sqlc-specialist` |

### 7.4 Verification Commands

```yaml
per_file:
  - "go build ./..."
  - "go vet ./..."
  - "golangci-lint run {file}"

full_ci:  # mirrors `make ci` = fmt vet staticcheck lint gen-docs-check test build
  - "gofmt -w . && go mod tidy"
  - "go vet ./..."
  - "./scripts/check_arch.sh"                                          # architecture boundary enforcement
  - "staticcheck ./..."
  - "golangci-lint run"
  - "swag init -g ./cmd/api/main.go -o /tmp/swag && diff -u cmd/docs/swagger.yaml /tmp/swag/swagger.yaml"  # gen-docs-check
  - "go test -coverprofile=bin/coverage.out ./..."
  - "CGO_ENABLED=0 go build -o /dev/null ./cmd/api"

full_ci_extended:  # mirrors `make ci-full` = ci + test-integration + security + coverage
  - "go test -tags=integration -timeout=15m ./integration/..."
  - "gosec -exclude-generated -conf .gosec.json -severity=high ./..."
  - "./scripts/check_govuln.sh"
  - "go tool cover -html=bin/coverage.out -o bin/coverage.html"

standalone:  # not in ci-full, run explicitly
  - "CGO_ENABLED=1 go test -race ./..."       # make test-race (opt-in)
  - "go test -bench=. -benchmem ./..."         # make bench

architecture_checks:
  - "./scripts/check_arch.sh"              # import boundary enforcement
  - "./scripts/check_env_usage.sh"         # no direct os.Getenv in adapters
  - "./scripts/check_logger_context.sh"    # structured logger with context
  - "./scripts/check_metrics_doc.sh"       # metrics documented
  - "./scripts/check_error_docs.sh"        # error codes documented
  - "./scripts/check_govuln.sh"            # vulnerability scan wrapper
  - "./scripts/generate_env_docs.sh"       # env documentation generator
```

---

## 8. Clean Architecture Enforcement

### 8.1 Layer Dependencies

```text
internal/domain/        (no internal imports, stdlib only)
  ^
internal/port/          (imports domain only — interface definitions)
  ^
internal/app/           (imports domain, port, config — plus third-party libs)
  ^
internal/adapter/       (imports app/domain/port, config, pkg — NEVER imported back)
  ^
internal/bootstrap/     (all layers — assembly and DI ONLY, zero business logic)
  ^
cmd/                    (entry point, calls bootstrap only)

Cross-cutting packages (outside the layer hierarchy):
  config/               (stdlib + third-party only, no internal imports — any layer may import)
  pkg/                  (stdlib only, generic utilities with no domain knowledge — any layer may import)
```

**Note:** Import rules govern *internal* package dependencies. Third-party imports (e.g., `gin`, `pgx`, `kafka`) are allowed at all layers except `domain`, which is stdlib-only.

### 8.2 Project Structure (Generated Code)

```text
project/
├── cmd/
│   ├── api/
│   │   └── main.go
│   └── docs/                     # Generated Swagger docs (swag init output)
│       └── swagger.yaml
├── internal/
│   ├── domain/
│   │   ├── entity/
│   │   └── vo/
│   ├── port/
│   │   ├── input/                 # Use case interfaces
│   │   └── output/                # Repository interfaces
│   ├── app/
│   │   └── service/
│   ├── adapter/
│   │   ├── handler/
│   │   │   ├── http/              # Gin handlers + router
│   │   │   └── grpc/              # gRPC servers + setup
│   │   ├── repository/            # sqlc/pgx implementations
│   │   ├── middleware/
│   │   │   ├── http/              # Gin middlewares
│   │   │   └── grpc/              # gRPC interceptors
│   │   └── consumer/              # Kafka consumers
│   └── bootstrap/
│       ├── app.go                 # DI assembly
│       ├── http_server.go         # Gin engine + routes
│       └── grpc_server.go         # gRPC server + interceptors
├── db/
│   ├── query/                     # sqlc SQL files
│   ├── migration/                 # golang-migrate migrations
│   └── sqlc.yaml
├── api/
│   └── proto/                     # Protobuf definitions
├── deploy/
│   ├── docker/
│   ├── docker-compose-signoz.yml  # SigNoz observability stack
│   └── k8s/
├── config/
├── pkg/                           # Shared utilities (exported)
├── scripts/                      # Governance and automation scripts
│   ├── check_arch.sh             # Import boundary enforcement
│   ├── check_env_usage.sh        # No direct env access in adapters
│   ├── check_logger_context.sh   # Logger context usage
│   ├── check_metrics_doc.sh      # Metrics documentation
│   ├── check_error_docs.sh       # Error code documentation
│   ├── check_govuln.sh           # Vulnerability scan wrapper
│   ├── generate_env_docs.sh      # Environment documentation generator
│   ├── import_dashboards.sh      # SigNoz dashboard import
│   ├── import_alerts.sh          # SigNoz alert import
│   ├── export_dashboards.sh      # SigNoz dashboard export
│   └── setup-codex.sh            # Tool installation for offline environments
├── integration/                  # Integration tests (run with -tags=integration)
├── loadtest/                     # k6 load test scripts (.ts)
├── docs/
│   └── signoz/                   # SigNoz dashboards and alert definitions
├── go.mod
├── Makefile
├── .golangci.yml
└── .gosec.json
```

### 8.3 Import Rules

```yaml
clean_architecture_gate:
  domain_imports: "stdlib only, zero internal imports, zero third-party imports"
  port_imports: "domain only"
  app_imports: "domain, port, config + third-party libs"
  adapter_imports: "app, domain, port, config, pkg + third-party libs — never imported back"
  bootstrap_imports: "all layers — assembly and DI only, zero business logic"
  cmd_imports: "bootstrap only"
  config_imports: "stdlib + third-party only, no internal imports"
  pkg_imports: "stdlib only, generic utilities with no domain knowledge"
```

---

## 9. Agent Template (Go-adapted _template.md)

### 9.0 Agent Tier Definitions

| Tier | Name | Lines | Purpose | Examples |
|------|------|-------|---------|----------|
| **T1** | Utility | 80-150 | Single-concern tools, lightweight helpers | `go-developer`, `config-specialist`, `logging-specialist` |
| **T2** | Domain Expert | 150-350 | Specialists with KB domains, structured decision-making | `handler-builder`, `service-builder`, `code-reviewer` |
| **T3** | Platform Specialist | 350-600 | Deep platform expertise, MCP dependencies, error recovery | `gin-specialist`, `k8s-specialist`, `otel-specialist` |

### 9.1 Confidence Scoring

Agents calculate confidence from evidence, never self-assess.

**Agreement Matrix:**

```text
                 | MCP AGREES     | MCP DISAGREES  | MCP SILENT     |
-----------------+----------------+----------------+----------------+
KB HAS PATTERN   | HIGH (0.95)    | CONFLICT(0.50) | MEDIUM (0.75)  |
                 | -> Execute     | -> Investigate | -> Proceed     |
-----------------+----------------+----------------+----------------+
KB SILENT        | MCP-ONLY(0.85) | N/A            | LOW (0.50)     |
                 | -> Proceed     |                | -> Ask User    |
```

**Impact Tiers:**

| Tier | Threshold | Action if Below | Examples |
|------|-----------|-----------------|----------|
| CRITICAL | 0.95 | REFUSE + explain | DB migrations, production config, delete ops |
| IMPORTANT | 0.90 | ASK user first | Service creation, auth config, Kafka topics |
| STANDARD | 0.85 | PROCEED + caveat | Code generation, documentation |
| ADVISORY | 0.75 | PROCEED freely | Explanations, comparisons |

**Confidence Modifiers:**

| Modifier | Value | When |
|----------|-------|------|
| Codebase example found | +0.10 | Real implementation exists in project |
| Multiple sources agree | +0.05 | KB + MCP + codebase aligned |
| Breaking change / version mismatch | -0.15 | Version-specific risk detected |
| No working examples | -0.05 | Theory only, no code to reference |

### 9.2 Section-by-Tier Matrix

All 43 agents inherit from `_template.md` with 12 sections:

| # | Section | T1 | T2 | T3 |
|---|---------|:--:|:--:|:--:|
| 1 | Frontmatter | Required | Required | Required |
| 2 | Identity | Required | Required | Required |
| 3 | Knowledge Resolution | Compact | Full + Agreement Matrix | Full + Sources + Decision Tree |
| 4 | Capabilities | 2-4 | 3-5 | 3-6 |
| 5 | Constraints | -- | Required | Required |
| 6 | Stop Conditions | -- | Required | Required |
| 7 | Quality Gate | 3-5 items | 5-8 items | Multi-section |
| 8 | Response Format | Single | Standard + Below-threshold | 4-tier |
| 9 | Anti-Patterns | 3-5 rows | 5+ rows + Warning Signs | Full + Warning Signs |
| 10 | Error Recovery | -- | -- | Required |
| 11 | Extension Points | -- | -- | Required |
| 12 | Remember | Required | Required | Required |

### Go Shared Anti-Patterns

| Never Do | Why | Instead |
|----------|-----|---------|
| `panic()` for error handling | Crashes the process | Return `error`, wrap with `%w` |
| Goroutine without lifecycle | Leak risk | Use `errgroup`, respect `context.Context` |
| `interface{}` / `any` without need | Loses type safety | Use generics or concrete types |
| Import adapter into domain | Breaks Clean Architecture | Domain has zero internal imports |
| `SELECT *` in sqlc queries | Schema drift, perf | Explicit column list |
| Ignore `context.Context` | No cancellation/timeout | Pass and check context everywhere |
| Hardcode config values | Inflexible, insecure | Use env vars / config files |
| Skip `-race` in tests | Misses data races | Always `go test -race` |

---

## 10. Naming Conventions

| Item | Format | Example |
|------|--------|---------|
| Feature name | SCREAMING_SNAKE_CASE | `ORDER_SERVICE` |
| Agent name | kebab-case | `handler-builder` |
| Go files | snake_case | `order_handler.go` |
| Go packages | lowercase | `handler`, `service` |
| Go interfaces | Descriptive; -er suffix for single-behavior | `OrderRepository`, `Authenticator` |
| KB domains | kebab-case | `clean-architecture` |
| Commands | kebab-case | `kafka-consumer` |
| Migrations | Timestamp-based (golang-migrate) | `20260327120000_create_orders.up.sql` / `.down.sql` |
| Proto files | snake_case | `order_service.proto` |

---

## 11. Status Transitions

Identical to AgentSpec:

```text
brainstorm: Exploring -> Approaches Identified -> Ready for Define -> Complete (Defined)
define:     Draft -> In Progress -> Ready for Design -> Complete (Designed) -> Complete (Built) -> Shipped
design:     Draft -> In Progress -> Ready for Build -> Complete (Built) -> Shipped
build:      In Progress -> Complete -> Shipped
```

Each agent updates upstream document statuses before completing.

---

## 12. Code Generation

sqlc, Protobuf, and Swagger require code generation. The workflow:

| Tool | Source | Generated Output | Trigger |
|------|--------|-------------------|---------|
| sqlc | `db/query/*.sql` + `db/sqlc.yaml` | `internal/adapter/repository/sqlcgen/` | `make sqlc` or `go generate ./...` |
| protoc | `api/proto/*.proto` | `api/proto/gen/` | `make proto` or `go generate ./...` |
| swag | Handler annotations + `cmd/api/main.go` | `cmd/docs/swagger.yaml` | `make gen-docs` |

**Rules:**
- Generated code lives in dedicated `*gen/` subdirectories (sqlc, protoc)
- Swagger output goes to `cmd/docs/` (YAML only by default, JSON via `make swagger-json`)
- Generated files are committed to git (no `go generate` in CI)
- `//go:generate` directives in `db/generate.go` and `api/generate.go`
- Makefile targets: `make sqlc`, `make proto`, `make gen-docs`, `make generate` (runs all)
- `make gen-docs-check` validates swagger docs are up-to-date (used in CI)

---

## 13. Settings and Storage

### `settings.json`

```json
{
  "permissions": {
    "defaultMode": "bypassPermissions",
    "allow": [
      "Bash(*)", "Read", "Write", "Edit", "Glob", "Grep",
      "Agent", "Task", "TodoWrite", "ToolSearch",
      "WebFetch", "WebSearch", "Skill", "AskUserQuestion",
      "EnterPlanMode", "ExitPlanMode"
    ],
    "deny": []
  }
}
```

### `storage/`

Scratch space for agent intermediate outputs (temp files, partial results). Contents are gitignored. Used by agents that need to write temporary artifacts during multi-step operations.

### `CLAUDE.md`

Project context file at the repo root. Contains: plugin overview, repository structure, active development tasks, coding standards, available commands, key files reference, and version. Updated via `/sync-context` command.

---

## 14. Version

- **Version:** 1.0.0
- **Date:** 2026-03-27
- **Status:** Initial release
