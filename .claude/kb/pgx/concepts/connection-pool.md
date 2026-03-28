# Connection Pool

## Architecture

`pgxpool.Pool` manages a pool of `*pgx.Conn` connections. It handles:

- Connection creation and destruction
- Health checks on idle connections
- Automatic reconnection
- Connection lifetime management

```go
import "github.com/jackc/pgx/v5/pgxpool"

func NewPool(ctx context.Context, databaseURL string) (*pgxpool.Pool, error) {
    config, err := pgxpool.ParseConfig(databaseURL)
    if err != nil {
        return nil, fmt.Errorf("parse pool config: %w", err)
    }

    config.MaxConns = 25
    config.MinConns = 5
    config.MaxConnLifetime = 30 * time.Minute
    config.MaxConnIdleTime = 5 * time.Minute
    config.HealthCheckPeriod = 30 * time.Second

    pool, err := pgxpool.NewWithConfig(ctx, config)
    if err != nil {
        return nil, fmt.Errorf("create pool: %w", err)
    }

    if err := pool.Ping(ctx); err != nil {
        pool.Close()
        return nil, fmt.Errorf("ping database: %w", err)
    }

    return pool, nil
}
```

## Pool Sizing

Rule of thumb: `MaxConns = (CPU cores * 2) + effective_disk_spindles`

For cloud databases (RDS, Cloud SQL): start with 25, monitor `pool.Stat()`.

```go
stat := pool.Stat()
// stat.AcquiredConns()   — currently in use
// stat.IdleConns()       — waiting in pool
// stat.TotalConns()      — total managed
// stat.MaxConns()        — configured max
```
