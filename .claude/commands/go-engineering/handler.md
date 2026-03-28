---
name: handler
description: Scaffold a Gin HTTP handler — delegates to handler-builder agent
---

# Handler Command

> Scaffold production-ready Gin HTTP handlers with request/response structs and route registration.

## Usage

```bash
/handler <description-or-file>
```

## Examples

```bash
/handler "CRUD handler for orders with pagination"
/handler "WebSocket handler for real-time notifications"
/handler "POST /auth/login with JWT response"
/handler path/to/spec.md
```

---

## What This Command Does

1. Invokes the **handler-builder** agent
2. Analyzes your description or requirements file
3. Loads KB patterns from `gin`, `middleware`, and `error-handling` domains
4. Generates: Gin handler files, request/response structs, route registration, input validation

## Agent Delegation

| Agent | Role |
|-------|------|
| `handler-builder` | Primary — scaffolds Gin handler with full lifecycle |
| `gin-specialist` | Escalation — complex routing, middleware chains, engine config |
| `auth-specialist` | Escalation — auth handlers, JWT extraction, role guards |

## KB Domains Used

- `gin` — Handler patterns, binding, context usage, route groups
- `middleware` — Middleware integration and ordering
- `error-handling` — Standardized error responses and sentinel errors

## Output

- `internal/adapter/handler/http/<resource>_handler.go` — Handler struct and methods
- `internal/adapter/handler/http/<resource>_handler_test.go` — Table-driven tests
- Route registration snippet for `bootstrap/router.go`
- Request/response struct definitions with validation tags
