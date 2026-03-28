# Channels

## Basics

```go
ch := make(chan int)      // unbuffered — send blocks until receiver is ready
ch := make(chan int, 10)  // buffered — send blocks only when full

ch <- 42          // send
v := <-ch         // receive (blocks until value available)
v, ok := <-ch     // ok=false means channel is closed

close(ch)         // only sender closes; closing twice panics
for v := range ch { ... }  // range drains until close
```

## Unbuffered vs Buffered

| Unbuffered `make(chan T)` | Buffered `make(chan T, n)` |
|---------------------------|---------------------------|
| Synchronization point     | Decouples producer/consumer |
| Sender blocks until receiver | Sender blocks only when full |
| Guarantees receiver has the value | No guarantee of immediate pickup |
| Good for signaling        | Good for pipelines, queues |

## Select Statement

`select` waits for multiple channel operations, picks one that's ready:

```go
select {
case msg := <-msgCh:
    process(msg)
case err := <-errCh:
    return err
case <-ctx.Done():
    return ctx.Err()
case <-time.After(5 * time.Second):
    return errors.New("timeout")
default:
    // non-blocking fallthrough
}
```

## Channel Directions in Signatures

Restrict channels to send-only or receive-only in function signatures:

```go
// Producer: send-only
func produce(out chan<- int) {
    out <- 42
}

// Consumer: receive-only
func consume(in <-chan int) {
    v := <-in
    fmt.Println(v)
}
```

## Done Channel Pattern (broadcast)

`close(done)` wakes up ALL goroutines waiting on `<-done`:

```go
done := make(chan struct{})

// Multiple goroutines wait
for i := 0; i < N; i++ {
    go func() {
        select {
        case <-done:
            fmt.Println("shutting down")
            return
        case v := <-work:
            process(v)
        }
    }()
}

// Broadcast shutdown to all
close(done)
```

## Semaphore Channel (Rate Limiting)

Limit concurrent goroutines to N:

```go
sem := make(chan struct{}, maxConcurrent)

for _, item := range items {
    sem <- struct{}{}  // acquire slot
    go func(item Item) {
        defer func() { <-sem }()  // release slot
        process(item)
    }(item)
}

// Wait for all to finish
for i := 0; i < cap(sem); i++ {
    sem <- struct{}{}
}
```

## Timeout Pattern

```go
func fetchWithTimeout(ctx context.Context, url string) ([]byte, error) {
    ch := make(chan []byte, 1)
    go func() {
        body, _ := httpGet(url)
        ch <- body
    }()

    select {
    case body := <-ch:
        return body, nil
    case <-ctx.Done():
        return nil, ctx.Err()
    }
}
```

## Pipeline Stage

```go
// Each stage reads from input channel, writes to output channel
func multiply(in <-chan int, factor int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)
        for v := range in {
            out <- v * factor
        }
    }()
    return out
}

// Chain: source → multiply → filter → sink
nums   := generate(1, 2, 3, 4, 5)
doubled := multiply(nums, 2)
```

## Common Mistakes

```go
// 1. Sending to nil channel blocks forever
var ch chan int
ch <- 1  // blocks forever

// 2. Receiving from nil channel blocks forever
v := <-ch  // blocks forever

// 3. Closing a nil channel panics
close(ch)  // panic

// 4. Closing a closed channel panics — use sync.Once
var once sync.Once
once.Do(func() { close(ch) })

// 5. Loop variable capture pre-Go 1.22
for _, v := range items {
    v := v  // shadow to capture correctly
    go func() { use(v) }()
}
```

## When to Use Channels vs Mutex

| Use Channels When                       | Use Mutex When                        |
|-----------------------------------------|---------------------------------------|
| Passing ownership of data between goroutines | Protecting shared state (map, counter) |
| Signaling events                        | Caching / in-memory store             |
| Pipeline / producer-consumer            | Updating a struct's fields            |
| Fan-out / fan-in                        | Simple read-write guards              |
