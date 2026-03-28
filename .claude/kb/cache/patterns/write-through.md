# Write-Through Cache Pattern

```go
type WriteThroughUserRepo struct {
    repo  port.UserRepository
    cache *redis.Client
    ttl   time.Duration
}

func (r *WriteThroughUserRepo) Create(ctx context.Context, user domain.User) (*domain.User, error) {
    // Write to DB first
    created, err := r.repo.Create(ctx, user)
    if err != nil {
        return nil, err
    }

    // Write to cache immediately
    r.cacheUser(ctx, created)
    return created, nil
}

func (r *WriteThroughUserRepo) Update(ctx context.Context, id uuid.UUID, input domain.UpdateUser) (*domain.User, error) {
    updated, err := r.repo.Update(ctx, id, input)
    if err != nil {
        return nil, err
    }

    // Update cache with fresh data
    r.cacheUser(ctx, updated)
    return updated, nil
}

func (r *WriteThroughUserRepo) GetByID(ctx context.Context, id uuid.UUID) (*domain.User, error) {
    key := "user:" + id.String()

    // Always try cache first
    data, err := r.cache.Get(ctx, key).Bytes()
    if err == nil {
        var user domain.User
        if json.Unmarshal(data, &user) == nil {
            return &user, nil
        }
    }

    // Fallback to DB
    user, err := r.repo.GetByID(ctx, id)
    if err != nil {
        return nil, err
    }

    r.cacheUser(ctx, user)
    return user, nil
}

func (r *WriteThroughUserRepo) cacheUser(ctx context.Context, user *domain.User) {
    data, err := json.Marshal(user)
    if err != nil {
        return // best-effort caching
    }
    r.cache.Set(ctx, "user:"+user.ID.String(), data, r.ttl)
}
```
