# Histogram Bucket Design

## Default Buckets

```go
prometheus.DefBuckets // {.005, .01, .025, .05, .1, .25, .5, 1, 2.5, 5, 10}
```

## API Latency Buckets

```go
apiBuckets := []float64{.001, .005, .01, .025, .05, .1, .25, .5, 1, 2.5, 5}
```

## DB Query Buckets

```go
dbBuckets := []float64{.0005, .001, .005, .01, .025, .05, .1, .5, 1}
```

## Message Processing Buckets

```go
kafkaBuckets := []float64{.01, .05, .1, .5, 1, 5, 10, 30, 60}
```

## Design Rules

- 10-15 buckets per histogram
- Cover expected P50 through P99.9
- More granularity around SLO thresholds
- Exponential spacing: each bucket ~2-3x previous
- Include a bucket just above your SLO target
