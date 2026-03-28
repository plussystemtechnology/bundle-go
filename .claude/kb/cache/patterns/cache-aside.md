# Cache-Aside Pattern

```go
type CachedUserRepository struct {
    repo  port.UserRepository
    cache *redis.Client
    ttl   time.Duration
}

func NewCachedUserRepository(repo port.UserRepository, cache *redis.Client) *CachedUserRepository {
    return &CachedUserRepository{repo: repo, cache: cache, ttl: 5 * time.Minute}
}

func (r *CachedUserRepository) GetByID(ctx context.Context, id uuid.UUID) (*domain.User, error) {
    key := "user:" + id.String()

    // Try cache
    data, err := r.cache.Get(ctx, key).Bytes()
    if err == nil {
        var user domain.User
        if json.Unmarshal(data, &user) == nil {
            return &user, nil
        }
    }

    // Cache miss — load from DB
    user, err := r.repo.GetByID(ctx, id)
    if err != nil {
        return nil, err
    }

    // Write to cache (best-effort)
    if data, err := json.Marshal(user); err == nil {
        r.cache.Set(ctx, key, data, r.ttl)
    }

    return user, nil
}

func (r *CachedUserRepository) Update(ctx context.Context, id uuid.UUID, input domain.UpdateUser) (*domain.User, error) {
    user, err := r.repo.Update(ctx, id, input)
    if err != nil {
        return nil, err
    }

    // Invalidate cache
    r.cache.Del(ctx, "user:"+id.String())
    return user, nil
}
```
