# Concurrency — Quick Reference

## Pattern Decision Matrix

| Need                                        | Pattern                    |
|---------------------------------------------|----------------------------|
| Run N tasks, get first error                | `errgroup.WithContext`     |
| Process items with bounded parallelism      | Worker pool                |
| Transform data in stages                    | Pipeline                   |
| Distribute work to N workers, merge results | Fan-out / fan-in           |
| Protect shared mutable state                | `sync.Mutex` / `sync.RWMutex` |
| One-time lazy initialization                | `sync.Once`                |
| Wait for N goroutines                       | `sync.WaitGroup`           |
| Reuse byte buffers                          | `sync.Pool`                |
| Lock-free counter/flag                      | `atomic.Int64` / `atomic.Bool` |
| Cancel inflight work on shutdown            | `context.WithCancel`       |
| Timeout a single operation                  | `context.WithTimeout`      |

## errgroup Cheat Sheet

```go
import "golang.org/x/sync/errgroup"

g, ctx := errgroup.WithContext(ctx)

g.Go(func() error { return doA(ctx) })
g.Go(func() error { return doB(ctx) })

if err := g.Wait(); err != nil {
    return err  // first non-nil error
}
```

## Worker Pool Cheat Sheet

```go
jobs    := make(chan Job, len(items))
results := make(chan Result, len(items))

// Start N workers
for i := 0; i < numWorkers; i++ {
    go func() {
        for job := range jobs {
            results <- process(job)
        }
    }()
}

// Send jobs
for _, item := range items { jobs <- item }
close(jobs)

// Collect results
for i := 0; i < len(items); i++ {
    r := <-results
}
```

## context Cheat Sheet

```go
// With timeout
ctx, cancel := context.WithTimeout(parent, 5*time.Second)
defer cancel()

// With cancellation
ctx, cancel := context.WithCancel(parent)
defer cancel()

// With deadline
ctx, cancel := context.WithDeadline(parent, time.Now().Add(30*time.Second))
defer cancel()

// With value (use sparingly — not for business params)
ctx = context.WithValue(ctx, traceIDKey{}, traceID)
traceID := ctx.Value(traceIDKey{}).(string)

// Check cancellation in loops
select {
case <-ctx.Done():
    return ctx.Err()
default:
}
```

## sync Cheat Sheet

```go
// Mutex
var mu sync.Mutex
mu.Lock()
defer mu.Unlock()

// RWMutex
var rw sync.RWMutex
rw.RLock(); defer rw.RUnlock()  // reader
rw.Lock();  defer rw.Unlock()   // writer

// WaitGroup
var wg sync.WaitGroup
wg.Add(1)
go func() { defer wg.Done(); work() }()
wg.Wait()

// Once
var once sync.Once
once.Do(func() { expensiveInit() })

// Pool
var pool = sync.Pool{New: func() any { return make([]byte, 4096) }}
buf := pool.Get().([]byte)
defer pool.Put(buf[:0])
```

## Channel Idioms

```go
// Done signal
done := make(chan struct{})
close(done)  // broadcast to all receivers

// Semaphore (limit concurrent work to N)
sem := make(chan struct{}, N)
sem <- struct{}{}      // acquire
defer func() { <-sem }() // release

// Timeout on send/receive
select {
case ch <- val: // sent
case <-ctx.Done(): return ctx.Err()
}

// Non-blocking receive
select {
case v := <-ch: use(v)
default:        // nothing ready
}
```

## Common Mistakes

| Mistake                                  | Fix                                             |
|------------------------------------------|-------------------------------------------------|
| Goroutine with no shutdown               | Pass ctx, check `<-ctx.Done()`                  |
| Closing a channel twice                  | Only the sender closes; use sync.Once           |
| Writing to closed channel                | Use `select` with `ctx.Done` guard              |
| Capturing loop var in goroutine          | Shadow: `item := item` inside loop (pre-1.22)   |
| Mutex with value receiver                | Use pointer receiver `func (s *S) method()`     |
| `sync.WaitGroup` copy                    | Always pass `*sync.WaitGroup`                   |
