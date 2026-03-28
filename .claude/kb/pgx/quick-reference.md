# pgx Quick Reference

## Pool Creation

```go
pool, err := pgxpool.New(ctx, connString)
// or with config:
config, _ := pgxpool.ParseConfig(connString)
config.MaxConns = 25
pool, err := pgxpool.NewWithConfig(ctx, config)
```

## Pool Config Settings

| Setting | Default | Recommended | Why |
|---------|---------|-------------|-----|
| `MaxConns` | 4 | 25 | Match expected concurrency |
| `MinConns` | 0 | 5 | Avoid cold-start latency |
| `MaxConnLifetime` | 1h | 30m | Rebalance after failover |
| `MaxConnIdleTime` | 30m | 5m | Release idle resources |
| `HealthCheckPeriod` | 1m | 30s | Detect stale connections |

## Query Methods

| Method | Use For |
|--------|---------|
| `pool.Query(ctx, sql, args...)` | Multiple rows |
| `pool.QueryRow(ctx, sql, args...)` | Single row |
| `pool.Exec(ctx, sql, args...)` | INSERT/UPDATE/DELETE |
| `pool.Begin(ctx)` | Start transaction |
| `pool.BeginTx(ctx, opts)` | Transaction with isolation level |
| `pool.SendBatch(ctx, batch)` | Batch multiple queries |
| `pool.CopyFrom(ctx, ...)` | Bulk COPY |

## Transaction Isolation Levels

| Level | pgx Constant | Use Case |
|-------|-------------|----------|
| Read Committed | `pgx.ReadCommitted` | Default, most queries |
| Repeatable Read | `pgx.RepeatableRead` | Consistent reads |
| Serializable | `pgx.Serializable` | Financial transactions |
