# Production Go Dockerfile

```dockerfile
# syntax=docker/dockerfile:1

# ---- Build Stage ----
FROM golang:1.22-alpine AS builder

RUN apk add --no-cache git ca-certificates tzdata

WORKDIR /app

# Cache dependencies
COPY go.mod go.sum ./
RUN go mod download && go mod verify

# Build
COPY . .
ARG VERSION=dev
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -trimpath \
    -ldflags="-w -s -X main.version=${VERSION}" \
    -o /bin/api ./cmd/api

# ---- Runtime Stage ----
FROM gcr.io/distroless/static-debian12

# Timezone data (for time.LoadLocation)
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
# TLS certificates
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
# Binary
COPY --from=builder /bin/api /bin/api

EXPOSE 8080

USER nonroot:nonroot

ENTRYPOINT ["/bin/api"]
```

## Build Commands

```bash
# Build
docker build -t myapp:latest .

# Build with version
docker build --build-arg VERSION=$(git describe --tags) -t myapp:v1.0.0 .

# Multi-platform
docker buildx build --platform linux/amd64,linux/arm64 -t myapp:latest .
```
