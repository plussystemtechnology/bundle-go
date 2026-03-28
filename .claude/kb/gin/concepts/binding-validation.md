# Request Binding & Validation

## Struct Tags

Gin uses `go-playground/validator` for validation. Bind with `ShouldBind*` (returns error) not `Bind*` (auto-responds 400).

```go
type CreateUserRequest struct {
    Name     string `json:"name"     binding:"required,min=2,max=100"`
    Email    string `json:"email"    binding:"required,email"`
    Role     string `json:"role"     binding:"required,oneof=admin user viewer"`
    Age      int    `json:"age"      binding:"omitempty,min=18,max=120"`
    Password string `json:"password" binding:"required,min=8"`
}
```

## Binding Methods

```go
// JSON body
func (h *Handler) Create(c *gin.Context) {
    var req CreateUserRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{
            "error":   "validation_failed",
            "details": err.Error(),
        })
        return
    }
    // req is valid here
}
```

## URI Parameter Binding

```go
type GetUserRequest struct {
    ID string `uri:"id" binding:"required,uuid"`
}

func (h *Handler) Get(c *gin.Context) {
    var req GetUserRequest
    if err := c.ShouldBindUri(&req); err != nil {
        c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
        return
    }
}
```

## Query Binding

```go
type ListRequest struct {
    Page   int    `form:"page"   binding:"omitempty,min=1"`
    Limit  int    `form:"limit"  binding:"omitempty,min=1,max=100"`
    Search string `form:"search" binding:"omitempty,max=200"`
}

func (h *Handler) List(c *gin.Context) {
    var req ListRequest
    if err := c.ShouldBindQuery(&req); err != nil {
        // handle error
    }
}
```
