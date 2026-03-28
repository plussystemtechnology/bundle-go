# Changelog

All notable changes to Bundle-Go will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.0.0] - 2026-03-27

### Added

- 43 specialized agents across 8 categories (workflow, architect, go-core, api, data, cloud, observability, test)
- 22 KB domains for Go Backend/API (6 core Go, 9 stack, 7 infra)
- 23 slash commands (7 SDD workflow, 10 Go engineering, 4 core, 1 knowledge, 1 review)
- 5-phase SDD workflow adapted for Go (brainstorm, define, design, build, ship)
- Clean Architecture enforcement with layer import rules
- Go-specific quality gates (golangci-lint, go vet, go test -race, staticcheck)
- Agent template system with 3 tiers (T1/T2/T3) and Agreement Matrix
- Knowledge Base framework with concepts and patterns per domain
- SDD document templates with Go-aware sections
- Workflow contracts with Go delegation map and verification commands
- Cross-phase `/iterate` command for updating existing documents
- Agent routing map and escalation guide in `.claude/agents/README.md`
