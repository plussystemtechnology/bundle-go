# Commands Reference

> Bundle-Go ships 23 slash commands across 5 categories. All commands are invoked via Claude Code's `/` prefix.

---

## Quick Start

```bash
# Start a new feature end-to-end
/bundle-go:workflow:brainstorm "Add JWT authentication middleware"
/bundle-go:workflow:define JWT_AUTH
/bundle-go:workflow:design JWT_AUTH
/bundle-go:workflow:build JWT_AUTH
/bundle-go:workflow:ship JWT_AUTH

# Scaffold Go code
/bundle-go:go-engineering:handler "POST /auth/login with JWT response"
/bundle-go:go-engineering:service "AuthService with login and refresh"
/bundle-go:go-engineering:repository "UserRepository with CRUD"

# Review and quality
/bundle-go:review:review
/bundle-go:review:review --deep internal/app/
/bundle-go:go-engineering:security-scan

# Utilities
/bundle-go:core:memory
/bundle-go:core:sync-context
```

---

## How Commands Work

Each command is a markdown file with YAML frontmatter. Claude Code reads the frontmatter (`name`, `description`) to register the slash command. The body describes the command's behavior, which Claude executes when invoked.

Commands may delegate to specialized agents (e.g., `/bundle-go:go-engineering:handler` delegates to `handler-builder`), call tools directly (e.g., `/bundle-go:review:review` runs `golangci-lint`), or drive SDD document workflows.

---

## SDD Workflow (7)

These commands drive the 5-phase Software Design Document workflow.

| Command | Phase | Purpose |
|---------|-------|---------|
| `/bundle-go:workflow:brainstorm <idea>` | 0 | Explore an idea through dialogue before committing |
| `/bundle-go:workflow:define <FEATURE>` | 1 | Capture requirements into `define.md` |
| `/bundle-go:workflow:design <FEATURE>` | 2 | Create architecture and technical spec into `design.md` |
| `/bundle-go:workflow:build <FEATURE>` | 3 | Execute implementation with agent delegation |
| `/bundle-go:workflow:ship <FEATURE>` | 4 | Archive completed feature with lessons learned |
| `/bundle-go:workflow:iterate <FEATURE>` | cross | Update any existing SDD document |
| `/bundle-go:workflow:create-pr` | cross | Create pull request with conventional commits |

SDD documents live in `.claude/sdd/features/<FEATURE>/`.

---

## Go Engineering (10)

These commands scaffold Go code following Clean Architecture conventions.

| Command | Purpose | Delegates To |
|---------|---------|-------------|
| `/bundle-go:go-engineering:handler "<description>"` | Gin HTTP handler | `handler-builder` |
| `/bundle-go:go-engineering:service "<description>"` | Application service layer | `service-builder` |
| `/bundle-go:go-engineering:repository "<description>"` | sqlc/pgx repository | `repository-builder` |
| `/bundle-go:go-engineering:migration "<description>"` | SQL migration files (golang-migrate) | `migration-specialist` |
| `/bundle-go:go-engineering:middleware "<description>"` | Gin middleware (auth, logging, rate-limit) | `middleware-builder` |
| `/bundle-go:go-engineering:proto "<description>"` | Protobuf + gRPC service definition | `grpc-specialist` |
| `/bundle-go:go-engineering:kafka-consumer "<description>"` | Kafka consumer with dead-letter queue | `kafka-specialist` |
| `/bundle-go:go-engineering:swagger <file>` | Add Swagger/OpenAPI annotations | `swagger-builder` |
| `/bundle-go:go-engineering:security-scan` | OWASP + secrets audit | `security-scanner` |
| `/bundle-go:go-engineering:go-review` | Go-specific code review | `code-reviewer` |

---

## Core Utilities (4)

| Command | Purpose |
|---------|---------|
| `/bundle-go:core:memory` | Save session insights to `.claude/storage/memory-{date}.md` |
| `/bundle-go:core:meeting` | Extract decisions and action items from a transcript |
| `/bundle-go:core:readme-maker` | Generate `README.md` by scanning the Go codebase |
| `/bundle-go:core:sync-context` | Analyze codebase and update `CLAUDE.md` |

---

## Knowledge (1)

| Command | Purpose |
|---------|---------|
| `/bundle-go:knowledge:create-kb <DOMAIN>` | Scaffold a new KB domain with index, quick-reference, concepts/, patterns/ |
| `/bundle-go:knowledge:create-kb --audit` | Verify all registered KB domains are consistent |

KB domains live in `.claude/kb/` and are registered in `.claude/kb/_index.yaml`.

---

## Review (1)

| Command | Purpose |
|---------|---------|
| `/bundle-go:review:review` | All changes vs main — static analysis + deep architectural review |
| `/bundle-go:review:review uncommitted` | Unstaged and staged changes only |
| `/bundle-go:review:review committed` | Commits ahead of main |
| `/bundle-go:review:review --quick` | Lint only (`golangci-lint`, `go vet`, `staticcheck`) |
| `/bundle-go:review:review --deep <path>` | Full architectural review of a specific path |

---

## Command File Locations

```
.claude/commands/
└── bundle-go/
    ├── workflow/          # brainstorm, define, design, build, ship, iterate, create-pr
    ├── go-engineering/    # handler, service, repository, migration, middleware,
    │                      # proto, kafka-consumer, swagger, security-scan, go-review
    ├── core/              # memory, meeting, readme-maker, sync-context
    ├── knowledge/         # create-kb
    ├── review/            # review
    └── README.md          # this file
```
