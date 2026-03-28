# JWT (JSON Web Tokens)

## Creating Tokens

```go
import "github.com/golang-jwt/jwt/v5"

type Claims struct {
    jwt.RegisteredClaims
    UserID string `json:"uid"`
    Role   string `json:"role"`
}

func (s *AuthService) CreateToken(user domain.User) (string, error) {
    claims := Claims{
        RegisteredClaims: jwt.RegisteredClaims{
            Issuer:    "bundle-go-api",
            Subject:   user.ID.String(),
            ExpiresAt: jwt.NewNumericDate(time.Now().Add(1 * time.Hour)),
            IssuedAt:  jwt.NewNumericDate(time.Now()),
            ID:        uuid.New().String(),
        },
        UserID: user.ID.String(),
        Role:   string(user.Role),
    }

    token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
    return token.SignedString([]byte(s.secretKey))
}
```

## Validating Tokens

```go
func (s *AuthService) ValidateToken(tokenString string) (*Claims, error) {
    token, err := jwt.ParseWithClaims(tokenString, &Claims{},
        func(token *jwt.Token) (any, error) {
            if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
                return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
            }
            return []byte(s.secretKey), nil
        },
    )
    if err != nil {
        return nil, fmt.Errorf("parse token: %w", err)
    }

    claims, ok := token.Claims.(*Claims)
    if !ok || !token.Valid {
        return nil, fmt.Errorf("invalid token claims")
    }

    return claims, nil
}
```

## Key Points

- Use `HS256` for internal services (shared secret)
- Use `RS256` for public APIs (asymmetric keys)
- Always validate `alg` header to prevent algorithm confusion attacks
- Keep access tokens short-lived (15m-1h)
- Store signing keys in Vault, not config files
