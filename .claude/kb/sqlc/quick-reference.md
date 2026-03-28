# sqlc Quick Reference

## Query Annotations

| Annotation | Returns | Use For |
|-----------|---------|---------|
| `-- name: GetUser :one` | Single row | Get by ID |
| `-- name: ListUsers :many` | Slice of rows | List queries |
| `-- name: CreateUser :exec` | `error` only | Insert/update (no return) |
| `-- name: CreateUser :execresult` | `sql.Result` + error | Insert with affected rows |
| `-- name: CreateUser :one` | Created row | Insert RETURNING |
| `-- name: DeleteOld :execrows` | `int64` + error | Delete with count |
| `-- name: BatchInsert :batchexec` | Batch error | Bulk insert |

## sqlc.yaml Minimal Config

```yaml
version: "2"
sql:
  - engine: "postgresql"
    queries: "db/query/"
    schema: "db/migration/"
    gen:
      go:
        package: "db"
        out: "internal/adapter/repository/sqlc"
        sql_package: "pgx/v5"
        emit_json_tags: true
        emit_empty_slices: true
        overrides:
          - db_type: "uuid"
            go_type: "github.com/google/uuid.UUID"
          - db_type: "timestamptz"
            go_type: "time.Time"
```

## Commands

| Command | Purpose |
|---------|---------|
| `sqlc generate` | Generate Go code from SQL |
| `sqlc compile` | Check SQL without generating |
| `sqlc diff` | Show what would change |
| `sqlc vet` | Lint SQL queries |

## Type Overrides

| DB Type | Go Type |
|---------|---------|
| `uuid` | `github.com/google/uuid.UUID` |
| `timestamptz` | `time.Time` |
| `jsonb` | `json.RawMessage` |
| `text[]` | `[]string` |
| `inet` | `netip.Addr` |
