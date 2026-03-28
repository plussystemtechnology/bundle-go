# Prepared Statements

## Automatic Preparation

pgx automatically prepares statements on first use and caches them per connection. No manual `Prepare()` needed.

```go
// pgx prepares this automatically on first execution
rows, err := pool.Query(ctx, "SELECT id, name FROM users WHERE role = $1", "admin")
```

## Statement Cache Modes

Configure via connection config:

```go
config, _ := pgxpool.ParseConfig(connString)

// Default: automatic preparation and caching
config.ConnConfig.DefaultQueryExecMode = pgx.QueryExecModeCacheStatement

// Description cache only (no server-side prepare)
config.ConnConfig.DefaultQueryExecMode = pgx.QueryExecModeCacheDescribe

// Simple protocol (no preparation, for pgBouncer transaction mode)
config.ConnConfig.DefaultQueryExecMode = pgx.QueryExecModeSimpleProtocol
```

## pgBouncer Compatibility

When using pgBouncer in transaction pooling mode, server-side prepared statements don't work. Use simple protocol:

```go
config.ConnConfig.DefaultQueryExecMode = pgx.QueryExecModeSimpleProtocol
```

## Statement Cache Size

```go
config.ConnConfig.StatementCacheCapacity = 512   // default: 512
config.ConnConfig.DescriptionCacheCapacity = 512  // default: 512
```
