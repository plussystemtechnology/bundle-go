# Mocking in Go

## Philosophy

In NoxCare-Go, mocks are **hand-written** by default (no magic, no generated code unless
the interface is large or changes frequently). Use `mockery` for large, stable interfaces.

## Hand-Written Mock (recommended for small interfaces)

```go
// app/service/patient_service_test.go
type mockPatientRepo struct {
    findByIDFn  func(ctx context.Context, id string) (*patient.Patient, error)
    findByCPFFn func(ctx context.Context, cpf string) (*patient.Patient, error)
    saveFn      func(ctx context.Context, p *patient.Patient) error
    deleteFn    func(ctx context.Context, id string) error
}

func (m *mockPatientRepo) FindByID(ctx context.Context, id string) (*patient.Patient, error) {
    if m.findByIDFn != nil { return m.findByIDFn(ctx, id) }
    return nil, nil
}
func (m *mockPatientRepo) FindByCPF(ctx context.Context, cpf string) (*patient.Patient, error) {
    if m.findByCPFFn != nil { return m.findByCPFFn(ctx, cpf) }
    return nil, nil
}
func (m *mockPatientRepo) Save(ctx context.Context, p *patient.Patient) error {
    if m.saveFn != nil { return m.saveFn(ctx, p) }
    return nil
}
func (m *mockPatientRepo) Delete(ctx context.Context, id string) error {
    if m.deleteFn != nil { return m.deleteFn(ctx, id) }
    return nil
}
```

Usage in tests:
```go
func TestCreatePatient_CPFExists(t *testing.T) {
    existing := &patient.Patient{ID: "p-1", CPF: "123.456.789-09"}
    repo := &mockPatientRepo{
        findByCPFFn: func(_ context.Context, _ string) (*patient.Patient, error) {
            return existing, nil  // simulate CPF already exists
        },
    }
    svc := service.NewPatientService(repo, &noopPublisher{}, testConfig(), testLogger())
    _, err := svc.CreatePatient(context.Background(), dto.CreatePatientCommand{
        Name: "Bob",
        CPF:  "123.456.789-09",
    })
    assert.ErrorIs(t, err, patient.ErrCPFAlreadyExists)
}
```

## Spy Mock (records calls for assertions)

```go
type spyNotifier struct {
    mu    sync.Mutex
    calls []notifyCall
}

type notifyCall struct {
    To      string
    Subject string
}

func (s *spyNotifier) Send(_ context.Context, msg port.NotificationMessage) error {
    s.mu.Lock()
    defer s.mu.Unlock()
    s.calls = append(s.calls, notifyCall{To: msg.To, Subject: msg.Subject})
    return nil
}

func (s *spyNotifier) CallCount() int {
    s.mu.Lock()
    defer s.mu.Unlock()
    return len(s.calls)
}

// In test
spy := &spyNotifier{}
svc := service.NewNotificationService(spy, testLogger())
_ = svc.Notify(ctx, "patient-1", "Hello")

assert.Equal(t, 1, spy.CallCount())
assert.Equal(t, "patient-1", spy.calls[0].To)
```

## Mockery (generated mocks for large interfaces)

Generate mocks from interfaces:

```bash
# Install
go install github.com/vektra/mockery/v2@latest

# Generate for a specific interface
mockery --name=PatientRepository --dir=port --output=mocks --outpkg=mocks

# Or use go:generate directive
//go:generate mockery --name=PatientRepository
```

Generated mock usage:

```go
import "github.com/org/noxcare-go/mocks"

func TestGetPatient(t *testing.T) {
    repo := mocks.NewPatientRepository(t)
    repo.On("FindByID", mock.Anything, "p-123").
        Return(&patient.Patient{ID: "p-123"}, nil)

    svc := service.NewPatientService(repo, ...)
    p, err := svc.GetPatient(context.Background(), "p-123")

    assert.NoError(t, err)
    assert.Equal(t, "p-123", p.ID)
    repo.AssertExpectations(t)
}
```

## Noop Implementations

For dependencies where tests don't care about the behavior:

```go
// testutil/noop.go
package testutil

type NoopPublisher struct{}
func (n *NoopPublisher) PublishCreated(_ context.Context, _ *patient.Patient) error { return nil }

type NoopCache struct{}
func (n *NoopCache) Get(_ context.Context, _ string) (*patient.Patient, error) {
    return nil, patient.ErrNotFound
}
func (n *NoopCache) Set(_ context.Context, _ *patient.Patient, _ time.Duration) error { return nil }
func (n *NoopCache) Invalidate(_ context.Context, _ string) error { return nil }
```

## When to Use Which Approach

| Situation                                 | Use                       |
|-------------------------------------------|---------------------------|
| Interface has 1-3 methods                 | Hand-written mock          |
| Interface is stable and large (5+ methods)| mockery generated          |
| Test needs to verify calls were made      | Spy (records calls)        |
| Test doesn't care about the dependency    | Noop                       |
| DB-level test (real queries)              | testcontainers (no mock)  |

## Rule: Mock at the Port Boundary

Only mock `port/` interfaces in `app/service/` tests.
Never mock `domain/` types — they're pure Go, no I/O, test them directly.
Never mock adapters directly — test them with testcontainers.
