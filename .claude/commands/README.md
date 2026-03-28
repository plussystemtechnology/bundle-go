# Commands Reference

> NoxCare-Go ships 23 slash commands across 5 categories. All commands are invoked via Claude Code's `/` prefix.

---

## Quick Start

```bash
# Start a new feature end-to-end
/brainstorm "Add JWT authentication middleware"
/define JWT_AUTH
/design JWT_AUTH
/build JWT_AUTH
/ship JWT_AUTH

# Scaffold Go code
/handler "POST /auth/login with JWT response"
/service "AuthService with login and refresh"
/repository "UserRepository with CRUD"

# Review and quality
/review
/review --deep internal/app/
/security-scan

# Utilities
/memory
/sync-context
```

---

## How Commands Work

Each command is a markdown file with YAML frontmatter. Claude Code reads the frontmatter (`name`, `description`) to register the slash command. The body describes the command's behavior, which Claude executes when invoked.

Commands may delegate to specialized agents (e.g., `/handler` delegates to `handler-builder`), call tools directly (e.g., `/review` runs `golangci-lint`), or drive SDD document workflows.

---

## SDD Workflow (7)

These commands drive the 5-phase Software Design Document workflow.

| Command | Phase | Purpose |
|---------|-------|---------|
| `/brainstorm <idea>` | 0 | Explore an idea through dialogue before committing |
| `/define <FEATURE>` | 1 | Capture requirements into `define.md` |
| `/design <FEATURE>` | 2 | Create architecture and technical spec into `design.md` |
| `/build <FEATURE>` | 3 | Execute implementation with agent delegation |
| `/ship <FEATURE>` | 4 | Archive completed feature with lessons learned |
| `/iterate <FEATURE>` | cross | Update any existing SDD document |
| `/create-pr` | cross | Create pull request with conventional commits |

SDD documents live in `.claude/sdd/features/<FEATURE>/`.

---

## Go Engineering (10)

These commands scaffold Go code following Clean Architecture conventions.

| Command | Purpose | Delegates To |
|---------|---------|-------------|
| `/handler "<description>"` | Gin HTTP handler | `handler-builder` |
| `/service "<description>"` | Application service layer | `service-builder` |
| `/repository "<description>"` | sqlc/pgx repository | `repository-builder` |
| `/migration "<description>"` | SQL migration files (golang-migrate) | `migration-specialist` |
| `/middleware "<description>"` | Gin middleware (auth, logging, rate-limit) | `middleware-builder` |
| `/proto "<description>"` | Protobuf + gRPC service definition | `grpc-specialist` |
| `/kafka-consumer "<description>"` | Kafka consumer with dead-letter queue | `kafka-specialist` |
| `/swagger <file>` | Add Swagger/OpenAPI annotations | `swagger-builder` |
| `/security-scan` | OWASP + secrets audit | `security-scanner` |
| `/go-review` | Go-specific code review | `code-reviewer` |

---

## Core Utilities (4)

| Command | Purpose |
|---------|---------|
| `/memory` | Save session insights to `.claude/storage/memory-{date}.md` |
| `/meeting` | Extract decisions and action items from a transcript |
| `/readme-maker` | Generate `README.md` by scanning the Go codebase |
| `/sync-context` | Analyze codebase and update `CLAUDE.md` |

---

## Knowledge (1)

| Command | Purpose |
|---------|---------|
| `/create-kb <DOMAIN>` | Scaffold a new KB domain with index, quick-reference, concepts/, patterns/ |
| `/create-kb --audit` | Verify all registered KB domains are consistent |

KB domains live in `.claude/kb/` and are registered in `.claude/kb/_index.yaml`.

---

## Review (1)

| Command | Purpose |
|---------|---------|
| `/review` | All changes vs main — static analysis + deep architectural review |
| `/review uncommitted` | Unstaged and staged changes only |
| `/review committed` | Commits ahead of main |
| `/review --quick` | Lint only (`golangci-lint`, `go vet`, `staticcheck`) |
| `/review --deep <path>` | Full architectural review of a specific path |

---

## Command File Locations

```
.claude/commands/
├── workflow/          # brainstorm, define, design, build, ship, iterate, create-pr
├── go-engineering/    # handler, service, repository, migration, middleware,
│                      # proto, kafka-consumer, swagger, security-scan, go-review
├── core/              # memory, meeting, readme-maker, sync-context
├── knowledge/         # create-kb
├── review/            # review
└── README.md          # this file
```
