# Go Patterns — Quick Reference

## Pattern Decision Matrix

| Situation                                           | Use This Pattern          |
|-----------------------------------------------------|---------------------------|
| Function/struct with many optional parameters       | Functional Options        |
| Complex object built in multiple steps              | Builder                   |
| Select from N implementations at startup            | Factory                   |
| Swap algorithm without changing caller              | Strategy                  |
| Add methods to external type                        | Embedding (struct wrapper)|
| Reuse methods across types                          | Interface embedding       |
| Type-safe collection utility                        | Generics                  |
| Polymorphism without inheritance                    | Interface                 |

## Functional Options — Cheat Sheet

```go
type Option func(*Config)
func WithTimeout(d time.Duration) Option { return func(c *Config) { c.timeout = d } }

// Usage
s := New("addr", WithTimeout(5*time.Second), WithLogger(l))
```

## Interface — Cheat Sheet

```go
// Declare at point of use (consumer side)
type Storer interface { Store(ctx context.Context, key string, val []byte) error }

// Accept interface
func Process(s Storer) { ... }

// Compile-time check
var _ Storer = (*RedisStorer)(nil)
```

## Generics — Cheat Sheet (Go 1.18+)

```go
// Generic function
func Map[T, U any](s []T, fn func(T) U) []U {
    result := make([]U, len(s))
    for i, v := range s { result[i] = fn(v) }
    return result
}

// Constraint
type Number interface { ~int | ~int64 | ~float64 }
func Sum[T Number](nums []T) T { ... }

// Generic struct
type Result[T any] struct { Value T; Err error }
```

## Embedding — Cheat Sheet

```go
// Struct embedding (promotes fields + methods)
type LoggedRepo struct {
    *PatientRepo              // promoted methods
    logger *zap.Logger
}

// Interface embedding (compose interfaces)
type ReadWriter interface { Reader; Writer }
```

## Strategy — Cheat Sheet

```go
type Notifier interface { Send(ctx context.Context, msg Message) error }

type NotificationService struct { notifier Notifier }
func (s *NotificationService) Notify(ctx context.Context, msg Message) error {
    return s.notifier.Send(ctx, msg)
}
```

## Builder — Cheat Sheet

```go
type QueryBuilder struct { table string; wheres []string; limit int }

func (b *QueryBuilder) Where(cond string) *QueryBuilder {
    b.wheres = append(b.wheres, cond)
    return b
}
func (b *QueryBuilder) Limit(n int) *QueryBuilder { b.limit = n; return b }
func (b *QueryBuilder) Build() (string, error) { /* validate + build */ }

// Usage
q, err := NewQueryBuilder("patients").Where("active = true").Limit(10).Build()
```

## Factory — Cheat Sheet

```go
type CacheProvider string
const (ProviderRedis CacheProvider = "redis"; ProviderMemory CacheProvider = "memory")

func NewCache(provider CacheProvider, cfg *config.CacheConfig) (port.Cache, error) {
    switch provider {
    case ProviderRedis:  return redis.NewCache(cfg.RedisAddr)
    case ProviderMemory: return memory.NewCache(cfg.MaxEntries)
    default: return nil, fmt.Errorf("unknown cache provider: %s", provider)
    }
}
```

## Common Mistakes to Avoid

| Mistake                                | Fix                                           |
|----------------------------------------|-----------------------------------------------|
| `interface{}` / `any` everywhere       | Use generics or specific interface            |
| Large interface (10+ methods)          | Split into focused interfaces                 |
| Returning interface from constructor   | Return `*ConcreteType`                        |
| `init()` with side effects             | Explicit initialization in bootstrap          |
| Global `var logger = zap.NewNop()`     | Inject logger via constructor                 |
| Embedding to "inherit" behavior        | Prefer composition via interface field        |
| Unused interface at declaration site   | Define interface at usage site                |

## Accept Interfaces, Return Structs

```go
// GOOD
func Process(r io.Reader) *Result { ... }    // accept interface
func NewService(repo port.Repo) *Service { } // accept interface, return struct

// BAD
func NewService(repo port.Repo) port.Service { } // returning interface limits caller
func Process(f *os.File) *Result { ... }          // too concrete, hard to test
```
