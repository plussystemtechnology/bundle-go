# Error Handling — Quick Reference

## Decision Matrix: Which Error Type?

| Situation                                     | Use                                          |
|-----------------------------------------------|----------------------------------------------|
| Named business condition (not found, conflict)| Sentinel error (`var ErrX = errors.New(...)`) |
| Error with extra data (field, code)           | Custom error struct + `Error() string`       |
| Validation with multiple field errors         | `ValidationError` slice                      |
| HTTP response error with status code          | `APIError{Code int, Message string}`         |
| Adding context to an existing error           | `fmt.Errorf("ctx: %w", err)`                 |
| Completely unexpected bug                     | `panic` (only in init/startup, not handlers) |

## Core Functions Cheat Sheet

```go
// Create
err := errors.New("static message")
err := fmt.Errorf("with value %s: %w", val, underlying)

// Wrap (always add operation context)
return fmt.Errorf("patient service create: %w", err)

// Check sentinel
if errors.Is(err, patient.ErrNotFound) { ... }

// Check type
var ve *ValidationError
if errors.As(err, &ve) { handleValidation(ve) }

// Unwrap chain
unwrapped := errors.Unwrap(err)

// Multiple wrapping (Go 1.20+)
err := fmt.Errorf("dual: %w, %w", err1, err2)
```

## Error Wrapping Convention

```go
// Pattern: "<package/function>: %w"
// adapter layer wraps with source
return fmt.Errorf("patient repo find by id: %w", err)

// app layer adds use case context
return fmt.Errorf("get patient: %w", err)

// handler layer translates to HTTP — does NOT re-wrap
if errors.Is(err, patient.ErrNotFound) {
    c.JSON(404, gin.H{"error": "patient not found"})
    return
}
```

## HTTP Status Mapping

| Error Condition          | HTTP Status |
|--------------------------|-------------|
| Not found (sentinel)     | 404         |
| Already exists / conflict| 409         |
| Validation failure       | 422 or 400  |
| Unauthorized             | 401         |
| Forbidden                | 403         |
| Internal / unexpected    | 500         |
| External service down    | 502/503     |

## Don't Do These

```go
// BAD: discarded error
repo.Save(ctx, p)

// BAD: no context
return err

// BAD: panic in handler
if err != nil { panic(err) }

// BAD: fmt.Sprintf instead of fmt.Errorf
return fmt.Errorf(fmt.Sprintf("error: %v", err)) // loses wrapping

// BAD: error string starts with capital or ends with punctuation
return errors.New("Patient not found.") // wrong
return errors.New("patient not found")  // correct
```

## Error Message Style

```go
// lowercase, no punctuation at end, describe the operation
errors.New("patient not found")
fmt.Errorf("list appointments by patient: %w", err)
fmt.Errorf("parse config: expected int, got %q: %w", val, err)

// NOT:
errors.New("Patient Not Found!")
errors.New("ERROR: failed to get patient")
```

## Logging vs Returning

```go
// In handlers/adapters: LOG then return HTTP error
if err != nil {
    logger.Error("get patient", zap.Error(err), zap.String("id", id))
    c.JSON(500, gin.H{"error": "internal error"})
    return
}

// In services/domain: RETURN only (let the handler decide how to log/respond)
if err := s.repo.FindByID(ctx, id); err != nil {
    return nil, fmt.Errorf("get patient: %w", err)
}
```
