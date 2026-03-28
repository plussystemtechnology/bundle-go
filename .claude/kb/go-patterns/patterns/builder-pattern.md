# Builder Pattern

## Overview

Builder constructs complex objects step-by-step with validation.
In Go, it's typically implemented as a method-chaining struct with a terminal `Build()` that validates.

## When to Use

- The object has many fields and not all are always set
- Construction requires validation before the object is usable
- You want a fluent API for readability
- The building process involves multiple discrete steps

## Notification Message Builder

```go
// domain/notification/message.go
package notification

import (
    "errors"
    "strings"
    "time"
)

type Channel string
const (
    ChannelEmail Channel = "email"
    ChannelSMS   Channel = "sms"
    ChannelPush  Channel = "push"
)

type Message struct {
    RecipientID string
    Channel     Channel
    Subject     string
    Body        string
    ScheduledAt *time.Time
    Metadata    map[string]string
}

// MessageBuilder builds a validated Message
type MessageBuilder struct {
    msg Message
    errs []string
}

func NewMessageBuilder(recipientID string, channel Channel) *MessageBuilder {
    return &MessageBuilder{
        msg: Message{
            RecipientID: recipientID,
            Channel:     channel,
            Metadata:    make(map[string]string),
        },
    }
}

func (b *MessageBuilder) WithSubject(subject string) *MessageBuilder {
    if strings.TrimSpace(subject) == "" {
        b.errs = append(b.errs, "subject cannot be empty")
    }
    b.msg.Subject = subject
    return b
}

func (b *MessageBuilder) WithBody(body string) *MessageBuilder {
    if strings.TrimSpace(body) == "" {
        b.errs = append(b.errs, "body cannot be empty")
    }
    b.msg.Body = body
    return b
}

func (b *MessageBuilder) ScheduleAt(t time.Time) *MessageBuilder {
    if t.Before(time.Now()) {
        b.errs = append(b.errs, "scheduled time must be in the future")
    }
    b.msg.ScheduledAt = &t
    return b
}

func (b *MessageBuilder) WithMetadata(key, value string) *MessageBuilder {
    b.msg.Metadata[key] = value
    return b
}

func (b *MessageBuilder) Build() (*Message, error) {
    if b.msg.RecipientID == "" {
        b.errs = append(b.errs, "recipient ID is required")
    }
    if b.msg.Body == "" && len(b.errs) == 0 {
        b.errs = append(b.errs, "body is required")
    }
    if len(b.errs) > 0 {
        return nil, errors.New("invalid message: " + strings.Join(b.errs, "; "))
    }
    msg := b.msg // copy
    return &msg, nil
}
```

Usage:
```go
msg, err := notification.NewMessageBuilder("patient-123", notification.ChannelEmail).
    WithSubject("Your appointment is confirmed").
    WithBody("Dear Alice, your appointment on 2026-04-01 is confirmed.").
    WithMetadata("appointment_id", "appt-456").
    Build()
if err != nil {
    return fmt.Errorf("build notification: %w", err)
}
```

## Query Builder

```go
// pkg/querybuilder/querybuilder.go
package querybuilder

import (
    "fmt"
    "strings"
)

type QueryBuilder struct {
    table      string
    conditions []string
    orderBy    string
    limitVal   int
    offsetVal  int
    args       []any
    argIdx     int
}

func New(table string) *QueryBuilder {
    return &QueryBuilder{table: table, argIdx: 1}
}

func (b *QueryBuilder) Where(col string, val any) *QueryBuilder {
    b.conditions = append(b.conditions, fmt.Sprintf("%s = $%d", col, b.argIdx))
    b.args = append(b.args, val)
    b.argIdx++
    return b
}

func (b *QueryBuilder) OrderBy(col, dir string) *QueryBuilder {
    b.orderBy = fmt.Sprintf("%s %s", col, dir)
    return b
}

func (b *QueryBuilder) Limit(n int) *QueryBuilder  { b.limitVal = n; return b }
func (b *QueryBuilder) Offset(n int) *QueryBuilder { b.offsetVal = n; return b }

func (b *QueryBuilder) Build() (string, []any, error) {
    if b.table == "" {
        return "", nil, fmt.Errorf("table name is required")
    }
    var sb strings.Builder
    sb.WriteString("SELECT * FROM ")
    sb.WriteString(b.table)

    if len(b.conditions) > 0 {
        sb.WriteString(" WHERE ")
        sb.WriteString(strings.Join(b.conditions, " AND "))
    }
    if b.orderBy != "" {
        sb.WriteString(" ORDER BY ")
        sb.WriteString(b.orderBy)
    }
    if b.limitVal > 0 {
        sb.WriteString(fmt.Sprintf(" LIMIT $%d", b.argIdx))
        b.args = append(b.args, b.limitVal)
        b.argIdx++
    }
    if b.offsetVal > 0 {
        sb.WriteString(fmt.Sprintf(" OFFSET $%d", b.argIdx))
        b.args = append(b.args, b.offsetVal)
    }
    return sb.String(), b.args, nil
}
```

Usage:
```go
q, args, err := querybuilder.New("patients").
    Where("active", true).
    Where("doctor_id", doctorID).
    OrderBy("created_at", "DESC").
    Limit(20).
    Offset(0).
    Build()
```

## Builder vs Functional Options

| Situation                              | Use                      |
|----------------------------------------|--------------------------|
| Build complex object with validation   | Builder (`Build() error`)|
| Configure existing type with defaults  | Functional Options       |
| Fluent API for readability             | Builder (method chaining)|
| Optional config for constructor        | Functional Options       |
