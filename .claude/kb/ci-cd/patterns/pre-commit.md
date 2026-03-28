# Pre-commit Hooks

## Git Hook Script

```bash
#!/bin/bash
# .githooks/pre-commit

set -e

echo "Running pre-commit checks..."

# Format check
if [ -n "$(gofmt -l .)" ]; then
    echo "Code is not formatted. Run: gofmt -w ."
    gofmt -l .
    exit 1
fi

# Vet
echo "Running go vet..."
go vet ./...

# Lint (fast mode)
echo "Running golangci-lint..."
golangci-lint run --fast

# Tests (short mode)
echo "Running tests..."
go test -short -race ./...

echo "Pre-commit checks passed!"
```

## Setup

```bash
# Set hooks directory
git config core.hooksPath .githooks

# Or copy to .git/hooks
cp .githooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## Makefile Target

```makefile
.PHONY: install-hooks
install-hooks: ## Install git hooks
	git config core.hooksPath .githooks
	chmod +x .githooks/*
```

## Key Points

- Use `--fast` flag for golangci-lint in pre-commit (faster)
- Use `-short` flag for tests (skip integration tests)
- Don't use `--no-verify` to skip hooks — fix the issues instead
