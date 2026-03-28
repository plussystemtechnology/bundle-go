# OWASP Top 10 for Go

## A01: Broken Access Control

```go
// Always check resource ownership
func (h *Handler) GetOrder(c *gin.Context) {
    userID, _ := c.Get("user_id")
    order, _ := h.svc.GetOrder(ctx, orderID)
    if order.UserID != userID {
        c.AbortWithStatus(http.StatusForbidden)
        return
    }
}
```

## A02: Cryptographic Failures

```go
// Use bcrypt for passwords
import "golang.org/x/crypto/bcrypt"
hash, _ := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
err := bcrypt.CompareHashAndPassword(hash, []byte(password))
```

## A03: Injection

Go + sqlc prevents SQL injection by design (parameterized queries). Never use `fmt.Sprintf` for SQL.

## A07: Authentication Failures

- Rate limit login endpoints
- Use constant-time comparison for tokens: `subtle.ConstantTimeCompare`
- Lock accounts after N failed attempts

## A09: Security Logging

```go
// Log security events
logger.Warn("authentication failed",
    zap.String("email", email),
    zap.String("ip", c.ClientIP()),
    // NEVER log passwords or tokens
)
```
