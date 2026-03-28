# Session Store Pattern

```go
type SessionStore struct {
    rdb *redis.Client
    ttl time.Duration
}

func NewSessionStore(rdb *redis.Client, ttl time.Duration) *SessionStore {
    return &SessionStore{rdb: rdb, ttl: ttl}
}

type Session struct {
    UserID    uuid.UUID `json:"user_id"`
    Role      string    `json:"role"`
    ExpiresAt time.Time `json:"expires_at"`
}

func (s *SessionStore) Create(ctx context.Context, session Session) (string, error) {
    token := uuid.New().String()
    session.ExpiresAt = time.Now().Add(s.ttl)

    data, err := json.Marshal(session)
    if err != nil {
        return "", fmt.Errorf("marshal session: %w", err)
    }

    if err := s.rdb.Set(ctx, "session:"+token, data, s.ttl).Err(); err != nil {
        return "", fmt.Errorf("store session: %w", err)
    }

    return token, nil
}

func (s *SessionStore) Get(ctx context.Context, token string) (*Session, error) {
    data, err := s.rdb.Get(ctx, "session:"+token).Bytes()
    if errors.Is(err, redis.Nil) {
        return nil, domain.ErrSessionExpired
    }
    if err != nil {
        return nil, fmt.Errorf("get session: %w", err)
    }

    var session Session
    if err := json.Unmarshal(data, &session); err != nil {
        return nil, fmt.Errorf("unmarshal session: %w", err)
    }

    return &session, nil
}

func (s *SessionStore) Destroy(ctx context.Context, token string) error {
    return s.rdb.Del(ctx, "session:"+token).Err()
}

func (s *SessionStore) Refresh(ctx context.Context, token string) error {
    return s.rdb.Expire(ctx, "session:"+token, s.ttl).Err()
}
```
