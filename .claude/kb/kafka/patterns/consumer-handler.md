# Consumer Handler Pattern

```go
type MessageHandler func(ctx context.Context, msg kafka.Message) error

type Consumer struct {
    reader  *kafka.Reader
    handler MessageHandler
    logger  *zap.Logger
}

func NewConsumer(brokers []string, topic, groupID string, handler MessageHandler, logger *zap.Logger) *Consumer {
    return &Consumer{
        reader: kafka.NewReader(kafka.ReaderConfig{
            Brokers:     brokers,
            GroupID:     groupID,
            Topic:       topic,
            MinBytes:    1,
            MaxBytes:    10e6,
            StartOffset: kafka.LastOffset,
        }),
        handler: handler,
        logger:  logger,
    }
}

func (c *Consumer) Start(ctx context.Context) error {
    for {
        msg, err := c.reader.FetchMessage(ctx)
        if err != nil {
            if ctx.Err() != nil {
                return nil // graceful shutdown
            }
            c.logger.Error("fetch message", zap.Error(err))
            continue
        }

        if err := c.handler(ctx, msg); err != nil {
            c.logger.Error("handle message",
                zap.String("topic", msg.Topic),
                zap.Int("partition", msg.Partition),
                zap.Int64("offset", msg.Offset),
                zap.Error(err),
            )
            continue // don't commit failed messages
        }

        if err := c.reader.CommitMessages(ctx, msg); err != nil {
            c.logger.Error("commit message", zap.Error(err))
        }
    }
}

func (c *Consumer) Close() error {
    return c.reader.Close()
}
```
