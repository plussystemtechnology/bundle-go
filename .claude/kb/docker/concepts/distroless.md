# Distroless Images

## What Are They

Google's distroless images contain only the application and its runtime dependencies — no shell, no package manager, no OS utilities.

## Options for Go

| Image | Size | Has Shell | Use When |
|-------|------|-----------|----------|
| `gcr.io/distroless/static-debian12` | ~2MB | No | CGO_ENABLED=0 (most Go apps) |
| `gcr.io/distroless/base-debian12` | ~20MB | No | CGO_ENABLED=1 (needs libc) |
| `scratch` | 0MB | No | Absolute minimum |

## Security Benefits

- No shell → can't exec into container → smaller attack surface
- No package manager → can't install malware
- Fewer OS packages → fewer CVEs to patch
- Read-only filesystem by default

## Debugging

Since there's no shell, debug in dev with an alpine-based image. In production, use distroless + remote debugging or log-based troubleshooting.

```dockerfile
# Debug variant (has busybox shell)
FROM gcr.io/distroless/static-debian12:debug
```
