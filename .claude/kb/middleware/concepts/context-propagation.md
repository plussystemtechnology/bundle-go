# Context Propagation

## Gin Context vs Go Context

Gin has TWO context mechanisms:

1. **`c.Set(key, val)` / `c.Get(key)`** — Gin-specific, lives in `*gin.Context`
2. **`c.Request.Context()`** — Standard Go `context.Context`, used by services/repos

```go
// Middleware sets value in Gin context
func AuthMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        claims := validateToken(c)
        c.Set("claims", claims)
        c.Set("user_id", claims.UserID)
        c.Next()
    }
}

// Handler reads from Gin context, passes Go context downstream
func (h *Handler) GetProfile(c *gin.Context) {
    userID, _ := c.Get("user_id")                    // from Gin context
    profile, err := h.svc.GetProfile(c.Request.Context(), userID.(string)) // Go context
    // ...
}
```

## Enriching Go Context

For values needed by services/repositories (not just handlers), add to Go context:

```go
func RequestIDMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        reqID := uuid.New().String()
        c.Set("request_id", reqID)

        // Also add to Go context for downstream use
        ctx := context.WithValue(c.Request.Context(), requestIDKey, reqID)
        c.Request = c.Request.WithContext(ctx)

        c.Header("X-Request-ID", reqID)
        c.Next()
    }
}
```

## Key Points

- Use `c.Set/Get` for handler-level data (auth claims, request metadata)
- Use `c.Request.Context()` for passing to service/repository layers
- Always pass `c.Request.Context()` to service calls (carries tracing, deadlines)
