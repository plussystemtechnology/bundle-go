# LISTEN/NOTIFY — PostgreSQL Pub/Sub

## Listener Setup

```go
func StartListener(ctx context.Context, pool *pgxpool.Pool, channel string, handler func(payload string)) error {
    conn, err := pool.Acquire(ctx)
    if err != nil {
        return fmt.Errorf("acquire conn: %w", err)
    }

    _, err = conn.Exec(ctx, "LISTEN "+channel)
    if err != nil {
        conn.Release()
        return fmt.Errorf("listen: %w", err)
    }

    go func() {
        defer conn.Release()
        for {
            notification, err := conn.Conn().WaitForNotification(ctx)
            if err != nil {
                if ctx.Err() != nil {
                    return // context cancelled, clean shutdown
                }
                continue
            }
            handler(notification.Payload)
        }
    }()

    return nil
}
```

## Sending Notifications

```go
// From SQL (e.g., in a trigger)
// PERFORM pg_notify('order_created', row_to_json(NEW)::text);

// From Go
_, err := pool.Exec(ctx, "SELECT pg_notify($1, $2)", "order_created", orderJSON)
```

## Use Cases

- Real-time cache invalidation
- Event-driven processing without Kafka overhead
- Simple task queues within a single database
- Live dashboard updates
