# Service Mesh Integration

## Istio Sidecar

Istio automatically injects an Envoy sidecar. Go services need no code changes — just proper health endpoints and graceful shutdown.

```yaml
metadata:
  annotations:
    sidecar.istio.io/inject: "true"
```

## Graceful Shutdown (Required)

```go
func main() {
    srv := &http.Server{Addr: ":8080", Handler: router}

    go func() {
        if err := srv.ListenAndServe(); err != http.ErrServerClosed {
            log.Fatal(err)
        }
    }()

    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit

    // Give sidecar time to drain
    ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
    defer cancel()
    srv.Shutdown(ctx)
}
```

## Key Points

- Match `terminationGracePeriodSeconds` (30s) > shutdown timeout (15s)
- Implement `/health/ready` endpoint — mesh uses it for traffic routing
- Use `preStop` hook if sidecar needs drain time:

```yaml
lifecycle:
  preStop:
    exec:
      command: ["sleep", "5"]
```
