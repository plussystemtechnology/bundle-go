# Rate Limiter with Redis

## Sliding Window

```go
func (rl *RateLimiter) Allow(ctx context.Context, key string, limit int, window time.Duration) (bool, error) {
    now := time.Now().UnixMilli()
    windowStart := now - window.Milliseconds()
    member := fmt.Sprintf("%d:%s", now, uuid.New().String()[:8])

    pipe := rl.rdb.Pipeline()
    pipe.ZRemRangeByScore(ctx, key, "0", strconv.FormatInt(windowStart, 10))
    pipe.ZAdd(ctx, key, redis.Z{Score: float64(now), Member: member})
    countCmd := pipe.ZCard(ctx, key)
    pipe.Expire(ctx, key, window)

    _, err := pipe.Exec(ctx)
    if err != nil {
        return false, fmt.Errorf("rate limit check: %w", err)
    }

    return countCmd.Val() <= int64(limit), nil
}
```

## Gin Middleware

```go
func RateLimitMiddleware(rdb *redis.Client, limit int, window time.Duration) gin.HandlerFunc {
    rl := &RateLimiter{rdb: rdb}
    return func(c *gin.Context) {
        key := "ratelimit:" + c.ClientIP()
        allowed, err := rl.Allow(c.Request.Context(), key, limit, window)
        if err != nil {
            c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": "rate limit error"})
            return
        }
        if !allowed {
            c.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{
                "error": "rate limit exceeded",
                "retry_after": window.Seconds(),
            })
            return
        }
        c.Next()
    }
}
```
