# context.Context

## What Is Context?

`context.Context` carries:
1. **Cancellation signal** — when the operation should stop
2. **Deadline / timeout** — when the operation must stop
3. **Request-scoped values** — trace IDs, user IDs (use sparingly)

## The Rule

Every function that does I/O, blocking work, or could be cancelled
must accept `ctx context.Context` as its **first parameter**:

```go
func (r *PatientRepo) FindByID(ctx context.Context, id string) (*patient.Patient, error)
func (s *PatientService) CreatePatient(ctx context.Context, cmd CreateCommand) (*patient.Patient, error)
func (c *KafkaConsumer) ConsumeLoop(ctx context.Context) error
```

## Creating Contexts

```go
// Root context — only at the top level (main, test)
ctx := context.Background()

// For tests or placeholder
ctx := context.TODO()

// With cancellation
ctx, cancel := context.WithCancel(parent)
defer cancel()  // ALWAYS defer cancel to prevent context leak

// With timeout (auto-cancels after duration)
ctx, cancel := context.WithTimeout(parent, 5*time.Second)
defer cancel()

// With deadline (auto-cancels at absolute time)
deadline := time.Now().Add(30 * time.Second)
ctx, cancel := context.WithDeadline(parent, deadline)
defer cancel()
```

## Using Context in Handlers (Gin)

```go
func (h *PatientHandler) Get(c *gin.Context) {
    // c.Request.Context() carries the request lifetime
    ctx := c.Request.Context()

    p, err := h.svc.GetPatient(ctx, c.Param("id"))
    if err != nil { ... }
    c.JSON(http.StatusOK, gin.H{"data": p})
}
```

When the client disconnects, `ctx` is cancelled and propagated to all downstream calls.

## Checking Cancellation

```go
// In a loop
for {
    select {
    case <-ctx.Done():
        return ctx.Err()
    default:
    }
    // do work
}

// In a goroutine waiting for work
select {
case job := <-jobs:
    process(ctx, job)
case <-ctx.Done():
    return ctx.Err()
}

// After each DB call — pgx/sqlc uses ctx internally
row, err := r.queries.GetPatient(ctx, id)
if err != nil {
    if ctx.Err() != nil {
        return nil, fmt.Errorf("query cancelled: %w", ctx.Err())
    }
    return nil, fmt.Errorf("query patient: %w", err)
}
```

## Context Values (Request-Scoped Data)

Use a private key type to avoid collisions:

```go
// pkg/ctxkey/keys.go
package ctxkey

type traceIDKey struct{}
type userIDKey  struct{}

func WithTraceID(ctx context.Context, id string) context.Context {
    return context.WithValue(ctx, traceIDKey{}, id)
}
func TraceID(ctx context.Context) (string, bool) {
    v, ok := ctx.Value(traceIDKey{}).(string)
    return v, ok
}

func WithUserID(ctx context.Context, id string) context.Context {
    return context.WithValue(ctx, userIDKey{}, id)
}
func UserID(ctx context.Context) (string, bool) {
    v, ok := ctx.Value(userIDKey{}).(string)
    return v, ok
}
```

Usage in middleware:
```go
func AuthMiddleware(svc *service.AuthService) gin.HandlerFunc {
    return func(c *gin.Context) {
        token := c.GetHeader("Authorization")
        claims, err := svc.ValidateToken(c.Request.Context(), token)
        if err != nil {
            c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
            c.Abort()
            return
        }
        ctx := ctxkey.WithUserID(c.Request.Context(), claims.UserID)
        c.Request = c.Request.WithContext(ctx)
        c.Next()
    }
}
```

## Context Values: What to Store

| Store in Context           | Do NOT Store in Context      |
|----------------------------|------------------------------|
| Trace / request IDs        | Business parameters (patientID) |
| User ID (auth subject)     | Configuration                |
| Logger with request fields | Database connections         |
| Feature flags per request  | Anything needing testing     |

## Context Deadline Best Practices

```go
// Per-request timeout: set at handler or service boundary
func (h *ReportHandler) Generate(c *gin.Context) {
    ctx, cancel := context.WithTimeout(c.Request.Context(), 30*time.Second)
    defer cancel()

    report, err := h.svc.GenerateReport(ctx, c.Param("id"))
    // ...
}

// DB operations: let DB library propagate the context (pgx does this)
// Don't add extra timeouts inside repository methods — they'd stack

// Kafka publish: short timeout for each produce
func (p *Publisher) Publish(ctx context.Context, msg Message) error {
    pCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
    defer cancel()
    return p.client.ProduceSync(pCtx, toRecord(msg)).FirstErr()
}
```
