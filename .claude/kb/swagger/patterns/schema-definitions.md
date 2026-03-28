# Schema Definitions

## Request/Response Models

```go
// ErrorResponse standard API error
type ErrorResponse struct {
    Error   string            `json:"error"   example:"validation failed"`
    Code    string            `json:"code"    example:"VALIDATION_ERROR"`
    Details map[string]string `json:"details,omitempty"`
}

// PaginatedResponse wraps paginated data
type PaginatedResponse[T any] struct {
    Data       []T  `json:"data"`
    Total      int  `json:"total"       example:"100"`
    Page       int  `json:"page"        example:"1"`
    Limit      int  `json:"limit"       example:"20"`
    TotalPages int  `json:"total_pages" example:"5"`
    HasMore    bool `json:"has_more"    example:"true"`
}
```

## Enum Documentation

```go
// OrderStatus represents the state of an order
// @Description Order status enum
// @enum pending,processing,shipped,delivered,cancelled
type OrderStatus string
```

## Nested Objects

```go
type OrderResponse struct {
    ID     string             `json:"id"     example:"550e8400-..."`
    Status string             `json:"status" example:"pending" enums:"pending,processing,shipped"`
    Items  []OrderItemResponse `json:"items"`
    Total  int64              `json:"total"  example:"4999"`
}

type OrderItemResponse struct {
    ProductID string `json:"product_id" example:"prod-123"`
    Quantity  int    `json:"quantity"   example:"2"`
    Price     int64  `json:"price"      example:"2499"`
}
```
