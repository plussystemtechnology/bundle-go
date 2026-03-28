# Labels

## Good Labels (Low Cardinality)

```go
[]string{"method", "status", "handler"} // ~50 combinations
// method: GET, POST, PUT, DELETE (4)
// status: 2xx, 4xx, 5xx (3)
// handler: /users, /orders, /auth (5)
```

## Bad Labels (High Cardinality)

```go
[]string{"user_id"}    // millions of values → OOM
[]string{"request_id"} // unique per request → OOM
[]string{"path"}       // /users/123 vs /users/456 → unbounded
```

## Path Normalization

Replace dynamic segments with placeholders:

```go
func normalizePath(c *gin.Context) string {
    return c.FullPath() // returns "/users/:id" not "/users/123"
}
```

## Cardinality Rule

Total time series = metric × label₁ × label₂ × ...

Keep total under 10,000 per metric. Monitor with: `count({__name__=~"http_.*"}) by (__name__)`
