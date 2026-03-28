# OpenAPI 3.0 Overview

## Structure

```yaml
openapi: "3.0.0"
info:
  title: BundleGo API
  version: "1.0"
paths:
  /users:
    get: ...
    post: ...
  /users/{id}:
    get: ...
components:
  schemas:
    User: ...
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
```

## Key Concepts

- **Paths** — API endpoints with HTTP methods
- **Operations** — GET/POST/PUT/DELETE on a path
- **Components** — Reusable schemas, security schemes, parameters
- **Tags** — Group operations for organization

## Swaggo generates OpenAPI from Go comments

The `swag init` command parses Go comments and generates:
- `docs/swagger.json` — OpenAPI spec in JSON
- `docs/swagger.yaml` — OpenAPI spec in YAML
- `docs/docs.go` — Go package for embedding

These files are committed to the repo and served by gin-swagger at `/swagger/*`.
