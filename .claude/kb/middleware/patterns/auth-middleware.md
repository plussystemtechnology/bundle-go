# Auth Middleware Pattern

```go
func JWTAuth(authSvc port.AuthService) gin.HandlerFunc {
    return func(c *gin.Context) {
        header := c.GetHeader("Authorization")
        if header == "" {
            c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
                "error": "missing authorization header",
                "code":  "AUTH_MISSING",
            })
            return
        }

        token := strings.TrimPrefix(header, "Bearer ")
        if token == header {
            c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
                "error": "invalid authorization format",
                "code":  "AUTH_FORMAT",
            })
            return
        }

        claims, err := authSvc.ValidateToken(c.Request.Context(), token)
        if err != nil {
            c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
                "error": "invalid or expired token",
                "code":  "AUTH_INVALID",
            })
            return
        }

        c.Set("user_id", claims.UserID)
        c.Set("role", claims.Role)
        c.Set("claims", claims)
        c.Next()
    }
}

// Optional auth — doesn't abort if missing, but populates if present
func OptionalJWTAuth(authSvc port.AuthService) gin.HandlerFunc {
    return func(c *gin.Context) {
        header := c.GetHeader("Authorization")
        if header == "" {
            c.Next()
            return
        }

        token := strings.TrimPrefix(header, "Bearer ")
        claims, err := authSvc.ValidateToken(c.Request.Context(), token)
        if err == nil {
            c.Set("user_id", claims.UserID)
            c.Set("role", claims.Role)
        }
        c.Next()
    }
}
```
