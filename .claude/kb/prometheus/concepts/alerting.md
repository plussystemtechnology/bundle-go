# Alerting

## Alert Rules

```yaml
groups:
  - name: api-alerts
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate ({{ $value | humanizePercentage }})"

      - alert: SlowRequests
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 2
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "P95 latency above 2s"

      - alert: HighDBConnUsage
        expr: db_active_connections / db_max_connections > 0.8
        for: 5m
        labels:
          severity: warning
```

## Key Thresholds for Go APIs

| Metric | Warning | Critical |
|--------|---------|----------|
| Error rate (5xx) | > 1% | > 5% |
| P95 latency | > 1s | > 5s |
| DB pool usage | > 70% | > 90% |
| Memory usage | > 70% limit | > 90% limit |
| Goroutine count | > 10,000 | > 50,000 |
