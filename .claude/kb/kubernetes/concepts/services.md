# Services

## Service Types

| Type | Access | Use Case |
|------|--------|----------|
| ClusterIP | Internal only | Service-to-service |
| NodePort | External via node port | Dev/testing |
| LoadBalancer | External via cloud LB | Production (simple) |
| ExternalName | DNS alias | External services |

## ClusterIP Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api
spec:
  type: ClusterIP
  selector:
    app: api
  ports:
    - name: http
      port: 8080
      targetPort: 8080
    - name: grpc
      port: 50051
      targetPort: 50051
```

## DNS Resolution

Services get DNS: `<service>.<namespace>.svc.cluster.local`

```go
// Connect to db service in same namespace
connString := "postgres://user:pass@db:5432/app"

// Connect to service in different namespace
connString := "postgres://user:pass@db.data-ns.svc.cluster.local:5432/app"
```
