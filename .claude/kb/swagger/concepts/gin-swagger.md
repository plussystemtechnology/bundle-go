# Gin-Swagger Integration

## Setup

```go
import (
    swaggerFiles "github.com/swaggo/files"
    ginSwagger "github.com/swaggo/gin-swagger"
    _ "github.com/myapp/docs" // generated docs
)

func SetupSwagger(r *gin.Engine) {
    // Serve Swagger UI at /swagger/*
    r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
}
```

## Conditional by Environment

```go
func SetupSwagger(r *gin.Engine, env string) {
    if env == "production" {
        return // don't expose in production
    }
    r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler,
        ginSwagger.URL("/swagger/doc.json"),
        ginSwagger.DefaultModelsExpandDepth(-1),
    ))
}
```

## Makefile Target

```makefile
.PHONY: gen-docs
gen-docs: ## Generate Swagger documentation
	@swag init -g cmd/api/main.go -o docs/ --parseDependency --parseInternal
	@swag fmt
```

## Access

- Swagger UI: `http://localhost:8080/swagger/index.html`
- JSON spec: `http://localhost:8080/swagger/doc.json`
