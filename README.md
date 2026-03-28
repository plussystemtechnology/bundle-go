# Bundle-Go

> Claude Code plugin for Go Backend/API development with Clean Architecture

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-blue)](https://claude.ai/claude-code)
[![Version](https://img.shields.io/badge/Version-1.0.0-green)](CHANGELOG.md)
[![Agents](https://img.shields.io/badge/Agents-43-purple)](.claude/agents/)
[![KB Domains](https://img.shields.io/badge/KB%20Domains-22-orange)](.claude/kb/)
[![Commands](https://img.shields.io/badge/Commands-23-red)](.claude/commands/)

**[Quick Start](#quick-start)** · **[Go Engineering](#go-engineering-commands)** · **[Documentation](#project-structure)** · **[Contributing](CONTRIBUTING.md)**

---

## The Problem

Go backend development with AI assistants produces inconsistent results: wrong architecture, missing error handling, bad concurrency patterns, generated code that ignores Clean Architecture layer boundaries. Each conversation starts from scratch, with no memory of your stack, your conventions, or the decisions already made.

---

## The Solution

Bundle-Go brings **Spec-Driven Development (SDD)** to Go Backend/API on Claude Code. A 5-phase workflow, 43 specialized agents, 22 KB domains, and 23 commands — all tuned for Go.

```
/bundle-go:workflow:brainstorm → /bundle-go:workflow:define → /bundle-go:workflow:design → /bundle-go:workflow:build → /bundle-go:workflow:ship
```

Every phase understands Go: Clean Architecture layers, Gin handlers, sqlc queries, pgx pools, Kafka consumers, gRPC services. Quality gates run automatically: `golangci-lint`, `go vet`, `go test -race`, `staticcheck`.

---

## Quick Start

### Install via Claude Code Marketplace (recommended)

```bash
/plugin marketplace add plussystemtechnology/bundle-go
/plugin install bundle-go@bundle-go
```

### Install via skills.sh

```bash
npx skills add plussystemtechnology/bundle-go
```

### Manual install

```bash
git clone https://github.com/plussystemtechnology/bundle-go
cp -r bundle-go/.claude your-go-project/.claude
```

### SDD Workflow

```bash
# Phase 0 — Explore an idea (optional)
/bundle-go:workflow:brainstorm "Add JWT authentication middleware"

# Phase 1 — Capture requirements
/bundle-go:workflow:define JWT_AUTH

# Phase 2 — Design the architecture
/bundle-go:workflow:design JWT_AUTH

# Phase 3 — Build it
/bundle-go:workflow:build JWT_AUTH

# Phase 4 — Ship when complete
/bundle-go:workflow:ship JWT_AUTH
```

### Go Engineering Commands

```bash
# Scaffold a Gin handler
/bundle-go:go-engineering:handler "POST /auth/login with JWT response"

# Generate a service layer
/bundle-go:go-engineering:service "AuthService with login and refresh token"

# Create a sqlc repository
/bundle-go:go-engineering:repository "UserRepository with CRUD operations"

# Generate a Kafka consumer
/bundle-go:go-engineering:kafka-consumer "OrderCreatedConsumer with dead-letter queue"

# Add Swagger annotations
/bundle-go:go-engineering:swagger internal/adapter/http/handler/auth.go

# Generate a gRPC service
/bundle-go:go-engineering:proto "UserService with GetUser and ListUsers"

# Gin middleware
/bundle-go:go-engineering:middleware "RateLimiter with Redis backend"

# SQL migration
/bundle-go:go-engineering:migration "create users table with soft delete"
```

---

## What You Get

### 5-Phase Workflow

| Phase | Command | What It Does | Quality Gate |
|-------|---------|-------------|--------------|
| 0 — Brainstorm | `/bundle-go:workflow:brainstorm` | Explore ideas before committing to requirements | — |
| 1 — Define | `/bundle-go:workflow:define` | Capture and validate requirements | Requirements checklist |
| 2 — Design | `/bundle-go:workflow:design` | Architecture, API contracts, DB schema | Layer import rules |
| 3 — Build | `/bundle-go:workflow:build` | Implement with agent delegation | golangci-lint, go test -race |
| 4 — Ship | `/bundle-go:workflow:ship` | Archive feature with lessons learned | Full test suite |

### 43 Specialized Agents

| Category | Count | Agents |
|----------|-------|--------|
| Workflow | 6 | brainstorm, define, design, build, ship, iterate |
| Architect | 6 | api-architect, clean-arch-architect, pipeline-architect, platform-engineer, schema-designer, the-planner |
| Go Core | 6 | config-specialist, go-developer, handler-builder, middleware-builder, repository-builder, service-builder |
| API | 6 | api-gateway-specialist, auth-specialist, gin-specialist, grpc-specialist, rest-designer, swagger-builder |
| Data | 6 | cache-specialist, event-store-specialist, kafka-specialist, migration-specialist, pgx-specialist, sqlc-specialist |
| Cloud | 4 | aws-deployer, ci-cd-specialist, docker-specialist, k8s-specialist |
| Observability | 4 | health-check-specialist, logging-specialist, otel-specialist, prometheus-specialist |
| Test | 5 | test-generator, integration-test-specialist, benchmark-specialist, security-scanner, code-reviewer |

### 22 KB Domains

| Category | Domains |
|----------|---------|
| Core Go (6) | clean-architecture, go-patterns, concurrency, error-handling, testing, zap |
| Stack (9) | gin, sqlc, pgx, kafka, grpc, swagger, auth, middleware, migrations |
| Infra (7) | docker, kubernetes, ci-cd, prometheus, otel, security, cache |

### 23 Slash Commands

| Category | Commands |
|----------|---------|
| SDD Workflow (7) | `/bundle-go:workflow:brainstorm`, `/bundle-go:workflow:define`, `/bundle-go:workflow:design`, `/bundle-go:workflow:build`, `/bundle-go:workflow:ship`, `/bundle-go:workflow:iterate`, `/bundle-go:workflow:create-pr` |
| Go Engineering (10) | `/bundle-go:go-engineering:handler`, `/bundle-go:go-engineering:service`, `/bundle-go:go-engineering:repository`, `/bundle-go:go-engineering:migration`, `/bundle-go:go-engineering:middleware`, `/bundle-go:go-engineering:proto`, `/bundle-go:go-engineering:kafka-consumer`, `/bundle-go:go-engineering:swagger`, `/bundle-go:go-engineering:security-scan`, `/bundle-go:go-engineering:go-review` |
| Core Utilities (4) | `/bundle-go:core:meeting`, `/bundle-go:core:memory`, `/bundle-go:core:readme-maker`, `/bundle-go:core:sync-context` |
| Knowledge (1) | `/bundle-go:knowledge:create-kb` |
| Review (1) | `/bundle-go:review:review` |

---

## How It Works

When you run `/bundle-go:workflow:build`, the build agent reads your design document and delegates to the right specialist:

```
/bundle-go:workflow:design JWT_AUTH
        │
        ▼
  design-agent
  (reads DESIGN.md)
        │
        ├──► handler-builder     → internal/adapter/http/handler/auth.go
        ├──► service-builder     → internal/app/service/auth_service.go
        ├──► repository-builder  → internal/adapter/db/repository/user_repo.go
        ├──► middleware-builder  → internal/adapter/http/middleware/jwt.go
        └──► auth-specialist     → token generation, validation, refresh

/bundle-go:workflow:build JWT_AUTH
        │
        ▼
  build-agent
  (delegates + verifies)
        │
        └──► go vet ./...
             golangci-lint run
             go test -race -cover ./...
```

Agent matching is automatic — the build agent reads the design document, identifies the layers touched, and routes to the correct specialist agents.

---

## Project Structure

```text
.claude/
├── agents/              # 43 specialized agents
│   ├── workflow/        # 6 SDD phase agents
│   ├── architect/       # 6 system-level design
│   ├── go-core/         # 6 Clean Arch layer builders
│   ├── api/             # 6 API specialists
│   ├── data/            # 6 data/messaging
│   ├── cloud/           # 4 infra/deploy
│   ├── observability/   # 4 monitoring/tracing
│   └── test/            # 5 testing/quality
│
├── commands/            # 23 slash commands
│   ├── workflow/        # SDD phases (7)
│   ├── go-engineering/  # Go commands (10)
│   ├── core/            # Utilities (4)
│   ├── knowledge/       # KB management (1)
│   └── review/          # Code review (1)
│
├── sdd/                 # SDD framework
│   ├── architecture/    # WORKFLOW_CONTRACTS.yaml
│   ├── templates/       # 5 phase templates
│   ├── features/        # Active features
│   ├── reports/         # Build reports
│   └── archive/         # Shipped features
│
└── kb/                  # 22 Knowledge Base domains
    ├── clean-architecture/  # Layer rules, DIP
    ├── gin/                 # Routing, middleware
    ├── sqlc/                # Query generation
    ├── pgx/                 # Connection pools
    ├── kafka/               # Consumer groups
    ├── grpc/                # Protobuf, streaming
    └── ... (and 16 more)
```

---

## Clean Architecture Layer Rules

| Layer | Allowed imports |
|-------|----------------|
| `domain/` | stdlib only |
| `port/` | domain only |
| `app/` | domain, port, config |
| `adapter/` | app, domain, port, config, pkg |
| `bootstrap/` | all layers |
| `cmd/` | bootstrap only |

---

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on adding agents, KB domains, commands, and bug fixes.

---

## License

MIT License — see [LICENSE](LICENSE) for details.
