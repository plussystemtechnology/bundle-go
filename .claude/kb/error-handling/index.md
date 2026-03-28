# Error Handling — Bundle-Go

## Philosophy

> Errors are values. Handle them where you have context. Wrap with `%w`.

Go errors are explicit — no exceptions, no panic for expected failures.
Every error must be either handled or returned (with wrapping context added).

## Error Layers

| Layer     | Error Type                        | Example                            |
|-----------|-----------------------------------|------------------------------------|
| domain/   | Domain sentinel errors            | `ErrPatientNotFound`, `ErrInvalidCPF` |
| port/     | No errors (just signatures)       | —                                  |
| app/      | Wrapped domain + infra errors     | `fmt.Errorf("create patient: %w", err)` |
| adapter/  | Infra errors wrapped with context | `fmt.Errorf("db find patient: %w", err)` |
| pkg/      | Validation errors, HTTP errors    | `apierror.New(400, "invalid input")` |

## Core Tools

```go
// Wrap with context
fmt.Errorf("operation context: %w", err)

// Check type/value in chain
errors.Is(err, ErrPatientNotFound)  // sentinel check
errors.As(err, &validationErr)       // type check

// Create
errors.New("something went wrong")  // simple
fmt.Errorf("with %s format: %w", "context", err)  // wrapped
```

## Error Types Used in Bundle-Go

| Type              | Purpose                                  | Where defined    |
|-------------------|------------------------------------------|------------------|
| Sentinel errors   | Named error values for domain conditions | domain/          |
| `ValidationError` | Field-level validation failures          | pkg/apierror/    |
| `APIError`        | HTTP error with status code + message    | pkg/apierror/    |
| Wrapped errors    | Context chain for debugging              | everywhere       |

## Quick Navigation

- `concepts/error-types.md` — types of errors and when to use each
- `concepts/wrapping.md` — `fmt.Errorf("%w")`, errors.Is/As
- `concepts/sentinel-errors.md` — named error variables
- `patterns/custom-errors.md` — struct-based custom errors
- `patterns/error-chain.md` — wrapping pattern across layers
- `patterns/validation-errors.md` — multi-field validation errors
- `patterns/api-errors.md` — HTTP error responses
