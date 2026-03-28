# Gin Middleware Chain

## Execution Model

Middleware runs as a chain. Each middleware calls `c.Next()` to pass control to the next handler, or `c.Abort()` to stop the chain.

```text
Request → Logger → Auth → RateLimit → Handler → (response flows back)
                                         ↓
                                    c.Next() at each step
```

## Writing Middleware

```go
func AuthMiddleware(authSvc port.AuthService) gin.HandlerFunc {
    return func(c *gin.Context) {
        token := c.GetHeader("Authorization")
        if token == "" {
            c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
                "error": "missing authorization header",
            })
            return
        }

        claims, err := authSvc.ValidateToken(c.Request.Context(), token)
        if err != nil {
            c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
                "error": "invalid token",
            })
            return
        }

        // Store claims for downstream handlers
        c.Set("user_id", claims.UserID)
        c.Set("role", claims.Role)
        c.Next()
    }
}
```

## Applying Middleware

```go
// Global — applies to all routes
r.Use(middleware.Logger(), middleware.Recovery())

// Group-level — applies to group routes only
api := r.Group("/api/v1")
api.Use(middleware.Auth(authSvc))

// Route-level — single route
r.GET("/admin", middleware.RequireRole("admin"), adminHandler)
```

## Before/After Pattern

```go
func TimingMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()
        c.Next() // process request
        duration := time.Since(start)
        c.Header("X-Response-Time", duration.String())
    }
}
```
