# Graceful Shutdown

```go
func main() {
    ctx, cancel := context.WithCancel(context.Background())
    defer cancel()

    // Setup
    consumer := NewConsumer(brokers, "orders", "order-processor", handler, logger)
    producer := NewProducer(brokers, "events")

    // Signal handling
    sigCh := make(chan os.Signal, 1)
    signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)

    // Start consumer in goroutine
    g, gCtx := errgroup.WithContext(ctx)
    g.Go(func() error {
        return consumer.Start(gCtx)
    })

    // Wait for signal
    select {
    case sig := <-sigCh:
        logger.Info("received signal, shutting down", zap.String("signal", sig.String()))
        cancel() // cancel context → stops consumer loop
    case <-gCtx.Done():
        // errgroup cancelled (consumer error)
    }

    // Graceful shutdown with timeout
    shutdownCtx, shutdownCancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer shutdownCancel()

    // Close consumer (commits pending offsets, leaves group)
    if err := consumer.Close(); err != nil {
        logger.Error("consumer close", zap.Error(err))
    }

    // Close producer (flushes pending messages)
    if err := producer.Close(); err != nil {
        logger.Error("producer close", zap.Error(err))
    }

    // Wait for goroutines
    if err := g.Wait(); err != nil && !errors.Is(err, context.Canceled) {
        logger.Error("shutdown error", zap.Error(err))
    }

    _ = shutdownCtx // used for additional cleanup if needed
    logger.Info("shutdown complete")
}
```

## Key Points

- Cancel context to signal consumer to stop
- Close consumer to commit offsets and leave group
- Close producer to flush buffered messages
- Use `errgroup` to manage concurrent goroutines
- Set a shutdown timeout (30s) to avoid hanging
