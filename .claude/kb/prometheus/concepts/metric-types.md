# Metric Types

## Counter

Monotonically increasing. Reset only on restart.

```go
requestsTotal := prometheus.NewCounterVec(
    prometheus.CounterOpts{Name: "http_requests_total", Help: "Total requests"},
    []string{"method", "status"},
)
requestsTotal.WithLabelValues("GET", "200").Inc()
```

## Gauge

Current value — goes up and down.

```go
activeConns := prometheus.NewGauge(prometheus.GaugeOpts{
    Name: "db_active_connections",
    Help: "Current active database connections",
})
activeConns.Set(float64(pool.Stat().AcquiredConns()))
```

## Histogram

Distribution of observed values into configurable buckets.

```go
duration := prometheus.NewHistogramVec(
    prometheus.HistogramOpts{
        Name:    "http_request_duration_seconds",
        Help:    "Request duration in seconds",
        Buckets: []float64{.005, .01, .025, .05, .1, .25, .5, 1, 2.5, 5},
    },
    []string{"method", "path"},
)

timer := prometheus.NewTimer(duration.WithLabelValues("GET", "/users"))
defer timer.ObserveDuration()
```

## Naming Convention

```text
<namespace>_<name>_<unit>
http_request_duration_seconds    (histogram)
http_requests_total              (counter — must end in _total)
db_connections_active            (gauge)
```
