# Cache Quick Reference

## go-redis Client Setup

```go
rdb := redis.NewClient(&redis.Options{
    Addr:         "localhost:6379",
    Password:     "",
    DB:           0,
    PoolSize:     50,
    MinIdleConns: 10,
    ReadTimeout:  3 * time.Second,
    WriteTimeout: 3 * time.Second,
})
```

## Common Operations

| Operation | Command | go-redis |
|-----------|---------|----------|
| Set with TTL | `SET key val EX 300` | `rdb.Set(ctx, key, val, 5*time.Minute)` |
| Get | `GET key` | `rdb.Get(ctx, key).Result()` |
| Delete | `DEL key` | `rdb.Del(ctx, key)` |
| Check exists | `EXISTS key` | `rdb.Exists(ctx, key).Result()` |
| Set if not exists | `SETNX key val` | `rdb.SetNX(ctx, key, val, ttl)` |
| Increment | `INCR key` | `rdb.Incr(ctx, key)` |
| Hash set | `HSET key field val` | `rdb.HSet(ctx, key, field, val)` |
| Hash get all | `HGETALL key` | `rdb.HGetAll(ctx, key).Result()` |

## Cache Strategy Decision

| Pattern | When | Pros | Cons |
|---------|------|------|------|
| Cache-Aside | Read-heavy, tolerates stale | Simple, only caches hot data | Cache miss penalty |
| Write-Through | Read-heavy, fresh data needed | Always consistent | Write latency |
| Write-Behind | Write-heavy | Fast writes | Data loss risk |
| Read-Through | Simplify app code | Transparent caching | More infra complexity |

## TTL Guidelines

| Data Type | TTL | Rationale |
|-----------|-----|-----------|
| User session | 30m-24h | Security + UX |
| API response cache | 1m-5m | Freshness |
| Config/feature flags | 5m-15m | Balance freshness vs load |
| Aggregated data | 1h-24h | Expensive to compute |
