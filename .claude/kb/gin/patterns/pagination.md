# Pagination Patterns

## Offset Pagination

```go
type PaginationRequest struct {
    Page  int `form:"page"  binding:"omitempty,min=1"`
    Limit int `form:"limit" binding:"omitempty,min=1,max=100"`
}

func (p *PaginationRequest) Offset() int {
    if p.Page <= 0 {
        p.Page = 1
    }
    return (p.Page - 1) * p.GetLimit()
}

func (p *PaginationRequest) GetLimit() int {
    if p.Limit <= 0 {
        return 20 // default
    }
    return p.Limit
}

type PaginatedResponse[T any] struct {
    Data       []T  `json:"data"`
    Total      int  `json:"total"`
    Page       int  `json:"page"`
    Limit      int  `json:"limit"`
    TotalPages int  `json:"total_pages"`
    HasMore    bool `json:"has_more"`
}

func NewPaginatedResponse[T any](data []T, total, page, limit int) PaginatedResponse[T] {
    totalPages := (total + limit - 1) / limit
    return PaginatedResponse[T]{
        Data:       data,
        Total:      total,
        Page:       page,
        Limit:      limit,
        TotalPages: totalPages,
        HasMore:    page < totalPages,
    }
}
```

## Cursor Pagination

```go
type CursorRequest struct {
    Cursor string `form:"cursor" binding:"omitempty"`
    Limit  int    `form:"limit"  binding:"omitempty,min=1,max=100"`
}

type CursorResponse[T any] struct {
    Data       []T    `json:"data"`
    NextCursor string `json:"next_cursor,omitempty"`
    HasMore    bool   `json:"has_more"`
}
```

## When to Use What

| Pattern | Best For | Drawbacks |
|---------|----------|-----------|
| Offset | Admin UIs, small datasets | Slow on large tables, page drift |
| Cursor | Infinite scroll, large datasets | No random page access |
