# Validator Rules

## Common Security-Relevant Rules

```go
type CreateUserRequest struct {
    Name     string `binding:"required,min=2,max=100,excludesall=<>"`
    Email    string `binding:"required,email,max=254"`
    Password string `binding:"required,min=8,max=72"`
    Phone    string `binding:"omitempty,e164"`           // international format
    URL      string `binding:"omitempty,url,max=2048"`
    Role     string `binding:"required,oneof=user viewer"` // allowlist
}
```

## Dangerous Patterns to Avoid

```go
// BAD: accepts any string for role
Role string `binding:"required"`

// GOOD: allowlist of valid values
Role string `binding:"required,oneof=user viewer admin"`

// BAD: no length limit
Bio string `binding:"omitempty"`

// GOOD: prevent abuse
Bio string `binding:"omitempty,max=5000"`

// BAD: allows HTML/script tags
Name string `binding:"required"`

// GOOD: exclude dangerous characters
Name string `binding:"required,excludesall=<>"`
```

## UUID Validation

```go
type GetRequest struct {
    ID string `uri:"id" binding:"required,uuid"`
}
```

Always validate UUID format before passing to database queries.
