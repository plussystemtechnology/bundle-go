# Strategy Pattern

## Overview

The Strategy pattern defines a family of algorithms / behaviors behind an interface
and makes them interchangeable. The client selects the strategy at construction or runtime.

In Go this is naturally expressed as an interface field on a struct.

## Notification Strategy

```go
// port/notifier.go
package port

import "context"

type NotificationMessage struct {
    To      string
    Subject string
    Body    string
}

// Notifier is the strategy interface
type Notifier interface {
    Send(ctx context.Context, msg NotificationMessage) error
}
```

Concrete strategies:

```go
// adapter/notification/email_sender.go
package notification

type EmailSender struct{ client *smtp.Client }

func (s *EmailSender) Send(ctx context.Context, msg port.NotificationMessage) error {
    // send via SMTP
    return nil
}

// adapter/notification/sms_sender.go
type SMSSender struct{ client *twilio.Client }

func (s *SMSSender) Send(ctx context.Context, msg port.NotificationMessage) error {
    // send via Twilio
    return nil
}

// adapter/notification/push_sender.go
type PushSender struct{ client *firebase.Client }

func (s *PushSender) Send(ctx context.Context, msg port.NotificationMessage) error {
    // send via Firebase
    return nil
}
```

Context that uses the strategy:

```go
// app/service/notification_service.go
package service

type NotificationService struct {
    notifier port.Notifier  // strategy
    logger   *zap.Logger
}

func NewNotificationService(notifier port.Notifier, logger *zap.Logger) *NotificationService {
    return &NotificationService{notifier: notifier, logger: logger}
}

func (s *NotificationService) Notify(ctx context.Context, to, subject, body string) error {
    msg := port.NotificationMessage{To: to, Subject: subject, Body: body}
    if err := s.notifier.Send(ctx, msg); err != nil {
        return fmt.Errorf("notify: %w", err)
    }
    return nil
}
```

## Multi-Strategy (Fan-out)

Send to multiple channels simultaneously:

```go
// adapter/notification/multi_sender.go
package notification

import (
    "context"
    "fmt"

    "golang.org/x/sync/errgroup"
    "github.com/org/bundle-go/port"
)

type MultiSender struct {
    senders []port.Notifier
}

func NewMultiSender(senders ...port.Notifier) *MultiSender {
    return &MultiSender{senders: senders}
}

func (m *MultiSender) Send(ctx context.Context, msg port.NotificationMessage) error {
    g, ctx := errgroup.WithContext(ctx)
    for _, s := range m.senders {
        s := s // capture
        g.Go(func() error { return s.Send(ctx, msg) })
    }
    if err := g.Wait(); err != nil {
        return fmt.Errorf("multi-send: %w", err)
    }
    return nil
}
```

## Strategy with Runtime Switching

Select strategy based on user preference stored in DB:

```go
// app/service/notification_service.go
type ChannelAwareNotificationService struct {
    strategies map[string]port.Notifier
    repo       port.PatientPreferencesRepository
}

func (s *ChannelAwareNotificationService) Notify(ctx context.Context, patientID string, msg port.NotificationMessage) error {
    prefs, err := s.repo.GetPreferences(ctx, patientID)
    if err != nil {
        return fmt.Errorf("get preferences: %w", err)
    }

    notifier, ok := s.strategies[prefs.PreferredChannel]
    if !ok {
        notifier = s.strategies["email"] // fallback
    }
    return notifier.Send(ctx, msg)
}
```

## Payment Strategy

```go
// port/payment_processor.go
type PaymentProcessor interface {
    Process(ctx context.Context, amount int64, currency, token string) (*PaymentResult, error)
    Refund(ctx context.Context, paymentID string, amount int64) error
}

// adapter/payment/stripe_processor.go
type StripeProcessor struct{ client *stripe.Client }
func (p *StripeProcessor) Process(...) (*port.PaymentResult, error) { ... }
func (p *StripeProcessor) Refund(...) error { ... }

// adapter/payment/pagseguro_processor.go
type PagSeguroProcessor struct{ client *pagseguro.Client }
func (p *PagSeguroProcessor) Process(...) (*port.PaymentResult, error) { ... }
func (p *PagSeguroProcessor) Refund(...) error { ... }
```

## Noop Strategy for Testing

```go
// Always include a noop implementation for use in tests and development
type NoopNotifier struct{}

func (n *NoopNotifier) Send(_ context.Context, msg port.NotificationMessage) error {
    return nil
}

// LoggingNotifier wraps another and logs each call
type LoggingNotifier struct {
    wrapped port.Notifier
    logger  *zap.Logger
}

func (n *LoggingNotifier) Send(ctx context.Context, msg port.NotificationMessage) error {
    n.logger.Info("sending notification", zap.String("to", msg.To))
    err := n.wrapped.Send(ctx, msg)
    if err != nil {
        n.logger.Error("notification failed", zap.Error(err))
    }
    return err
}
```

## Key Points

- Strategy = interface field on the context struct
- Inject strategy via constructor (dependency injection)
- Include a Noop/stub strategy for tests and graceful fallback
- MultiSender lets you fan-out across strategies without changing the caller
