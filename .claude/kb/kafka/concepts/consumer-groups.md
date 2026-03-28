# Consumer Groups

## How Groups Work

A consumer group distributes partitions among group members. Each partition is assigned to exactly one consumer in the group.

```text
Topic: orders (4 partitions)
Group: order-processor

Consumer A → Partition 0, 1
Consumer B → Partition 2, 3
```

If Consumer B dies, its partitions are rebalanced to Consumer A.

## kafka-go Reader with Group

```go
r := kafka.NewReader(kafka.ReaderConfig{
    Brokers:        []string{"broker1:9092", "broker2:9092"},
    GroupID:        "order-processor",
    Topic:          "orders",
    MinBytes:       1,
    MaxBytes:       10e6,
    CommitInterval: time.Second, // auto-commit interval
    StartOffset:    kafka.LastOffset,
})
```

## Manual Offset Commit

For at-least-once delivery, use `FetchMessage` + `CommitMessages`:

```go
for {
    msg, err := r.FetchMessage(ctx)
    if err != nil {
        break
    }

    if err := processMessage(ctx, msg); err != nil {
        log.Error("process failed", zap.Error(err))
        continue // don't commit — will be redelivered
    }

    if err := r.CommitMessages(ctx, msg); err != nil {
        log.Error("commit failed", zap.Error(err))
    }
}
```

## Key Points

- Set `GroupID` to enable consumer group mode
- Without `GroupID`, reader consumes all partitions directly
- `CommitInterval: 0` disables auto-commit (use manual commit)
- `StartOffset: kafka.FirstOffset` for new groups to read from beginning
