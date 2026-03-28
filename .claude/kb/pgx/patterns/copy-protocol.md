# COPY Protocol — Bulk Operations

## Bulk Insert with CopyFrom

```go
func (r *Repository) BulkInsertUsers(ctx context.Context, users []domain.User) (int64, error) {
    rows := make([][]any, len(users))
    for i, u := range users {
        rows[i] = []any{u.ID, u.Name, u.Email, u.Role, time.Now(), time.Now()}
    }

    count, err := r.pool.CopyFrom(
        ctx,
        pgx.Identifier{"users"},
        []string{"id", "name", "email", "role", "created_at", "updated_at"},
        pgx.CopyFromRows(rows),
    )
    if err != nil {
        return 0, fmt.Errorf("copy from: %w", err)
    }

    return count, nil
}
```

## CopyFrom with Slice Source

```go
count, err := pool.CopyFrom(
    ctx,
    pgx.Identifier{"events"},
    []string{"id", "type", "payload", "created_at"},
    pgx.CopyFromSlice(len(events), func(i int) ([]any, error) {
        payload, err := json.Marshal(events[i].Payload)
        if err != nil {
            return nil, err
        }
        return []any{events[i].ID, events[i].Type, payload, events[i].CreatedAt}, nil
    }),
)
```

## Performance

- COPY is 5-10x faster than individual INSERTs for bulk data
- Use for batch sizes > 100 rows
- For < 100 rows, batch INSERT with UNNEST is simpler
