# JWT Middleware Pattern

```go
func JWTAuthMiddleware(authSvc port.AuthService) gin.HandlerFunc {
    return func(c *gin.Context) {
        header := c.GetHeader("Authorization")
        if header == "" {
            c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
                "error": "missing authorization header",
            })
            return
        }

        parts := strings.SplitN(header, " ", 2)
        if len(parts) != 2 || parts[0] != "Bearer" {
            c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
                "error": "invalid authorization format, expected 'Bearer <token>'",
            })
            return
        }

        claims, err := authSvc.ValidateToken(c.Request.Context(), parts[1])
        if err != nil {
            c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
                "error": "invalid or expired token",
            })
            return
        }

        // Store claims in context
        c.Set("user_id", claims.UserID)
        c.Set("role", claims.Role)
        c.Set("claims", claims)
        c.Next()
    }
}

// Helper to extract user ID from context
func GetUserID(c *gin.Context) (uuid.UUID, error) {
    id, exists := c.Get("user_id")
    if !exists {
        return uuid.Nil, fmt.Errorf("user_id not in context")
    }
    return uuid.Parse(id.(string))
}
```
