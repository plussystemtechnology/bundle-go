# sqlc Code Generation

## How It Works

sqlc reads SQL schema files and annotated query files, then generates type-safe Go code.

```text
db/migration/*.sql  ──┐
                      ├──> sqlc generate ──> internal/adapter/repository/sqlc/
db/query/*.sql     ──┘                        ├── db.go         (DBTX interface)
                                              ├── models.go     (struct per table)
                                              ├── query.sql.go  (methods per query)
                                              └── querier.go    (interface, optional)
```

## Generated Interface (DBTX)

```go
// db.go — generated
type DBTX interface {
    Exec(context.Context, string, ...interface{}) (pgconn.CommandTag, error)
    Query(context.Context, string, ...interface{}) (pgx.Rows, error)
    QueryRow(context.Context, string, ...interface{}) pgx.Row
}

type Queries struct {
    db DBTX
}

func New(db DBTX) *Queries {
    return &Queries{db: db}
}
```

## Key Points

- Generated code is **not edited** — re-run `sqlc generate` after SQL changes
- Schema is read from migration files (same ones golang-migrate uses)
- One `Queries` struct wraps all generated methods
- `DBTX` interface accepts both `*pgxpool.Pool` and `pgx.Tx` (enables transactions)
- Use `emit_json_tags: true` for JSON-serializable models
- Use `emit_empty_slices: true` to return `[]` not `null` in JSON
