# McFuzzy Agent Forge

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Claude Code](https://img.shields.io/badge/Claude_Code-Plugin-orange)
![Bash](https://img.shields.io/badge/Bash-4EAA25?logo=gnubash&logoColor=fff)
![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?logo=powershell&logoColor=fff)

> Bootstrap a custom Claude Code agent team from your PRD — in minutes.

**McFuzzy Agent Forge** turns your requirements document into a coordinated team of Claude Code specialist agents. Each agent owns a specific domain, understands its dependencies, and works in sequence so nothing gets missed.

[Getting Started](#getting-started) • [How It Works](#how-it-works) • [Usage](#usage) • [Prompt Playbook](docs/prompt-playbook.md) • [FAQ](#faq)

---

## How It Works

| Approach | Best for |
|---|---|
| **Monolithic PRD** → agent team → build | Small-to-medium projects |
| **PRD** → decompose into features → agent team → build feature by feature | Larger projects or incremental delivery |

Both approaches use the same toolkit:

| What | Role |
|---|---|
| `/forge-build-prd` skill | Interviews you and creates a comprehensive PRD |
| `/forge-decompose-prd` skill | Splits a monolithic PRD into Product Vision + Feature documents |
| `/forge-build-feature-prd` skill | Creates a Feature PRD to add a new feature to an existing project |
| `forge-team-builder` agent | Reads a PRD or feature set and generates the specialist agent team |
| `project-orchestrator` agent | Coordinates agents through implementation phases |
| Bootstrap scripts | Copy plugin skeleton + CLAUDE.md into any target repository |

---

## Getting Started

### 1. Install the forge plugin

```bash
git clone https://github.com/McFuzzySquirrel/mcfuzzy-agent-forge.git
```

Then install in Claude Code:
```
/plugin install /path/to/mcfuzzy-agent-forge
```

### 2. Bootstrap into your project

**Bash:**
```bash
./scripts/bootstrap.sh /path/to/your/project
```

**PowerShell:**
```powershell
.\scripts\bootstrap.ps1 -Target C:\path\to\your\project
```

This copies `.claude/plugins/agent-forge/` (with `project-orchestrator` pre-installed) and generates a `CLAUDE.md` in your target project.

### 3. Commit and open your project

```bash
cd /path/to/your/project
git add .claude/ CLAUDE.md
git commit -m "chore: bootstrap Agent Forge"
```

Open the project in Claude Code.

### 4. Build your PRD

```
/forge-build-prd
```

### 5. Generate your agent team

```
/forge-build-agent-team
```

Specialist agents appear in `.claude/plugins/agent-forge/agents/`.

### 6. Execute the build

Invoke `project-orchestrator` to coordinate agents phase by phase.

---

## Usage

### Bootstrap options

```bash
./scripts/bootstrap.sh /path/to/project          # Interactive (prompts on conflict)
./scripts/bootstrap.sh /path/to/project --force  # Overwrite without prompting
```

### Add a feature to an existing project

```
/forge-build-feature-prd
```

Then run `/forge-build-agent-team` to extend your agent team with the new feature's specialist.

### Decompose a large PRD into features

```
/forge-decompose-prd
```

Produces `docs/product-vision.md` and `docs/features/*.md`. Then run `/forge-build-agent-team` to generate the team from the decomposed documents.

---

## Plugin Structure

```
mcfuzzy-agent-forge/
├── plugin.json                          # Claude Code plugin manifest
├── skills/
│   ├── forge-build-prd/SKILL.md
│   ├── forge-decompose-prd/SKILL.md
│   ├── forge-build-feature-prd/SKILL.md
│   └── forge-build-agent-team/SKILL.md
├── agents/
│   ├── forge-team-builder.md
│   └── project-orchestrator.md
├── templates/
│   ├── plugin.json.ejs                  # Generated plugin manifest template
│   ├── CLAUDE.md.ejs                    # Generated CLAUDE.md template
│   └── agents/
│       └── project-orchestrator.md     # Bootstrapped into target projects
└── scripts/
    ├── bootstrap.sh
    └── bootstrap.ps1
```

---

## FAQ

**Do I need the forge plugin installed in the target project?**
No. The generated agent team in `.claude/plugins/agent-forge/` is self-contained. The forge plugin only needs to be installed where you run `/forge-build-agent-team`.

**Can I use this without Claude Code?**
This plugin is designed for Claude Code. For GitHub Copilot, use the original [v1 branch](https://github.com/McFuzzySquirrel/mcfuzzy-agent-forge/tree/v1-copilot).

**How many agents does it generate?**
3–4 agents for small projects, 8–12 for larger ones. The forge scales the team to your PRD's complexity.

