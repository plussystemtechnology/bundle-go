# gRPC Health Checking

## Standard Health Protocol

```go
import "google.golang.org/grpc/health"
import healthpb "google.golang.org/grpc/health/grpc_health_v1"

func setupHealth(s *grpc.Server) *health.Server {
    healthSrv := health.NewServer()
    healthpb.RegisterHealthServer(s, healthSrv)

    // Set service status
    healthSrv.SetServingStatus("", healthpb.HealthCheckResponse_SERVING)
    healthSrv.SetServingStatus("api.v1.UserService", healthpb.HealthCheckResponse_SERVING)

    return healthSrv
}
```

## Kubernetes Integration

```yaml
livenessProbe:
  grpc:
    port: 50051
  initialDelaySeconds: 10
  periodSeconds: 10

readinessProbe:
  grpc:
    port: 50051
  initialDelaySeconds: 5
  periodSeconds: 5
```

## Dynamic Health Updates

```go
// During graceful shutdown
healthSrv.SetServingStatus("", healthpb.HealthCheckResponse_NOT_SERVING)

// When dependency is unhealthy
healthSrv.SetServingStatus("api.v1.OrderService", healthpb.HealthCheckResponse_NOT_SERVING)
```
