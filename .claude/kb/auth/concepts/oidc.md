# OpenID Connect (OIDC)

## Provider Setup

```go
import "github.com/coreos/go-oidc/v3/oidc"

func NewOIDCVerifier(ctx context.Context, issuerURL, clientID string) (*oidc.IDTokenVerifier, error) {
    provider, err := oidc.NewProvider(ctx, issuerURL)
    if err != nil {
        return nil, fmt.Errorf("oidc provider: %w", err)
    }

    return provider.Verifier(&oidc.Config{
        ClientID: clientID,
    }), nil
}
```

## Token Verification

```go
func (s *AuthService) VerifyIDToken(ctx context.Context, rawToken string) (*oidc.IDToken, error) {
    idToken, err := s.verifier.Verify(ctx, rawToken)
    if err != nil {
        return nil, fmt.Errorf("verify token: %w", err)
    }

    var claims struct {
        Email         string `json:"email"`
        EmailVerified bool   `json:"email_verified"`
        Name          string `json:"name"`
    }
    if err := idToken.Claims(&claims); err != nil {
        return nil, fmt.Errorf("parse claims: %w", err)
    }

    return idToken, nil
}
```

## Common Providers

| Provider | Issuer URL |
|----------|-----------|
| Google | `https://accounts.google.com` |
| Azure AD | `https://login.microsoftonline.com/{tenant}/v2.0` |
| Keycloak | `https://keycloak.example.com/realms/{realm}` |
| Auth0 | `https://{domain}.auth0.com/` |
