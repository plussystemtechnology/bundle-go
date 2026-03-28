# Gin KB Domain

> HTTP framework for Go — routing, middleware, binding, validation, error responses.

## Topics

- **Routing** — Route registration, groups, parameters, wildcard routes
- **Binding & Validation** — Request binding (JSON/XML/Form), struct tags, custom validators
- **Middleware Chain** — Handler chain, `c.Next()`, `c.Abort()`, execution order
- **Error Responses** — Structured error responses, `c.AbortWithStatusJSON`, error types
- **CRUD Handlers** — Standard handler patterns for Create, Read, Update, Delete
- **Route Groups** — API versioning, auth-protected groups, nested groups
- **Custom Validators** — `go-playground/validator` custom rules
- **Pagination** — Cursor-based and offset pagination patterns

## Concepts

- `concepts/routing.md` — Route registration and parameter handling
- `concepts/binding-validation.md` — Request binding and struct validation
- `concepts/middleware-chain.md` — Middleware execution model
- `concepts/error-responses.md` — Structured API error responses

## Patterns

- `patterns/crud-handler.md` — Complete CRUD handler set
- `patterns/route-groups.md` — API versioning with route groups
- `patterns/custom-validators.md` — Custom validation rules
- `patterns/pagination.md` — Pagination patterns
