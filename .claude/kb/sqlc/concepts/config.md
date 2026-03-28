# sqlc Configuration

## Full Config Reference

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
        emit_result_struct_pointers: false
        emit_params_struct_pointers: false
        emit_interface: true
        query_parameter_limit: 3
        overrides:
          - db_type: "uuid"
            go_type: "github.com/google/uuid.UUID"
          - db_type: "timestamptz"
            go_type: "time.Time"
          - db_type: "jsonb"
            go_type: "encoding/json.RawMessage"
```

## Key Settings

| Setting | Default | Recommended | Why |
|---------|---------|-------------|-----|
| `sql_package` | `database/sql` | `pgx/v5` | Native pgx types, better perf |
| `emit_json_tags` | `false` | `true` | JSON-serializable models |
| `emit_empty_slices` | `false` | `true` | Return `[]` not `null` |
| `emit_interface` | `false` | `true` | Generates `Querier` interface for mocking |
| `query_parameter_limit` | `1` | `3` | Inline params up to N (avoids tiny structs) |

## Multi-Schema Setup

```yaml
sql:
  - engine: "postgresql"
    queries: "db/query/users/"
    schema: "db/migration/"
    gen:
      go:
        package: "userdb"
        out: "internal/adapter/repository/userdb"
        sql_package: "pgx/v5"
  - engine: "postgresql"
    queries: "db/query/orders/"
    schema: "db/migration/"
    gen:
      go:
        package: "orderdb"
        out: "internal/adapter/repository/orderdb"
        sql_package: "pgx/v5"
```
