# Custom Type Overrides

## Config Overrides

Map database types to Go types in `sqlc.yaml`:

```yaml
overrides:
  - db_type: "uuid"
    go_type: "github.com/google/uuid.UUID"
  - db_type: "timestamptz"
    go_type: "time.Time"
  - db_type: "jsonb"
    go_type: "encoding/json.RawMessage"
  - db_type: "text[]"
    go_type: "[]string"
  - db_type: "pg_catalog.int4"
    go_type: "int32"
```

## Column-Level Overrides

Override a specific column in a specific table:

```yaml
overrides:
  - column: "users.metadata"
    go_type:
      import: "github.com/myapp/internal/domain"
      type: "UserMetadata"
  - column: "orders.status"
    go_type:
      import: "github.com/myapp/internal/domain"
      type: "OrderStatus"
```

## Nullable Handling

sqlc maps nullable columns to pointer types by default. For custom handling:

```yaml
overrides:
  - db_type: "text"
    nullable: true
    go_type:
      import: "database/sql"
      type: "NullString"
```

## Enum Mapping

PostgreSQL enums map to Go string types with constants:

```sql
CREATE TYPE order_status AS ENUM ('pending', 'processing', 'completed', 'cancelled');
```

Generates:

```go
type OrderStatus string

const (
    OrderStatusPending    OrderStatus = "pending"
    OrderStatusProcessing OrderStatus = "processing"
    OrderStatusCompleted  OrderStatus = "completed"
    OrderStatusCancelled  OrderStatus = "cancelled"
)
```
