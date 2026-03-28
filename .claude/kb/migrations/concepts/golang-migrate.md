# golang-migrate

## Tool

`golang-migrate/migrate` provides both CLI and Go library for database migrations.

```bash
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest
```

## Go Library Integration

```go
import (
    "github.com/golang-migrate/migrate/v4"
    _ "github.com/golang-migrate/migrate/v4/database/pgx/v5"
    _ "github.com/golang-migrate/migrate/v4/source/file"
)

func RunMigrations(databaseURL, migrationsPath string) error {
    m, err := migrate.New("file://"+migrationsPath, databaseURL)
    if err != nil {
        return fmt.Errorf("create migrator: %w", err)
    }
    defer m.Close()

    if err := m.Up(); err != nil && !errors.Is(err, migrate.ErrNoChange) {
        return fmt.Errorf("run migrations: %w", err)
    }

    version, dirty, _ := m.Version()
    log.Printf("migration version: %d, dirty: %v", version, dirty)
    return nil
}
```

## Key Points

- Use `pgx/v5` driver tag for pgx compatibility
- `migrate.ErrNoChange` means all migrations are applied — not an error
- Check `dirty` flag — if true, a migration failed mid-execution
- Use `m.Force(version)` to fix dirty state after manual intervention
