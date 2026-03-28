---
name: proto
description: Generate Protobuf and gRPC service definitions — delegates to grpc-specialist agent
---

# Proto Command

> Generate .proto files, generated Go stubs, and gRPC server adapter for a service.

## Usage

```bash
/proto <description-or-file>
```

## Examples

```bash
/proto "Order service with CRUD + streaming"
/proto "Health check service"
/proto "Payment service with bidirectional streaming"
/proto path/to/spec.md
```

---

## What This Command Does

1. Invokes the **grpc-specialist** agent
2. Analyzes your description or requirements file
3. Loads KB patterns from `grpc` and `go-patterns` domains
4. Generates: Proto file, buf config, generated stubs, server adapter

## Agent Delegation

| Agent | Role |
|-------|------|
| `grpc-specialist` | Primary — proto definition, buf workflow, server adapter |
| `api-architect` | Escalation — service contract design, versioning strategy |
| `rest-designer` | Escalation — gRPC-Gateway HTTP transcoding annotations |

## KB Domains Used

- `grpc` — Proto3 conventions, service patterns, streaming types, error codes
- `go-patterns` — Go idioms for server implementation, interceptors, context usage

## Output

- `api/proto/<service>/v1/<service>.proto` — Proto3 service and message definitions
- `buf.yaml` / `buf.gen.yaml` — buf build and generation config
- `internal/adapter/grpc/<service>_server.go` — gRPC server adapter implementing the interface
- Interceptor stubs for logging, auth, and recovery
