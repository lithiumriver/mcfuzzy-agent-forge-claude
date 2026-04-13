# Claude Code Plugin Design — McFuzzy Agent Forge

**Date:** 2026-04-13
**Status:** Approved

## Overview

Port McFuzzy Agent Forge from a GitHub Copilot template forge to a Claude Code plugin. The plugin turns a PRD into a coordinated Claude Code agent team, deployable into any target project. Intended for public release.

---

## Architecture

The plugin has two independent layers:

**Layer 1 — The Forge Plugin** (installed once, globally by the user)
A Claude Code plugin in this repo. Provides the PRD interview, decomposition, and agent-team generation workflows via slash commands and agents.

**Layer 2 — The Generated Plugin** (bootstrapped into each target project)
A self-contained Claude Code plugin directory + CLAUDE.md that the forge writes into the target project. Works without the forge being installed at runtime.

**Bootstrap flow:**
1. User runs `bootstrap.sh /path/to/project` — copies plugin skeleton + CLAUDE.md into target
2. User opens target project in Claude Code
3. User invokes `/forge-build-prd` → interviewed → `docs/PRD.md` written
4. User invokes `/forge-build-agent-team` → specialist agents generated into `.claude/plugins/agent-forge/agents/`
5. `project-orchestrator` coordinates the build phase by phase

---

## Forge Plugin Structure

```
mcfuzzy-agent-forge/
├── plugin.json
├── skills/
│   ├── forge-build-prd/
│   │   └── SKILL.md
│   ├── forge-build-feature-prd/
│   │   └── SKILL.md
│   ├── forge-decompose-prd/
│   │   └── SKILL.md
│   └── forge-build-agent-team/
│       └── SKILL.md
├── agents/
│   ├── forge-team-builder.md
│   └── project-orchestrator.md
├── templates/
│   ├── plugin.json.ejs
│   ├── CLAUDE.md.ejs
│   └── agents/
│       └── project-orchestrator.md
├── scripts/
│   ├── bootstrap.sh
│   └── bootstrap.ps1
└── docs/
    ├── prompt-playbook.md
    └── running-with-local-models.md
```

The existing `templates/` folder is repurposed from the Copilot version. The forge's own skills and agents move to top-level `skills/` and `agents/` directories as required by the Claude Code plugin spec.

---

## Generated Plugin Output

Running `bootstrap.sh /path/to/project` produces:

```
your-project/
├── .claude/
│   └── plugins/
│       └── agent-forge/
│           ├── plugin.json
│           ├── agents/
│           │   ├── project-orchestrator.md   # Pre-installed
│           │   └── (specialist agents added by /forge-build-agent-team)
│           └── skills/
│               └── (project-specific skills added by /forge-build-agent-team)
└── CLAUDE.md
```

- Bootstrap renders `.ejs` templates with project name/path variables, then copies output — `project-orchestrator` is the sole pre-populated agent
- `/forge-build-agent-team` fills in specialist agents tailored to the PRD
- CLAUDE.md includes agent routing conventions, build phase instructions, and optional EJS contract
- Generated plugin is fully self-contained — no forge dependency at runtime

---

## Skill & Agent Interfaces

| Invocation | What it does |
|---|---|
| `/forge-build-prd` | Interviews user, writes `docs/PRD.md` |
| `/forge-decompose-prd` | Splits `docs/PRD.md` → `docs/product-vision.md` + `docs/features/*.md` |
| `/forge-build-feature-prd` | Adds a new feature doc to an existing project |
| `/forge-build-agent-team` | Reads PRD or feature set, generates specialist agents |

**Agents:**
- `forge-team-builder` — internal agent, invoked by `/forge-build-agent-team`, writes agent files
- `project-orchestrator` — lives in the target project, coordinates specialists through build phases

Users never call `forge-team-builder` directly. `project-orchestrator` is the only agent the user interacts with post-bootstrap.

---

## Workflow Paths

```
Monolithic:   /forge-build-prd → /forge-build-agent-team → build

Decomposed:   /forge-build-prd → /forge-decompose-prd
                               → /forge-build-agent-team (per feature)
                               → build feature by feature

Add feature:  /forge-build-feature-prd → /forge-build-agent-team → build
```

---

## Out of Scope

- MCP server integration (can be added in a future iteration)
- Hook-based automation (post-commit, pre-tool triggers)
- GUI or web-based PRD builder
