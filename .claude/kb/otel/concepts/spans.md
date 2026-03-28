# Spans

## Creating Spans

```go
tracer := otel.Tracer("user-service")

func (s *UserService) GetByID(ctx context.Context, id uuid.UUID) (*domain.User, error) {
    ctx, span := tracer.Start(ctx, "UserService.GetByID")
    defer span.End()

    span.SetAttributes(attribute.String("user.id", id.String()))

    user, err := s.repo.GetByID(ctx, id)
    if err != nil {
        span.RecordError(err)
        span.SetStatus(codes.Error, err.Error())
        return nil, err
    }

    return user, nil
}
```

## Span Attributes

```go
span.SetAttributes(
    attribute.String("http.method", "GET"),
    attribute.String("http.url", "/users/123"),
    attribute.Int("http.status_code", 200),
    attribute.String("db.system", "postgresql"),
    attribute.String("db.statement", "SELECT ..."),
)
```

## Span Events

```go
span.AddEvent("cache.miss", trace.WithAttributes(
    attribute.String("cache.key", key),
))
```

## Key Rules

- Always pass `ctx` — it carries the trace
- Always `defer span.End()` immediately after `Start`
- Record errors with `span.RecordError(err)`
- Use semantic conventions for attribute names
