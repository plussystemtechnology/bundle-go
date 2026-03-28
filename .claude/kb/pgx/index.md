# pgx KB Domain

> PostgreSQL driver for Go — connection pools, transactions, COPY protocol, LISTEN/NOTIFY.

## Topics

- **Connection Pool** — pgxpool configuration, health checks, pool sizing
- **Prepared Statements** — Automatic preparation, statement cache
- **Types** — pgx type system, custom type registration
- **Pool Config** — Production pool settings
- **Transactions** — Isolation levels, savepoints, nested transactions
- **COPY Protocol** — Bulk data import/export
- **LISTEN/NOTIFY** — Real-time notifications

## Concepts

- `concepts/connection-pool.md` — Pool architecture and configuration
- `concepts/prepared-statements.md` — Statement preparation and caching
- `concepts/types.md` — pgx type system

## Patterns

- `patterns/pool-config.md` — Production pool configuration
- `patterns/transactions.md` — Transaction patterns
- `patterns/copy-protocol.md` — Bulk COPY operations
- `patterns/listen-notify.md` — PostgreSQL pub/sub
