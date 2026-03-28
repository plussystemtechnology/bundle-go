# Interfaces in Go

## How Go Interfaces Work

Go interfaces are **implicitly satisfied** — no `implements` keyword.
If a type has all the methods of an interface, it satisfies it automatically.

```go
type Stringer interface { String() string }

type Patient struct{ Name string }
func (p Patient) String() string { return p.Name }

// Patient satisfies Stringer — no declaration needed
var s Stringer = Patient{Name: "Alice"} // works
```

## The Two Roles of Interfaces

### 1. Abstraction (port pattern)
Define what a consumer needs; concrete types satisfy it:

```go
// port/cache.go — consumer defines what it needs
type Cache interface {
    Get(ctx context.Context, key string) ([]byte, error)
    Set(ctx context.Context, key string, val []byte, ttl time.Duration) error
    Delete(ctx context.Context, key string) error
}
```

### 2. Polymorphism
Accept different types that share behavior:

```go
type Closer interface { Close() error }

func closeAll(closers []Closer) {
    for _, c := range closers {
        if err := c.Close(); err != nil {
            log.Printf("close error: %v", err)
        }
    }
}
```

## Accept Interfaces, Return Structs

```go
// GOOD: parameter is interface → flexible, testable
func NewHandler(svc PatientServicer) *PatientHandler { ... }

// BAD: parameter is concrete → tightly coupled
func NewHandler(svc *service.PatientService) *PatientHandler { ... }

// GOOD: return concrete type → caller has full capability
func NewRedisCache(addr string) *RedisCache { ... }

// BAD: return interface → hides the type, limits callers
func NewRedisCache(addr string) Cache { ... }
```

## Interface Best Practices

### Small is better

```go
// GOOD: one method
type Reader interface { Read(p []byte) (n int, err error) }

// BAD: kitchen sink
type ReaderWriterCloserSeeker interface {
    Read(p []byte) (n int, err error)
    Write(p []byte) (n int, err error)
    Close() error
    Seek(offset int64, whence int) (int64, error)
    ReadAt(p []byte, off int64) (n int, err error)
}
```

### Compose when you need more

```go
type ReadWriter  interface { Reader; Writer }
type ReadCloser  interface { Reader; Closer }
```

### Compile-time satisfaction check

```go
// Add this line in the implementation file
var _ port.PatientRepository = (*PatientRepo)(nil)

// If PatientRepo doesn't satisfy port.PatientRepository, compile error:
// cannot use (*PatientRepo)(nil) (type *PatientRepo) as type port.PatientRepository
```

## Interface Naming Conventions

| Pattern       | Example                                           |
|---------------|---------------------------------------------------|
| -er suffix    | `Reader`, `Writer`, `Closer`, `Notifier`, `Sender`|
| Noun (ports)  | `PatientRepository`, `CacheStore`, `EventBus`     |
| -able (rare)  | `Cancelable`, `Resettable`                        |

## nil Interface vs nil Pointer

A common gotcha:

```go
var r *PatientRepo = nil
var i port.PatientRepository = r  // i is NOT nil!

fmt.Println(i == nil)  // false — interface holds (type, nil pointer)
fmt.Println(r == nil)  // true

// Safe nil check for interfaces:
if i == nil { ... }         // checks if interface itself is nil
if reflect.ValueOf(i).IsNil() { ... }  // checks if pointer inside is nil
```

Rule: never return a typed nil pointer as an interface:

```go
// BAD
func getRepo() port.Repository {
    var r *PatientRepo = nil
    return r  // returns non-nil interface wrapping nil pointer
}

// GOOD
func getRepo() port.Repository {
    return nil  // returns nil interface
}
```

## Empty Interface (any)

```go
// Go 1.18+ uses `any` as alias for interface{}
func Log(msg string, args ...any) { ... }

// Type assertion
if s, ok := v.(string); ok { ... }

// Type switch
switch t := v.(type) {
case string:  fmt.Println("string:", t)
case int:     fmt.Println("int:", t)
case error:   fmt.Println("error:", t)
default:      fmt.Printf("unknown: %T\n", t)
}
```

Avoid `any` in business logic. Use it only in:
- Logging (`...any` args)
- JSON marshaling helpers
- Generic utilities with proper constraints

## Interface as Behavior Contract

Interfaces express what a type **can do**, not what it **is**:

```go
// Not: "this is a patient" (is-a)
// But: "this can send notifications" (can-do)
type NotificationSender interface {
    SendNotification(ctx context.Context, to string, msg string) error
}

// Patient, Doctor, Admin can all satisfy NotificationSender
// without inheriting from a base class
```
