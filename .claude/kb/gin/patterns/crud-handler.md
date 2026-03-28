# CRUD Handler Pattern

## Complete Handler Set

```go
type UserHandler struct {
    svc port.UserService
}

func NewUserHandler(svc port.UserService) *UserHandler {
    return &UserHandler{svc: svc}
}

// Create godoc
// @Summary Create user
// @Tags users
// @Accept json
// @Produce json
// @Param request body CreateUserRequest true "User data"
// @Success 201 {object} UserResponse
// @Failure 400 {object} ErrorResponse
// @Router /api/v1/users [post]
func (h *UserHandler) Create(c *gin.Context) {
    var req CreateUserRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        HandleValidationError(c, err)
        return
    }

    user, err := h.svc.Create(c.Request.Context(), req.ToDomain())
    if err != nil {
        HandleError(c, err)
        return
    }

    c.JSON(http.StatusCreated, ToUserResponse(user))
}

func (h *UserHandler) Get(c *gin.Context) {
    var uri IDRequest
    if err := c.ShouldBindUri(&uri); err != nil {
        HandleValidationError(c, err)
        return
    }

    user, err := h.svc.GetByID(c.Request.Context(), uri.ID)
    if err != nil {
        HandleError(c, err)
        return
    }

    c.JSON(http.StatusOK, ToUserResponse(user))
}

func (h *UserHandler) List(c *gin.Context) {
    var req ListRequest
    if err := c.ShouldBindQuery(&req); err != nil {
        HandleValidationError(c, err)
        return
    }

    users, total, err := h.svc.List(c.Request.Context(), req.ToFilter())
    if err != nil {
        HandleError(c, err)
        return
    }

    c.JSON(http.StatusOK, ToListResponse(users, total, req.Page, req.Limit))
}

func (h *UserHandler) Update(c *gin.Context) {
    var uri IDRequest
    if err := c.ShouldBindUri(&uri); err != nil {
        HandleValidationError(c, err)
        return
    }

    var req UpdateUserRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        HandleValidationError(c, err)
        return
    }

    user, err := h.svc.Update(c.Request.Context(), uri.ID, req.ToDomain())
    if err != nil {
        HandleError(c, err)
        return
    }

    c.JSON(http.StatusOK, ToUserResponse(user))
}

func (h *UserHandler) Delete(c *gin.Context) {
    var uri IDRequest
    if err := c.ShouldBindUri(&uri); err != nil {
        HandleValidationError(c, err)
        return
    }

    if err := h.svc.Delete(c.Request.Context(), uri.ID); err != nil {
        HandleError(c, err)
        return
    }

    c.Status(http.StatusNoContent)
}
```
