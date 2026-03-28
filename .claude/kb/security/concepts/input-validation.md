# Input Validation

## Defense in Depth

Validate at every boundary:

1. **HTTP layer** — Gin binding tags (`binding:"required,email"`)
2. **Service layer** — Business rule validation
3. **Database layer** — Constraints (NOT NULL, CHECK, UNIQUE)

## Gin Binding Validation

```go
type CreateUserRequest struct {
    Name     string `json:"name"     binding:"required,min=2,max=100,alphanum"`
    Email    string `json:"email"    binding:"required,email"`
    Password string `json:"password" binding:"required,min=8,max=72"`
    Role     string `json:"role"     binding:"required,oneof=user viewer"`
}
```

## Sanitization

```go
import "html"

// Escape HTML to prevent XSS in stored data
sanitized := html.EscapeString(userInput)

// For SQL, always use parameterized queries (sqlc handles this)
// NEVER: fmt.Sprintf("SELECT * FROM users WHERE name = '%s'", name)
```

## Key Rules

- Never trust client input — validate everything
- Use allowlists (oneof, enum) not blocklists
- Limit string lengths to prevent abuse
- Use `max=72` for bcrypt passwords (72-byte limit)
- Validate UUID format before database queries
