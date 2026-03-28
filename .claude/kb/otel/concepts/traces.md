# Traces

## What is a Trace

A trace represents a request's journey through a distributed system. It consists of spans linked by parent-child relationships.

```text
Trace: user-request-123
├── [HTTP] GET /orders        (50ms) ← root span
│   ├── [DB] SELECT orders    (5ms)
│   ├── [Redis] GET cache     (1ms)
│   └── [gRPC] PaymentCheck   (30ms)
│       ├── [DB] SELECT payment (3ms)
│       └── [HTTP] FraudAPI    (20ms)
```

## Trace Context

Propagated via HTTP headers (`traceparent`, `tracestate`) or gRPC metadata.

```text
traceparent: 00-<trace-id>-<span-id>-<flags>
traceparent: 00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01
```

## Lifecycle

1. Request arrives → root span created
2. Internal operations → child spans
3. Outgoing calls → context propagated
4. Response sent → root span ends
5. Spans batched and exported to collector
