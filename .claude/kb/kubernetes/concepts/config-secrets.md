# ConfigMaps and Secrets

## ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: api-config
data:
  APP_ENV: production
  LOG_LEVEL: info
  DB_HOST: db.data-ns.svc.cluster.local
  DB_PORT: "5432"
  REDIS_ADDR: redis:6379
```

## Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: api-secrets
type: Opaque
stringData:  # plain text (base64 encoded automatically)
  DB_PASSWORD: supersecret
  JWT_SECRET: my-jwt-signing-key
  VAULT_TOKEN: s.xxxxx
```

## Injection Methods

### Environment Variables

```yaml
envFrom:
  - configMapRef:
      name: api-config
  - secretRef:
      name: api-secrets
```

### Volume Mount (for files)

```yaml
volumes:
  - name: config
    configMap:
      name: api-config
containers:
  - volumeMounts:
      - name: config
        mountPath: /etc/config
        readOnly: true
```

## Best Practice: External Secrets Operator

For production, use External Secrets Operator to sync from Vault/AWS Secrets Manager instead of plain K8s Secrets.
