# HashiCorp Vault Integration

## Client Setup

```go
import vault "github.com/hashicorp/vault/api"

func NewVaultClient(addr, token string) (*vault.Client, error) {
    config := vault.DefaultConfig()
    config.Address = addr

    client, err := vault.NewClient(config)
    if err != nil {
        return nil, fmt.Errorf("vault client: %w", err)
    }

    client.SetToken(token)
    return client, nil
}
```

## Reading Secrets

```go
func (v *VaultStore) GetSecret(ctx context.Context, path string) (map[string]any, error) {
    secret, err := v.client.KVv2("secret").Get(ctx, path)
    if err != nil {
        return nil, fmt.Errorf("read secret %s: %w", path, err)
    }

    return secret.Data, nil
}

// Usage
data, err := store.GetSecret(ctx, "database/credentials")
dbPassword := data["password"].(string)
```

## Dynamic Database Credentials

```go
func (v *VaultStore) GetDBCredentials(ctx context.Context) (string, string, error) {
    secret, err := v.client.Logical().ReadWithContext(ctx, "database/creds/app-role")
    if err != nil {
        return "", "", fmt.Errorf("get db creds: %w", err)
    }

    username := secret.Data["username"].(string)
    password := secret.Data["password"].(string)

    // Credentials are leased — renew before expiry
    go v.renewLease(ctx, secret)

    return username, password, nil
}
```

## Key Points

- Never hardcode Vault tokens — use Kubernetes auth or AppRole
- Use KV v2 for static secrets, database engine for dynamic credentials
- Renew leases before expiry to avoid credential rotation gaps
