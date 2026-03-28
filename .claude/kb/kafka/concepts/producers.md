# Kafka Producers

## Writer Configuration

```go
w := &kafka.Writer{
    Addr:         kafka.TCP("broker1:9092", "broker2:9092"),
    Topic:        "events",
    Balancer:     &kafka.Hash{},        // key-based partitioning
    BatchSize:    100,                   // batch up to 100 messages
    BatchTimeout: 10 * time.Millisecond, // or flush after 10ms
    RequiredAcks: kafka.RequireAll,      // wait for all ISR
    Async:        false,                 // synchronous by default
    Compression:  kafka.Snappy,
}
```

## Producing Messages

```go
err := w.WriteMessages(ctx,
    kafka.Message{
        Key:   []byte(orderID.String()),
        Value: eventJSON,
        Headers: []kafka.Header{
            {Key: "event-type", Value: []byte("order.created")},
            {Key: "trace-id", Value: []byte(traceID)},
        },
    },
)
```

## Partitioning Strategies

| Balancer | Behavior | Use When |
|----------|----------|----------|
| `Hash{}` | Key hash → partition | Need ordering per key |
| `LeastBytes{}` | Least loaded partition | Even distribution |
| `RoundRobin{}` | Sequential rotation | Simple spread |
| `CRC32Balancer{}` | Compatible with Java | Interop with JVM clients |

## Key Points

- Always set a message key for ordering guarantees
- Messages with same key go to same partition → ordered
- `RequireAll` = strongest durability (waits for all in-sync replicas)
- Use `Async: true` only if you can tolerate message loss
