# Bundle-Go Development

> Claude Code plugin for Go Backend/API development with Clean Architecture and SDD workflow

---

## Project Context

**What is Bundle-Go?** A Claude Code plugin that provides structured AI-assisted development through a 5-phase SDD workflow, specialized for Go Backend/API with Clean Architecture. It ships 43 specialized agents, 23 commands, and 22 KB domains.

**Current Status:** v1.0.0 — Initial release with full Go Backend/API coverage.

---

## Repository Structure

```text
bundle-go/
├── .claude/
│   ├── agents/                    # 43 specialized agents (8 categories)
│   │   ├── workflow/              # 6 SDD phase agents
│   │   ├── architect/             # 6 system-level design
│   │   ├── go-core/               # 6 Clean Arch layer builders
│   │   ├── api/                   # 6 API specialists (REST + gRPC + Swagger)
│   │   ├── data/                  # 6 data/messaging specialists
│   │   ├── cloud/                 # 4 infra/deploy
│   │   ├── observability/         # 4 monitoring/tracing
│   │   ├── test/                  # 5 testing/quality/review
│   │   ├── _template.md           # Base template T1/T2/T3
│   │   └── README.md              # Agent routing + escalation map
│   │
│   ├── commands/                  # 23 slash commands
│   │   └── bundle-go/            # namespaced under bundle-go
│   │       ├── workflow/          # 7 SDD commands
│   │       ├── go-engineering/    # 10 Go-specific commands
│   │       ├── core/              # 4 utility commands
│   │       ├── knowledge/         # 1 KB command
│   │       └── review/            # 1 review command
│   │
│   ├── sdd/                       # SDD framework
│   │   ├── _index.md
│   │   ├── README.md
│   │   ├── architecture/          # WORKFLOW_CONTRACTS.yaml, ARCHITECTURE.md
│   │   ├── templates/             # 5 document templates (Go-aware)
│   │   ├── features/              # Active development
│   │   ├── reports/               # Build reports
│   │   └── archive/               # Shipped features
│   │
│   ├── kb/                        # 22 KB domains
│   │   ├── _index.yaml            # Domain registry
│   │   └── {domain}/              # 22 domains
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

## Development Workflow

Use Bundle-Go's own SDD workflow to develop Go Backend/API features:

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

# Cross-phase — Update any existing document
/bundle-go:workflow:iterate JWT_AUTH
```

Go engineering examples:

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
```

---

## Coding Standards

### Go

- **Format:** `gofmt -w .`
- **Lint:** `golangci-lint run`
- **Vet:** `go vet ./... && staticcheck ./...`
- **Test:** `go test -race -cover ./...`
- **Build:** `CGO_ENABLED=0 go build ./cmd/api`

### Clean Architecture Layer Rules

| Layer | Allowed imports |
|-------|----------------|
| `domain/` | stdlib only |
| `port/` | domain only |
| `app/` | domain, port, config |
| `adapter/` | app, domain, port, config, pkg |
| `bootstrap/` | all layers |
| `cmd/` | bootstrap only |

### Never Do

- `panic()` for errors — return them
- Goroutine without lifecycle management (context cancellation / WaitGroup)
- `interface{}` without a clear need
- Import `adapter` into `domain`
- `SELECT *` in SQL queries
- Ignore `context.Context` in function signatures

### Markdown Files

- ATX-style headers (`#`, `##`, `###`)
- Fenced code blocks with language identifiers
- Tables properly aligned

### Agent Prompts

- Specific trigger conditions
- Clear capabilities list
- Concrete examples
- Defined output format
- `kb_domains` field referencing relevant KB domains

---

## Commands Available

### SDD Workflow (7)

| Command | Purpose |
|---------|---------|
| `/bundle-go:workflow:brainstorm` | Explore ideas (Phase 0) |
| `/bundle-go:workflow:define` | Capture requirements (Phase 1) |
| `/bundle-go:workflow:design` | Create architecture (Phase 2) |
| `/bundle-go:workflow:build` | Execute implementation (Phase 3) |
| `/bundle-go:workflow:ship` | Archive completed work (Phase 4) |
| `/bundle-go:workflow:iterate` | Update existing docs (Cross-phase) |
| `/bundle-go:workflow:create-pr` | Create pull request |

### Go Engineering (10)

| Command | Purpose |
|---------|---------|
| `/bundle-go:go-engineering:handler` | Gin HTTP handler scaffolding |
| `/bundle-go:go-engineering:service` | Application service layer |
| `/bundle-go:go-engineering:repository` | sqlc/pgx repository scaffolding |
| `/bundle-go:go-engineering:migration` | SQL migration files (golang-migrate) |
| `/bundle-go:go-engineering:middleware` | Gin middleware (auth, logging, rate-limit) |
| `/bundle-go:go-engineering:proto` | Protobuf + gRPC service definition |
| `/bundle-go:go-engineering:kafka-consumer` | Kafka consumer with error handling |
| `/bundle-go:go-engineering:swagger` | Swagger/OpenAPI annotations |
| `/bundle-go:go-engineering:security-scan` | Security audit (OWASP, secrets) |
| `/bundle-go:go-engineering:go-review` | Go-specific code review |

### Core & Utilities (6)

| Command | Purpose |
|---------|---------|
| `/bundle-go:knowledge:create-kb` | Create KB domain |
| `/bundle-go:review:review` | General code review |
| `/bundle-go:core:meeting` | Meeting transcript analysis |
| `/bundle-go:core:memory` | Save session insights |
| `/bundle-go:core:sync-context` | Update CLAUDE.md |
| `/bundle-go:core:readme-maker` | Generate README |

---

## Key Files to Know

| File | Purpose |
|------|---------|
| `.claude/sdd/architecture/WORKFLOW_CONTRACTS.yaml` | Phase transition rules |
| `.claude/sdd/templates/*.md` | SDD document templates (Go-aware) |
| `.claude/kb/_index.yaml` | KB domain registry (22 domains) |
| `.claude/agents/README.md` | Agent routing + escalation map |
| `.claude/agents/_template.md` | Base agent template T1/T2/T3 |
| `.claude/agents/workflow/` | SDD phase agents (define, design, build…) |
| `.claude/agents/go-core/` | Clean Architecture layer builders |
| `.claude/agents/api/` | REST, gRPC, Swagger specialists |
| `.claude/agents/data/` | sqlc, pgx, Kafka, Redis specialists |
| `.claude/agents/test/` | Testing, benchmarking, code review |
| `.claude/agents/cloud/` | Docker, Kubernetes, Terraform, CI/CD |
| `.claude/agents/observability/` | OpenTelemetry, Prometheus, logging |
| `.claude/settings.json` | Claude Code permissions + hooks |

---

## Version

- **Version:** 1.0.0
- **Status:** Release
- **Last Updated:** 2026-03-27
