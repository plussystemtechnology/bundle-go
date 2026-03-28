# Transaction Patterns

## Basic Transaction

```go
func (r *Repository) TransferFunds(ctx context.Context, fromID, toID uuid.UUID, amount int64) error {
    tx, err := r.pool.Begin(ctx)
    if err != nil {
        return fmt.Errorf("begin tx: %w", err)
    }
    defer tx.Rollback(ctx) // no-op if committed

    q := db.New(tx)

    if err := q.DebitAccount(ctx, db.DebitAccountParams{ID: fromID, Amount: amount}); err != nil {
        return fmt.Errorf("debit: %w", err)
    }

    if err := q.CreditAccount(ctx, db.CreditAccountParams{ID: toID, Amount: amount}); err != nil {
        return fmt.Errorf("credit: %w", err)
    }

    return tx.Commit(ctx)
}
```

## Transaction with Isolation Level

```go
tx, err := pool.BeginTx(ctx, pgx.TxOptions{
    IsoLevel: pgx.Serializable,
})
```

## Reusable Transaction Helper

```go
func ExecTx(ctx context.Context, pool *pgxpool.Pool, fn func(pgx.Tx) error) error {
    tx, err := pool.Begin(ctx)
    if err != nil {
        return fmt.Errorf("begin: %w", err)
    }
    defer tx.Rollback(ctx)

    if err := fn(tx); err != nil {
        return err
    }
    return tx.Commit(ctx)
}
```
