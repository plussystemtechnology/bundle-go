# Batch Operations

## Batch Insert with UNNEST

```sql
-- name: BatchCreateUsers :many
INSERT INTO users (id, name, email, role, created_at, updated_at)
SELECT
    unnest(sqlc.arg(ids)::uuid[]),
    unnest(sqlc.arg(names)::text[]),
    unnest(sqlc.arg(emails)::text[]),
    unnest(sqlc.arg(roles)::text[]),
    now(), now()
RETURNING id, name, email, role, created_at;
```

## Batch Exec

```sql
-- name: BatchDeleteUsers :batchexec
DELETE FROM users WHERE id = $1;
```

Usage:

```go
results := q.BatchDeleteUsers(ctx, ids)
results.Exec(func(i int, err error) {
    if err != nil {
        log.Error("failed to delete user", zap.Int("index", i), zap.Error(err))
    }
})
```

## Upsert (ON CONFLICT)

```sql
-- name: UpsertUser :one
INSERT INTO users (id, name, email, role, created_at, updated_at)
VALUES ($1, $2, $3, $4, now(), now())
ON CONFLICT (email) DO UPDATE SET
    name = EXCLUDED.name,
    role = EXCLUDED.role,
    updated_at = now()
RETURNING id, name, email, role, created_at, updated_at;
```

## Key Points

- Use `UNNEST` with typed arrays for batch inserts in PostgreSQL
- `batchexec` annotation uses pgx batch API (efficient pipelining)
- Always handle per-row errors in batch callbacks
- `ON CONFLICT` for idempotent upserts
