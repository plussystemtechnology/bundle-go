# Docker Quick Reference

## Go Dockerfile Cheat Sheet

```dockerfile
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /bin/api ./cmd/api

FROM gcr.io/distroless/static-debian12
COPY --from=builder /bin/api /bin/api
EXPOSE 8080
ENTRYPOINT ["/bin/api"]
```

## Image Size Comparison

| Base Image | Size | Use Case |
|-----------|------|----------|
| `golang:1.22` | ~800MB | Build stage only |
| `alpine:3.19` | ~7MB | Need shell access |
| `distroless/static` | ~2MB | Production (no CGO) |
| `scratch` | 0MB | Ultra-minimal |

## Common Commands

| Command | Purpose |
|---------|---------|
| `docker build -t app .` | Build image |
| `docker compose up -d` | Start all services |
| `docker compose logs -f api` | Follow service logs |
| `docker compose down -v` | Stop and remove volumes |
| `docker compose exec db psql` | Execute in running container |

## Build Cache Optimization

```text
COPY go.mod go.sum ./   ← cached if dependencies unchanged
RUN go mod download      ← cached (downloads only on dep change)
COPY . .                 ← invalidates on any source change
RUN go build             ← rebuilds only when source changes
```
