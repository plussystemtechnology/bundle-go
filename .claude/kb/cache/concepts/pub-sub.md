# Redis Pub/Sub

## Publisher

```go
func (p *Publisher) PublishEvent(ctx context.Context, channel string, event any) error {
    data, err := json.Marshal(event)
    if err != nil {
        return fmt.Errorf("marshal event: %w", err)
    }
    return p.rdb.Publish(ctx, channel, data).Err()
}
```

## Subscriber

```go
func StartSubscriber(ctx context.Context, rdb *redis.Client, channels ...string) {
    sub := rdb.Subscribe(ctx, channels...)
    defer sub.Close()

    ch := sub.Channel()
    for {
        select {
        case msg, ok := <-ch:
            if !ok {
                return
            }
            handleMessage(msg.Channel, msg.Payload)
        case <-ctx.Done():
            return
        }
    }
}
```

## Pattern Subscribe

```go
// Subscribe to all order events: order.created, order.updated, etc.
sub := rdb.PSubscribe(ctx, "order.*")
```

## When to Use

| Use Case | Redis Pub/Sub | Kafka |
|----------|--------------|-------|
| Cache invalidation | Yes | Overkill |
| Real-time notifications | Yes | Yes |
| Event sourcing | No (no persistence) | Yes |
| High-throughput processing | No | Yes |
| At-least-once delivery | No | Yes |

Redis Pub/Sub is fire-and-forget — no persistence, no replay. Use Kafka for durable messaging.
