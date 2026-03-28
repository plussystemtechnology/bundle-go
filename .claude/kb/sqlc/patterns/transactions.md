# Transaction Patterns

## Using DBTX Interface

sqlc's `Queries` struct accepts any `DBTX` — works with both pool and transaction.

```go
// Repository wraps sqlc queries with transaction support
type UserRepository struct {
    pool *pgxpool.Pool
    q    *db.Queries
}

func NewUserRepository(pool *pgxpool.Pool) *UserRepository {
    return &UserRepository{
        pool: pool,
        q:    db.New(pool),
    }
}

// WithTx creates a new Queries instance bound to a transaction
func (r *UserRepository) WithTx(tx pgx.Tx) *db.Queries {
    return db.New(tx)
}
```

## Transaction Helper

```go
func (r *UserRepository) ExecTx(ctx context.Context, fn func(*db.Queries) error) error {
    tx, err := r.pool.Begin(ctx)
    if err != nil {
        return fmt.Errorf("begin tx: %w", err)
    }
    defer tx.Rollback(ctx)

    q := db.New(tx)
    if err := fn(q); err != nil {
        return err
    }

    return tx.Commit(ctx)
}
```

## Usage in Service Layer

```go
func (s *OrderService) CreateOrder(ctx context.Context, req CreateOrderRequest) (*Order, error) {
    var order db.Order

    err := s.repo.ExecTx(ctx, func(q *db.Queries) error {
        var err error
        order, err = q.CreateOrder(ctx, db.CreateOrderParams{...})
        if err != nil {
            return fmt.Errorf("create order: %w", err)
        }

        for _, item := range req.Items {
            _, err = q.CreateOrderItem(ctx, db.CreateOrderItemParams{
                OrderID: order.ID,
                // ...
            })
            if err != nil {
                return fmt.Errorf("create order item: %w", err)
            }
        }
        return nil
    })

    return toDomainOrder(order), err
}
```
