# Session Management

```go
type SessionManager struct {
    store  *redis.Client
    ttl    time.Duration
    secret []byte
}

type Session struct {
    ID        string    `json:"id"`
    UserID    uuid.UUID `json:"user_id"`
    Role      string    `json:"role"`
    IP        string    `json:"ip"`
    UserAgent string    `json:"user_agent"`
    CreatedAt time.Time `json:"created_at"`
    ExpiresAt time.Time `json:"expires_at"`
}

func (m *SessionManager) Create(ctx context.Context, c *gin.Context, userID uuid.UUID, role string) (string, error) {
    session := Session{
        ID:        uuid.New().String(),
        UserID:    userID,
        Role:      role,
        IP:        c.ClientIP(),
        UserAgent: c.GetHeader("User-Agent"),
        CreatedAt: time.Now(),
        ExpiresAt: time.Now().Add(m.ttl),
    }

    data, _ := json.Marshal(session)
    if err := m.store.Set(ctx, "session:"+session.ID, data, m.ttl).Err(); err != nil {
        return "", fmt.Errorf("store session: %w", err)
    }

    // Track active sessions per user
    m.store.SAdd(ctx, "user_sessions:"+userID.String(), session.ID)

    return session.ID, nil
}

func (m *SessionManager) RevokeAllForUser(ctx context.Context, userID uuid.UUID) error {
    key := "user_sessions:" + userID.String()
    sessionIDs, err := m.store.SMembers(ctx, key).Result()
    if err != nil {
        return err
    }

    pipe := m.store.Pipeline()
    for _, sid := range sessionIDs {
        pipe.Del(ctx, "session:"+sid)
    }
    pipe.Del(ctx, key)
    _, err = pipe.Exec(ctx)
    return err
}
```
