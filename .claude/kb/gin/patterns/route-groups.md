# Route Groups Pattern

## API Versioning with Groups

```go
func SetupRouter(
    userH *handler.UserHandler,
    orderH *handler.OrderHandler,
    authMW gin.HandlerFunc,
    adminMW gin.HandlerFunc,
) *gin.Engine {
    r := gin.New()
    r.Use(gin.Recovery(), middleware.Logger(), middleware.RequestID())

    // Health check — no auth
    r.GET("/health", handler.HealthCheck)

    // Public routes
    public := r.Group("/api/v1")
    {
        public.POST("/auth/login", authH.Login)
        public.POST("/auth/register", authH.Register)
    }

    // Authenticated routes
    auth := r.Group("/api/v1")
    auth.Use(authMW)
    {
        users := auth.Group("/users")
        {
            users.GET("", userH.List)
            users.GET("/:id", userH.Get)
            users.PUT("/:id", userH.Update)
        }

        orders := auth.Group("/orders")
        {
            orders.GET("", orderH.List)
            orders.POST("", orderH.Create)
            orders.GET("/:id", orderH.Get)
        }
    }

    // Admin routes
    admin := r.Group("/api/v1/admin")
    admin.Use(authMW, adminMW)
    {
        admin.GET("/users", userH.ListAll)
        admin.DELETE("/users/:id", userH.Delete)
    }

    return r
}
```

## Key Points

- Group routes by access level (public, authenticated, admin)
- Apply middleware at the group level, not per-route
- Use consistent path prefixes for versioning (`/api/v1`, `/api/v2`)
- Health check stays outside auth groups
