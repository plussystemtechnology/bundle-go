# Deployments

## Rolling Update (Default)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # 1 extra pod during update
      maxUnavailable: 0   # zero downtime
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
        - name: api
          image: myapp:v1.0.0
```

## Deployment Strategies

| Strategy | How | When |
|----------|-----|------|
| RollingUpdate | Gradual replacement | Default, most services |
| Recreate | Kill all, then create | Database, stateful apps |
| Blue-Green | Switch traffic at once | Need instant rollback |
| Canary | Route % to new version | Gradual rollout |
