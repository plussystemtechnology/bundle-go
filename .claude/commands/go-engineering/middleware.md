---
name: middleware
description: Generate Gin middleware — delegates to middleware-builder agent
---

# Middleware Command

> Generate production-ready Gin middleware for auth, logging, rate-limiting, and more.

## Usage

```bash
/middleware <description-or-file>
```

## Examples

```bash
/middleware "JWT auth with role-based access"
/middleware "Rate limiting with Redis"
/middleware "Request logging with correlation ID"
/middleware path/to/spec.md
```

---

## What This Command Does

1. Invokes the **middleware-builder** agent
2. Analyzes your description or requirements file
3. Loads KB patterns from `middleware`, `gin`, and `security` domains
4. Generates: Middleware function, configuration struct, registration helper, tests

## Agent Delegation

| Agent | Role |
|-------|------|
| `middleware-builder` | Primary — generates Gin middleware with proper context handling |
| `auth-specialist` | Escalation — JWT validation, OAuth2, RBAC, session management |
| `gin-specialist` | Escalation — engine-level config, recovery middleware, trusted proxies |

## KB Domains Used

- `middleware` — Gin middleware patterns, context key conventions, abort flow
- `gin` — Handler context, request binding, response helpers
- `security` — Token validation, header inspection, OWASP middleware checklist

## Output

- `internal/adapter/middleware/http/<name>_middleware.go` — Middleware function and config struct
- `internal/adapter/middleware/http/<name>_middleware_test.go` — Table-driven middleware tests
- Registration snippet for `bootstrap/router.go`
- Configuration loading from environment or options pattern
