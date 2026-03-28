# Fan-Out / Fan-In Pattern

## Overview

**Fan-out:** Distribute work from one channel to N workers (goroutines).
**Fan-in:** Merge results from N workers into one channel.

Used together for parallel processing with result aggregation.

```
input → [worker 1] ↘
input → [worker 2]  → merge → output
input → [worker 3] ↗
```

## Fan-Out

```go
// fanOut distributes items from in to N worker goroutines
// Returns N output channels, one per worker
func fanOut[T, R any](
    ctx context.Context,
    in <-chan T,
    workers int,
    processFn func(ctx context.Context, item T) (R, error),
) []<-chan R {
    channels := make([]<-chan R, workers)

    for i := 0; i < workers; i++ {
        out := make(chan R)
        channels[i] = out
        go func(out chan<- R) {
            defer close(out)
            for {
                select {
                case item, ok := <-in:
                    if !ok { return }
                    r, err := processFn(ctx, item)
                    if err != nil {
                        // log or send to error channel
                        continue
                    }
                    select {
                    case out <- r:
                    case <-ctx.Done():
                        return
                    }
                case <-ctx.Done():
                    return
                }
            }
        }(out)
    }

    return channels
}
```

## Fan-In (Merge)

```go
// fanIn merges multiple read-only channels into one
func fanIn[T any](ctx context.Context, channels ...<-chan T) <-chan T {
    out := make(chan T)
    var wg sync.WaitGroup

    relay := func(ch <-chan T) {
        defer wg.Done()
        for {
            select {
            case v, ok := <-ch:
                if !ok { return }
                select {
                case out <- v:
                case <-ctx.Done():
                    return
                }
            case <-ctx.Done():
                return
            }
        }
    }

    wg.Add(len(channels))
    for _, ch := range channels {
        go relay(ch)
    }

    go func() {
        wg.Wait()
        close(out)
    }()

    return out
}
```

## Combined Fan-Out + Fan-In

```go
func processParallel[T, R any](
    ctx context.Context,
    items []T,
    workers int,
    fn func(ctx context.Context, item T) (R, error),
) ([]R, error) {
    // Source channel
    in := make(chan T, len(items))
    for _, item := range items { in <- item }
    close(in)

    // Fan-out to workers
    workerChannels := fanOut(ctx, in, workers, fn)

    // Fan-in results
    merged := fanIn(ctx, workerChannels...)

    // Collect
    var results []R
    for r := range merged {
        results = append(results, r)
    }
    return results, nil
}
```

## Real Example: Parallel Patient Notification

```go
// app/service/notification_service.go
func (s *NotificationService) BroadcastAlert(ctx context.Context, patientIDs []string, alert Alert) (int, []error) {
    const workers = 20

    // Source
    in := make(chan string, len(patientIDs))
    for _, id := range patientIDs { in <- id }
    close(in)

    type result struct {
        id  string
        err error
    }

    // Fan-out: N workers process IDs
    outChannels := make([]<-chan result, workers)
    for i := 0; i < workers; i++ {
        out := make(chan result, 1)
        outChannels[i] = out
        go func(out chan<- result) {
            defer close(out)
            for id := range in {
                err := s.notifier.Send(ctx, port.NotificationMessage{
                    To:      id,
                    Subject: alert.Title,
                    Body:    alert.Body,
                })
                select {
                case out <- result{id: id, err: err}:
                case <-ctx.Done():
                    return
                }
            }
        }(out)
    }

    // Fan-in: merge all results
    merged := fanIn(ctx, outChannels...)

    var (
        sent int
        errs []error
    )
    for r := range merged {
        if r.err != nil {
            errs = append(errs, fmt.Errorf("notify %s: %w", r.id, r.err))
            s.logger.Warn("broadcast alert failed", zap.String("patient_id", r.id), zap.Error(r.err))
        } else {
            sent++
        }
    }
    return sent, errs
}
```

## When to Use Fan-Out/Fan-In

- Processing a fixed list of independent items in parallel
- Each item requires I/O (HTTP call, DB query, Kafka publish)
- You need to collect all results (not just first error)

## Comparison

| Pattern     | Best For                                    |
|-------------|---------------------------------------------|
| Worker Pool | Continuous stream, controlled queue         |
| Fan-out/in  | Fixed set of items, full result collection  |
| errgroup    | Fixed set of *heterogeneous* tasks, first error |
| Pipeline    | Multi-stage data transformation             |
