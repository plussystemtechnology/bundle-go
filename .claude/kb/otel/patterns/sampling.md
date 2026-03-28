# Sampling Strategies

## Always On (Development)

```go
tp := trace.NewTracerProvider(
    trace.WithSampler(trace.AlwaysSample()),
)
```

## Ratio-Based (Production)

```go
// Sample 10% of traces
tp := trace.NewTracerProvider(
    trace.WithSampler(trace.TraceIDRatioBased(0.1)),
)
```

## Parent-Based (Recommended)

```go
// Respect parent decision, sample 10% of root spans
tp := trace.NewTracerProvider(
    trace.WithSampler(trace.ParentBased(
        trace.TraceIDRatioBased(0.1),
    )),
)
```

## Decision Matrix

| Environment | Strategy | Ratio |
|-------------|----------|-------|
| Development | AlwaysSample | 100% |
| Staging | ParentBased + Ratio | 50% |
| Production (low traffic) | ParentBased + Ratio | 10-25% |
| Production (high traffic) | ParentBased + Ratio | 1-5% |
| Critical path | AlwaysSample | 100% |

## Environment Variable

```bash
OTEL_TRACES_SAMPLER=parentbased_traceidratio
OTEL_TRACES_SAMPLER_ARG=0.1
```
