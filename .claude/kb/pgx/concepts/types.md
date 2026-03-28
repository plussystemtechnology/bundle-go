# pgx Type System

## Built-in Type Mappings

pgx maps PostgreSQL types to Go types automatically:

| PostgreSQL | Go |
|-----------|-----|
| `int4` | `int32` |
| `int8` | `int64` |
| `text`, `varchar` | `string` |
| `bool` | `bool` |
| `float8` | `float64` |
| `timestamptz` | `time.Time` |
| `uuid` | `[16]byte` (or `google/uuid.UUID` with registration) |
| `jsonb` | `map[string]any` or custom type |
| `bytea` | `[]byte` |

## Registering Custom Types

```go
import "github.com/jackc/pgx/v5/pgtype"

func registerTypes(ctx context.Context, pool *pgxpool.Pool) error {
    conn, err := pool.Acquire(ctx)
    if err != nil {
        return err
    }
    defer conn.Release()

    // Register enum type
    dt, err := conn.Conn().LoadType(ctx, "order_status")
    if err != nil {
        return fmt.Errorf("load type order_status: %w", err)
    }
    conn.Conn().TypeMap().RegisterType(dt)

    return nil
}
```

## UUID with google/uuid

```go
import (
    "github.com/google/uuid"
    "github.com/jackc/pgx/v5"
    "github.com/jackc/pgx/v5/pgtype"
)

// pgx v5 supports google/uuid natively via pgtype.UUID
// Just use uuid.UUID in your structs — pgx handles conversion
```

## Nullable Types

```go
// Use pgtype for nullable values
var name pgtype.Text
err := pool.QueryRow(ctx, "SELECT name FROM users WHERE id = $1", id).Scan(&name)
if name.Valid {
    fmt.Println(name.String)
}
```
