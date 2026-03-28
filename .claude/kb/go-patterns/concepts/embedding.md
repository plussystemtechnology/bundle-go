# Embedding in Go

## What is Embedding?

Embedding promotes fields and methods of one type into another.
It is **not** inheritance — it is composition with method promotion.

## Struct Embedding

```go
type Base struct {
    CreatedAt time.Time
    UpdatedAt time.Time
}

func (b *Base) Touch() { b.UpdatedAt = time.Now() }

type Patient struct {
    Base              // embedded — all Base fields/methods promoted
    ID   string
    Name string
}

// Usage — promoted fields/methods accessible directly
p := Patient{ID: "1", Name: "Alice"}
p.Base.CreatedAt = time.Now()  // explicit
p.Touch()                       // promoted — same as p.Base.Touch()
fmt.Println(p.UpdatedAt)        // promoted field
```

## Embedding for Logging Wrapper (Adapter pattern)

```go
// adapter/db/repo/logged_patient_repo.go
type LoggedPatientRepo struct {
    *PatientRepo              // embeds concrete type, promotes all methods
    logger *zap.Logger
}

func NewLoggedPatientRepo(r *PatientRepo, l *zap.Logger) *LoggedPatientRepo {
    return &LoggedPatientRepo{PatientRepo: r, logger: l}
}

// Override only FindByID — all other methods use PatientRepo's
func (r *LoggedPatientRepo) FindByID(ctx context.Context, id string) (*patient.Patient, error) {
    start := time.Now()
    p, err := r.PatientRepo.FindByID(ctx, id)  // delegate
    r.logger.Info("FindByID",
        zap.String("id", id),
        zap.Duration("elapsed", time.Since(start)),
        zap.Error(err),
    )
    return p, err
}
```

## Interface Embedding (Composition)

```go
// port/patient_repository.go
type PatientReader interface {
    FindByID(ctx context.Context, id string) (*patient.Patient, error)
    ListActive(ctx context.Context, n int) ([]*patient.Patient, error)
}

type PatientWriter interface {
    Save(ctx context.Context, p *patient.Patient) error
    Delete(ctx context.Context, id string) error
}

// Compose interfaces
type PatientRepository interface {
    PatientReader
    PatientWriter
}
```

## Embedding for Partial Mocks

```go
// In tests: embed the real interface to get zero-value behavior for unneeded methods
type mockOnlyReader struct {
    port.PatientRepository  // embed interface — all methods panic with nil receiver
}

// Only override what the test needs
func (m *mockOnlyReader) FindByID(_ context.Context, id string) (*patient.Patient, error) {
    return &patient.Patient{ID: id, Name: "Test"}, nil
}

// Now Save, Delete, etc. will panic if called — catches unexpected calls in tests
```

**Warning:** Using embedded interfaces in mocks is clever but can mask bugs.
Prefer explicit mocks with all methods implemented for production test code.

## Embedding vs. Explicit Field

```go
// Embedding — promotes methods to outer type
type Server struct {
    *http.Server          // can call s.ListenAndServe() directly
    logger *zap.Logger
}

// Explicit field — no promotion, must use s.server.ListenAndServe()
type Server struct {
    server *http.Server
    logger *zap.Logger
}
```

Use embedding when:
- You want to extend an existing type with new methods
- You want the outer type to satisfy the embedded type's interface
- The embedded type is a pure implementation detail (like `sync.Mutex`)

## sync.Mutex Embedding Pattern

```go
// Embed mutex to lock the struct itself
type SafeCounter struct {
    sync.Mutex
    count int
}

func (c *SafeCounter) Inc() {
    c.Lock()
    defer c.Unlock()
    c.count++
}

func (c *SafeCounter) Value() int {
    c.Lock()
    defer c.Unlock()
    return c.count
}
```

## Pitfalls

### Method set of pointer vs value receiver

```go
type Animal struct{}
func (a *Animal) Speak() string { return "..." }

type Dog struct{ Animal }

d := Dog{}
d.Speak()    // OK — Go auto-derives pointer
(&d).Speak() // OK

// But as interface:
var s Speaker = d   // ERROR: Dog doesn't implement Speaker (Speak is on *Animal)
var s Speaker = &d  // OK
```

### Field collision

```go
type A struct { ID string }
type B struct { ID string }

type C struct { A; B }

c := C{}
c.ID       // COMPILE ERROR: ambiguous selector c.ID
c.A.ID     // OK — explicit
```

When two embedded types have the same field, you must qualify it explicitly.
