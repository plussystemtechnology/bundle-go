# Build Arguments

## Version Injection

```dockerfile
ARG VERSION=dev
ARG BUILD_TIME
ARG COMMIT_SHA

RUN CGO_ENABLED=0 go build \
    -ldflags="-w -s \
    -X main.version=${VERSION} \
    -X main.buildTime=${BUILD_TIME} \
    -X main.commitSHA=${COMMIT_SHA}" \
    -o /bin/api ./cmd/api
```

## Go Code

```go
var (
    version   = "dev"
    buildTime = "unknown"
    commitSHA = "unknown"
)

func (h *Handler) Version(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{
        "version":    version,
        "build_time": buildTime,
        "commit":     commitSHA,
    })
}
```

## Build Command

```bash
docker build \
    --build-arg VERSION=$(git describe --tags --always) \
    --build-arg BUILD_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
    --build-arg COMMIT_SHA=$(git rev-parse --short HEAD) \
    -t myapp:$(git describe --tags --always) .
```
