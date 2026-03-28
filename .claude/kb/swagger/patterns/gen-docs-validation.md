# Docs Generation & Validation

## Generate

```bash
# Basic generation
swag init -g cmd/api/main.go -o docs/

# With dependency parsing (for imported types)
swag init -g cmd/api/main.go -o docs/ --parseDependency --parseInternal

# Format annotations
swag fmt
```

## Validate in CI

```makefile
.PHONY: swagger-check
swagger-check: ## Ensure swagger docs are up to date
	@swag init -g cmd/api/main.go -o docs/ --parseDependency --parseInternal
	@git diff --exit-code docs/ || (echo "Swagger docs are out of date. Run 'make gen-docs'" && exit 1)
```

## Common Issues

| Issue | Fix |
|-------|-----|
| Types not found | Add `--parseDependency` flag |
| Internal types missing | Add `--parseInternal` flag |
| Wrong base path | Check `@BasePath` in main.go |
| Missing security | Add `@securityDefinitions.apikey` to main |
| Generic types not resolved | Swaggo supports generics since v1.16 |

## Pre-commit Hook

```bash
#!/bin/bash
# .githooks/pre-commit
swag init -g cmd/api/main.go -o docs/ --parseDependency --parseInternal
git diff --exit-code docs/ || {
    echo "Swagger docs changed. Please stage the changes."
    exit 1
}
```
