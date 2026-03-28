# Docker Compose

## Local Development Stack

Compose runs the full dependency stack locally: PostgreSQL, Redis, Kafka, etc.

```yaml
services:
  api:
    build: .
    ports: ["8080:8080"]
    env_file: .env
    depends_on:
      db: { condition: service_healthy }
      redis: { condition: service_healthy }

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: app
      POSTGRES_USER: app
      POSTGRES_PASSWORD: secret
    ports: ["5432:5432"]
    volumes: ["pgdata:/var/lib/postgresql/data"]
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U app"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s

volumes:
  pgdata:
```

## Key Points

- Use `depends_on` with `condition: service_healthy` for startup ordering
- Health checks ensure dependencies are ready before app starts
- Named volumes persist data across restarts
- Use `.env` file for configuration (not committed to git)
