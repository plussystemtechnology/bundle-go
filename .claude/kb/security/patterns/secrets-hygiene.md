# Secrets Hygiene

## Never Do

- Hardcode secrets in source code
- Commit `.env` files with real credentials
- Log secrets (passwords, tokens, API keys)
- Store secrets in ConfigMaps (use Secrets or Vault)

## .gitignore

```gitignore
.env
.env.*
!.env.example
*.pem
*.key
credentials.json
```

## Environment Variables

```go
func LoadConfig() Config {
    return Config{
        DBPassword:  os.Getenv("DB_PASSWORD"),
        JWTSecret:   os.Getenv("JWT_SECRET"),
        VaultToken:  os.Getenv("VAULT_TOKEN"),
    }
}
```

## Pre-commit Secret Detection

```bash
# Install gitleaks
brew install gitleaks

# Scan
gitleaks detect --source=. --verbose

# Pre-commit hook
gitleaks protect --staged
```

## .env.example (Committed)

```env
DB_PASSWORD=changeme
JWT_SECRET=changeme
VAULT_ADDR=http://localhost:8200
VAULT_TOKEN=changeme
```
