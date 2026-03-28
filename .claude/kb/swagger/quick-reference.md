# Swagger Quick Reference

## Annotation Tags

| Tag | Purpose | Example |
|-----|---------|---------|
| `@Summary` | Short description | `@Summary Create a user` |
| `@Description` | Detailed description | `@Description Creates a new user` |
| `@Tags` | Group endpoints | `@Tags users` |
| `@Accept` | Request content type | `@Accept json` |
| `@Produce` | Response content type | `@Produce json` |
| `@Param` | Parameter definition | `@Param id path string true "User ID"` |
| `@Success` | Success response | `@Success 200 {object} UserResponse` |
| `@Failure` | Error response | `@Failure 400 {object} ErrorResponse` |
| `@Router` | Route definition | `@Router /users/{id} [get]` |
| `@Security` | Auth requirement | `@Security BearerAuth` |

## Param Format

```text
@Param name location type required "description"
```

Locations: `path`, `query`, `header`, `body`, `formData`

## Commands

```bash
# Install swag
go install github.com/swaggo/swag/cmd/swag@latest

# Generate docs
swag init -g cmd/api/main.go -o docs/

# Format annotations
swag fmt
```

## Main File Annotations

```go
// @title NoxCare API
// @version 1.0
// @description Go Backend API with Clean Architecture
// @host localhost:8080
// @BasePath /api/v1
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
func main() { ... }
```
