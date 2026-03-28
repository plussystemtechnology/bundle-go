# Sync Primitives

## sync.Mutex — Exclusive Lock

Use when you need to protect shared mutable state with a single writer:

```go
type SafeCounter struct {
    mu    sync.Mutex
    count int
}

func (c *SafeCounter) Increment() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.count++
}

func (c *SafeCounter) Value() int {
    c.mu.Lock()
    defer c.mu.Unlock()
    return c.count
}
```

Rules:
- Always use pointer receivers when embedding mutex
- Never copy a Mutex (use `go vet` to detect this)
- Keep the critical section small — unlock as soon as possible

## sync.RWMutex — Many Readers, One Writer

```go
type Cache struct {
    rw    sync.RWMutex
    items map[string]any
}

func (c *Cache) Get(key string) (any, bool) {
    c.rw.RLock()           // multiple readers can hold RLock simultaneously
    defer c.rw.RUnlock()
    v, ok := c.items[key]
    return v, ok
}

func (c *Cache) Set(key string, val any) {
    c.rw.Lock()            // exclusive — blocks all readers and writers
    defer c.rw.Unlock()
    c.items[key] = val
}
```

## sync.WaitGroup — Wait for N Goroutines

```go
func sendNotifications(ctx context.Context, patients []*patient.Patient, msg Message) error {
    var wg sync.WaitGroup
    errs := make(chan error, len(patients))

    for _, p := range patients {
        p := p
        wg.Add(1)
        go func() {
            defer wg.Done()
            if err := sendOne(ctx, p, msg); err != nil {
                errs <- err
            }
        }()
    }

    wg.Wait()
    close(errs)

    var allErrs []error
    for err := range errs { allErrs = append(allErrs, err) }
    return errors.Join(allErrs...)
}
```

## sync.Once — Single Initialization

```go
type DB struct {
    once sync.Once
    pool *pgxpool.Pool
}

func (db *DB) Pool() *pgxpool.Pool {
    db.once.Do(func() {
        var err error
        db.pool, err = pgxpool.New(context.Background(), db.dsn)
        if err != nil {
            panic(fmt.Sprintf("init db pool: %v", err))
        }
    })
    return db.pool
}
```

For safe channel closing:
```go
type SafeChannel[T any] struct {
    ch   chan T
    once sync.Once
}

func (s *SafeChannel[T]) Close() {
    s.once.Do(func() { close(s.ch) })
}
```

## sync.Pool — Reuse Allocations

Use to reduce GC pressure for frequently allocated, short-lived objects (buffers, JSON encoders):

```go
var bufferPool = sync.Pool{
    New: func() any {
        return bytes.NewBuffer(make([]byte, 0, 4096))
    },
}

func encodeJSON(v any) ([]byte, error) {
    buf := bufferPool.Get().(*bytes.Buffer)
    buf.Reset()
    defer bufferPool.Put(buf)  // return to pool, not to GC

    if err := json.NewEncoder(buf).Encode(v); err != nil {
        return nil, err
    }
    // Copy before returning — buf goes back to pool
    result := make([]byte, buf.Len())
    copy(result, buf.Bytes())
    return result, nil
}
```

## atomic — Lock-Free Operations

For single numeric values or flags that need concurrent access without mutex overhead:

```go
import "sync/atomic"

// Counter
var requestCount atomic.Int64
requestCount.Add(1)
total := requestCount.Load()

// Boolean flag
var healthy atomic.Bool
healthy.Store(true)
if healthy.Load() { ... }

// Compare-and-swap
var version atomic.Int64
old := version.Load()
swapped := version.CompareAndSwap(old, old+1)

// Pointer (any type, Go 1.19+)
var config atomic.Pointer[Config]
config.Store(newCfg)
current := config.Load()
```

## Choosing Between Primitives

| Scenario                              | Use                   |
|---------------------------------------|-----------------------|
| Simple counter / flag                 | `atomic`              |
| Guard a map or complex struct         | `sync.Mutex`          |
| Cache (many reads, rare writes)       | `sync.RWMutex`        |
| Wait for group of goroutines          | `sync.WaitGroup`      |
| Initialize once (lazy singleton)      | `sync.Once`           |
| Reuse byte buffers / encoders         | `sync.Pool`           |
| Parallel work + first error           | `errgroup.Group`      |
| Passing ownership of data             | channels              |

## Race Detector

Always run tests with `-race`:

```bash
go test -race ./...
go run -race cmd/api/main.go
```

The race detector catches:
- Concurrent map writes
- Unsynchronized variable access
- Missing mutex around shared state
