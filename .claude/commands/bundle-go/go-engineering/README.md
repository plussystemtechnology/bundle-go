# Go Engineering Commands

> 10 commands that scaffold, generate, and review Go Backend/API code — each delegates to a specialized agent with KB domain knowledge.

## Commands

| Command | Description | Primary Agent |
|---------|-------------|---------------|
| `/handler` | Scaffold a Gin HTTP handler with request/response structs | `handler-builder` |
| `/service` | Generate an application service layer with port interfaces | `service-builder` |
| `/repository` | Scaffold a sqlc/pgx repository with query files | `repository-builder` |
| `/migration` | Generate golang-migrate up/down SQL migration files | `migration-specialist` |
| `/middleware` | Generate Gin middleware (auth, logging, rate-limit) | `middleware-builder` |
| `/proto` | Generate Protobuf definitions and gRPC server adapter | `grpc-specialist` |
| `/kafka-consumer` | Generate a Kafka consumer with DLQ and retry logic | `kafka-specialist` |
| `/swagger` | Add swaggo annotations and generate OpenAPI docs | `swagger-builder` |
| `/security-scan` | Security audit with gosec, govulncheck, and OWASP mapping | `security-scanner` |
| `/go-review` | Go-specific code review covering quality, security, and architecture | `code-reviewer` |

---

## Quick Start

```bash
# Scaffold a new REST resource end-to-end
/handler "CRUD handler for orders with pagination"
/service "OrderService with create, update, cancel"
/repository "Orders with search and soft-delete"
/migration "Create orders table with indexes"

# Add API documentation
/swagger internal/adapter/handler/http/order.go

# Add a Kafka consumer for async processing
/kafka-consumer "Order events with dead letter queue"

# Security and quality checks
/security-scan
/go-review internal/
```

---

## How Commands Work

Each command is a thin delegation layer:

1. **Trigger** — You run `/command "description"` or `/command path/to/file`
2. **Agent activation** — The primary agent is invoked with your input
3. **KB loading** — The agent loads relevant KB domains for patterns and conventions
4. **Generation** — Files are created following Clean Architecture layer rules
5. **Escalation** — If the task exceeds the primary agent's scope, a specialist is escalated to automatically

All generated code follows the project's Clean Architecture layer import rules and Go coding standards (`gofmt`, `golangci-lint`, `go vet`).

---

## Agent Escalation Map

| Primary Agent | Escalates To | When |
|---------------|-------------|------|
| `handler-builder` | `gin-specialist` | Complex routing or middleware chains |
| `handler-builder` | `auth-specialist` | Authentication/authorization handlers |
| `service-builder` | `clean-arch-architect` | Layer design concerns |
| `service-builder` | `the-planner` | Multi-service orchestration |
| `repository-builder` | `sqlc-specialist` | Complex queries, CTEs, window functions |
| `repository-builder` | `pgx-specialist` | Pool config, custom types, batching |
| `migration-specialist` | `schema-designer` | Complex schemas, normalization |
| `middleware-builder` | `auth-specialist` | JWT, OAuth2, RBAC |
| `grpc-specialist` | `api-architect` | Service contract design |
| `kafka-specialist` | `pipeline-architect` | Event topology, fan-out |
| `security-scanner` | `code-reviewer` | Deep review of flagged code |
| `code-reviewer` | `security-scanner` | Security-focused deep dive |
