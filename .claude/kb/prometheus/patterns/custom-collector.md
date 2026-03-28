# Custom Collector

```go
type DBPoolCollector struct {
    pool            *pgxpool.Pool
    activeConns     *prometheus.Desc
    idleConns       *prometheus.Desc
    totalConns      *prometheus.Desc
    maxConns        *prometheus.Desc
}

func NewDBPoolCollector(pool *pgxpool.Pool) *DBPoolCollector {
    return &DBPoolCollector{
        pool:        pool,
        activeConns: prometheus.NewDesc("db_pool_active_connections", "Active connections", nil, nil),
        idleConns:   prometheus.NewDesc("db_pool_idle_connections", "Idle connections", nil, nil),
        totalConns:  prometheus.NewDesc("db_pool_total_connections", "Total connections", nil, nil),
        maxConns:    prometheus.NewDesc("db_pool_max_connections", "Max connections", nil, nil),
    }
}

func (c *DBPoolCollector) Describe(ch chan<- *prometheus.Desc) {
    ch <- c.activeConns
    ch <- c.idleConns
    ch <- c.totalConns
    ch <- c.maxConns
}

func (c *DBPoolCollector) Collect(ch chan<- prometheus.Metric) {
    stat := c.pool.Stat()
    ch <- prometheus.MustNewConstMetric(c.activeConns, prometheus.GaugeValue, float64(stat.AcquiredConns()))
    ch <- prometheus.MustNewConstMetric(c.idleConns, prometheus.GaugeValue, float64(stat.IdleConns()))
    ch <- prometheus.MustNewConstMetric(c.totalConns, prometheus.GaugeValue, float64(stat.TotalConns()))
    ch <- prometheus.MustNewConstMetric(c.maxConns, prometheus.GaugeValue, float64(stat.MaxConns()))
}

// Register
prometheus.MustRegister(NewDBPoolCollector(pool))
```
