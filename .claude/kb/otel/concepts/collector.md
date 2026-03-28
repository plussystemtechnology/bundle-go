# OTel Collector

## Architecture

```text
App → (OTLP gRPC) → Collector → (export) → Jaeger/Tempo/SigNoz
```

## Collector Config

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:
    timeout: 5s
    send_batch_size: 1000

exporters:
  otlp/jaeger:
    endpoint: jaeger:4317
    tls:
      insecure: true

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlp/jaeger]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlp/jaeger]
```

## Docker Compose

```yaml
otel-collector:
  image: otel/opentelemetry-collector-contrib:0.95.0
  ports:
    - "4317:4317"  # gRPC
    - "4318:4318"  # HTTP
  volumes:
    - ./otel-collector-config.yaml:/etc/otel-collector-config.yaml
  command: ["--config=/etc/otel-collector-config.yaml"]
```
