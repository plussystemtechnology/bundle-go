# Goroutines

## What Are Goroutines?

Goroutines are lightweight, cooperatively scheduled threads managed by the Go runtime.
Starting a goroutine costs ~2KB of stack (grows as needed). Millions can run concurrently.

```go
go func() {
    // runs concurrently
}()
```

## Goroutine Lifecycle Rules

1. Every goroutine must have a way to **stop**
2. Never start a goroutine without knowing **when it will end**
3. Always propagate `context.Context` so work can be cancelled

## Pattern: Goroutine with Context

```go
func (w *Worker) Start(ctx context.Context) {
    go func() {
        for {
            select {
            case <-ctx.Done():
                w.logger.Info("worker stopping", zap.Error(ctx.Err()))
                return
            case job := <-w.jobs:
                w.process(ctx, job)
            }
        }
    }()
}
```

## Pattern: Goroutine with WaitGroup

```go
func processAll(ctx context.Context, items []Item) error {
    var wg sync.WaitGroup
    errCh := make(chan error, len(items))

    for _, item := range items {
        item := item  // capture (required pre-Go 1.22)
        wg.Add(1)
        go func() {
            defer wg.Done()
            if err := process(ctx, item); err != nil {
                errCh <- err
            }
        }()
    }

    wg.Wait()
    close(errCh)

    // Collect first error
    for err := range errCh {
        return err
    }
    return nil
}
```

(Prefer `errgroup` for this — see patterns/errgroup.md)

## Goroutine Leak Examples and Fixes

### Leak: blocked on channel forever

```go
// BAD: goroutine blocks forever if no one reads
go func() {
    result := compute()
    ch <- result  // blocks if ch is full and no reader
}()

// FIX: buffered channel or context-aware send
ch := make(chan Result, 1)  // buffer ensures non-blocking write
go func() {
    select {
    case ch <- compute():
    case <-ctx.Done():
    }
}()
```

### Leak: infinite loop with no exit

```go
// BAD
go func() {
    for {
        doWork()
        time.Sleep(1 * time.Second)
    }
}()

// FIX: respect context cancellation
go func() {
    ticker := time.NewTicker(1 * time.Second)
    defer ticker.Stop()
    for {
        select {
        case <-ctx.Done():
            return
        case <-ticker.C:
            doWork()
        }
    }
}()
```

### Leak: waiting on response that never comes

```go
// BAD
go func() {
    resp, err := http.Get(url)  // no timeout
    process(resp)
}()

// FIX: use context with timeout
go func() {
    req, _ := http.NewRequestWithContext(ctx, "GET", url, nil)
    resp, err := http.DefaultClient.Do(req)
    if err != nil { return }
    process(resp)
}()
```

## Graceful Shutdown Pattern

```go
// cmd/api/main.go
func main() {
    ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
    defer stop()

    app, err := bootstrap.Setup(cfg)
    if err != nil { log.Fatal(err) }

    // Start background workers
    app.StartWorkers(ctx)

    // Wait for shutdown signal
    <-ctx.Done()
    stop() // restore default signal behavior for second Ctrl+C

    shutdownCtx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
    defer cancel()
    if err := app.Shutdown(shutdownCtx); err != nil {
        log.Printf("shutdown error: %v", err)
    }
}
```

## Background Task Pattern

For fire-and-forget tasks that should not outlive the process:

```go
type BackgroundRunner struct {
    wg  sync.WaitGroup
    ctx context.Context
}

func (r *BackgroundRunner) Go(fn func(ctx context.Context)) {
    r.wg.Add(1)
    go func() {
        defer r.wg.Done()
        fn(r.ctx)
    }()
}

func (r *BackgroundRunner) Wait() { r.wg.Wait() }
```

## Detecting Goroutine Leaks

Use `goleak` in tests:

```go
import "go.uber.org/goleak"

func TestMain(m *testing.M) {
    goleak.VerifyTestMain(m)
}

func TestWorker(t *testing.T) {
    defer goleak.VerifyNone(t)
    // test worker — goleak detects leaks on test exit
}
```
