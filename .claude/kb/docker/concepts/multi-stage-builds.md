# Multi-Stage Builds

## Concept

Separate compilation (large image with tools) from runtime (minimal image). The final image only contains the binary.

```dockerfile
# Stage 1: Build
FROM golang:1.22-alpine AS builder
RUN apk add --no-cache git ca-certificates
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags="-w -s -X main.version=${VERSION}" \
    -o /bin/api ./cmd/api

# Stage 2: Runtime
FROM gcr.io/distroless/static-debian12
COPY --from=builder /bin/api /bin/api
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
EXPOSE 8080
USER nonroot:nonroot
ENTRYPOINT ["/bin/api"]
```

## Key Points

- `CGO_ENABLED=0` — static binary, no C dependencies
- `-ldflags="-w -s"` — strip debug info, smaller binary
- Copy only the binary and certs to runtime stage
- Run as `nonroot` for security
- Final image is ~10-15MB (binary + distroless base)
