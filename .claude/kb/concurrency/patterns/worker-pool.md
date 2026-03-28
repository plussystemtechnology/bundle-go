# Worker Pool Pattern

## Overview

A worker pool processes items from a queue with a bounded number of goroutines,
preventing unbounded resource usage.

## Basic Worker Pool

```go
// pkg/workerpool/pool.go
package workerpool

import (
    "context"
    "sync"
)

type Job[T any] struct {
    ID      string
    Payload T
}

type Result[T, R any] struct {
    Job    Job[T]
    Output R
    Err    error
}

type Pool[T, R any] struct {
    workers    int
    processFn  func(ctx context.Context, job Job[T]) (R, error)
}

func New[T, R any](workers int, fn func(ctx context.Context, job Job[T]) (R, error)) *Pool[T, R] {
    return &Pool[T, R]{workers: workers, processFn: fn}
}

func (p *Pool[T, R]) Run(ctx context.Context, jobs []Job[T]) []Result[T, R] {
    jobCh    := make(chan Job[T], len(jobs))
    resultCh := make(chan Result[T, R], len(jobs))

    var wg sync.WaitGroup
    for i := 0; i < p.workers; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for {
                select {
                case job, ok := <-jobCh:
                    if !ok { return }
                    out, err := p.processFn(ctx, job)
                    resultCh <- Result[T, R]{Job: job, Output: out, Err: err}
                case <-ctx.Done():
                    return
                }
            }
        }()
    }

    // Feed jobs
    for _, job := range jobs {
        jobCh <- job
    }
    close(jobCh)

    // Wait and close results
    go func() {
        wg.Wait()
        close(resultCh)
    }()

    // Collect results
    results := make([]Result[T, R], 0, len(jobs))
    for r := range resultCh {
        results = append(results, r)
    }
    return results
}
```

## Kafka Consumer Worker Pool

```go
// adapter/kafka/consumer/notification_consumer.go
package consumer

import (
    "context"
    "encoding/json"
    "fmt"
    "sync"

    "github.com/twmb/franz-go/pkg/kgo"
    "go.uber.org/zap"
    "github.com/org/noxcare-go/app/service"
)

const defaultWorkers = 10

type NotificationConsumer struct {
    client      *kgo.Client
    svc         *service.NotificationService
    workers     int
    logger      *zap.Logger
}

func NewNotificationConsumer(client *kgo.Client, svc *service.NotificationService, logger *zap.Logger) *NotificationConsumer {
    return &NotificationConsumer{
        client:  client,
        svc:     svc,
        workers: defaultWorkers,
        logger:  logger,
    }
}

type notificationEvent struct {
    PatientID string `json:"patient_id"`
    Message   string `json:"message"`
    Channel   string `json:"channel"`
}

func (c *NotificationConsumer) Start(ctx context.Context) error {
    jobs := make(chan *kgo.Record, c.workers*2)

    // Start worker pool
    var wg sync.WaitGroup
    for i := 0; i < c.workers; i++ {
        wg.Add(1)
        go func(workerID int) {
            defer wg.Done()
            c.worker(ctx, workerID, jobs)
        }(i)
    }

    // Fetch loop
    defer func() {
        close(jobs)
        wg.Wait()
    }()

    for {
        select {
        case <-ctx.Done():
            return nil
        default:
        }

        fetches := c.client.PollFetches(ctx)
        if fetches.IsClientClosed() { return nil }
        if errs := fetches.Errors(); len(errs) > 0 {
            c.logger.Error("kafka poll error", zap.Any("errors", errs))
            continue
        }

        fetches.EachRecord(func(r *kgo.Record) {
            select {
            case jobs <- r:
            case <-ctx.Done():
            }
        })
    }
}

func (c *NotificationConsumer) worker(ctx context.Context, id int, jobs <-chan *kgo.Record) {
    log := c.logger.With(zap.Int("worker", id))
    for {
        select {
        case rec, ok := <-jobs:
            if !ok { return }
            if err := c.process(ctx, rec); err != nil {
                log.Error("process notification", zap.Error(err), zap.ByteString("key", rec.Key))
            } else {
                c.client.MarkCommitRecords(rec)
            }
        case <-ctx.Done():
            return
        }
    }
}

func (c *NotificationConsumer) process(ctx context.Context, rec *kgo.Record) error {
    var evt notificationEvent
    if err := json.Unmarshal(rec.Value, &evt); err != nil {
        return fmt.Errorf("unmarshal notification event: %w", err)
    }
    return c.svc.Notify(ctx, evt.PatientID, evt.Channel, evt.Message)
}
```

## Simple Semaphore-Based Pool

When you just need to cap concurrency without a full pool:

```go
func processWithLimit(ctx context.Context, items []Item, limit int) error {
    sem := make(chan struct{}, limit)
    errs := make(chan error, len(items))
    var wg sync.WaitGroup

    for _, item := range items {
        item := item
        select {
        case sem <- struct{}{}:  // acquire slot
        case <-ctx.Done():
            break
        }

        wg.Add(1)
        go func() {
            defer wg.Done()
            defer func() { <-sem }()  // release slot

            if err := process(ctx, item); err != nil {
                errs <- err
            }
        }()
    }

    wg.Wait()
    close(errs)

    for err := range errs {
        if err != nil { return err }
    }
    return nil
}
```

## When to Use a Worker Pool

- Processing Kafka messages with controlled concurrency
- Bulk operations (send 10k notifications, limited to 50 concurrent)
- CPU-bound tasks (parsing, transformation) — set workers = `runtime.NumCPU()`
- I/O-bound tasks — set workers higher (50-200 is common)
