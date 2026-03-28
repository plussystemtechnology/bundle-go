# OpenTelemetry Quick Reference

## SDK Setup

```go
import (
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
    "go.opentelemetry.io/otel/sdk/trace"
)

func InitTracer(ctx context.Context) (func(), error) {
    exporter, err := otlptracegrpc.New(ctx)
    if err != nil {
        return nil, err
    }

    tp := trace.NewTracerProvider(
        trace.WithBatcher(exporter),
        trace.WithResource(resource.NewWithAttributes(
            semconv.SchemaURL,
            semconv.ServiceName("api"),
            semconv.ServiceVersion("1.0.0"),
        )),
    )
    otel.SetTracerProvider(tp)

    return func() { tp.Shutdown(ctx) }, nil
}
```

## Common Operations

| Operation | Code |
|-----------|------|
| Get tracer | `otel.Tracer("component")` |
| Start span | `ctx, span := tracer.Start(ctx, "name")` |
| End span | `defer span.End()` |
| Add attribute | `span.SetAttributes(attribute.String("key", "val"))` |
| Record error | `span.RecordError(err)` |
| Set status | `span.SetStatus(codes.Error, "msg")` |

## Environment Variables

| Var | Default | Purpose |
|-----|---------|---------|
| `OTEL_EXPORTER_OTLP_ENDPOINT` | `localhost:4317` | Collector address |
| `OTEL_SERVICE_NAME` | `unknown_service` | Service name |
| `OTEL_TRACES_SAMPLER` | `parentbased_always_on` | Sampling strategy |
