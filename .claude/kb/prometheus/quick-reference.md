# Prometheus Quick Reference

## Metric Types

| Type | Use For | Example |
|------|---------|---------|
| Counter | Monotonically increasing | Total requests, errors |
| Gauge | Can go up or down | Active connections, queue size |
| Histogram | Distribution of values | Request duration, response size |
| Summary | Client-side percentiles | Rarely used (prefer Histogram) |

## Label Best Practices

- Low cardinality: method, status, endpoint pattern (not full URL)
- Never use: user_id, request_id, timestamps (high cardinality)
- Consistent naming: `http_requests_total`, `http_request_duration_seconds`

## Standard Go Metrics

```go
import "github.com/prometheus/client_golang/prometheus"

var (
    httpRequestsTotal = prometheus.NewCounterVec(
        prometheus.CounterOpts{
            Name: "http_requests_total",
            Help: "Total HTTP requests",
        },
        []string{"method", "path", "status"},
    )

    httpRequestDuration = prometheus.NewHistogramVec(
        prometheus.HistogramOpts{
            Name:    "http_request_duration_seconds",
            Help:    "HTTP request duration",
            Buckets: prometheus.DefBuckets,
        },
        []string{"method", "path"},
    )
)

func init() {
    prometheus.MustRegister(httpRequestsTotal, httpRequestDuration)
}
```
