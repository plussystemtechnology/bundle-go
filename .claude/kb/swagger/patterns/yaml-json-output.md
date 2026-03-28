# Output Configuration

## Generated Files

After `swag init`, three files are created:

```text
docs/
├── docs.go       # Go package (import for gin-swagger)
├── swagger.json   # OpenAPI 3.0 in JSON
└── swagger.yaml   # OpenAPI 3.0 in YAML
```

## Custom Output Directory

```bash
swag init -g cmd/api/main.go -o internal/adapter/http/docs/
```

Update import accordingly:

```go
import _ "github.com/myapp/internal/adapter/http/docs"
```

## Serving Both Formats

```go
// gin-swagger serves JSON by default at /swagger/doc.json
r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

// For YAML, serve the file directly
r.StaticFile("/api-docs/swagger.yaml", "./docs/swagger.yaml")
```

## Using with External Tools

```bash
# Validate with swagger-cli
npx @apidevtools/swagger-cli validate docs/swagger.json

# Generate client SDK
openapi-generator generate -i docs/swagger.json -g typescript-axios -o sdk/

# Import to Postman
# File → Import → docs/swagger.json
```
