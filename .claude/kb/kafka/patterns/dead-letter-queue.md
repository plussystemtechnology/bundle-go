# Dead Letter Queue Pattern

```go
type DLQConsumer struct {
    reader    *kafka.Reader
    dlqWriter *kafka.Writer
    handler   MessageHandler
    maxRetry  int
    logger    *zap.Logger
}

func (c *DLQConsumer) Start(ctx context.Context) error {
    for {
        msg, err := c.reader.FetchMessage(ctx)
        if err != nil {
            if ctx.Err() != nil {
                return nil
            }
            continue
        }

        retryCount := getRetryCount(msg.Headers)

        if err := c.handler(ctx, msg); err != nil {
            if retryCount >= c.maxRetry {
                // Max retries exceeded — send to DLQ
                c.sendToDLQ(ctx, msg, err)
            } else {
                c.logger.Warn("message processing failed, will retry",
                    zap.Int("retry", retryCount),
                    zap.Error(err),
                )
                // Don't commit — message will be redelivered
                continue
            }
        }

        c.reader.CommitMessages(ctx, msg)
    }
}

func (c *DLQConsumer) sendToDLQ(ctx context.Context, original kafka.Message, processErr error) {
    headers := append(original.Headers,
        kafka.Header{Key: "dlq-reason", Value: []byte(processErr.Error())},
        kafka.Header{Key: "dlq-timestamp", Value: []byte(time.Now().Format(time.RFC3339))},
        kafka.Header{Key: "original-topic", Value: []byte(original.Topic)},
    )

    dlqMsg := kafka.Message{
        Key:     original.Key,
        Value:   original.Value,
        Headers: headers,
    }

    if err := c.dlqWriter.WriteMessages(ctx, dlqMsg); err != nil {
        c.logger.Error("failed to write to DLQ", zap.Error(err))
    }
}

func getRetryCount(headers []kafka.Header) int {
    for _, h := range headers {
        if h.Key == "retry-count" {
            n, _ := strconv.Atoi(string(h.Value))
            return n
        }
    }
    return 0
}
```
