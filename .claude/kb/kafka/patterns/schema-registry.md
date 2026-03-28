# Schema Registry

## Event Schema Versioning

Use a typed event envelope for schema evolution:

```go
type EventEnvelope struct {
    EventID   string          `json:"event_id"`
    EventType string          `json:"event_type"`
    Version   int             `json:"version"`
    Timestamp time.Time       `json:"timestamp"`
    Source    string           `json:"source"`
    Data      json.RawMessage `json:"data"`
}
```

## Producer with Schema

```go
func (p *Producer) PublishEvent(ctx context.Context, topic string, key string, eventType string, data any) error {
    payload, err := json.Marshal(data)
    if err != nil {
        return fmt.Errorf("marshal data: %w", err)
    }

    envelope := EventEnvelope{
        EventID:   uuid.New().String(),
        EventType: eventType,
        Version:   1,
        Timestamp: time.Now().UTC(),
        Source:    "order-service",
        Data:      payload,
    }

    msg, err := json.Marshal(envelope)
    if err != nil {
        return fmt.Errorf("marshal envelope: %w", err)
    }

    return p.writer.WriteMessages(ctx, kafka.Message{
        Key:   []byte(key),
        Value: msg,
        Headers: []kafka.Header{
            {Key: "event-type", Value: []byte(eventType)},
            {Key: "schema-version", Value: []byte("1")},
        },
    })
}
```

## Consumer with Version Handling

```go
func (h *Handler) HandleMessage(ctx context.Context, msg kafka.Message) error {
    var envelope EventEnvelope
    if err := json.Unmarshal(msg.Value, &envelope); err != nil {
        return fmt.Errorf("unmarshal envelope: %w", err)
    }

    switch envelope.EventType {
    case "order.created":
        return h.handleOrderCreated(ctx, envelope)
    case "order.updated":
        return h.handleOrderUpdated(ctx, envelope)
    default:
        h.logger.Warn("unknown event type", zap.String("type", envelope.EventType))
        return nil // skip unknown events
    }
}
```
