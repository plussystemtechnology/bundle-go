# sqlc KB Domain

> Type-safe SQL code generation for Go — write SQL, get Go code.

## Topics

- **Code Generation** — sqlc compile/generate workflow, config, output
- **Query Annotations** — `:one`, `:many`, `:exec`, `:execresult`, `:batchexec`
- **Custom Types** — Overrides for UUID, JSON, enums, nullable types
- **Configuration** — `sqlc.yaml` settings, plugins, engine selection
- **CRUD Queries** — Standard insert/select/update/delete patterns
- **Batch Operations** — Bulk insert with `COPY` or batch exec
- **Transactions** — DBTX interface, transaction support
- **JSON Columns** — JSONB handling with custom types

## Concepts

- `concepts/codegen.md` — How sqlc generates code
- `concepts/query-annotations.md` — Query annotation syntax
- `concepts/custom-types.md` — Type overrides and mappings
- `concepts/config.md` — sqlc.yaml configuration

## Patterns

- `patterns/crud-queries.md` — Standard CRUD SQL patterns
- `patterns/batch-operations.md` — Bulk operations
- `patterns/transactions.md` — Transaction patterns
- `patterns/json-columns.md` — JSONB column handling
