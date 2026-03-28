---
name: create-kb
description: Create a complete KB domain from scratch
---

# Create-KB Command

> Scaffold a new knowledge base domain with index, quick-reference, concepts, and patterns.

## Usage

```
/create-kb <DOMAIN>
/create-kb --audit
```

## Examples

```
/create-kb grpc
/create-kb redis-caching
/create-kb clean-architecture
/create-kb --audit
```

## What This Command Does

### `/create-kb <DOMAIN>`

1. **Validate prerequisites** — check `.claude/kb/_index.yaml` exists
2. **Check for conflicts** — abort if domain already exists
3. **Create domain directory** — `.claude/kb/<domain>/`
4. **Scaffold files**:
   - `index.md` — domain overview, scope, when to use
   - `quick-reference.md` — cheat sheet with code snippets
   - `concepts/` — directory for deep-dive concept files
   - `patterns/` — directory for reusable pattern files
5. **Register in index** — append entry to `.claude/kb/_index.yaml`
6. **Confirm creation** — report created paths

### `/create-kb --audit`

Reads `.claude/kb/_index.yaml` and verifies:
- Every registered domain has its directory
- Each domain has `index.md` and `quick-reference.md`
- No orphan directories exist (directory without index entry)

Reports missing files and orphan directories.

## Output Structure

```
.claude/kb/<domain>/
├── index.md            # Overview: scope, related domains, agent hints
├── quick-reference.md  # Code snippets, commands, key rules
├── concepts/           # (empty — add concept files as needed)
└── patterns/           # (empty — add pattern files as needed)
```

## KB Index Entry

Added to `.claude/kb/_index.yaml`:

```yaml
- domain: <domain>
  path: kb/<domain>/
  description: <one-line description>
  tags: []
```
