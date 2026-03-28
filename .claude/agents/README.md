# Bundle-Go Agents

Bundle-Go deploys **43 specialized agents** across **8 categories**, each built on a **three-tier template system** with mandatory **KB-First knowledge resolution**. Every agent carries a cognitive framework that enforces structured confidence scoring, provenance tracking, and explicit stop conditions -- turning raw LLM capability into disciplined, auditable Go backend expertise.

`43 agents | 8 categories | 3 tiers (T1/T2/T3) | Clean Architecture | KB-First`

---

## How Agents Work (Cognitive Architecture)

Bundle-Go agents are not raw LLM prompts. They operate through a three-layer cognitive architecture that separates routing, reasoning, and domain knowledge.

### Layer 1: Claude Code Orchestrator (Router)

The orchestrator is Claude Code itself. It reads all 43 agent description fields from frontmatter, pattern-matches user messages to agent capabilities, and launches the best-fit agent. The orchestrator:

- Maintains memory, tasks, and plans across messages
- Selects agents based on trigger phrases, file types, and context
- Receives structured responses with confidence scores
- Is a **generalist** -- it knows WHO to call, not HOW to do the work

### Layer 2: Agent Template (Cognitive Framework)

Every agent inherits from `_template.md`, which defines structured thinking:

- **KB-First Resolution** -- check local knowledge before external sources
- **Agreement Matrix** -- structured confidence scoring (KB vs MCP alignment)
- **Impact Tiers** -- CRITICAL/IMPORTANT/STANDARD/ADVISORY with thresholds
- **Stop Conditions** -- agents know when to REFUSE or ESCALATE
- **Provenance** -- every response cites confidence score and sources
- **Go Anti-Patterns** -- shared table of Go-specific mistakes to avoid

### Layer 3: Agent Instance (Domain Specialist)

Each agent adds domain-specific knowledge, capabilities, quality gates, and anti-patterns on top of the template framework. This layer carries the Go Backend/API expertise -- Gin, sqlc, pgx, Kafka, Redis, and so on.

### Request Flow

```text
User
  |
  v
Orchestrator (Claude Code)
  |-- reads 43 agent descriptions from frontmatter
  |-- pattern-matches message to capabilities
  |-- selects best-fit agent
  v
Agent Instance
  |-- KB-First: read .claude/kb/{domain}/
  |-- Agreement Matrix: calculate confidence
  |-- Impact Tier: check threshold for task type
  |-- Clean Architecture: enforce layer boundaries
  |-- Execute (confidence met) or Stop (below threshold)
  v
Response with Provenance
  |-- confidence score
  |-- sources cited (KB file, MCP query, codebase path)
```

---

## Agent Tiers (T1 / T2 / T3)

Every agent declares a tier in frontmatter (`tier: T1|T2|T3`). The tier governs which template sections are required and sets a line budget.

| Tier | Name | Lines | Purpose | Examples |
|------|------|-------|---------|----------|
| **T1** | Utility | 80-150 | Single-concern tools | go-developer, config-specialist, logging-specialist |
| **T2** | Domain Expert | 150-350 | KB domains, structured decisions | handler-builder, service-builder, code-reviewer |
| **T3** | Platform Specialist | 350-600 | Deep expertise, error recovery | gin-specialist, k8s-specialist, otel-specialist |

### Section-by-Tier Matrix

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

---

## Core Principle: KB-First Resolution

Every agent follows this mandatory knowledge resolution order. Agents that skip KB and go straight to MCP are violating the architecture.

### Resolution Order

```text
1. KB CHECK       Read .claude/kb/{domain}/index.md -- scan headings only (~20 lines)
2. ON-DEMAND LOAD Read specific pattern/concept file matching the task (one file, not all)
3. MCP FALLBACK   Single query if KB insufficient (max 3 MCP calls per task)
4. CONFIDENCE     Calculate from Agreement Matrix (never self-assess)
```

### Agreement Matrix

```text
                 | MCP AGREES     | MCP DISAGREES  | MCP SILENT     |
-----------------+----------------+----------------+----------------+
KB HAS PATTERN   | HIGH (0.95)    | CONFLICT(0.50) | MEDIUM (0.75)  |
                 | -> Execute     | -> Investigate | -> Proceed     |
-----------------+----------------+----------------+----------------+
KB SILENT        | MCP-ONLY(0.85) | N/A            | LOW (0.50)     |
                 | -> Proceed     |                | -> Ask User    |
```

### Impact Tiers

| Tier | Threshold | Action if Below | Examples |
|------|-----------|-----------------|----------|
| CRITICAL | 0.95 | REFUSE + explain | DB migrations, production config, delete ops |
| IMPORTANT | 0.90 | ASK user first | Service creation, auth config, Kafka topics |
| STANDARD | 0.85 | PROCEED + caveat | Code generation, documentation |
| ADVISORY | 0.75 | PROCEED freely | Explanations, comparisons |

---

## Go Shared Anti-Patterns

All agents enforce this table. These are Go-specific mistakes the entire system must avoid.

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

## Agent Categories

### 1. Workflow (6 agents)

Drive the SDD workflow phases from brainstorm to ship.

| Agent | Tier | Model | Phase | Purpose |
|-------|------|-------|-------|---------|
| `brainstorm-agent` | T2 | sonnet | 0 | Explore ideas through collaborative dialogue |
| `define-agent` | T2 | sonnet | 1 | Capture requirements with clarity scoring |
| `design-agent` | T2 | opus | 2 | Create technical architecture with file manifest |
| `build-agent` | T2 | sonnet | 3 | Execute implementation with agent delegation |
| `ship-agent` | T2 | haiku | 4 | Archive with lessons learned |
| `iterate-agent` | T2 | sonnet | All | Update documents with cascade awareness |

### 2. Architect (6 agents)

System-level design, Clean Architecture enforcement, and infrastructure decisions.

| Agent | Tier | Model | Purpose |
|-------|------|-------|---------|
| `api-architect` | T2 | opus | API contract design, versioning strategy, REST standards |
| `schema-designer` | T2 | sonnet | PostgreSQL schema design, normalization, index strategy |
| `clean-arch-architect` | T2 | opus | Clean Architecture layer enforcement, dependency rules |
| `pipeline-architect` | T2 | sonnet | Kafka topology, event-driven design, async pipeline patterns |
| `platform-engineer` | T2 | sonnet | Infrastructure decisions, service mesh, platform capabilities |
| `the-planner` | T2 | opus | Strategic architecture and comprehensive implementation plans |

### 3. Go Core (6 agents)

Go language implementation specialists for every layer of Clean Architecture.

| Agent | Tier | Model | Purpose |
|-------|------|-------|---------|
| `go-developer` | T1 | sonnet | Go code architecture, error handling, idiomatic patterns |
| `handler-builder` | T2 | sonnet | HTTP handler construction, request/response binding, validation |
| `service-builder` | T2 | sonnet | Business logic services, use case implementation, domain rules |
| `repository-builder` | T2 | sonnet | Data access layer, repository patterns, query construction |
| `middleware-builder` | T2 | sonnet | Gin middleware, request lifecycle, cross-cutting concerns |
| `config-specialist` | T1 | sonnet | App configuration, env vars, viper/env loading patterns |

### 4. API (6 agents)

HTTP, gRPC, authentication, and API documentation specialists.

| Agent | Tier | Model | Purpose |
|-------|------|-------|---------|
| `gin-specialist` | T3 | sonnet | Gin framework deep expertise, routing, engine configuration |
| `grpc-specialist` | T3 | sonnet | gRPC service definitions, protobuf, streaming, interceptors |
| `rest-designer` | T2 | sonnet | RESTful API design, status codes, resource modeling |
| `auth-specialist` | T2 | opus | JWT, OAuth2, OIDC, Vault secrets, RBAC patterns |
| `swagger-builder` | T1 | sonnet | OpenAPI 3.0 spec generation, swaggo annotations |
| `api-gateway-specialist` | T1 | sonnet | API gateway patterns, rate limiting, request routing |

### 5. Data (6 agents)

Database, messaging, and caching layer specialists.

| Agent | Tier | Model | Purpose |
|-------|------|-------|---------|
| `sqlc-specialist` | T3 | sonnet | sqlc query generation, type-safe DB access, query patterns |
| `pgx-specialist` | T3 | sonnet | pgx driver, connection pools, transactions, bulk operations |
| `migration-specialist` | T2 | sonnet | golang-migrate, schema versioning, rollback strategy |
| `kafka-specialist` | T3 | sonnet | Kafka producers/consumers, sarama/confluent-kafka-go, topics |
| `cache-specialist` | T2 | sonnet | Redis caching patterns, go-redis, TTL strategy, cache invalidation |
| `event-store-specialist` | T1 | sonnet | Event sourcing, outbox pattern, event replay, CQRS |

### 6. Cloud (4 agents)

Deployment, containerization, and CI/CD pipeline specialists.

| Agent | Tier | Model | Purpose |
|-------|------|-------|---------|
| `k8s-specialist` | T3 | sonnet | Kubernetes manifests, Helm charts, health probes, scaling |
| `docker-specialist` | T2 | sonnet | Multi-stage Dockerfiles, compose, image optimization |
| `aws-deployer` | T2 | sonnet | ECS, ECR, RDS, ElastiCache, IAM, infrastructure as code |
| `ci-cd-specialist` | T3 | sonnet | GitHub Actions, pipeline automation, test/build/deploy stages |

### 7. Observability (4 agents)

Metrics, tracing, logging, and health monitoring specialists.

| Agent | Tier | Model | Purpose |
|-------|------|-------|---------|
| `prometheus-specialist` | T2 | sonnet | Prometheus metrics, custom collectors, alerting rules |
| `otel-specialist` | T3 | sonnet | OpenTelemetry tracing, spans, context propagation, exporters |
| `logging-specialist` | T1 | sonnet | Structured logging, zerolog/zap, log levels, correlation IDs |
| `health-check-specialist` | T1 | sonnet | Health endpoints, readiness/liveness probes, dependency checks |

### 8. Test & Quality (5 agents)

Testing, benchmarking, security, and code review specialists.

| Agent | Tier | Model | Purpose |
|-------|------|-------|---------|
| `test-generator` | T2 | sonnet | Go unit tests, table-driven tests, mocks with testify |
| `benchmark-specialist` | T1 | sonnet | Go benchmarks, profiling, pprof, performance analysis |
| `integration-test-specialist` | T2 | sonnet | Integration tests, testcontainers-go, DB fixtures |
| `security-scanner` | T1 | sonnet | SAST with gosec, dependency audits, secrets detection |
| `code-reviewer` | T2 | sonnet | Code review for quality, security, and Clean Architecture |

---

## Escalation Map

Agents are not isolated. When a task crosses domain boundaries, agents escalate to the appropriate specialist.

```text
Workflow <-> Go Core:
  build-agent -> handler-builder, service-builder, repository-builder
  design-agent -> clean-arch-architect, api-architect
  define-agent -> schema-designer

Go Core <-> Data:
  repository-builder -> sqlc-specialist, pgx-specialist
  service-builder -> kafka-specialist, cache-specialist

Go Core <-> API:
  handler-builder -> gin-specialist, auth-specialist, swagger-builder
  middleware-builder -> auth-specialist, gin-specialist

API <-> Data:
  grpc-specialist -> sqlc-specialist, kafka-specialist

API Internal:
  swagger-builder -> gin-specialist
  auth-specialist -> config-specialist

Test & Quality <-> All:
  test-generator -> handler-builder, repository-builder
  integration-test-specialist -> docker-specialist
  security-scanner -> ci-cd-specialist
  code-reviewer -> all layers

Cloud <-> Observability:
  k8s-specialist -> health-check-specialist, prometheus-specialist
  docker-specialist -> ci-cd-specialist
  otel-specialist -> logging-specialist

Architect <-> All:
  clean-arch-architect -> go-core/*
  pipeline-architect -> kafka-specialist + cache-specialist
  the-planner -> any agent
```

---

## When NOT to Create an Agent

Before creating a new agent, verify **all four** conditions are met:

1. **No existing agent covers >60% of this capability** -- check the escalation map above
2. **The new agent has a unique KB domain or tool combination** -- not just a renamed existing agent
3. **At least 3 distinct trigger scenarios exist** -- if fewer, it belongs as a capability of an existing agent
4. **No >80% overlap with an existing agent** -- if overlap exists, consolidate instead

If any condition fails, extend an existing agent rather than creating a new one.

---

## Creating Custom Agents

### Step-by-Step

1. **Check the "When NOT to Create" criteria** -- verify all four conditions
2. **Choose a tier** -- T1 for simple tools, T2 for domain experts, T3 for platform specialists with deep Go expertise
3. **Copy `_template.md`** to the appropriate category folder
4. **Fill in frontmatter** -- all required fields for your tier (see schema below)
5. **Write sections** required for your tier (see Section-by-Tier Matrix)
6. **Place in the correct category folder** -- architect, api, go-core, data, cloud, observability, test, or workflow
7. **Verify compliance** -- all required sections present, line count within budget, Go anti-patterns included

### Frontmatter Schema

**Required (all tiers):**

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Agent identifier (kebab-case, matches filename) |
| `description` | string | Purpose, trigger conditions, and 2 examples |
| `tools` | list | Available tools (Read, Write, Edit, Grep, Glob, Bash, etc.) |
| `kb_domains` | list | KB domains this agent reads (empty `[]` if none) |
| `color` | string | UI color: blue, green, orange, purple, red, or yellow |
| `tier` | string | T1, T2, or T3 |
| `anti_pattern_refs` | list | Always include `[shared-anti-patterns]` |

**Optional (defaults shown):**

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `model` | string | sonnet | LLM model: sonnet (default), opus (complex reasoning), haiku (fast) |

**Required for T2+ only:**

| Field | Type | Description |
|-------|------|-------------|
| `stop_conditions` | list | Conditions that cause the agent to halt or refuse |
| `escalation_rules` | list | Trigger/target/reason rules for cross-agent routing |

**Optional for T3:**

| Field | Type | Description |
|-------|------|-------------|
| `mcp_servers` | list | MCP server dependencies with name, tools, and purpose |

---

## Template v1.0 Reference

All agents inherit from `_template.md`. The template defines 12 sections:

| # | Section | Purpose |
|---|---------|---------|
| 1 | **Frontmatter** | Name, description, tools, KB domains, tier, color |
| 2 | **Identity** | Purpose, domain, threshold (blockquote format) |
| 3 | **Knowledge Resolution** | KB-First order, Agreement Matrix (T2+), Sources (T3) |
| 4 | **Capabilities** | When/Process/Output for each capability |
| 5 | **Constraints** | Domain boundaries and resource limits (T2+) |
| 6 | **Stop Conditions** | Hard stops, escalation rules, retry limits (T2+) |
| 7 | **Quality Gate** | Pre-flight checklist scaled to tier + Go-specific checks (T3) |
| 8 | **Response Format** | Standard + below-threshold (T2+) + conflict/low-confidence (T3) |
| 9 | **Anti-Patterns** | Go Shared + Agent-specific Never Do / Why / Instead table |
| 10 | **Error Recovery** | Error/recovery/fallback table including Go toolchain errors (T3) |
| 11 | **Extension Points** | How to extend capabilities, KB, MCP, lint rules (T3) |
| 12 | **Remember** | Motto, mission, core principle |

See `_template.md` for the full template with inline comments marking tier requirements.
