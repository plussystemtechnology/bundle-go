# Migrations Quick Reference

## File Naming

```text
db/migration/
├── 000001_create_users.up.sql
├── 000001_create_users.down.sql
├── 000002_add_orders.up.sql
├── 000002_add_orders.down.sql
```

## CLI Commands

```bash
# Create new migration
migrate create -ext sql -dir db/migration -seq add_products

# Run all up migrations
migrate -path db/migration -database "$DB_URL" up

# Rollback last migration
migrate -path db/migration -database "$DB_URL" down 1

# Go to specific version
migrate -path db/migration -database "$DB_URL" goto 3

# Show current version
migrate -path db/migration -database "$DB_URL" version

# Force version (fix dirty state)
migrate -path db/migration -database "$DB_URL" force 2
```

## Go Library

```go
import "github.com/golang-migrate/migrate/v4"

m, err := migrate.New("file://db/migration", databaseURL)
err = m.Up()           // run all pending
err = m.Down()         // rollback all
err = m.Steps(1)       // up 1
err = m.Steps(-1)      // down 1
version, dirty, _ := m.Version()
```

## Safety Rules

- Every `up.sql` must have a matching `down.sql`
- Never modify an applied migration — create a new one
- Use `IF NOT EXISTS` / `IF EXISTS` for idempotency
- Test rollback in CI before merging
