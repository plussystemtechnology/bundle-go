---
name: service
description: Generate an application service layer — delegates to service-builder agent
---

# Service Command

> Generate application service files with port interfaces, business logic, and transaction boundaries.

## Usage

```bash
/service <description-or-file>
```

## Examples

```bash
/service "Order processing with inventory check"
/service "AuthService with login and refresh token"
/service "NotificationService with email and SMS dispatch"
/service path/to/spec.md
```

---

## What This Command Does

1. Invokes the **service-builder** agent
2. Analyzes your description or requirements file
3. Loads KB patterns from `clean-architecture` and `error-handling` domains
4. Generates: Service struct, port interfaces, use-case methods, error types

## Agent Delegation

| Agent | Role |
|-------|------|
| `service-builder` | Primary — generates app service with Clean Architecture boundaries |
| `clean-arch-architect` | Escalation — layer design, dependency inversion, interface contracts |
| `the-planner` | Escalation — complex multi-service orchestration, saga patterns |

## KB Domains Used

- `clean-architecture` — Layer boundaries, dependency rules, use-case patterns
- `error-handling` — Domain errors, sentinel errors, error wrapping strategy

## Output

- `internal/app/service/<name>_service.go` — Service struct with constructor and methods
- `internal/port/<name>_port.go` — Input/output port interfaces
- `internal/app/service/<name>_service_test.go` — Unit tests with mock ports
- Transaction boundary annotations and context propagation patterns
