# Context Propagation

## Setup Propagators

```go
otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(
    propagation.TraceContext{}, // W3C traceparent
    propagation.Baggage{},     // W3C baggage
))
```

## HTTP Client Propagation

```go
import "go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"

// Wrap http.Client — automatically injects trace headers
client := &http.Client{Transport: otelhttp.NewTransport(http.DefaultTransport)}

resp, err := client.Get("http://payment-service/check")
```

## gRPC Client Propagation

```go
import "go.opentelemetry.io/contrib/instrumentation/google.golang.org/grpc/otelgrpc"

conn, err := grpc.Dial(addr,
    grpc.WithUnaryInterceptor(otelgrpc.UnaryClientInterceptor()),
    grpc.WithStreamInterceptor(otelgrpc.StreamClientInterceptor()),
)
```

## Kafka Propagation

```go
// Inject into Kafka headers
otel.GetTextMapPropagator().Inject(ctx, propagation.MapCarrier(headers))

// Extract from Kafka headers
ctx = otel.GetTextMapPropagator().Extract(ctx, propagation.MapCarrier(headers))
```
