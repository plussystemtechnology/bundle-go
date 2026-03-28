# Auth Quick Reference

## JWT Libraries

| Library | Use For |
|---------|---------|
| `golang-jwt/jwt/v5` | JWT creation and validation |
| `coreos/go-oidc/v3` | OIDC provider integration |
| `golang.org/x/oauth2` | OAuth2 client flows |
| `hashicorp/vault/api` | Vault secrets access |

## JWT Claims

```go
type Claims struct {
    jwt.RegisteredClaims
    UserID string `json:"uid"`
    Role   string `json:"role"`
    Email  string `json:"email"`
}
```

## Auth Decision Matrix

| Scenario | Approach |
|----------|----------|
| Internal API, trusted clients | JWT with shared secret |
| Public API, third-party apps | OAuth2 + OIDC |
| Microservice-to-microservice | mTLS or JWT with service account |
| Admin operations | JWT + RBAC with elevated claims |
| Single-page app | OIDC authorization code + PKCE |

## Token Lifetimes

| Token Type | TTL | Storage |
|-----------|-----|---------|
| Access token | 15m-1h | Memory/header |
| Refresh token | 7d-30d | HttpOnly cookie or Redis |
| ID token (OIDC) | 1h | Client memory |

## Common HTTP Headers

```text
Authorization: Bearer <access_token>
X-Refresh-Token: <refresh_token>
```
