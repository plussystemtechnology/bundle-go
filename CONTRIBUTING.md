# Contributing to Bundle-Go

Thank you for your interest in contributing. Bundle-Go is a Claude Code plugin — contributions improve Go Backend/API development for everyone using it.

---

## Quick Start

```bash
git clone https://github.com/plussystemtechnology/bundle-go
cd bundle-go
# The entire framework lives in .claude/
```

No build step required. All agents, commands, and KB domains are Markdown files.

---

## Ways to Contribute

| Type | Where | Description |
|------|-------|-------------|
| New Agent | `.claude/agents/{category}/` | Add a specialist for a Go tool or pattern |
| KB Domain | `.claude/kb/{domain}/` | Add knowledge for a library or concept |
| Command | `.claude/commands/{category}/` | Add a slash command |
| Bug Fix | Any file | Fix incorrect guidance, broken YAML, bad examples |
| Documentation | Root `*.md` files | Improve clarity, fix typos, add examples |

---

## Adding a New Agent

1. Copy the base template:

```bash
cp .claude/agents/_template.md .claude/agents/{category}/{agent-name}.md
```

2. Fill in all sections: description, trigger conditions, capabilities, examples, output format, and `kb_domains`.

3. Choose the correct category directory:

| Category | Purpose |
|----------|---------|
| `workflow/` | SDD phase agents (define, design, build, ship…) |
| `architect/` | System-level design and architecture decisions |
| `go-core/` | Clean Architecture layer builders (domain, port, app, adapter…) |
| `api/` | REST, gRPC, Swagger, middleware, auth specialists |
| `data/` | sqlc, pgx, Kafka, Redis, migrations specialists |
| `cloud/` | Docker, Kubernetes, AWS, CI/CD |
| `observability/` | OpenTelemetry, Prometheus, structured logging, health checks |
| `test/` | Test generation, integration tests, benchmarks, security scanning |

4. Reference relevant KB domains in the `kb_domains` field.

5. Update `.claude/agents/README.md` to include the new agent in the routing map.

---

## Adding a KB Domain

### Using the command

```bash
/create-kb {domain-name}
```

### Manual

1. Create the domain directory:

```bash
mkdir .claude/kb/{domain-name}
```

2. Add `concepts.md` (what it is, core principles) and `patterns.md` (how to use it in Go).

3. Register the domain in `.claude/kb/_index.yaml`:

```yaml
- name: {domain-name}
  category: {core-go|stack|infra}
  description: "One-line description"
```

---

## Adding a Command

1. Create the command file in the appropriate category:

```bash
# Example: new Go engineering command
touch .claude/commands/go-engineering/{command-name}.md
```

2. Add YAML frontmatter at the top:

```yaml
---
name: command-name
description: "What this command does"
category: go-engineering
agent: {agent-name}  # if it delegates to an agent
---
```

3. Write the command body: description, usage, examples, expected output.

4. Update `.claude/commands/README.md` if one exists for the category.

---

## Bug Fixes

- For incorrect Go guidance: verify against the official Go documentation and correct the agent or KB domain.
- For broken YAML frontmatter: validate the YAML syntax before submitting.
- For bad code examples: examples must compile and follow Clean Architecture layer rules.

---

## Documentation Standards

- Use ATX-style headers (`#`, `##`, `###`) — no underline-style headers.
- Use fenced code blocks with language identifiers (` ```go `, ` ```yaml `, ` ```bash `).
- Align table columns for readability.
- Keep line length reasonable — no hard wrapping required, but avoid very long lines in prose.

---

## Pull Request Process

1. Fork the repository and create a feature branch.
2. Make your changes following the standards above.
3. Verify that any new agent has all required sections (trigger, capabilities, examples, output format, kb_domains).
4. Verify that any new KB domain is registered in `_index.yaml`.
5. Open a pull request with a clear description of what was added and why.

PR titles should follow conventional commits style:

```
feat: add redis-cluster-specialist agent
fix: correct pgx pool configuration in kb/pgx/patterns.md
docs: clarify Clean Architecture layer rules in README
```

---

## Code of Conduct

This project follows the [Contributor Covenant](https://www.contributor-covenant.org/). Be respectful, constructive, and collaborative.
