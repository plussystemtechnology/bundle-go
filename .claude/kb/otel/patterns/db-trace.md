# Database Tracing

## pgx with otelpgx

```go
import "github.com/exaring/otelpgx"

config, _ := pgxpool.ParseConfig(connString)
config.ConnConfig.Tracer = otelpgx.NewTracer()

pool, err := pgxpool.NewWithConfig(ctx, config)
```

This automatically creates spans for every query with:
- `db.system: postgresql`
- `db.statement: SELECT ...`
- `db.operation: SELECT`
- Duration and error tracking

## Manual DB Spans

```go
func (r *Repository) GetByID(ctx context.Context, id uuid.UUID) (*domain.User, error) {
    ctx, span := tracer.Start(ctx, "UserRepository.GetByID",
        trace.WithAttributes(
            attribute.String("db.system", "postgresql"),
            attribute.String("db.operation", "SELECT"),
        ),
    )
    defer span.End()

    user, err := r.q.GetUserByID(ctx, id)
    if err != nil {
        span.RecordError(err)
        span.SetStatus(codes.Error, err.Error())
    }
    return user, err
}
```
