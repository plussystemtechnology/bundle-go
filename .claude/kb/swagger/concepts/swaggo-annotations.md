# Swaggo Annotations

## Handler Annotation

```go
// CreateUser godoc
// @Summary Create a new user
// @Description Create a user with the provided data
// @Tags users
// @Accept json
// @Produce json
// @Param request body CreateUserRequest true "User creation data"
// @Success 201 {object} UserResponse
// @Failure 400 {object} ErrorResponse "Validation error"
// @Failure 409 {object} ErrorResponse "Email already exists"
// @Failure 500 {object} ErrorResponse "Internal server error"
// @Security BearerAuth
// @Router /users [post]
func (h *UserHandler) CreateUser(c *gin.Context) { ... }
```

## Struct Annotations

```go
// CreateUserRequest represents the user creation payload
type CreateUserRequest struct {
    Name  string `json:"name"  example:"John Doe" binding:"required,min=2"`
    Email string `json:"email" example:"john@example.com" binding:"required,email"`
    Role  string `json:"role"  example:"user" enums:"admin,user,viewer"`
}

// UserResponse represents a user in API responses
type UserResponse struct {
    ID        string `json:"id"         example:"550e8400-e29b-41d4-a716-446655440000"`
    Name      string `json:"name"       example:"John Doe"`
    Email     string `json:"email"      example:"john@example.com"`
    CreatedAt string `json:"created_at" example:"2024-01-15T10:30:00Z"`
}
```

## Key Points

- `example:` tag provides sample values in Swagger UI
- `enums:` tag defines allowed values
- `binding:` tags are also reflected in docs
- Comments above struct = schema description
- `godoc` comment (first line after func name) triggers swag parsing
