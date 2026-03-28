# Delivery Guarantees

## At-Most-Once

Auto-commit offsets before processing. Fast but may lose messages.

```go
r := kafka.NewReader(kafka.ReaderConfig{
    GroupID:        "fast-processor",
    Topic:          "events",
    CommitInterval: time.Second, // auto-commit
    // ReadMessage auto-commits
})

msg, _ := r.ReadMessage(ctx) // offset committed
processMessage(msg)           // if this fails, message is lost
```

## At-Least-Once

Commit after successful processing. Safe but may process duplicates.

```go
msg, _ := r.FetchMessage(ctx)       // offset NOT committed
err := processMessage(ctx, msg)      // process first
if err == nil {
    r.CommitMessages(ctx, msg)       // then commit
}
// if crash before commit → message redelivered
```

## Exactly-Once (Idempotent Processing)

Make consumers idempotent — processing the same message twice produces the same result.

```go
func (h *Handler) ProcessOrder(ctx context.Context, msg kafka.Message) error {
    var event OrderCreatedEvent
    json.Unmarshal(msg.Value, &event)

    // Idempotency check — use event ID as dedup key
    processed, err := h.repo.IsEventProcessed(ctx, event.EventID)
    if err != nil {
        return err
    }
    if processed {
        return nil // already handled, skip
    }

    // Process in transaction
    return h.repo.ExecTx(ctx, func(q *db.Queries) error {
        if err := q.CreateOrder(ctx, ...); err != nil {
            return err
        }
        return q.MarkEventProcessed(ctx, event.EventID)
    })
}
```

## Decision Matrix

| Need | Strategy | Implementation |
|------|----------|---------------|
| Speed over safety | At-most-once | `ReadMessage` (auto-commit) |
| Safety over speed | At-least-once | `FetchMessage` + `CommitMessages` |
| Both | Exactly-once | At-least-once + idempotent consumer |
