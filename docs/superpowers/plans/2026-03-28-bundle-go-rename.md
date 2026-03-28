# Bundle-Go Rename Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rename the project from bundle-go to bundle-go, update org to plussystemtechnology, restructure commands under a `bundle-go/` namespace, and rename the root directory.

**Architecture:** Pure text/file rename operation across ~58 markdown and YAML files. Four ordered text replacements (Bundle-Go → Bundle-Go, BundleGo → BundleGo, bundle-go → bundle-go, plussystemtechnology → plussystemtechnology), command directory restructuring into a `bundle-go/` wrapper, doc file renames, CLAUDE.md command table updates, and root directory rename.

**Tech Stack:** bash (sed, mv, git mv), markdown, YAML

---

### Task 1: Text replacements — KB files (batch 1 of 3)

**Files (modify all):**
- `.claude/kb/clean-architecture/concepts/dependency-inversion.md`
- `.claude/kb/clean-architecture/concepts/layer-rules.md`
- `.claude/kb/clean-architecture/index.md`
- `.claude/kb/clean-architecture/patterns/dependency-injection.md`
- `.claude/kb/clean-architecture/patterns/port-adapter.md`
- `.claude/kb/clean-architecture/patterns/repository-pattern.md`
- `.claude/kb/clean-architecture/patterns/service-pattern.md`
- `.claude/kb/concurrency/index.md`
- `.claude/kb/concurrency/patterns/pipeline.md`
- `.claude/kb/concurrency/patterns/worker-pool.md`
- `.claude/kb/error-handling/concepts/sentinel-errors.md`
- `.claude/kb/error-handling/index.md`
- `.claude/kb/error-handling/patterns/api-errors.md`
- `.claude/kb/error-handling/patterns/custom-errors.md`
- `.claude/kb/error-handling/patterns/validation-errors.md`
- `.claude/kb/go-patterns/index.md`
- `.claude/kb/go-patterns/patterns/factory-pattern.md`
- `.claude/kb/go-patterns/patterns/strategy-pattern.md`
- `.claude/kb/testing/concepts/fuzzing.md`
- `.claude/kb/testing/concepts/mocking.md`
- `.claude/kb/testing/concepts/test-helpers.md`
- `.claude/kb/testing/index.md`
- `.claude/kb/testing/patterns/benchmark.md`
- `.claude/kb/testing/patterns/db-testing.md`
- `.claude/kb/testing/patterns/http-testing.md`
- `.claude/kb/testing/patterns/testcontainers.md`
- `.claude/kb/zap/concepts/logger-setup.md`
- `.claude/kb/zap/concepts/sugar-vs-structured.md`
- `.claude/kb/zap/index.md`
- `.claude/kb/zap/patterns/context-fields.md`
- `.claude/kb/zap/patterns/middleware-logging.md`
- `.claude/kb/zap/patterns/sink-config.md`
- `.claude/kb/zap/quick-reference.md`
- `.claude/kb/swagger/concepts/openapi-spec.md`
- `.claude/kb/swagger/quick-reference.md`
- `.claude/kb/auth/concepts/jwt.md`
- `.claude/kb/_index.yaml`

- [ ] **Step 1: Run ordered sed replacements on all KB files**

Run these four commands in order against all files in `.claude/kb/`:

```bash
find .claude/kb/ -type f \( -name '*.md' -o -name '*.yaml' \) -exec sed -i 's/Bundle-Go/Bundle-Go/g' {} +
find .claude/kb/ -type f \( -name '*.md' -o -name '*.yaml' \) -exec sed -i 's/BundleGo/BundleGo/g' {} +
find .claude/kb/ -type f \( -name '*.md' -o -name '*.yaml' \) -exec sed -i 's/bundle-go/bundle-go/g' {} +
```

- [ ] **Step 2: Verify no noxcare references remain in KB**

```bash
grep -ri 'noxcare\|BundleGo' .claude/kb/
```

Expected: no output (zero matches).

- [ ] **Step 3: Commit**

```bash
git add .claude/kb/
git commit -m "rename: replace bundle-go with bundle-go in KB files"
```

---

### Task 2: Text replacements — SDD files (batch 2 of 3)

**Files (modify all):**
- `.claude/sdd/README.md`
- `.claude/sdd/_index.md`
- `.claude/sdd/architecture/ARCHITECTURE.md`
- `.claude/sdd/architecture/WORKFLOW_CONTRACTS.yaml`

- [ ] **Step 1: Run ordered sed replacements on all SDD files**

```bash
find .claude/sdd/ -type f \( -name '*.md' -o -name '*.yaml' \) -exec sed -i 's/Bundle-Go/Bundle-Go/g' {} +
find .claude/sdd/ -type f \( -name '*.md' -o -name '*.yaml' \) -exec sed -i 's/BundleGo/BundleGo/g' {} +
find .claude/sdd/ -type f \( -name '*.md' -o -name '*.yaml' \) -exec sed -i 's/bundle-go/bundle-go/g' {} +
```

- [ ] **Step 2: Verify no noxcare references remain in SDD**

```bash
grep -ri 'noxcare\|BundleGo' .claude/sdd/
```

Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add .claude/sdd/
git commit -m "rename: replace bundle-go with bundle-go in SDD files"
```

---

### Task 3: Text replacements — agents and remaining .claude files (batch 3 of 3)

**Files (modify):**
- `.claude/agents/README.md`
- `.claude/agents/cloud/ci-cd-specialist.md`

- [ ] **Step 1: Run ordered sed replacements on agent files**

```bash
find .claude/agents/ -type f -name '*.md' -exec sed -i 's/Bundle-Go/Bundle-Go/g' {} +
find .claude/agents/ -type f -name '*.md' -exec sed -i 's/BundleGo/BundleGo/g' {} +
find .claude/agents/ -type f -name '*.md' -exec sed -i 's/bundle-go/bundle-go/g' {} +
find .claude/agents/ -type f -name '*.md' -exec sed -i 's/plussystemtechnology/plussystemtechnology/g' {} +
```

- [ ] **Step 2: Verify no noxcare/plussystemtechnology references remain in agents**

```bash
grep -ri 'noxcare\|BundleGo\|plussystemtechnology' .claude/agents/
```

Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add .claude/agents/
git commit -m "rename: replace bundle-go with bundle-go in agent files"
```

---

### Task 4: Text replacements — root-level files

**Files (modify):**
- `README.md`
- `CONTRIBUTING.md`
- `CHANGELOG.md`
- `LICENSE`

- [ ] **Step 1: Run ordered sed replacements on root-level files**

```bash
for f in README.md CONTRIBUTING.md CHANGELOG.md LICENSE; do
  sed -i 's/Bundle-Go/Bundle-Go/g' "$f"
  sed -i 's/BundleGo/BundleGo/g' "$f"
  sed -i 's/bundle-go/bundle-go/g' "$f"
  sed -i 's/plussystemtechnology/plussystemtechnology/g' "$f"
done
```

- [ ] **Step 2: Verify no noxcare/plussystemtechnology references remain in root files**

```bash
grep -i 'noxcare\|plussystemtechnology' README.md CONTRIBUTING.md CHANGELOG.md LICENSE
```

Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add README.md CONTRIBUTING.md CHANGELOG.md LICENSE
git commit -m "rename: replace bundle-go with bundle-go in root files"
```

---

### Task 5: Text replacements — docs (specs and plans) + file renames

**Files (modify and rename):**
- `docs/superpowers/specs/2026-03-27-bundle-go-plugin-design.md` → `docs/superpowers/specs/2026-03-27-bundle-go-plugin-design.md`
- `docs/superpowers/plans/2026-03-27-bundle-go-plugin.md` → `docs/superpowers/plans/2026-03-27-bundle-go-plugin.md`
- `docs/superpowers/specs/2026-03-28-bundle-go-rename-design.md` (already uses bundle-go, verify only)

- [ ] **Step 1: Run text replacements on docs files**

```bash
find docs/ -type f -name '*.md' -exec sed -i 's/Bundle-Go/Bundle-Go/g' {} +
find docs/ -type f -name '*.md' -exec sed -i 's/BundleGo/BundleGo/g' {} +
find docs/ -type f -name '*.md' -exec sed -i 's/bundle-go/bundle-go/g' {} +
find docs/ -type f -name '*.md' -exec sed -i 's/plussystemtechnology/plussystemtechnology/g' {} +
```

- [ ] **Step 2: Rename doc files with git mv**

```bash
git mv docs/superpowers/specs/2026-03-27-bundle-go-plugin-design.md docs/superpowers/specs/2026-03-27-bundle-go-plugin-design.md
git mv docs/superpowers/plans/2026-03-27-bundle-go-plugin.md docs/superpowers/plans/2026-03-27-bundle-go-plugin.md
```

- [ ] **Step 3: Verify no noxcare references remain in docs**

```bash
grep -ri 'noxcare' docs/
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add docs/
git commit -m "rename: replace bundle-go with bundle-go in docs, rename files"
```

---

### Task 6: Restructure commands under bundle-go/ namespace

**Current structure:**
```
.claude/commands/{README.md,workflow/,go-engineering/,core/,knowledge/,review/}
```

**Target structure:**
```
.claude/commands/bundle-go/{README.md,workflow/,go-engineering/,core/,knowledge/,review/}
```

- [ ] **Step 1: Create the bundle-go wrapper directory**

```bash
mkdir -p .claude/commands/bundle-go
```

- [ ] **Step 2: Move all subdirectories and README into bundle-go/**

```bash
git mv .claude/commands/workflow .claude/commands/bundle-go/workflow
git mv .claude/commands/go-engineering .claude/commands/bundle-go/go-engineering
git mv .claude/commands/core .claude/commands/bundle-go/core
git mv .claude/commands/knowledge .claude/commands/bundle-go/knowledge
git mv .claude/commands/review .claude/commands/bundle-go/review
git mv .claude/commands/README.md .claude/commands/bundle-go/README.md
```

- [ ] **Step 3: Verify structure**

```bash
ls -R .claude/commands/
```

Expected: only `bundle-go/` directory under `.claude/commands/`, with all subdirectories inside it.

- [ ] **Step 4: Commit**

```bash
git add .claude/commands/
git commit -m "rename: restructure commands under bundle-go/ namespace"
```

---

### Task 7: Update command files — text replacements + command references

**Files (modify all):**
- `.claude/commands/bundle-go/workflow/brainstorm.md`
- `.claude/commands/bundle-go/workflow/define.md`
- `.claude/commands/bundle-go/workflow/design.md`
- `.claude/commands/bundle-go/workflow/build.md`
- `.claude/commands/bundle-go/workflow/ship.md`
- `.claude/commands/bundle-go/workflow/iterate.md`
- `.claude/commands/bundle-go/workflow/create-pr.md`
- `.claude/commands/bundle-go/go-engineering/handler.md`
- `.claude/commands/bundle-go/go-engineering/service.md`
- `.claude/commands/bundle-go/go-engineering/repository.md`
- `.claude/commands/bundle-go/go-engineering/migration.md`
- `.claude/commands/bundle-go/go-engineering/middleware.md`
- `.claude/commands/bundle-go/go-engineering/proto.md`
- `.claude/commands/bundle-go/go-engineering/kafka-consumer.md`
- `.claude/commands/bundle-go/go-engineering/swagger.md`
- `.claude/commands/bundle-go/go-engineering/security-scan.md`
- `.claude/commands/bundle-go/go-engineering/go-review.md`
- `.claude/commands/bundle-go/go-engineering/README.md`
- `.claude/commands/bundle-go/core/memory.md`
- `.claude/commands/bundle-go/core/meeting.md`
- `.claude/commands/bundle-go/core/readme-maker.md`
- `.claude/commands/bundle-go/core/sync-context.md`
- `.claude/commands/bundle-go/knowledge/create-kb.md`
- `.claude/commands/bundle-go/review/review.md`
- `.claude/commands/bundle-go/README.md`

- [ ] **Step 1: Run ordered sed replacements on all command files**

```bash
find .claude/commands/bundle-go/ -type f -name '*.md' -exec sed -i 's/Bundle-Go/Bundle-Go/g' {} +
find .claude/commands/bundle-go/ -type f -name '*.md' -exec sed -i 's/BundleGo/BundleGo/g' {} +
find .claude/commands/bundle-go/ -type f -name '*.md' -exec sed -i 's/bundle-go/bundle-go/g' {} +
```

- [ ] **Step 2: Update command README — command invocations with new prefix**

In `.claude/commands/bundle-go/README.md`, update all command references to include the `bundle-go:` prefix. Replace the Quick Start block:

```bash
sed -i 's|/brainstorm |/bundle-go:workflow:brainstorm |g' .claude/commands/bundle-go/README.md
sed -i 's|/define |/bundle-go:workflow:define |g' .claude/commands/bundle-go/README.md
sed -i 's|/design |/bundle-go:workflow:design |g' .claude/commands/bundle-go/README.md
sed -i 's|/build |/bundle-go:workflow:build |g' .claude/commands/bundle-go/README.md
sed -i 's|/ship |/bundle-go:workflow:ship |g' .claude/commands/bundle-go/README.md
sed -i 's|/iterate |/bundle-go:workflow:iterate |g' .claude/commands/bundle-go/README.md
sed -i 's|/create-pr|/bundle-go:workflow:create-pr|g' .claude/commands/bundle-go/README.md
sed -i 's|/handler |/bundle-go:go-engineering:handler |g' .claude/commands/bundle-go/README.md
sed -i 's|/service |/bundle-go:go-engineering:service |g' .claude/commands/bundle-go/README.md
sed -i 's|/repository |/bundle-go:go-engineering:repository |g' .claude/commands/bundle-go/README.md
sed -i 's|/migration |/bundle-go:go-engineering:migration |g' .claude/commands/bundle-go/README.md
sed -i 's|/middleware |/bundle-go:go-engineering:middleware |g' .claude/commands/bundle-go/README.md
sed -i 's|/proto |/bundle-go:go-engineering:proto |g' .claude/commands/bundle-go/README.md
sed -i 's|/kafka-consumer |/bundle-go:go-engineering:kafka-consumer |g' .claude/commands/bundle-go/README.md
sed -i 's|/swagger |/bundle-go:go-engineering:swagger |g' .claude/commands/bundle-go/README.md
sed -i 's|/security-scan|/bundle-go:go-engineering:security-scan|g' .claude/commands/bundle-go/README.md
sed -i 's|/go-review|/bundle-go:go-engineering:go-review|g' .claude/commands/bundle-go/README.md
sed -i 's|/memory|/bundle-go:core:memory|g' .claude/commands/bundle-go/README.md
sed -i 's|/meeting|/bundle-go:core:meeting|g' .claude/commands/bundle-go/README.md
sed -i 's|/readme-maker|/bundle-go:core:readme-maker|g' .claude/commands/bundle-go/README.md
sed -i 's|/sync-context|/bundle-go:core:sync-context|g' .claude/commands/bundle-go/README.md
sed -i 's|/create-kb|/bundle-go:knowledge:create-kb|g' .claude/commands/bundle-go/README.md
sed -i 's|/review|/bundle-go:review:review|g' .claude/commands/bundle-go/README.md
```

- [ ] **Step 3: Update the directory tree in README**

Replace the command file locations tree in `.claude/commands/bundle-go/README.md` to show the new `bundle-go/` wrapper:

```
.claude/commands/
└── bundle-go/
    ├── workflow/          # brainstorm, define, design, build, ship, iterate, create-pr
    ├── go-engineering/    # handler, service, repository, migration, middleware,
    │                      # proto, kafka-consumer, swagger, security-scan, go-review
    ├── core/              # memory, meeting, readme-maker, sync-context
    ├── knowledge/         # create-kb
    ├── review/            # review
    └── README.md          # this file
```

- [ ] **Step 4: Verify no noxcare references remain in commands**

```bash
grep -ri 'noxcare' .claude/commands/
```

Expected: no output.

- [ ] **Step 5: Commit**

```bash
git add .claude/commands/
git commit -m "rename: update command content and references for bundle-go namespace"
```

---

### Task 8: Update CLAUDE.md — full rewrite of command tables and references

**Files (modify):**
- `CLAUDE.md`

- [ ] **Step 1: Run text replacements on CLAUDE.md**

```bash
sed -i 's/Bundle-Go/Bundle-Go/g' CLAUDE.md
sed -i 's/BundleGo/BundleGo/g' CLAUDE.md
sed -i 's/bundle-go/bundle-go/g' CLAUDE.md
```

- [ ] **Step 2: Update repository structure tree**

Replace `bundle-go/` at line 18 with `bundle-go/` and update the commands section to show the `bundle-go/` wrapper:

```text
bundle-go/
├── .claude/
│   ├── ...
│   ├── commands/                  # 23 slash commands
│   │   └── bundle-go/            # namespaced under bundle-go
│   │       ├── workflow/          # 7 SDD commands
│   │       ├── go-engineering/    # 10 Go-specific commands
│   │       ├── core/              # 4 utility commands
│   │       ├── knowledge/         # 1 KB command
│   │       └── review/            # 1 review command
```

- [ ] **Step 3: Update Development Workflow code blocks with prefixed commands**

Replace all command invocations in the code blocks:

```bash
# Phase 0 — Explore an idea (optional)
/bundle-go:workflow:brainstorm "Add JWT authentication middleware"

# Phase 1 — Capture requirements
/bundle-go:workflow:define JWT_AUTH

# Phase 2 — Design the architecture
/bundle-go:workflow:design JWT_AUTH

# Phase 3 — Build it
/bundle-go:workflow:build JWT_AUTH

# Phase 4 — Ship when complete
/bundle-go:workflow:ship JWT_AUTH

# Cross-phase — Update any existing document
/bundle-go:workflow:iterate JWT_AUTH
```

And the Go engineering examples:

```bash
# Scaffold a Gin handler
/bundle-go:go-engineering:handler "POST /auth/login with JWT response"

# Generate a service layer
/bundle-go:go-engineering:service "AuthService with login and refresh token"

# Create a sqlc repository
/bundle-go:go-engineering:repository "UserRepository with CRUD operations"

# Generate a Kafka consumer
/bundle-go:go-engineering:kafka-consumer "OrderCreatedConsumer with dead-letter queue"

# Add Swagger annotations
/bundle-go:go-engineering:swagger internal/adapter/http/handler/auth.go
```

- [ ] **Step 4: Update command tables**

Replace the SDD Workflow table:

| Command | Purpose |
|---------|---------|
| `/bundle-go:workflow:brainstorm` | Explore ideas (Phase 0) |
| `/bundle-go:workflow:define` | Capture requirements (Phase 1) |
| `/bundle-go:workflow:design` | Create architecture (Phase 2) |
| `/bundle-go:workflow:build` | Execute implementation (Phase 3) |
| `/bundle-go:workflow:ship` | Archive completed work (Phase 4) |
| `/bundle-go:workflow:iterate` | Update existing docs (Cross-phase) |
| `/bundle-go:workflow:create-pr` | Create pull request |

Replace the Go Engineering table:

| Command | Purpose |
|---------|---------|
| `/bundle-go:go-engineering:handler` | Gin HTTP handler scaffolding |
| `/bundle-go:go-engineering:service` | Application service layer |
| `/bundle-go:go-engineering:repository` | sqlc/pgx repository scaffolding |
| `/bundle-go:go-engineering:migration` | SQL migration files (golang-migrate) |
| `/bundle-go:go-engineering:middleware` | Gin middleware (auth, logging, rate-limit) |
| `/bundle-go:go-engineering:proto` | Protobuf + gRPC service definition |
| `/bundle-go:go-engineering:kafka-consumer` | Kafka consumer with error handling |
| `/bundle-go:go-engineering:swagger` | Swagger/OpenAPI annotations |
| `/bundle-go:go-engineering:security-scan` | Security audit (OWASP, secrets) |
| `/bundle-go:go-engineering:go-review` | Go-specific code review |

Replace the Core & Utilities table:

| Command | Purpose |
|---------|---------|
| `/bundle-go:knowledge:create-kb` | Create KB domain |
| `/bundle-go:review:review` | General code review |
| `/bundle-go:core:meeting` | Meeting transcript analysis |
| `/bundle-go:core:memory` | Save session insights |
| `/bundle-go:core:sync-context` | Update CLAUDE.md |
| `/bundle-go:core:readme-maker` | Generate README |

- [ ] **Step 5: Verify no noxcare references remain in CLAUDE.md**

```bash
grep -i 'noxcare' CLAUDE.md
```

Expected: no output.

- [ ] **Step 6: Commit**

```bash
git add CLAUDE.md
git commit -m "rename: update CLAUDE.md with bundle-go names and command prefixes"
```

---

### Task 9: Final verification and root directory rename

- [ ] **Step 1: Full project-wide verification**

```bash
grep -ri 'noxcare\|plussystemtechnology' --include='*.md' --include='*.yaml' .
```

Expected: no output. If any matches, fix them.

- [ ] **Step 2: Rename root directory**

```bash
cd /home/lerry/models
mv bundle-go bundle-go
cd /home/lerry/models/bundle-go
```

- [ ] **Step 3: Verify git still works after rename**

```bash
git status
git log --oneline -3
```

Expected: git recognizes the repo normally; recent commits visible.

- [ ] **Step 4: Update memory files**

Update `/home/lerry/.claude/projects/-home-lerry-models-bundle-go/memory/MEMORY.md` and `project_noxcare.md` to reflect the new project name `bundle-go` and repo URL `https://github.com/plussystemtechnology/bundle-go`.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "rename: final verification after bundle-go to bundle-go rename"
```
