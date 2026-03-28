# gosec Configuration

## .gosec.yaml

```yaml
global:
  audit: enabled
  nosec: false  # don't ignore #nosec comments

rules:
  # Enable all rules except:
  exclude:
    - G104  # Audit errors not checked (too noisy for some projects)
```

## Makefile Target

```makefile
.PHONY: security
security: ## Run security checks
	@echo "Running gosec..."
	@gosec -fmt=json -out=reports/gosec.json ./... 2>/dev/null || true
	@gosec ./...
	@echo "Running govulncheck..."
	@govulncheck ./...
```

## CI Integration

```yaml
- name: Security scan
  run: |
    go install github.com/securego/gosec/v2/cmd/gosec@latest
    gosec -fmt=sarif -out=gosec.sarif ./...

- name: Upload SARIF
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: gosec.sarif
```
