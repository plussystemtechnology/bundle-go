# Running Migrations in Containers

## Init Container (Kubernetes)

```yaml
initContainers:
  - name: migrate
    image: migrate/migrate:v4.17.0
    command: ["migrate"]
    args:
      - "-path=/migrations"
      - "-database=$(DB_URL)"
      - "up"
    envFrom:
      - secretRef:
          name: db-secrets
    volumeMounts:
      - name: migrations
        mountPath: /migrations
volumes:
  - name: migrations
    configMap:
      name: db-migrations
```

## Embedded in Go Binary

```go
import "embed"

//go:embed db/migration/*.sql
var migrationFS embed.FS

func RunEmbeddedMigrations(databaseURL string) error {
    source, err := iofs.New(migrationFS, "db/migration")
    if err != nil {
        return err
    }

    m, err := migrate.NewWithSourceInstance("iofs", source, databaseURL)
    if err != nil {
        return err
    }

    return m.Up()
}
```

## Docker Compose

```yaml
services:
  migrate:
    image: migrate/migrate:v4.17.0
    command: ["-path=/migrations", "-database=postgres://dev:dev@db:5432/app?sslmode=disable", "up"]
    volumes:
      - ./db/migration:/migrations
    depends_on:
      db: { condition: service_healthy }
```
