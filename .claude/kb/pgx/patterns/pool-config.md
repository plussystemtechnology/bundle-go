# Production Pool Configuration

```go
func NewProductionPool(ctx context.Context, cfg config.Database) (*pgxpool.Pool, error) {
    connString := fmt.Sprintf(
        "postgres://%s:%s@%s:%d/%s?sslmode=%s",
        cfg.User, cfg.Password, cfg.Host, cfg.Port, cfg.Name, cfg.SSLMode,
    )

    poolConfig, err := pgxpool.ParseConfig(connString)
    if err != nil {
        return nil, fmt.Errorf("parse config: %w", err)
    }

    // Pool sizing
    poolConfig.MaxConns = int32(cfg.MaxConns)          // 25
    poolConfig.MinConns = int32(cfg.MinConns)           // 5
    poolConfig.MaxConnLifetime = 30 * time.Minute
    poolConfig.MaxConnIdleTime = 5 * time.Minute
    poolConfig.HealthCheckPeriod = 30 * time.Second

    // Connection config
    poolConfig.ConnConfig.ConnectTimeout = 5 * time.Second

    // OpenTelemetry tracing (optional)
    poolConfig.ConnConfig.Tracer = otelpgx.NewTracer()

    // Hooks
    poolConfig.BeforeAcquire = func(ctx context.Context, conn *pgx.Conn) bool {
        return conn.Ping(ctx) == nil
    }
    poolConfig.AfterRelease = func(conn *pgx.Conn) bool {
        // Return false to destroy connection instead of returning to pool
        return true
    }

    pool, err := pgxpool.NewWithConfig(ctx, poolConfig)
    if err != nil {
        return nil, fmt.Errorf("create pool: %w", err)
    }

    if err := pool.Ping(ctx); err != nil {
        pool.Close()
        return nil, fmt.Errorf("ping: %w", err)
    }

    return pool, nil
}
```
