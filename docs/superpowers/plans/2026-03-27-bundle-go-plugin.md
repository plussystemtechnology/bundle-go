# Bundle-Go Plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a complete Claude Code plugin for Go Backend/API development with 43 agents, 22 KB domains, 23 commands, and 5-phase SDD workflow following Clean Architecture.

**Architecture:** Markdown-driven plugin following AgentSpec's 3-layer architecture (Orchestrator -> Agent Template -> Domain Specialist). All content is `.claude/` markdown files consumed by Claude Code. No Go source code -- this is a plugin, not a Go project.

**Tech Stack:** Claude Code plugin system (markdown agents, commands, KB domains), YAML contracts, JSON settings.

**Spec:** `docs/superpowers/specs/2026-03-27-bundle-go-plugin-design.md`

**Reference implementation:** `/home/lerry/models/agentspec/` (original AgentSpec plugin to port from)

---

## Phase 1: Foundation

### Task 1: Directory Structure + Settings

**Files:**
- Create: `.claude/settings.json`
- Create: `.claude/storage/.gitkeep`
- Create: `.claude/sdd/features/.gitkeep`
- Create: `.claude/sdd/reports/.gitkeep`
- Create: `.claude/sdd/archive/.gitkeep`
- Create: `.claude/kb/_templates/.gitkeep`

- [ ] **Step 1: Create all directories and gitkeeps**

```bash
mkdir -p .claude/{agents/{workflow,architect,go-core,api,data,cloud,observability,test},commands/{workflow,go-engineering,core,knowledge,review},sdd/{architecture,templates,features,reports,archive},kb/{_templates,clean-architecture/{concepts,patterns},gin/{concepts,patterns},sqlc/{concepts,patterns},pgx/{concepts,patterns},cache/{concepts,patterns},kafka/{concepts,patterns},grpc/{concepts,patterns},auth/{concepts,patterns},swagger/{concepts,patterns},testing/{concepts,patterns},middleware/{concepts,patterns},migrations/{concepts,patterns},docker/{concepts,patterns},kubernetes/{concepts,patterns},prometheus/{concepts,patterns},otel/{concepts,patterns},zap/{concepts,patterns},error-handling/{concepts,patterns},concurrency/{concepts,patterns},security/{concepts,patterns},ci-cd/{concepts,patterns},go-patterns/{concepts,patterns}},storage}
touch .claude/storage/.gitkeep .claude/sdd/features/.gitkeep .claude/sdd/reports/.gitkeep .claude/sdd/archive/.gitkeep .claude/kb/_templates/.gitkeep
```

- [ ] **Step 2: Create settings.json**

Write `.claude/settings.json` with permissions config from spec Section 13.

- [ ] **Step 3: Commit**

```bash
git add .claude/
git commit -m "feat: scaffold bundle-go plugin directory structure"
```

---

### Task 2: Agent Template + README

**Files:**
- Create: `.claude/agents/_template.md`
- Create: `.claude/agents/README.md`

**Reference:** Read `/home/lerry/models/agentspec/.claude/agents/_template.md` and `/home/lerry/models/agentspec/.claude/agents/README.md` for structure, then adapt ALL content for Go Backend/API.

- [ ] **Step 1: Create `_template.md`**

Port the agentspec `_template.md` with these Go adaptations:
- Replace Python references with Go (ruff -> golangci-lint, mypy -> go vet, pytest -> go test)
- Add Go Shared Anti-Patterns table from spec Section 9
- Add Clean Architecture layer enforcement in quality gate
- Keep all 12 sections, tier system (T1/T2/T3), Agreement Matrix, Impact Tiers, Confidence Modifiers exactly as in spec Section 9

- [ ] **Step 2: Create `README.md`**

Write the agents README with:
- Cognitive Architecture (3 layers) explanation
- Agent Tiers definition (T1/T2/T3) from spec Section 9.0
- All 43 agents cataloged by category (tables from spec Section 3)
- Complete Escalation Map from spec Section 4
- "When NOT to Create an Agent" rules
- "Creating Custom Agents" guide

- [ ] **Step 3: Commit**

```bash
git add .claude/agents/_template.md .claude/agents/README.md
git commit -m "feat: add Go-adapted agent template and routing README"
```

---

### Task 3: CLAUDE.md

**Files:**
- Create: `CLAUDE.md`

**Reference:** Read `/home/lerry/models/agentspec/CLAUDE.md` for structure, then rewrite for Go Backend/API.

- [ ] **Step 1: Create CLAUDE.md**

Write the project context file with:
- Project Context: Bundle-Go description, version 1.0.0
- Repository Structure: full tree from spec Section 2
- Development Workflow: SDD examples with Go commands
- Coding Standards: Go-specific (gofmt, golangci-lint, go vet, Clean Arch rules)
- Commands Available: all 23 commands from spec Section 5
- Key Files to Know: reference table
- Version info

- [ ] **Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "feat: add CLAUDE.md project context"
```

---

## Phase 2: SDD Framework

### Task 4: Workflow Contracts + Architecture

**Files:**
- Create: `.claude/sdd/architecture/WORKFLOW_CONTRACTS.yaml`
- Create: `.claude/sdd/architecture/ARCHITECTURE.md`
- Create: `.claude/sdd/_index.md`
- Create: `.claude/sdd/README.md`

**Reference:** Read these files from agentspec and adapt for Go:
- `/home/lerry/models/agentspec/.claude/sdd/architecture/WORKFLOW_CONTRACTS.yaml`
- `/home/lerry/models/agentspec/.claude/sdd/architecture/ARCHITECTURE.md`
- `/home/lerry/models/agentspec/.claude/sdd/_index.md`
- `/home/lerry/models/agentspec/.claude/sdd/README.md`

- [ ] **Step 1: Create WORKFLOW_CONTRACTS.yaml**

Port the agentspec contracts with these Go changes:
- Replace all Python tooling (ruff, mypy, pytest) with Go equivalents (golangci-lint, go vet, go test -race)
- Replace `data_engineering_delegation` with `go_delegation` map from spec Section 7.3
- Add `clean_architecture_gate` from spec Section 8.3
- Add `go_verification` commands from spec Section 7.4
- Replace DE quality gates with Go quality gates from spec Section 7.2
- Keep all 5 phases, cross-phase iterate, status transitions, naming conventions, folder structure exactly as in spec

- [ ] **Step 2: Create ARCHITECTURE.md**

Port the agentspec architecture doc with:
- Same ASCII diagrams (5-phase pipeline, phase flow, data flow, iteration flow, quality gates)
- Replace model assignments with spec values
- Replace folder structure with spec Section 2
- Go-specific quality gate details from spec Section 7.2

- [ ] **Step 3: Create _index.md and README.md**

Port from agentspec, replacing all references:
- Commands table with Go commands (spec Section 5)
- Phase details adapted for Go
- Model assignments from spec
- Quick start examples using Go commands

- [ ] **Step 4: Commit**

```bash
git add .claude/sdd/
git commit -m "feat: add SDD framework with Go-adapted workflow contracts"
```

---

### Task 5: SDD Templates (5)

**Files:**
- Create: `.claude/sdd/templates/BRAINSTORM_TEMPLATE.md`
- Create: `.claude/sdd/templates/DEFINE_TEMPLATE.md`
- Create: `.claude/sdd/templates/DESIGN_TEMPLATE.md`
- Create: `.claude/sdd/templates/BUILD_REPORT_TEMPLATE.md`
- Create: `.claude/sdd/templates/SHIPPED_TEMPLATE.md`

**Reference:** Read each template from `/home/lerry/models/agentspec/.claude/sdd/templates/` and adapt for Go.

- [ ] **Step 1: Create BRAINSTORM_TEMPLATE.md**

Port from agentspec. Mostly unchanged since brainstorm is language-agnostic. Add a "Technical Context" section that asks about Go version and Clean Architecture layers.

- [ ] **Step 2: Create DEFINE_TEMPLATE.md**

Port from agentspec. Add Go-specific Technical Context:
- Go version
- Clean Architecture layers involved
- KB domains to load
- Data lineage (if applicable)
- Target deployment (K8s, Docker, etc.)

- [ ] **Step 3: Create DESIGN_TEMPLATE.md**

Port from agentspec with Go adaptations:
- Architecture diagram must show Clean Arch layers
- File manifest uses Go paths (internal/domain/, internal/adapter/handler/http/, etc.)
- Agent assignments use Go agents from spec Section 3
- Code patterns must be idiomatic Go
- Dependencies section lists go.mod entries
- Testing strategy uses go test, testcontainers, benchmarks

- [ ] **Step 4: Create BUILD_REPORT_TEMPLATE.md**

Port from agentspec. Change verification section to use Go commands:
- `golangci-lint run ./...`
- `go test -race -cover ./...`
- `go build -o /dev/null ./cmd/...`
- `staticcheck ./...`

- [ ] **Step 5: Create SHIPPED_TEMPLATE.md**

Port directly from agentspec -- this is language-agnostic.

- [ ] **Step 6: Commit**

```bash
git add .claude/sdd/templates/
git commit -m "feat: add 5 SDD templates adapted for Go Clean Architecture"
```

---

## Phase 3: Workflow Agents + Commands

### Task 6: Workflow Agents (6)

**Files:**
- Create: `.claude/agents/workflow/brainstorm-agent.md`
- Create: `.claude/agents/workflow/define-agent.md`
- Create: `.claude/agents/workflow/design-agent.md`
- Create: `.claude/agents/workflow/build-agent.md`
- Create: `.claude/agents/workflow/ship-agent.md`
- Create: `.claude/agents/workflow/iterate-agent.md`

**Reference:** Read EACH corresponding agent from `/home/lerry/models/agentspec/.claude/agents/workflow/` and adapt for Go.

- [ ] **Step 1: Create brainstorm-agent.md**

Port from agentspec. T2, model opus. Mostly language-agnostic. Add Go-specific sample collection (ask about existing Go code, interfaces, test patterns).

- [ ] **Step 2: Create define-agent.md**

Port from agentspec. T2, model opus. Add Go Technical Context extraction (Go version, Clean Arch layers, deployment target).

- [ ] **Step 3: Create design-agent.md**

Port from agentspec. T2, model opus. Major Go adaptations:
- File manifest must follow Clean Architecture paths from spec Section 8.2
- Agent assignments use Go agents from spec Section 3
- Architecture diagrams must show layer dependencies from spec Section 8.1
- Code patterns must be idiomatic Go
- Import rules enforcement from spec Section 8.3

- [ ] **Step 4: Create build-agent.md**

Port from agentspec. T2, model sonnet. Major Go adaptations:
- Replace Python verification (ruff, mypy, pytest) with Go (golangci-lint, go vet, go test -race, staticcheck)
- Replace DE delegation map with Go delegation map from spec Section 7.3
- Add Clean Architecture layer import verification
- Verification commands from spec Section 7.4 (including `staticcheck ./...`)

- [ ] **Step 5: Create ship-agent.md**

Port from agentspec. T2, model haiku. Minimal changes -- mostly language-agnostic.

- [ ] **Step 6: Create iterate-agent.md**

Port from agentspec. T2, model sonnet. Cascade rules stay the same. Change code verification references to Go.

- [ ] **Step 7: Commit**

```bash
git add .claude/agents/workflow/
git commit -m "feat: add 6 workflow agents (SDD phases) adapted for Go"
```

---

### Task 7: Workflow Commands (7)

**Files:**
- Create: `.claude/commands/workflow/brainstorm.md`
- Create: `.claude/commands/workflow/define.md`
- Create: `.claude/commands/workflow/design.md`
- Create: `.claude/commands/workflow/build.md`
- Create: `.claude/commands/workflow/ship.md`
- Create: `.claude/commands/workflow/iterate.md`
- Create: `.claude/commands/workflow/create-pr.md`

**Reference:** Read each command from `/home/lerry/models/agentspec/.claude/commands/workflow/` and adapt for Go.

- [ ] **Step 1: Create all 7 workflow commands**

Port each from agentspec. Main changes:
- `build.md`: Replace Python verification (ruff, mypy, pytest) with Go (golangci-lint, go vet, go test -race -cover)
- `design.md`: Reference Go agents and Clean Arch layers
- Other commands need minimal changes (mostly language-agnostic)

Each command follows the same structure: frontmatter (name, description), Usage, Examples, Overview (phase position), What This Command Does, Process steps, Output, Quality Gate, Tips, References.

- [ ] **Step 2: Commit**

```bash
git add .claude/commands/workflow/
git commit -m "feat: add 7 SDD workflow commands"
```

---

## Phase 4: KB Domains (22)

> These tasks can be executed in parallel via subagents.

### Task 8: Core Go KB Domains (6)

**Files:**
- Create: `.claude/kb/clean-architecture/{index.md,quick-reference.md,concepts/*.md,patterns/*.md}`
- Create: `.claude/kb/go-patterns/{index.md,quick-reference.md,concepts/*.md,patterns/*.md}`
- Create: `.claude/kb/error-handling/{index.md,quick-reference.md,concepts/*.md,patterns/*.md}`
- Create: `.claude/kb/concurrency/{index.md,quick-reference.md,concepts/*.md,patterns/*.md}`
- Create: `.claude/kb/testing/{index.md,quick-reference.md,concepts/*.md,patterns/*.md}`
- Create: `.claude/kb/zap/{index.md,quick-reference.md,concepts/*.md,patterns/*.md}`

Each KB domain MUST have:
- `index.md` -- Domain overview with topic headings (~20 lines, scannable by agents)
- `quick-reference.md` -- Decision matrices, cheat sheet, common patterns
- `concepts/` -- 3-6 concept files explaining core ideas
- `patterns/` -- 3-6 pattern files with copy-paste Go code examples

- [ ] **Step 1: Create `clean-architecture/` KB domain**

Files: index.md, quick-reference.md, concepts/{layer-rules.md, dependency-inversion.md, interface-segregation.md, single-responsibility.md}, patterns/{port-adapter.md, dependency-injection.md, repository-pattern.md, service-pattern.md}

Content focus: Bundle-Go layer rules from spec Section 8, import rules from Section 8.3, Go-specific DIP with interfaces. All code examples in Go.

- [ ] **Step 2: Create `go-patterns/` KB domain**

Files: index.md, quick-reference.md, concepts/{functional-options.md, generics.md, interfaces.md, embedding.md}, patterns/{option-pattern.md, builder-pattern.md, factory-pattern.md, strategy-pattern.md}

Content focus: Idiomatic Go patterns, functional options for constructors, generics (Go 1.18+), interface design ("accept interfaces, return structs"), struct embedding for composition.

- [ ] **Step 3: Create `error-handling/` KB domain**

Files: index.md, quick-reference.md, concepts/{error-types.md, wrapping.md, sentinel-errors.md}, patterns/{custom-errors.md, error-chain.md, validation-errors.md, api-errors.md}

Content focus: `fmt.Errorf("%w", err)`, `errors.Is()`, `errors.As()`, sentinel errors, custom error types with HTTP status codes, structured error responses for APIs.

- [ ] **Step 4: Create `concurrency/` KB domain**

Files: index.md, quick-reference.md, concepts/{goroutines.md, channels.md, context.md, sync-primitives.md}, patterns/{worker-pool.md, errgroup.md, pipeline.md, fan-out-fan-in.md}

Content focus: `context.Context` everywhere, `errgroup.Group` for coordinated work, channel patterns, `sync.Pool`, `sync.Once`, graceful shutdown.

- [ ] **Step 5: Create `testing/` KB domain**

Files: index.md, quick-reference.md, concepts/{table-driven.md, mocking.md, test-helpers.md, fuzzing.md}, patterns/{http-testing.md, db-testing.md, testcontainers.md, golden-files.md, benchmark.md}

Content focus: Table-driven tests with subtests, `t.Helper()`, `t.Cleanup()`, `t.Parallel()`, `httptest`, interface mocking (no frameworks), testcontainers-go, `-race` flag, benchmarks with `b.ResetTimer()`.

- [ ] **Step 6: Create `zap/` KB domain**

Files: index.md, quick-reference.md, concepts/{logger-setup.md, sugar-vs-structured.md, log-levels.md}, patterns/{middleware-logging.md, context-fields.md, sampling.md, sink-config.md}

Content focus: `zap.NewProduction()`, `zap.L()` global, sugared vs structured, adding fields to context, request-scoped logging in Gin middleware, log sampling for high-throughput.

- [ ] **Step 7: Commit**

```bash
git add .claude/kb/clean-architecture/ .claude/kb/go-patterns/ .claude/kb/error-handling/ .claude/kb/concurrency/ .claude/kb/testing/ .claude/kb/zap/
git commit -m "feat: add 6 core Go KB domains (clean-arch, patterns, errors, concurrency, testing, zap)"
```

---

### Task 9: Stack KB Domains (9)

**Files:**
- Create: `.claude/kb/gin/{index.md,quick-reference.md,concepts/*.md,patterns/*.md}`
- Create: `.claude/kb/sqlc/{index.md,quick-reference.md,concepts/*.md,patterns/*.md}`
- Create: `.claude/kb/pgx/{index.md,quick-reference.md,concepts/*.md,patterns/*.md}`
- Create: `.claude/kb/cache/{index.md,quick-reference.md,concepts/*.md,patterns/*.md}`
- Create: `.claude/kb/kafka/{index.md,quick-reference.md,concepts/*.md,patterns/*.md}`
- Create: `.claude/kb/grpc/{index.md,quick-reference.md,concepts/*.md,patterns/*.md}`
- Create: `.claude/kb/auth/{index.md,quick-reference.md,concepts/*.md,patterns/*.md}`
- Create: `.claude/kb/swagger/{index.md,quick-reference.md,concepts/*.md,patterns/*.md}`
- Create: `.claude/kb/middleware/{index.md,quick-reference.md,concepts/*.md,patterns/*.md}`

- [ ] **Step 1: Create `gin/` KB domain**

Concepts: routing.md, binding-validation.md, middleware-chain.md, error-responses.md
Patterns: crud-handler.md, route-groups.md, custom-validators.md, pagination.md

- [ ] **Step 2: Create `sqlc/` KB domain**

Concepts: codegen.md, query-annotations.md, custom-types.md, config.md
Patterns: crud-queries.md, batch-operations.md, transactions.md, json-columns.md

- [ ] **Step 3: Create `pgx/` KB domain**

Concepts: connection-pool.md, prepared-statements.md, types.md
Patterns: pool-config.md, transactions.md, copy-protocol.md, listen-notify.md

- [ ] **Step 4: Create `cache/` KB domain**

Concepts: data-structures.md, cache-strategies.md, pub-sub.md, lru-inmemory.md
Patterns: cache-aside.md, distributed-lock.md, rate-limiter.md, session-store.md, write-through.md

- [ ] **Step 5: Create `kafka/` KB domain**

Concepts: consumer-groups.md, producers.md, partitioning.md, exactly-once.md
Patterns: consumer-handler.md, dead-letter-queue.md, schema-registry.md, graceful-shutdown.md

- [ ] **Step 6: Create `grpc/` KB domain**

Concepts: protobuf-style.md, interceptors.md, streaming.md, health.md
Patterns: unary-service.md, server-streaming.md, interceptor-chain.md, grpc-gateway.md

- [ ] **Step 7: Create `auth/` KB domain**

Concepts: jwt.md, oidc.md, oauth2.md, vault-secrets.md
Patterns: jwt-middleware.md, rbac.md, session-management.md, token-refresh.md

- [ ] **Step 8: Create `swagger/` KB domain**

Concepts: openapi-spec.md, swaggo-annotations.md, gin-swagger.md
Patterns: endpoint-docs.md, schema-definitions.md, gen-docs-validation.md, yaml-json-output.md

- [ ] **Step 9: Create `middleware/` KB domain**

Concepts: middleware-chain.md, context-propagation.md, request-lifecycle.md
Patterns: auth-middleware.md, cors.md, rate-limiter.md, request-id.md, recovery.md

- [ ] **Step 10: Commit**

```bash
git add .claude/kb/gin/ .claude/kb/sqlc/ .claude/kb/pgx/ .claude/kb/cache/ .claude/kb/kafka/ .claude/kb/grpc/ .claude/kb/auth/ .claude/kb/swagger/ .claude/kb/middleware/
git commit -m "feat: add 9 stack KB domains (gin, sqlc, pgx, cache, kafka, grpc, auth, swagger, middleware)"
```

---

### Task 10: Infra KB Domains (7)

**Files:**
- Create: `.claude/kb/docker/{index.md,quick-reference.md,concepts/*.md,patterns/*.md}`
- Create: `.claude/kb/kubernetes/{index.md,quick-reference.md,concepts/*.md,patterns/*.md}`
- Create: `.claude/kb/prometheus/{index.md,quick-reference.md,concepts/*.md,patterns/*.md}`
- Create: `.claude/kb/otel/{index.md,quick-reference.md,concepts/*.md,patterns/*.md}`
- Create: `.claude/kb/migrations/{index.md,quick-reference.md,concepts/*.md,patterns/*.md}`
- Create: `.claude/kb/security/{index.md,quick-reference.md,concepts/*.md,patterns/*.md}`
- Create: `.claude/kb/ci-cd/{index.md,quick-reference.md,concepts/*.md,patterns/*.md}`

- [ ] **Step 1: Create `docker/` KB domain**

Concepts: multi-stage-builds.md, distroless.md, compose.md
Patterns: go-dockerfile.md, docker-compose-dev.md, health-check.md, build-args.md

- [ ] **Step 2: Create `kubernetes/` KB domain**

Concepts: deployments.md, services.md, config-secrets.md, hpa.md
Patterns: go-deployment.md, service-mesh.md, configmap-mount.md, probes.md

- [ ] **Step 3: Create `prometheus/` KB domain**

Concepts: metric-types.md, labels.md, alerting.md
Patterns: http-metrics.md, custom-collector.md, histogram-buckets.md, grafana-dashboard.md

- [ ] **Step 4: Create `otel/` KB domain**

Concepts: traces.md, spans.md, propagation.md, collector.md
Patterns: gin-middleware-trace.md, grpc-interceptor-trace.md, db-trace.md, sampling.md

- [ ] **Step 5: Create `migrations/` KB domain**

Concepts: golang-migrate.md, versioning.md, idempotent-ddl.md
Patterns: create-table.md, add-column.md, seed-data.md, rollback.md, container-runner.md

- [ ] **Step 6: Create `security/` KB domain**

Concepts: gosec.md, govulncheck.md, input-validation.md, owasp-go.md
Patterns: gosec-config.md, vulnerability-scan.md, secrets-hygiene.md, validator-rules.md

- [ ] **Step 7: Create `ci-cd/` KB domain**

Concepts: github-actions.md, makefile.md, linting.md
Patterns: go-ci-workflow.md, release-automation.md, golangci-lint-config.md, pre-commit.md

- [ ] **Step 8: Commit**

```bash
git add .claude/kb/docker/ .claude/kb/kubernetes/ .claude/kb/prometheus/ .claude/kb/otel/ .claude/kb/migrations/ .claude/kb/security/ .claude/kb/ci-cd/
git commit -m "feat: add 7 infra KB domains (docker, k8s, prometheus, otel, migrations, security, ci-cd)"
```

---

### Task 11: KB Index

**Files:**
- Create: `.claude/kb/_index.yaml`

- [ ] **Step 1: Create KB index**

Register all 22 KB domains with name, path, description, and related agents.

- [ ] **Step 2: Commit**

```bash
git add .claude/kb/_index.yaml
git commit -m "feat: add KB domain registry (22 domains)"
```

---

## Phase 5: Specialist Agents (37)

### Task 12: Architect Agents (6)

**Files:**
- Create: `.claude/agents/architect/api-architect.md`
- Create: `.claude/agents/architect/schema-designer.md`
- Create: `.claude/agents/architect/clean-arch-architect.md`
- Create: `.claude/agents/architect/pipeline-architect.md`
- Create: `.claude/agents/architect/platform-engineer.md`
- Create: `.claude/agents/architect/the-planner.md`

Each agent MUST follow `_template.md` structure for its declared tier. Use spec Section 3.2 for tier, model, purpose. Include:
- Frontmatter with all required fields
- Identity block
- Knowledge Resolution (KB-First, Agreement Matrix for T2+)
- Capabilities (When/Process/Output)
- Quality Gate with Go checks
- Anti-Patterns table
- Remember motto

**Reference:** Read corresponding agentspec architect agents from `/home/lerry/models/agentspec/.claude/agents/architect/` for structural patterns, then write Go-specific content.

- [ ] **Step 1: Create `api-architect.md`** (T2, opus)

KB domains: gin, grpc, go-patterns, middleware. Capabilities: REST API design, gRPC service design, endpoint planning with Clean Architecture layers.

- [ ] **Step 2: Create `schema-designer.md`** (T2, sonnet)

KB domains: pgx, migrations, sqlc. Capabilities: DB schema design, ERD creation, index strategy, constraint design.

- [ ] **Step 3: Create `clean-arch-architect.md`** (T2, opus)

KB domains: clean-architecture, go-patterns. Capabilities: Layer design, interface contract definition (ports), dependency validation, import rule enforcement per spec Section 8.3.

- [ ] **Step 4: Create `pipeline-architect.md`** (T2, sonnet)

KB domains: kafka, cache, concurrency. Capabilities: Event-driven architecture, Kafka topic design, consumer group strategy.

- [ ] **Step 5: Create `platform-engineer.md`** (T1, sonnet)

KB domains: kubernetes, docker. Capabilities: Infra decisions, scaling strategy, cost estimation.

- [ ] **Step 6: Create `the-planner.md`** (T2, opus)

KB domains: clean-architecture. Capabilities: Strategic decomposition, implementation planning, feature breakdown.

- [ ] **Step 7: Commit**

```bash
git add .claude/agents/architect/
git commit -m "feat: add 6 architect agents"
```

---

### Task 13: Go Core Agents (6)

**Files:**
- Create: `.claude/agents/go-core/go-developer.md`
- Create: `.claude/agents/go-core/handler-builder.md`
- Create: `.claude/agents/go-core/service-builder.md`
- Create: `.claude/agents/go-core/repository-builder.md`
- Create: `.claude/agents/go-core/middleware-builder.md`
- Create: `.claude/agents/go-core/config-specialist.md`

**Reference:** Read agentspec Python agents from `/home/lerry/models/agentspec/.claude/agents/python/` for structural patterns (these are the closest equivalent), then write Go-specific content.

- [ ] **Step 1: Create `go-developer.md`** (T1, sonnet)

KB domains: go-patterns, error-handling, concurrency. General-purpose Go specialist for idiomatic code, stdlib usage, domain layer files.

- [ ] **Step 2: Create `handler-builder.md`** (T2, sonnet)

KB domains: gin, middleware, error-handling. Capabilities: Gin handler scaffolding with binding, validation, structured error responses, pagination. Generates files in `internal/adapter/handler/http/`.

- [ ] **Step 3: Create `service-builder.md`** (T2, sonnet)

KB domains: clean-architecture, error-handling, concurrency. Capabilities: Business logic services with transaction support, use case pattern. Generates files in `internal/app/service/`.

- [ ] **Step 4: Create `repository-builder.md`** (T2, sonnet)

KB domains: sqlc, pgx, clean-architecture. Capabilities: Repository implementations wrapping sqlc-generated code, pgx pool configuration. Generates files in `internal/adapter/repository/`.

- [ ] **Step 5: Create `middleware-builder.md`** (T2, sonnet)

KB domains: middleware, gin, security. Capabilities: HTTP middleware (auth, CORS, rate-limit, recovery, request-id) and gRPC interceptors. Generates files in `internal/adapter/middleware/`.

- [ ] **Step 6: Create `config-specialist.md`** (T1, sonnet)

KB domains: go-patterns. Capabilities: Config file setup (Viper or env-based), functional options pattern for services. Generates files in `config/`.

- [ ] **Step 7: Commit**

```bash
git add .claude/agents/go-core/
git commit -m "feat: add 6 Go core agents (Clean Architecture layer builders)"
```

---

### Task 14: API Agents (6)

**Files:**
- Create: `.claude/agents/api/gin-specialist.md`
- Create: `.claude/agents/api/grpc-specialist.md`
- Create: `.claude/agents/api/rest-designer.md`
- Create: `.claude/agents/api/auth-specialist.md`
- Create: `.claude/agents/api/swagger-builder.md`
- Create: `.claude/agents/api/api-gateway-specialist.md`

**Reference:** No direct agentspec equivalent. Use `.claude/agents/_template.md` as structural base. Read `/home/lerry/models/agentspec/.claude/agents/data-engineering/spark-specialist.md` (T2) and `/home/lerry/models/agentspec/.claude/agents/cloud/supabase-specialist.md` (T3) as structural exemplars for Go API agents.

- [ ] **Step 1: Create `gin-specialist.md`** (T3, sonnet)

KB domains: gin, middleware, go-patterns. Deep Gin expertise: route groups, engine config, custom validators, middleware chains, graceful shutdown. T3 requires Error Recovery and Extension Points sections.

- [ ] **Step 2: Create `grpc-specialist.md`** (T3, sonnet)

KB domains: grpc, go-patterns. Protobuf style guide, unary/streaming services, interceptor chains, health checking, gRPC-Gateway.

- [ ] **Step 3: Create `rest-designer.md`** (T2, sonnet)

KB domains: gin, go-patterns. REST API design: OpenAPI spec, versioning strategies, pagination, HATEOAS, error response format.

- [ ] **Step 4: Create `auth-specialist.md`** (T2, opus)

KB domains: security, middleware, gin. JWT generation/validation, OAuth2 flows, RBAC middleware, session management, secrets rotation.

- [ ] **Step 5: Create `swagger-builder.md`** (T1, sonnet)

KB domains: swagger, gin. swaggo annotations, gin-swagger UI setup, `swag init` config, OpenAPI generation, docs validation with gen-docs-check.

- [ ] **Step 6: Create `api-gateway-specialist.md`** (T1, sonnet)

KB domains: gin, middleware. Reverse proxy patterns, rate limiting, API routing, request/response transformation.

- [ ] **Step 7: Commit**

```bash
git add .claude/agents/api/
git commit -m "feat: add 6 API agents (gin, grpc, rest, auth, swagger, gateway)"
```

---

### Task 15: Data Agents (6)

**Files:**
- Create: `.claude/agents/data/sqlc-specialist.md`
- Create: `.claude/agents/data/pgx-specialist.md`
- Create: `.claude/agents/data/migration-specialist.md`
- Create: `.claude/agents/data/kafka-specialist.md`
- Create: `.claude/agents/data/cache-specialist.md`
- Create: `.claude/agents/data/event-store-specialist.md`

**Reference:** Use `.claude/agents/_template.md` as structural base. Read `/home/lerry/models/agentspec/.claude/agents/data-engineering/dbt-specialist.md` (T2) and `/home/lerry/models/agentspec/.claude/agents/data-engineering/spark-streaming-architect.md` (T3) as structural exemplars for data specialists.

- [ ] **Step 1: Create `sqlc-specialist.md`** (T3, sonnet)

KB domains: sqlc, pgx. sqlc.yaml config, query annotations (:one, :many, :exec, :batchexec), custom types, transactions via pgx.

- [ ] **Step 2: Create `pgx-specialist.md`** (T3, sonnet)

KB domains: pgx, concurrency. Connection pool tuning, prepared statements, COPY protocol, pgx.Rows scanning, pgxpool config.

- [ ] **Step 3: Create `migration-specialist.md`** (T2, sonnet)

KB domains: migrations, pgx. golang-migrate migration creation, idempotent DDL, seed data, rollback strategy, container-based runner.

- [ ] **Step 4: Create `kafka-specialist.md`** (T3, sonnet)

KB domains: kafka, concurrency, error-handling. Consumer group setup (segmentio/kafka-go or confluent), producer patterns, exactly-once semantics, dead letter queues, graceful shutdown.

- [ ] **Step 5: Create `cache-specialist.md`** (T2, sonnet)

KB domains: cache, concurrency. Redis (go-redis), Memcache (gomemcache), golang-lru in-memory, cache-aside pattern, write-through, distributed locks, pub/sub, session store, rate limiter implementation.

- [ ] **Step 6: Create `event-store-specialist.md`** (T1, sonnet)

KB domains: kafka, pgx. Event sourcing patterns, outbox pattern with pgx, event replay, snapshot strategy.

- [ ] **Step 7: Commit**

```bash
git add .claude/agents/data/
git commit -m "feat: add 6 data agents (sqlc, pgx, migrations, kafka, cache, event-store)"
```

---

### Task 16: Cloud Agents (4)

**Files:**
- Create: `.claude/agents/cloud/k8s-specialist.md`
- Create: `.claude/agents/cloud/docker-specialist.md`
- Create: `.claude/agents/cloud/aws-deployer.md`
- Create: `.claude/agents/cloud/ci-cd-specialist.md`

**Reference:** Read `/home/lerry/models/agentspec/.claude/agents/cloud/` for structural patterns. The agentspec cloud agents (aws-deployer, ci-cd-specialist) can be ported with Go-specific content. For k8s/docker, use `.claude/agents/_template.md` as base and `/home/lerry/models/agentspec/.claude/agents/cloud/ci-cd-specialist.md` (T3) as exemplar.

- [ ] **Step 1: Create `k8s-specialist.md`** (T3, sonnet)

KB domains: kubernetes, docker. Deployment manifests, HPA, configmaps, secrets, service mesh, probes, resource limits.

- [ ] **Step 2: Create `docker-specialist.md`** (T2, sonnet)

KB domains: docker, ci-cd. Multi-stage Go builds, distroless base images, docker-compose for dev, .dockerignore.

- [ ] **Step 3: Create `aws-deployer.md`** (T2, sonnet)

KB domains: kubernetes, ci-cd. ECS/EKS deployment, ECR push, ALB/NLB config, RDS setup, AWS Secrets Manager.

- [ ] **Step 4: Create `ci-cd-specialist.md`** (T3, sonnet)

KB domains: ci-cd, testing, docker. GitHub Actions workflows, Makefile targets, golangci-lint config, release automation, semantic versioning.

- [ ] **Step 5: Commit**

```bash
git add .claude/agents/cloud/
git commit -m "feat: add 4 cloud agents (k8s, docker, aws, ci-cd)"
```

---

### Task 17: Observability Agents (4)

**Files:**
- Create: `.claude/agents/observability/prometheus-specialist.md`
- Create: `.claude/agents/observability/otel-specialist.md`
- Create: `.claude/agents/observability/logging-specialist.md`
- Create: `.claude/agents/observability/health-check-specialist.md`

**Reference:** No direct agentspec equivalent. Use `.claude/agents/_template.md` as structural base. Read `/home/lerry/models/agentspec/.claude/agents/platform/fabric-logging-specialist.md` (T3) as structural exemplar for observability agents.

- [ ] **Step 1: Create `prometheus-specialist.md`** (T2, sonnet)

KB domains: prometheus, gin. HTTP metrics middleware, custom collectors, histogram buckets, alerting rules, Grafana dashboard JSON.

- [ ] **Step 2: Create `otel-specialist.md`** (T3, sonnet)

KB domains: otel, gin, grpc. OpenTelemetry SDK setup, Gin middleware tracer, gRPC interceptor tracer, DB span instrumentation, collector config.

- [ ] **Step 3: Create `logging-specialist.md`** (T1, sonnet)

KB domains: zap. zap logger setup, sugar vs structured, Gin request logging middleware, context-based field injection, sampling config.

- [ ] **Step 4: Create `health-check-specialist.md`** (T1, sonnet)

KB domains: kubernetes, gin. Liveness/readiness/startup probes, health check endpoints, dependency health (DB, Redis, Kafka).

- [ ] **Step 5: Commit**

```bash
git add .claude/agents/observability/
git commit -m "feat: add 4 observability agents (prometheus, otel, logging, health)"
```

---

### Task 18: Test & Quality Agents (5)

**Files:**
- Create: `.claude/agents/test/test-generator.md`
- Create: `.claude/agents/test/benchmark-specialist.md`
- Create: `.claude/agents/test/integration-test-specialist.md`
- Create: `.claude/agents/test/security-scanner.md`
- Create: `.claude/agents/test/code-reviewer.md`

**Reference:** Read `/home/lerry/models/agentspec/.claude/agents/test/` for structural patterns. The agentspec test-generator and data-quality-analyst can be ported with Go-specific content. Also read `/home/lerry/models/agentspec/.claude/agents/python/code-reviewer.md` for the code reviewer pattern.

- [ ] **Step 1: Create `test-generator.md`** (T2, sonnet)

KB domains: testing, go-patterns. Table-driven test generation, mock creation via interfaces, test helper functions, golden file tests, `-race` flag enforcement.

- [ ] **Step 2: Create `benchmark-specialist.md`** (T1, sonnet)

KB domains: testing, concurrency. Benchmark functions, `b.ResetTimer()`, `b.ReportAllocs()`, pprof profiling, allocation optimization.

- [ ] **Step 3: Create `integration-test-specialist.md`** (T2, sonnet)

KB domains: testing, docker. testcontainers-go setup (Postgres, Redis, Kafka), API integration tests with httptest, DB test fixtures with transactions.

- [ ] **Step 4: Create `security-scanner.md`** (T1, sonnet)

KB domains: security, ci-cd. gosec analysis, govulncheck scans, OWASP Go security checks, .gosec.json config, security linting integration.

- [ ] **Step 5: Create `code-reviewer.md`** (T2, sonnet)

KB domains: go-patterns, testing, security, clean-architecture. Code quality review, security audit, anti-pattern detection, Clean Architecture layer violation detection, concurrency safety.

- [ ] **Step 6: Commit**

```bash
git add .claude/agents/test/
git commit -m "feat: add 5 test/quality agents (test-gen, benchmark, integration, security, reviewer)"
```

---

## Phase 6: Go Engineering + Core Commands

### Task 19: Go Engineering Commands (10)

**Files:**
- Create: `.claude/commands/go-engineering/handler.md`
- Create: `.claude/commands/go-engineering/service.md`
- Create: `.claude/commands/go-engineering/repository.md`
- Create: `.claude/commands/go-engineering/migration.md`
- Create: `.claude/commands/go-engineering/middleware.md`
- Create: `.claude/commands/go-engineering/proto.md`
- Create: `.claude/commands/go-engineering/kafka-consumer.md`
- Create: `.claude/commands/go-engineering/swagger.md`
- Create: `.claude/commands/go-engineering/security-scan.md`
- Create: `.claude/commands/go-engineering/go-review.md`
- Create: `.claude/commands/go-engineering/README.md`

**Reference:** Read `/home/lerry/models/agentspec/.claude/commands/data-engineering/` for command structure patterns.

Each command follows: frontmatter (name, description), Usage, Examples, What This Command Does, Agent Delegation table, KB Domains Used, Output.

- [ ] **Step 1: Create `handler.md`**

Delegates to `handler-builder`. Examples: `/handler "CRUD handler for orders with pagination"`. KB: gin, middleware, error-handling.

- [ ] **Step 2: Create `service.md`**

Delegates to `service-builder`. Examples: `/service "Order processing with inventory check"`. KB: clean-architecture, error-handling.

- [ ] **Step 3: Create `repository.md`**

Delegates to `repository-builder`. Escalates to `sqlc-specialist` for queries. Examples: `/repository "Orders with search and soft-delete"`. KB: sqlc, pgx, clean-architecture.

- [ ] **Step 4: Create `migration.md`**

Delegates to `migration-specialist`. Examples: `/migration "Create orders table with indexes"`. KB: migrations, pgx.

- [ ] **Step 5: Create `middleware.md`**

Delegates to `middleware-builder`. Examples: `/middleware "JWT auth with role-based access"`. KB: middleware, gin, security.

- [ ] **Step 6: Create `proto.md`**

Delegates to `grpc-specialist`. Examples: `/proto "Order service with CRUD + streaming"`. KB: grpc, go-patterns.

- [ ] **Step 7: Create `kafka-consumer.md`**

Delegates to `kafka-specialist`. Examples: `/kafka-consumer "Order events with dead letter queue"`. KB: kafka, error-handling, concurrency.

- [ ] **Step 8: Create `swagger.md`**

Delegates to `swagger-builder`. Examples: `/swagger "Generate docs for order handlers"`. KB: swagger, gin. Runs `swag init` and validates with gen-docs-check.

- [ ] **Step 9: Create `security-scan.md`**

Delegates to `security-scanner`. Examples: `/security-scan` or `/security-scan internal/adapter/`. KB: security, ci-cd. Runs gosec + govulncheck and reports findings.

- [ ] **Step 10: Create `go-review.md`**

Delegates to `code-reviewer`. Examples: `/go-review internal/adapter/handler/`. KB: go-patterns, testing, security.

- [ ] **Step 11: Create `README.md`**

Write Go Engineering commands README with catalog table, quick start examples, and how commands work.

- [ ] **Step 12: Commit**

```bash
git add .claude/commands/go-engineering/
git commit -m "feat: add 10 Go engineering commands"
```

---

### Task 20: Core + Utility Commands (6)

**Files:**
- Create: `.claude/commands/core/memory.md`
- Create: `.claude/commands/core/meeting.md`
- Create: `.claude/commands/core/readme-maker.md`
- Create: `.claude/commands/core/sync-context.md`
- Create: `.claude/commands/knowledge/create-kb.md`
- Create: `.claude/commands/review/review.md`
- Create: `.claude/commands/README.md`

**Reference:** Read corresponding commands from `/home/lerry/models/agentspec/.claude/commands/core/`, `/home/lerry/models/agentspec/.claude/commands/knowledge/`, `/home/lerry/models/agentspec/.claude/commands/review/`.

- [ ] **Step 1: Port all 6 core commands**

These are largely language-agnostic. Port from agentspec with minimal changes:
- `sync-context.md`: Update to reference Go project structure and Bundle-Go CLAUDE.md
- `review.md`: Change lint/test references to Go tooling
- Others: port directly

- [ ] **Step 2: Create commands README.md**

Write the top-level commands README listing all 23 commands (7 SDD + 10 Go + 6 core).

- [ ] **Step 3: Commit**

```bash
git add .claude/commands/core/ .claude/commands/knowledge/ .claude/commands/review/ .claude/commands/README.md
git commit -m "feat: add 6 core/utility commands and commands README"
```

---

## Phase 7: Root Files

### Task 21: README, CHANGELOG, CONTRIBUTING, LICENSE

**Files:**
- Create: `README.md`
- Create: `CHANGELOG.md`
- Create: `CONTRIBUTING.md`
- Create: `LICENSE`

**Reference:** Read `/home/lerry/models/agentspec/README.md`, `/home/lerry/models/agentspec/CHANGELOG.md`, `/home/lerry/models/agentspec/CONTRIBUTING.md` for structure.

- [ ] **Step 1: Create README.md**

Write project README with:
- Banner/title: Bundle-Go
- Description: Claude Code plugin for Go Backend/API with Clean Architecture
- Key numbers (43 agents, 22 KB, 23 commands)
- Quick start (installation + first command examples)
- 5-phase pipeline diagram
- Command catalog (all 23)
- Agent categories overview
- KB domains list
- Clean Architecture diagram
- Contributing link

- [ ] **Step 2: Create CHANGELOG.md**

```markdown
# Changelog

## [1.0.0] - 2026-03-27

### Added
- 43 specialized agents across 8 categories
- 22 KB domains for Go Backend/API
- 23 slash commands (7 SDD + 10 Go + 6 core)
- 5-phase SDD workflow adapted for Go
- Clean Architecture enforcement
- Go-specific quality gates (golangci-lint, go vet, go test -race)
```

- [ ] **Step 3: Create CONTRIBUTING.md**

Port from agentspec, adapted for Go contribution guidelines.

- [ ] **Step 4: Create LICENSE**

MIT license.

- [ ] **Step 5: Commit**

```bash
git add README.md CHANGELOG.md CONTRIBUTING.md LICENSE
git commit -m "feat: add README, CHANGELOG, CONTRIBUTING, LICENSE"
```

---

## Execution Summary

| Phase | Tasks | Files | Parallelizable |
|-------|-------|-------|----------------|
| 1. Foundation | 1-3 | ~5 | Sequential |
| 2. SDD Framework | 4-5 | ~10 | Sequential |
| 3. Workflow | 6-7 | 13 | Tasks 6+7 parallel |
| 4. KB Domains | 8-11 | ~130+ | Tasks 8, 9, 10 parallel |
| 5. Specialist Agents | 12-18 | 37 | All tasks parallel |
| 6. Commands | 19-20 | 18 | Tasks 19+20 parallel |
| 7. Root Files | 21 | 4 | Sequential |

**Total:** 21 tasks, ~215+ files

**Critical dependency chain:** Task 1 -> Tasks 2+3 (parallel) -> Tasks 4-5 -> Everything else

**Phase ordering notes:**
- Tasks 8-10 (KB domains) and 12-18 (specialist agents) can run in parallel after Phase 2 completes
- Agents reference KB domains by canonical name from the spec (e.g., `gin`, `sqlc`) -- they do NOT depend on KB files existing first. Both phases can execute simultaneously.
- The listed files per KB domain are the **required minimum set**. Subagents may add additional files if the domain warrants it.
