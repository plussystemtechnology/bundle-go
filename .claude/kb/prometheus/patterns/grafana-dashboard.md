# Grafana Dashboard Patterns

## Essential Panels for Go API

### Request Rate

```promql
sum(rate(http_requests_total[5m])) by (method)
```

### Error Rate

```promql
sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))
```

### P50/P95/P99 Latency

```promql
histogram_quantile(0.50, rate(http_request_duration_seconds_bucket[5m]))
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))
```

### DB Pool Utilization

```promql
db_pool_active_connections / db_pool_max_connections
```

### Goroutine Count

```promql
go_goroutines
```

### Memory Usage

```promql
go_memstats_alloc_bytes / 1024 / 1024  # MB allocated
```

## Dashboard Layout

```text
Row 1: Request Rate | Error Rate | P95 Latency (single stat)
Row 2: Latency Over Time (graph) | Status Code Distribution (pie)
Row 3: DB Pool | Redis Connections | Goroutines
Row 4: CPU | Memory | GC Pause
```
