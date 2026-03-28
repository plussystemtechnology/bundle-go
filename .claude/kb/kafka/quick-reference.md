# Kafka Quick Reference

## kafka-go Writer (Producer)

```go
w := &kafka.Writer{
    Addr:         kafka.TCP("localhost:9092"),
    Topic:        "orders",
    Balancer:     &kafka.LeastBytes{},
    BatchSize:    100,
    BatchTimeout: 10 * time.Millisecond,
    RequiredAcks: kafka.RequireAll,
}
defer w.Close()
```

## kafka-go Reader (Consumer)

```go
r := kafka.NewReader(kafka.ReaderConfig{
    Brokers:  []string{"localhost:9092"},
    GroupID:  "order-processor",
    Topic:    "orders",
    MinBytes: 1,
    MaxBytes: 10e6,
})
defer r.Close()
```

## Common Operations

| Operation | Method |
|-----------|--------|
| Produce message | `w.WriteMessages(ctx, msg)` |
| Consume message | `r.ReadMessage(ctx)` |
| Fetch (manual commit) | `r.FetchMessage(ctx)` |
| Commit offset | `r.CommitMessages(ctx, msg)` |
| Create topic | `conn.CreateTopics(topicConfig)` |

## Delivery Guarantees

| Level | Setting | Trade-off |
|-------|---------|-----------|
| At-most-once | Auto-commit, no retry | Fast, may lose messages |
| At-least-once | Manual commit after process | Safe, may duplicate |
| Exactly-once | Idempotent + transactional | Slowest, strongest guarantee |

## Key Decision: Writer vs Dialer

| Need | Use |
|------|-----|
| Produce messages | `kafka.Writer` |
| Consume with group | `kafka.NewReader` with GroupID |
| Admin operations | `kafka.Dial` / `kafka.DialLeader` |
| Create topics | `(*Conn).CreateTopics` |
