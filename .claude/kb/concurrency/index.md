# Concurrency — NoxCare-Go

## Philosophy

> Don't communicate by sharing memory; share memory by communicating.
> Goroutines are cheap. Leaks are not. Always have a shutdown path.

## Core Primitives

| Primitive          | Use For                                           |
|--------------------|---------------------------------------------------|
| `goroutine`        | Async tasks, parallel work                        |
| `channel`          | Communication, signaling, pipeline stages         |
| `context.Context`  | Cancellation, deadlines, request-scoped values    |
| `sync.Mutex`       | Protecting shared state                           |
| `sync.RWMutex`     | Many readers, few writers                         |
| `sync.WaitGroup`   | Wait for N goroutines to finish                   |
| `sync.Once`        | One-time initialization                           |
| `sync.Pool`        | Reuse expensive allocations (buffers)             |
| `errgroup.Group`   | Fan-out + collect first error                     |
| `atomic`           | Lock-free counters and flags                      |

## NoxCare-Go Concurrency Patterns

| Scenario                            | Pattern                |
|-------------------------------------|------------------------|
| Parallel DB + cache fetch           | errgroup               |
| HTTP request handler goroutines     | managed by Gin/net/http|
| Kafka consumer workers              | Worker pool            |
| Background health checks            | Ticker + goroutine     |
| Graceful shutdown                   | context + WaitGroup    |
| Rate-limited notifications          | Worker pool + semaphore|
| Pipeline: consume → process → store | Pipeline + channels    |

## The Context Rule

Every function that:
- Makes a network call (DB, Redis, Kafka, HTTP)
- May take time
- Should be cancellable

Must accept `ctx context.Context` as its **first parameter**.

```go
func (s *PatientService) GetPatient(ctx context.Context, id string) (*patient.Patient, error)
```

## Quick Navigation

- `concepts/goroutines.md` — goroutine lifecycle, leak prevention
- `concepts/channels.md` — buffered/unbuffered, select, patterns
- `concepts/context.md` — Context usage, deadlines, values
- `concepts/sync-primitives.md` — Mutex, WaitGroup, Once, Pool
- `patterns/worker-pool.md` — bounded parallelism
- `patterns/errgroup.md` — parallel work with error collection
- `patterns/pipeline.md` — stage-based processing
- `patterns/fan-out-fan-in.md` — distributing and merging work
