# Interface Segregation Principle in Go

## Core Idea

Clients should not be forced to depend on interfaces they do not use.
In Go: **keep interfaces small and focused**. Prefer many small interfaces over one large one.

Go's implicit interface satisfaction makes ISP natural — you can define a tiny interface
anywhere you need it, without modifying the implementing type.

## Anti-Pattern: Fat Interface

```go
// BAD: forces every consumer to implement all methods
type PatientRepository interface {
    FindByID(ctx context.Context, id string) (*patient.Patient, error)
    ListActive(ctx context.Context, limit, offset int) ([]*patient.Patient, error)
    Save(ctx context.Context, p *patient.Patient) error
    Delete(ctx context.Context, id string) error
    UpdateStatus(ctx context.Context, id string, active bool) error
    FindByEmail(ctx context.Context, email string) (*patient.Patient, error)
    BulkImport(ctx context.Context, patients []*patient.Patient) error
    ExportToCSV(ctx context.Context, w io.Writer) error  // export concern mixed in!
}
```

A test that only needs `FindByID` still has to implement all 8 methods.

## Good Pattern: Segregated Interfaces

```go
// port/patient_reader.go
type PatientReader interface {
    FindByID(ctx context.Context, id string) (*patient.Patient, error)
    ListActive(ctx context.Context, limit, offset int) ([]*patient.Patient, error)
    FindByEmail(ctx context.Context, email string) (*patient.Patient, error)
}

// port/patient_writer.go
type PatientWriter interface {
    Save(ctx context.Context, p *patient.Patient) error
    Delete(ctx context.Context, id string) error
    UpdateStatus(ctx context.Context, id string, active bool) error
}

// port/patient_repository.go — composite for adapters that implement both
type PatientRepository interface {
    PatientReader
    PatientWriter
}

// port/patient_exporter.go — separate concern
type PatientExporter interface {
    ExportToCSV(ctx context.Context, w io.Writer) error
}
```

## Using the Smallest Interface Possible

```go
// app/service/patient_query_service.go
// This service only reads — depends on PatientReader, not full Repository
type PatientQueryService struct {
    reader port.PatientReader
}

func NewPatientQueryService(r port.PatientReader) *PatientQueryService {
    return &PatientQueryService{reader: r}
}
```

```go
// app/service/patient_command_service.go
// This service only writes
type PatientCommandService struct {
    writer port.PatientWriter
}
```

## The io.Reader / io.Writer Model

The Go standard library is the best example of ISP:

```go
type Reader interface { Read(p []byte) (n int, err error) }
type Writer interface { Write(p []byte) (n int, err error) }
type Closer interface { Close() error }

// Composites only when both are needed
type ReadWriter interface { Reader; Writer }
type ReadWriteCloser interface { Reader; Writer; Closer }
```

Apply the same thinking to domain interfaces.

## Role Interface Pattern

Define interfaces based on the **role** a dependency plays in a specific context:

```go
// NotificationService only needs to know how to find a patient's contact info
type PatientContactFinder interface {
    FindContactByID(ctx context.Context, id string) (*patient.Contact, error)
}

// ScheduleService only needs to check patient existence
type PatientExistenceChecker interface {
    ExistsID(ctx context.Context, id string) (bool, error)
}
```

Both are satisfied by the same `adapter/db/PatientRepo` struct, but each service
declares only the capability it needs.

## Testing Benefit

Small interfaces mean minimal mock implementations:

```go
// Test for a service that only reads
type stubReader struct{ p *patient.Patient }
func (s *stubReader) FindByID(_ context.Context, _ string) (*patient.Patient, error) {
    return s.p, nil
}
func (s *stubReader) ListActive(_ context.Context, _, _ int) ([]*patient.Patient, error) {
    return []*patient.Patient{s.p}, nil
}
func (s *stubReader) FindByEmail(_ context.Context, _ string) (*patient.Patient, error) {
    return s.p, nil
}
// 3 methods instead of 8
```

## Rule of Thumb

> If your mock has methods that return `nil, nil` or `panic("not implemented")`,
> your interface is too large — split it.
