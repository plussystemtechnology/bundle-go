# Gin Quick Reference

## Route Registration

| Method | Usage |
|--------|-------|
| `r.GET("/path", handler)` | GET endpoint |
| `r.POST("/path", handler)` | POST endpoint |
| `r.PUT("/path/:id", handler)` | PUT with param |
| `r.DELETE("/path/:id", handler)` | DELETE with param |
| `r.Group("/api/v1")` | Route group |

## Request Binding

| Tag | Source | Example |
|-----|--------|---------|
| `json:"name"` | JSON body | `c.ShouldBindJSON(&req)` |
| `form:"name"` | Query/Form | `c.ShouldBindQuery(&req)` |
| `uri:"id"` | URL param | `c.ShouldBindUri(&req)` |
| `header:"X-Token"` | Header | `c.ShouldBindHeader(&req)` |

## Common Validation Tags

| Tag | Meaning |
|-----|---------|
| `binding:"required"` | Field must be present |
| `binding:"min=1,max=100"` | Range check |
| `binding:"email"` | Email format |
| `binding:"oneof=active inactive"` | Enum values |
| `binding:"uuid"` | UUID format |

## Context Methods

| Method | Purpose |
|--------|---------|
| `c.Param("id")` | URL parameter |
| `c.Query("page")` | Query string |
| `c.GetHeader("Authorization")` | Request header |
| `c.JSON(200, obj)` | JSON response |
| `c.AbortWithStatusJSON(code, obj)` | Error + abort chain |
| `c.Set("key", val)` / `c.Get("key")` | Context values |
| `c.Next()` | Continue middleware chain |
| `c.Abort()` | Stop middleware chain |

## Decision: When to Use What

| Need | Use |
|------|-----|
| Bind JSON body | `c.ShouldBindJSON` |
| Bind query params | `c.ShouldBindQuery` |
| Bind URI params | `c.ShouldBindUri` |
| Return error | `c.AbortWithStatusJSON` |
| Pass data to next handler | `c.Set` / `c.Get` |
| Group routes with shared middleware | `r.Group().Use()` |
