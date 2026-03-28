# Middleware KB Domain

> Gin middleware patterns — auth, CORS, rate limiting, request ID, recovery.

## Topics

- **Middleware Chain** — Execution order, c.Next(), c.Abort()
- **Context Propagation** — Passing data through middleware chain
- **Request Lifecycle** — Pre/post processing, timing, cleanup
- **Auth Middleware** — JWT validation, role checking
- **CORS** — Cross-origin resource sharing configuration
- **Rate Limiter** — Request rate limiting
- **Request ID** — Correlation ID injection
- **Recovery** — Panic recovery with structured logging

## Concepts

- `concepts/middleware-chain.md` — Chain execution model
- `concepts/context-propagation.md` — Data passing patterns
- `concepts/request-lifecycle.md` — Request lifecycle hooks

## Patterns

- `patterns/auth-middleware.md` — Authentication middleware
- `patterns/cors.md` — CORS configuration
- `patterns/rate-limiter.md` — Rate limiting middleware
- `patterns/request-id.md` — Request ID middleware
- `patterns/recovery.md` — Panic recovery middleware
