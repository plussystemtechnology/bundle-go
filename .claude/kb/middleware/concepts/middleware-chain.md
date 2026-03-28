# Middleware Chain Execution

## How Gin Middleware Works

Each middleware is a `gin.HandlerFunc`. The chain executes in order. Each middleware can:

1. Run code **before** the request (pre-processing)
2. Call `c.Next()` to pass to the next handler
3. Run code **after** the response (post-processing)
4. Call `c.Abort()` to stop the chain

```go
func ExampleMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        // Pre-processing (before handler)
        start := time.Now()

        c.Next() // call next handler

        // Post-processing (after handler)
        duration := time.Since(start)
        status := c.Writer.Status()
        log.Printf("%d %s %s", status, c.Request.Method, duration)
    }
}
```

## Abort vs Next

```go
// c.Next() — continue to next handler in chain
// c.Abort() — stop chain, remaining handlers skipped
// c.AbortWithStatusJSON() — abort + set response

func AuthRequired() gin.HandlerFunc {
    return func(c *gin.Context) {
        if !isAuthenticated(c) {
            c.AbortWithStatusJSON(401, gin.H{"error": "unauthorized"})
            return // always return after Abort
        }
        c.Next()
    }
}
```

## Key Rules

- Middleware registered with `r.Use()` runs for ALL routes in that group
- Order matters — first registered = first executed
- `c.Abort()` prevents remaining handlers but still runs post-processing of already-called middleware
- Always `return` after `c.Abort*()` to prevent further code in current middleware
