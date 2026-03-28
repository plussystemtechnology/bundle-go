# Docker Health Check

## In Dockerfile

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD ["/bin/api", "healthcheck"]
```

## Go Health Endpoint

```go
// cmd/api/main.go
if len(os.Args) > 1 && os.Args[1] == "healthcheck" {
    resp, err := http.Get("http://localhost:8080/health")
    if err != nil || resp.StatusCode != 200 {
        os.Exit(1)
    }
    os.Exit(0)
}
```

## Compose Health Check

```yaml
services:
  api:
    healthcheck:
      test: ["CMD", "/bin/api", "healthcheck"]
      interval: 30s
      timeout: 5s
      start_period: 10s
      retries: 3
```
