# Partitioning

## Key Concepts

- Topic is divided into partitions (ordered, append-only logs)
- Messages within a partition are strictly ordered
- Messages across partitions have no ordering guarantee
- Partition count determines max parallelism for consumers

## Partition Key Design

Choose keys that ensure related messages go to the same partition:

```go
// Order events — partition by order ID (all events for an order are ordered)
kafka.Message{Key: []byte(orderID.String()), Value: data}

// User events — partition by user ID
kafka.Message{Key: []byte(userID.String()), Value: data}

// No key — round-robin distribution
kafka.Message{Value: data}
```

## Partition Count Guidelines

| Factor | Recommendation |
|--------|---------------|
| Consumer instances | Partitions >= max consumers |
| Throughput | More partitions = higher throughput |
| Ordering | Fewer partitions = simpler ordering |
| Typical starting point | 6-12 partitions per topic |
| High throughput | 30-50 partitions |

## Hot Partition Problem

If one key has disproportionate traffic, its partition becomes a bottleneck.

Solutions:
- Add random suffix to key: `userID + "-" + rand(0,3)`
- Use compound keys: `userID + "-" + date`
- Repartition to more partitions
