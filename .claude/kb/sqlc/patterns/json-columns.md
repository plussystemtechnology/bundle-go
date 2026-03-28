# JSONB Column Handling

## Schema

```sql
CREATE TABLE products (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name       TEXT NOT NULL,
    metadata   JSONB NOT NULL DEFAULT '{}',
    attributes JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

## sqlc Config Override

```yaml
overrides:
  - db_type: "jsonb"
    go_type: "encoding/json.RawMessage"
```

## Queries

```sql
-- name: CreateProduct :one
INSERT INTO products (name, metadata, attributes)
VALUES ($1, $2, $3)
RETURNING id, name, metadata, attributes, created_at;

-- name: GetProductsByAttribute :many
SELECT id, name, metadata, attributes, created_at
FROM products
WHERE attributes @> $1::jsonb
ORDER BY created_at DESC;

-- name: UpdateProductMetadata :one
UPDATE products
SET metadata = metadata || $2::jsonb
WHERE id = $1
RETURNING id, name, metadata, attributes, created_at;
```

## Go Usage

```go
// Marshal struct to json.RawMessage for insert
type ProductMetadata struct {
    Category string   `json:"category"`
    Tags     []string `json:"tags"`
}

meta := ProductMetadata{Category: "electronics", Tags: []string{"new"}}
metaJSON, err := json.Marshal(meta)
if err != nil {
    return fmt.Errorf("marshal metadata: %w", err)
}

product, err := q.CreateProduct(ctx, db.CreateProductParams{
    Name:     "Widget",
    Metadata: metaJSON, // json.RawMessage
})

// Unmarshal from query result
var resultMeta ProductMetadata
if err := json.Unmarshal(product.Metadata, &resultMeta); err != nil {
    return fmt.Errorf("unmarshal metadata: %w", err)
}
```
