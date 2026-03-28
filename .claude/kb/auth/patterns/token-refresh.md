# Token Refresh Pattern

```go
type TokenPair struct {
    AccessToken  string `json:"access_token"`
    RefreshToken string `json:"refresh_token"`
    ExpiresIn    int    `json:"expires_in"`
}

func (s *AuthService) CreateTokenPair(user domain.User) (*TokenPair, error) {
    accessToken, err := s.createAccessToken(user, 15*time.Minute)
    if err != nil {
        return nil, err
    }

    refreshToken := uuid.New().String()

    // Store refresh token in Redis with user binding
    err = s.cache.Set(context.Background(), "refresh:"+refreshToken, user.ID.String(), 7*24*time.Hour).Err()
    if err != nil {
        return nil, fmt.Errorf("store refresh token: %w", err)
    }

    return &TokenPair{
        AccessToken:  accessToken,
        RefreshToken: refreshToken,
        ExpiresIn:    900, // 15 minutes
    }, nil
}

func (s *AuthService) RefreshTokens(ctx context.Context, refreshToken string) (*TokenPair, error) {
    // Get user ID from refresh token
    userID, err := s.cache.Get(ctx, "refresh:"+refreshToken).Result()
    if errors.Is(err, redis.Nil) {
        return nil, domain.ErrInvalidRefreshToken
    }
    if err != nil {
        return nil, fmt.Errorf("get refresh token: %w", err)
    }

    // Rotate: delete old refresh token
    s.cache.Del(ctx, "refresh:"+refreshToken)

    // Get user and create new pair
    uid, _ := uuid.Parse(userID)
    user, err := s.userRepo.GetByID(ctx, uid)
    if err != nil {
        return nil, err
    }

    return s.CreateTokenPair(*user)
}
```

## Key Points

- Access tokens: short-lived (15m), stateless JWT
- Refresh tokens: long-lived (7d), opaque string stored in Redis
- Always rotate refresh tokens on use (delete old, issue new)
- Bind refresh tokens to user ID for revocation
