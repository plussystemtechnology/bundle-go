# NoxCare-Go Development

> Claude Code plugin for Go Backend/API development with Clean Architecture and SDD workflow

---

## Project Context

**What is NoxCare-Go?** A Claude Code plugin that provides structured AI-assisted development through a 5-phase SDD workflow, specialized for Go Backend/API with Clean Architecture. It ships 43 specialized agents, 23 commands, and 22 KB domains.

**Current Status:** v1.0.0 — Initial release with full Go Backend/API coverage.

---

## Repository Structure

```text
noxcare-go/
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
│   │   ├── workflow/              # 7 SDD commands
│   │   ├── go-engineering/        # 10 Go-specific commands
│   │   ├── core/                  # 4 utility commands
│   │   ├── knowledge/             # 1 KB command
│   │   └── review/                # 1 review command
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

Use NoxCare-Go's own SDD workflow to develop Go Backend/API features:

```bash
# Phase 0 — Explore an idea (optional)
/brainstorm "Add JWT authentication middleware"

# Phase 1 — Capture requirements
/define JWT_AUTH

# Phase 2 — Design the architecture
/design JWT_AUTH

# Phase 3 — Build it
/build JWT_AUTH

# Phase 4 — Ship when complete
/ship JWT_AUTH

# Cross-phase — Update any existing document
/iterate JWT_AUTH
```

Go engineering examples:

```bash
# Scaffold a Gin handler
/handler "POST /auth/login with JWT response"

# Generate a service layer
/service "AuthService with login and refresh token"

# Create a sqlc repository
/repository "UserRepository with CRUD operations"

# Generate a Kafka consumer
/kafka-consumer "OrderCreatedConsumer with dead-letter queue"

# Add Swagger annotations
/swagger internal/adapter/http/handler/auth.go
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
| `/brainstorm` | Explore ideas (Phase 0) |
| `/define` | Capture requirements (Phase 1) |
| `/design` | Create architecture (Phase 2) |
| `/build` | Execute implementation (Phase 3) |
| `/ship` | Archive completed work (Phase 4) |
| `/iterate` | Update existing docs (Cross-phase) |
| `/create-pr` | Create pull request |

### Go Engineering (10)

| Command | Purpose |
|---------|---------|
| `/handler` | Gin HTTP handler scaffolding |
| `/service` | Application service layer |
| `/repository` | sqlc/pgx repository scaffolding |
| `/migration` | SQL migration files (golang-migrate) |
| `/middleware` | Gin middleware (auth, logging, rate-limit) |
| `/proto` | Protobuf + gRPC service definition |
| `/kafka-consumer` | Kafka consumer with error handling |
| `/swagger` | Swagger/OpenAPI annotations |
| `/security-scan` | Security audit (OWASP, secrets) |
| `/go-review` | Go-specific code review |

### Core & Utilities (6)

| Command | Purpose |
|---------|---------|
| `/create-kb` | Create KB domain |
| `/review` | General code review |
| `/meeting` | Meeting transcript analysis |
| `/memory` | Save session insights |
| `/sync-context` | Update CLAUDE.md |
| `/readme-maker` | Generate README |

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
