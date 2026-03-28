# Kubernetes Quick Reference

## Resource Types

| Resource | Purpose |
|----------|---------|
| Deployment | Stateless app replicas |
| Service | Stable network endpoint |
| ConfigMap | Non-secret configuration |
| Secret | Sensitive data (base64) |
| HPA | Auto-scaling by metrics |
| Ingress | External HTTP routing |
| PDB | Pod Disruption Budget |

## Probe Types

| Probe | Purpose | Failure Action |
|-------|---------|----------------|
| `livenessProbe` | Is the process alive? | Restart container |
| `readinessProbe` | Can it serve traffic? | Remove from Service |
| `startupProbe` | Has it started? | Block other probes |

## Common kubectl Commands

```bash
kubectl apply -f manifests/
kubectl get pods -l app=api
kubectl logs -f deploy/api
kubectl rollout status deploy/api
kubectl rollout undo deploy/api
kubectl describe pod <name>
kubectl port-forward svc/api 8080:8080
```

## Resource Recommendations for Go

| Resource | Request | Limit |
|----------|---------|-------|
| CPU | 100m-250m | 500m-1000m |
| Memory | 64Mi-128Mi | 256Mi-512Mi |

Go services are memory-efficient. Start low, monitor, adjust.
