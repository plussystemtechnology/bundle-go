# Role-Based Access Control

```go
type Role string

const (
    RoleAdmin  Role = "admin"
    RoleUser   Role = "user"
    RoleViewer Role = "viewer"
)

// RequireRole middleware — checks if user has any of the allowed roles
func RequireRole(roles ...Role) gin.HandlerFunc {
    allowed := make(map[Role]bool, len(roles))
    for _, r := range roles {
        allowed[r] = true
    }

    return func(c *gin.Context) {
        roleStr, exists := c.Get("role")
        if !exists {
            c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
                "error": "no role found in context",
            })
            return
        }

        role := Role(roleStr.(string))
        if !allowed[role] {
            c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
                "error": "insufficient permissions",
                "required_roles": roles,
            })
            return
        }

        c.Next()
    }
}

// Usage in routes
admin := r.Group("/admin")
admin.Use(JWTAuthMiddleware(authSvc), RequireRole(RoleAdmin))
{
    admin.GET("/users", userH.ListAll)
    admin.DELETE("/users/:id", userH.Delete)
}

// Editor routes — admin or user
editor := r.Group("/api/v1")
editor.Use(JWTAuthMiddleware(authSvc), RequireRole(RoleAdmin, RoleUser))
{
    editor.POST("/articles", articleH.Create)
    editor.PUT("/articles/:id", articleH.Update)
}
```
