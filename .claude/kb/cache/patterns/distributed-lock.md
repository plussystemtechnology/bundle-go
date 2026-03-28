# Distributed Lock with Redis

```go
type RedisLock struct {
    rdb    *redis.Client
    key    string
    value  string
    ttl    time.Duration
}

func NewLock(rdb *redis.Client, key string, ttl time.Duration) *RedisLock {
    return &RedisLock{
        rdb:   rdb,
        key:   "lock:" + key,
        value: uuid.New().String(),
        ttl:   ttl,
    }
}

func (l *RedisLock) Acquire(ctx context.Context) (bool, error) {
    return l.rdb.SetNX(ctx, l.key, l.value, l.ttl).Result()
}

// Release using Lua script for atomicity
func (l *RedisLock) Release(ctx context.Context) error {
    script := redis.NewScript(`
        if redis.call("get", KEYS[1]) == ARGV[1] then
            return redis.call("del", KEYS[1])
        end
        return 0
    `)
    return script.Run(ctx, l.rdb, []string{l.key}, l.value).Err()
}

// Usage
func (s *Service) ProcessOrder(ctx context.Context, orderID uuid.UUID) error {
    lock := NewLock(s.rdb, "order:"+orderID.String(), 30*time.Second)

    acquired, err := lock.Acquire(ctx)
    if err != nil {
        return fmt.Errorf("acquire lock: %w", err)
    }
    if !acquired {
        return domain.ErrOrderBeingProcessed
    }
    defer lock.Release(ctx)

    // Safe to process — we hold the lock
    return s.doProcessOrder(ctx, orderID)
}
```
