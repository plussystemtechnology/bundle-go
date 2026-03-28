---
name: swagger
description: Add Swagger/OpenAPI annotations to handlers — delegates to swagger-builder agent
---

# Swagger Command

> Add swaggo annotations to Gin handlers, run `swag init`, and validate the generated docs.

## Usage

```bash
/swagger <description-or-file>
```

## Examples

```bash
/swagger "Generate docs for order handlers"
/swagger internal/adapter/handler/http/order.go
/swagger internal/adapter/handler/http/
/swagger path/to/spec.md
```

---

## What This Command Does

1. Invokes the **swagger-builder** agent
2. Analyzes the target handler file(s) or description
3. Loads KB patterns from `swagger` and `gin` domains
4. Generates: swaggo annotations inline, runs `swag init`, validates output

## Agent Delegation

| Agent | Role |
|-------|------|
| `swagger-builder` | Primary — adds @Summary, @Param, @Success, @Failure annotations |
| `rest-designer` | Escalation — API contract design, response schema modeling |
| `gin-specialist` | Escalation — route analysis, handler group structure |

## KB Domains Used

- `swagger` — swaggo annotation syntax, schema tags, security definitions
- `gin` — Handler signature analysis, route group parsing

## Output

- Inline swaggo annotations added to existing handler files
- `docs/swagger.json` and `docs/swagger.yaml` via `swag init`
- `docs/docs.go` generated Go docs
- Validation report of missing or malformed annotations
