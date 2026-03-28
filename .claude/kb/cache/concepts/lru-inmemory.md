# In-Memory LRU Cache

## hashicorp/golang-lru

Fast, thread-safe, in-process LRU cache. No network overhead.

```go
import lru "github.com/hashicorp/golang-lru/v2"

// Fixed-size LRU
cache, err := lru.New[string, *User](1000) // max 1000 entries

// Add
cache.Add("user:"+id, user)

// Get
user, ok := cache.Get("user:" + id)
if !ok {
    // cache miss
}

// Remove
cache.Remove("user:" + id)
```

## LRU with Expiration

```go
import lru "github.com/hashicorp/golang-lru/v2/expirable"

cache := lru.NewLRU[string, *Config](
    100,            // max entries
    nil,            // onEvict callback
    5*time.Minute,  // TTL
)
```

## Two-Level Cache Pattern

Use in-memory LRU as L1 cache in front of Redis L2.

```go
type TwoLevelCache struct {
    l1  *lru.Cache[string, []byte]
    l2  *redis.Client
    ttl time.Duration
}

func (c *TwoLevelCache) Get(ctx context.Context, key string) ([]byte, error) {
    // L1: in-memory
    if val, ok := c.l1.Get(key); ok {
        return val, nil
    }

    // L2: Redis
    val, err := c.l2.Get(ctx, key).Bytes()
    if err != nil {
        return nil, err
    }

    // Promote to L1
    c.l1.Add(key, val)
    return val, nil
}
```

## When to Use

| Scenario | In-Memory LRU | Redis |
|----------|--------------|-------|
| Single instance, hot data | Yes | Optional |
| Multi-instance, shared state | L1 only | Required as L2 |
| Config / feature flags | Yes | Optional |
| User sessions | No | Yes |
