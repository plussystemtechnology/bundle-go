# Middleware Quick Reference

## Standard Middleware Stack

```go
r := gin.New() // don't use gin.Default() — add middleware explicitly

r.Use(
    middleware.Recovery(logger),   // panic recovery (first!)
    middleware.RequestID(),        // inject X-Request-ID
    middleware.CORS(corsConfig),   // CORS headers
    middleware.Logger(logger),     // structured request logging
    otelgin.Middleware("api"),     // OpenTelemetry tracing
)
```

## Execution Order

```text
Request  → Recovery → RequestID → CORS → Logger → OTel → [route middleware] → Handler
Response ← Recovery ← RequestID ← CORS ← Logger ← OTel ← [route middleware] ← Handler
```

## Context Keys

| Key | Type | Set By | Used For |
|-----|------|--------|----------|
| `request_id` | string | RequestID MW | Correlation |
| `user_id` | string | Auth MW | User identification |
| `role` | string | Auth MW | Authorization |
| `claims` | *Claims | Auth MW | Full token claims |

## Decision: Middleware vs Handler

| Concern | Middleware | Handler |
|---------|-----------|---------|
| Auth/AuthZ | Yes | No |
| Logging | Yes | No |
| CORS | Yes | No |
| Rate limiting | Yes | No |
| Request validation | No | Yes |
| Business logic | No | Yes |
| Response formatting | No | Yes |
