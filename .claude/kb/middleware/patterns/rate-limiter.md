# Rate Limiter Middleware

## Token Bucket with golang.org/x/time/rate

```go
import "golang.org/x/time/rate"

type RateLimiterMiddleware struct {
    limiters sync.Map // ip -> *rate.Limiter
    rate     rate.Limit
    burst    int
}

func NewRateLimiter(rps int, burst int) *RateLimiterMiddleware {
    return &RateLimiterMiddleware{
        rate:  rate.Limit(rps),
        burst: burst,
    }
}

func (rl *RateLimiterMiddleware) getLimiter(ip string) *rate.Limiter {
    if v, ok := rl.limiters.Load(ip); ok {
        return v.(*rate.Limiter)
    }
    limiter := rate.NewLimiter(rl.rate, rl.burst)
    rl.limiters.Store(ip, limiter)
    return limiter
}

func (rl *RateLimiterMiddleware) Handler() gin.HandlerFunc {
    return func(c *gin.Context) {
        limiter := rl.getLimiter(c.ClientIP())
        if !limiter.Allow() {
            c.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{
                "error": "rate limit exceeded",
            })
            return
        }
        c.Next()
    }
}

// Usage
rl := NewRateLimiter(100, 10) // 100 req/s, burst of 10
r.Use(rl.Handler())
```
