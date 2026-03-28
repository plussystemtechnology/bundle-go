# Gin Routing

## Route Registration

Routes map HTTP methods + paths to handler functions.

```go
func SetupRoutes(r *gin.Engine, h *handler.UserHandler) {
    api := r.Group("/api/v1")
    {
        users := api.Group("/users")
        {
            users.GET("", h.List)
            users.POST("", h.Create)
            users.GET("/:id", h.Get)
            users.PUT("/:id", h.Update)
            users.DELETE("/:id", h.Delete)
        }
    }
}
```

## URL Parameters

```go
// Path parameter: /users/:id
func (h *UserHandler) Get(c *gin.Context) {
    id := c.Param("id") // string
    // parse to UUID
    uid, err := uuid.Parse(id)
    if err != nil {
        c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
        return
    }
    // ...
}
```

## Query Parameters

```go
// /users?page=1&limit=20&sort=name
func (h *UserHandler) List(c *gin.Context) {
    page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
    limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
    sort := c.DefaultQuery("sort", "created_at")
    // ...
}
```

## Wildcard Routes

```go
// Catch-all: /assets/*filepath
r.Static("/assets", "./public")
r.GET("/proxy/*path", proxyHandler)
```
