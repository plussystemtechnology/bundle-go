---
name: kafka-consumer
description: Generate a Kafka consumer with error handling — delegates to kafka-specialist agent
---

# Kafka Consumer Command

> Generate Kafka consumer workers with DLQ, retry logic, and graceful shutdown.

## Usage

```bash
/kafka-consumer <description-or-file>
```

## Examples

```bash
/kafka-consumer "Order events with dead letter queue"
/kafka-consumer "Payment processor with exactly-once semantics"
/kafka-consumer "Inventory sync consumer with batch processing"
/kafka-consumer path/to/spec.md
```

---

## What This Command Does

1. Invokes the **kafka-specialist** agent
2. Analyzes your description or requirements file
3. Loads KB patterns from `kafka`, `error-handling`, and `concurrency` domains
4. Generates: Consumer worker, handler interface, DLQ config, lifecycle management

## Agent Delegation

| Agent | Role |
|-------|------|
| `kafka-specialist` | Primary — consumer group, offset management, DLQ, retry backoff |
| `pipeline-architect` | Escalation — event topology, fan-out, consumer group design |
| `event-store-specialist` | Escalation — outbox pattern, event sourcing, exactly-once delivery |

## KB Domains Used

- `kafka` — Consumer group config, offset commit strategies, partition assignment
- `error-handling` — Retry policies, poison-pill handling, DLQ routing
- `concurrency` — Worker pool, context cancellation, WaitGroup lifecycle

## Output

- `internal/adapter/consumer/<name>_consumer.go` — Consumer worker with Start/Stop lifecycle
- `internal/adapter/consumer/<name>_handler.go` — Message handler interface and implementation
- DLQ topic configuration and producer setup
- Graceful shutdown with context propagation and drain logic
