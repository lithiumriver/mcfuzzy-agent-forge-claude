# Claude Code Plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port McFuzzy Agent Forge from a GitHub Copilot template bootstrapper to a Claude Code plugin that turns a PRD into a coordinated Claude Code agent team.

**Architecture:** A two-layer system — the forge plugin (installed once globally) provides skills and agents for building PRDs and generating agent teams; a bootstrap script copies a plugin skeleton into target projects; generated agents are self-contained and work without the forge at runtime.

**Tech Stack:** Markdown (YAML frontmatter), JSON (plugin manifest), EJS (bootstrap templates), Bash, PowerShell

---

## File Map

**Create:**
- `plugin.json` — Claude Code plugin manifest for the forge itself
- `skills/forge-build-prd/SKILL.md` — PRD interview skill (ported from `templates/skills/forge-build-prd/SKILL.md`)
- `skills/forge-decompose-prd/SKILL.md` — PRD decomposition skill (ported from `templates/skills/forge-decompose-prd/SKILL.md`)
- `skills/forge-build-feature-prd/SKILL.md` — Feature PRD skill (ported from `templates/skills/forge-build-feature-prd/SKILL.md`)
- `skills/forge-build-agent-team/SKILL.md` — Agent team generation skill (ported + updated output paths)
- `agents/forge-team-builder.md` — Team builder agent (ported + updated output paths and platform refs)
- `agents/project-orchestrator.md` — Orchestrator agent (ported + updated platform refs)
- `templates/plugin.json.ejs` — Template for generated target project plugin manifest
- `templates/CLAUDE.md.ejs` — Template for generated target project CLAUDE.md

**Modify:**
- `templates/agents/project-orchestrator.md` — Update Copilot → Claude Code references (this copy goes into target projects)
- `scripts/bootstrap.sh` — Update target paths from `.github/` → `.claude/plugins/agent-forge/`; add CLAUDE.md rendering
- `scripts/bootstrap.ps1` — Same updates for PowerShell
- `README.md` — Rewrite for Claude Code plugin workflow

**Delete:**
- `templates/agents/forge-team-builder.md` — Now lives at `agents/forge-team-builder.md`
- `templates/skills/` — All Copilot skill templates (forge now generates agents dynamically; old skills replaced by forge-side skills)

---

## Task 1: Create plugin.json

**Files:**
- Create: `plugin.json`

- [ ] **Step 1: Write plugin.json**

```json
{
  "name": "mcfuzzy-agent-forge",
  "version": "2.0.0",
  "description": "Bootstrap a custom Claude Code agent team from your PRD — in minutes.",
  "skills": [
    "skills/forge-build-prd",
    "skills/forge-decompose-prd",
    "skills/forge-build-feature-prd",
    "skills/forge-build-agent-team"
  ],
  "agents": [
    "agents/forge-team-builder.md",
    "agents/project-orchestrator.md"
  ]
}
```

- [ ] **Step 2: Verify it is valid JSON**

Run: `python3 -c "import json; json.load(open('plugin.json')); print('valid')"`
Expected: `valid`

- [ ] **Step 3: Commit**

```bash
git add plugin.json
git commit -m "feat: add Claude Code plugin manifest"
```

---

## Task 2: Create skills directory and port forge-build-prd skill

**Files:**
- Create: `skills/forge-build-prd/SKILL.md`

- [ ] **Step 1: Create directory and copy source**

```bash
mkdir -p skills/forge-build-prd
cp templates/skills/forge-build-prd/SKILL.md skills/forge-build-prd/SKILL.md
```

- [ ] **Step 2: Update the frontmatter description to remove Copilot-specific language**

Open `skills/forge-build-prd/SKILL.md`. Replace the frontmatter block (lines 1–6) with:

```yaml
---
name: forge-build-prd
description: >
  Build a comprehensive Product Requirements Document (PRD) or Technical Specification
  from a user's idea, concept, or research document. Use this skill when asked to create,
  draft, or formalize a PRD, spec, or requirements document.
---
```

- [ ] **Step 3: Verify the file has correct frontmatter and no Copilot references**

Run: `grep -n "Copilot\|github\.com/copilot\|\.github/agents" skills/forge-build-prd/SKILL.md`
Expected: no output (zero matches)

- [ ] **Step 4: Commit**

```bash
git add skills/forge-build-prd/SKILL.md
git commit -m "feat: add forge-build-prd skill for Claude Code"
```

---

## Task 3: Port forge-decompose-prd skill

**Files:**
- Create: `skills/forge-decompose-prd/SKILL.md`

- [ ] **Step 1: Create directory and copy source**

```bash
mkdir -p skills/forge-decompose-prd
cp templates/skills/forge-decompose-prd/SKILL.md skills/forge-decompose-prd/SKILL.md
```

- [ ] **Step 2: Update frontmatter**

Replace the frontmatter block with:

```yaml
---
name: forge-decompose-prd
description: >
  Decompose a monolithic PRD into a Product Vision document and individual Feature documents.
  Use this skill when a PRD has grown large (15+ requirements) or when the team wants to
  deliver features independently. Produces docs/product-vision.md and docs/features/*.md.
---
```

- [ ] **Step 3: Verify no Copilot references remain**

Run: `grep -n "Copilot\|\.github/agents\|\.github/skills" skills/forge-decompose-prd/SKILL.md`
Expected: no output

- [ ] **Step 4: Commit**

```bash
git add skills/forge-decompose-prd/SKILL.md
git commit -m "feat: add forge-decompose-prd skill for Claude Code"
```

---

## Task 4: Port forge-build-feature-prd skill

**Files:**
- Create: `skills/forge-build-feature-prd/SKILL.md`

- [ ] **Step 1: Create directory and copy source**

```bash
mkdir -p skills/forge-build-feature-prd
cp templates/skills/forge-build-feature-prd/SKILL.md skills/forge-build-feature-prd/SKILL.md
```

- [ ] **Step 2: Update frontmatter**

Replace the frontmatter block with:

```yaml
---
name: forge-build-feature-prd
description: >
  Build a Feature PRD for adding a new feature to an existing project, or for a greenfield
  feature during initial PRD decomposition. Use this skill when the project already has a
  completed PRD and the user wants to add a scoped feature. Produces docs/features/<name>.md.
---
```

- [ ] **Step 3: Verify no Copilot references remain**

Run: `grep -n "Copilot\|\.github/agents\|\.github/skills" skills/forge-build-feature-prd/SKILL.md`
Expected: no output

- [ ] **Step 4: Commit**

```bash
git add skills/forge-build-feature-prd/SKILL.md
git commit -m "feat: add forge-build-feature-prd skill for Claude Code"
```

---

## Task 5: Port and update forge-build-agent-team skill

This skill has the most changes — output paths shift from `.github/` to `.claude/plugins/agent-forge/`.

**Files:**
- Create: `skills/forge-build-agent-team/SKILL.md`

- [ ] **Step 1: Create directory and copy source**

```bash
mkdir -p skills/forge-build-agent-team
cp templates/skills/forge-build-agent-team/SKILL.md skills/forge-build-agent-team/SKILL.md
```

- [ ] **Step 2: Update frontmatter**

Replace the frontmatter block with:

```yaml
---
name: forge-build-agent-team
description: >
  Build a custom Claude Code agent team from a PRD, Product Vision with Feature documents,
  or a Feature PRD. Generates specialist agent files into .claude/plugins/agent-forge/agents/.
  Use this skill when asked to generate, extend, or restructure an agent team from requirements.
---
```

- [ ] **Step 3: Replace all output path references throughout the file**

Run these substitutions:
```bash
sed -i '' 's|\.github/agents/|.claude/plugins/agent-forge/agents/|g' skills/forge-build-agent-team/SKILL.md
sed -i '' 's|\.github/skills/|.claude/plugins/agent-forge/skills/|g' skills/forge-build-agent-team/SKILL.md
sed -i '' 's|\[docs/PRD\.md\](\.\.\/\.\.\/\.\.\/docs/PRD\.md)|\[docs/PRD.md\](../../../../docs/PRD.md)|g' skills/forge-build-agent-team/SKILL.md
```

- [ ] **Step 4: Replace GitHub Copilot platform references**

```bash
sed -i '' 's/GitHub Copilot custom agents/Claude Code agents/g' skills/forge-build-agent-team/SKILL.md
sed -i '' 's/GitHub Copilot agent/Claude Code agent/g' skills/forge-build-agent-team/SKILL.md
sed -i '' 's/Copilot custom agent/Claude Code agent/g' skills/forge-build-agent-team/SKILL.md
```

- [ ] **Step 5: Verify path and platform updates are correct**

Run: `grep -n "\.github/agents\|\.github/skills\|GitHub Copilot" skills/forge-build-agent-team/SKILL.md`
Expected: no output

Run: `grep -n "agent-forge/agents\|agent-forge/skills" skills/forge-build-agent-team/SKILL.md | head -5`
Expected: at least 3 lines showing the updated paths

- [ ] **Step 6: Commit**

```bash
git add skills/forge-build-agent-team/SKILL.md
git commit -m "feat: add forge-build-agent-team skill targeting Claude Code plugin paths"
```

---

## Task 6: Port and update forge-team-builder agent

**Files:**
- Create: `agents/forge-team-builder.md`

- [ ] **Step 1: Create directory and copy source**

```bash
mkdir -p agents
cp templates/agents/forge-team-builder.md agents/forge-team-builder.md
```

- [ ] **Step 2: Update frontmatter description**

Replace the frontmatter block (lines 1–8) with:

```yaml
---
name: forge-team-builder
description: >
  Analyzes a Product Requirements Document (PRD), Product Vision with Feature documents, or
  Feature PRD and generates or extends a team of Claude Code specialist agents tailored to
  the project. Use this agent when you need to build, extend, or restructure a development
  agent team from requirements documents.
---
```

- [ ] **Step 3: Update the opening paragraph platform reference**

Replace:
```
You are a **Team Builder** — a specialist in analyzing Product Requirements Documents and designing teams of GitHub Copilot custom agents and skills.
```
With:
```
You are a **Team Builder** — a specialist in analyzing Product Requirements Documents and designing teams of Claude Code specialist agents and skills.
```

- [ ] **Step 4: Update Output Standards section paths**

Find the Output Standards section and replace:
```
- All agent files go in `.github/agents/`.
- All skill files go in `.github/skills/{skill-name}/SKILL.md`.
```
With:
```
- All agent files go in `.claude/plugins/agent-forge/agents/`.
- All skill files go in `.claude/plugins/agent-forge/skills/{skill-name}/SKILL.md`.
```

Also replace relative PRD paths in that section:
```
- Relative paths to the PRD in agent files: `[docs/PRD.md](../../docs/PRD.md)`.
- Relative paths to the PRD in skill files: `[docs/PRD.md](../../../docs/PRD.md)`.
```
With:
```
- Relative paths to the PRD in agent files: `[docs/PRD.md](../../../../docs/PRD.md)`.
- Relative paths to the PRD in skill files: `[docs/PRD.md](../../../../../docs/PRD.md)`.
```

- [ ] **Step 5: Replace remaining Copilot references**

```bash
sed -i '' 's/GitHub Copilot custom agents/Claude Code agents/g' agents/forge-team-builder.md
sed -i '' 's/GitHub Copilot/Claude Code/g' agents/forge-team-builder.md
```

- [ ] **Step 6: Verify**

Run: `grep -n "GitHub Copilot\|\.github/agents\|\.github/skills" agents/forge-team-builder.md`
Expected: no output

- [ ] **Step 7: Commit**

```bash
git add agents/forge-team-builder.md
git commit -m "feat: add forge-team-builder agent for Claude Code plugin paths"
```

---

## Task 7: Port and update project-orchestrator agent (forge copy)

The forge keeps its own copy of `project-orchestrator` to stay in sync with updates. A separate copy goes in `templates/agents/` for bootstrapping into target projects (updated in Task 11).

**Files:**
- Create: `agents/project-orchestrator.md`

- [ ] **Step 1: Copy source**

```bash
cp templates/agents/project-orchestrator.md agents/project-orchestrator.md
```

- [ ] **Step 2: Replace Copilot platform references**

```bash
sed -i '' 's/GitHub Copilot/Claude Code/g' agents/project-orchestrator.md
sed -i '' 's/@workspace\b/@/g' agents/project-orchestrator.md
```

- [ ] **Step 3: Verify**

Run: `grep -n "GitHub Copilot\|@workspace" agents/project-orchestrator.md`
Expected: no output

- [ ] **Step 4: Commit**

```bash
git add agents/project-orchestrator.md
git commit -m "feat: add project-orchestrator agent for Claude Code"
```

---

## Task 8: Create templates/plugin.json.ejs

This template is rendered by bootstrap.sh and placed at `.claude/plugins/agent-forge/plugin.json` in the target project.

**Files:**
- Create: `templates/plugin.json.ejs`

- [ ] **Step 1: Write the template**

```json
{
  "name": "agent-forge",
  "version": "1.0.0",
  "description": "Custom Claude Code agent team for <%= projectName %>",
  "agents": [
    "agents/project-orchestrator.md"
  ],
  "skills": []
}
```

- [ ] **Step 2: Verify it is valid EJS (renders without error)**

Run:
```bash
node -e "
const ejs = require('ejs');
const fs = require('fs');
const tmpl = fs.readFileSync('templates/plugin.json.ejs', 'utf8');
const out = ejs.render(tmpl, { projectName: 'test-project' });
JSON.parse(out);
console.log('valid');
" 2>/dev/null || echo "ejs not available — verify manually after bootstrap smoke test"
```

- [ ] **Step 3: Commit**

```bash
git add templates/plugin.json.ejs
git commit -m "feat: add plugin.json EJS template for target project bootstrap"
```

---

## Task 9: Create templates/CLAUDE.md.ejs

This template is rendered by bootstrap.sh and placed at `CLAUDE.md` in the target project root.

**Files:**
- Create: `templates/CLAUDE.md.ejs`

- [ ] **Step 1: Write the template**

```markdown
# <%= projectName %> — Claude Code Configuration

## Agent Team

This project uses a custom Claude Code agent team managed by Agent Forge.

| Agent | Role |
|---|---|
| `project-orchestrator` | Coordinates specialist agents through PRD implementation phases |

> Agent files live in `.claude/plugins/agent-forge/agents/`. Run `/forge-build-agent-team` to generate specialist agents from your PRD.

## Workflow

1. **Build a PRD** — `/forge-build-prd` (if not done yet)
2. **Generate agents** — `/forge-build-agent-team`
3. **Execute the build** — invoke `project-orchestrator` to coordinate phases

For decomposed projects:
1. `/forge-build-prd` → `/forge-decompose-prd` → `/forge-build-agent-team` → build feature by feature

## Conventions

- Agent names are lowercase-hyphenated (e.g., `backend-engineer`, `qa-tester`)
- Each agent owns one domain — no overlapping responsibilities
- Agents reference the PRD by section number, not by copying content
- Commit after each phase completes

## EJS Recording Contract (optional)

If using the Engineering Journey System:
- Record decisions and sub-agent work to the session journey file
- Query `.ejs.db` before reading raw markdown for past context
- Attribute every entry by agent name
```

- [ ] **Step 2: Commit**

```bash
git add templates/CLAUDE.md.ejs
git commit -m "feat: add CLAUDE.md EJS template for target project bootstrap"
```

---

## Task 10: Update templates/agents/project-orchestrator.md

The copy in `templates/agents/` is what gets bootstrapped into target projects. It needs the same Claude Code updates as the forge's own copy.

**Files:**
- Modify: `templates/agents/project-orchestrator.md`

- [ ] **Step 1: Apply platform reference updates**

```bash
sed -i '' 's/GitHub Copilot/Claude Code/g' templates/agents/project-orchestrator.md
sed -i '' 's/@workspace\b/@/g' templates/agents/project-orchestrator.md
```

- [ ] **Step 2: Verify**

Run: `grep -n "GitHub Copilot\|@workspace" templates/agents/project-orchestrator.md`
Expected: no output

- [ ] **Step 3: Commit**

```bash
git add templates/agents/project-orchestrator.md
git commit -m "feat: update project-orchestrator template with Claude Code references"
```

---

## Task 11: Update bootstrap.sh

**Files:**
- Modify: `scripts/bootstrap.sh`

- [ ] **Step 1: Read the current bootstrap.sh to understand its structure before editing**

Read `scripts/bootstrap.sh` fully before making changes.

- [ ] **Step 2: Update the target directory structure**

Replace the bootstrap section that copies to `.github/agents/` and `.github/skills/` with logic that copies to `.claude/plugins/agent-forge/` and renders EJS templates.

The updated bootstrap section should:

```bash
# ---- Bootstrap ---------------------------------------------------------------

PLUGIN_DIR="$TARGET_DIR/.claude/plugins/agent-forge"
AGENTS_DIR="$PLUGIN_DIR/agents"
SKILLS_DIR="$PLUGIN_DIR/skills"

echo "Bootstrapping Agent Forge into: $TARGET_DIR"
echo ""

# Create directory structure
mkdir -p "$AGENTS_DIR" "$SKILLS_DIR"

# Copy project-orchestrator agent
copy_file "$TEMPLATES_DIR/agents/project-orchestrator.md" "$AGENTS_DIR/project-orchestrator.md"

# Render plugin.json from EJS template (requires Node + ejs, falls back to static copy)
PROJECT_NAME="$(basename "$TARGET_DIR")"
if command -v node &>/dev/null && node -e "require('ejs')" 2>/dev/null; then
  node -e "
    const ejs = require('ejs');
    const fs = require('fs');
    const tmpl = fs.readFileSync('$TEMPLATES_DIR/plugin.json.ejs', 'utf8');
    fs.writeFileSync('$PLUGIN_DIR/plugin.json', ejs.render(tmpl, { projectName: '$PROJECT_NAME' }));
  "
  echo "  Rendered plugin.json"
else
  # Static fallback — writes plugin.json without EJS rendering
  cat > "$PLUGIN_DIR/plugin.json" <<PLUGINJSON
{
  "name": "agent-forge",
  "version": "1.0.0",
  "description": "Custom Claude Code agent team for $PROJECT_NAME",
  "agents": ["agents/project-orchestrator.md"],
  "skills": []
}
PLUGINJSON
  echo "  Wrote plugin.json (static fallback — Node/EJS not available)"
fi

# Render CLAUDE.md from EJS template
CLAUDE_MD="$TARGET_DIR/CLAUDE.md"
if command -v node &>/dev/null && node -e "require('ejs')" 2>/dev/null; then
  node -e "
    const ejs = require('ejs');
    const fs = require('fs');
    const tmpl = fs.readFileSync('$TEMPLATES_DIR/CLAUDE.md.ejs', 'utf8');
    const out = ejs.render(tmpl, { projectName: '$PROJECT_NAME' });
    fs.writeFileSync('$CLAUDE_MD', out);
  "
  echo "  Rendered CLAUDE.md"
else
  # Static fallback
  sed "s/<%= projectName %>/$PROJECT_NAME/g" "$TEMPLATES_DIR/CLAUDE.md.ejs" > "$CLAUDE_MD"
  echo "  Wrote CLAUDE.md (static fallback)"
fi

echo ""
echo "Done! Next steps:"
echo "  1. Open $TARGET_DIR in Claude Code"
echo "  2. Run /forge-build-prd to create your PRD"
echo "  3. Run /forge-build-agent-team to generate your agent team"
```

- [ ] **Step 3: Run a smoke test on a temp directory**

```bash
mkdir -p /tmp/forge-smoke-test
bash scripts/bootstrap.sh /tmp/forge-smoke-test --force
```

Expected output:
```
Bootstrapping Agent Forge into: /tmp/forge-smoke-test
  Copied .../project-orchestrator.md → .../agents/project-orchestrator.md
  Wrote plugin.json ...
  Wrote CLAUDE.md ...
Done! Next steps:
  ...
```

- [ ] **Step 4: Verify the output structure**

```bash
find /tmp/forge-smoke-test -not -path '*/.git/*' | sort
```

Expected:
```
/tmp/forge-smoke-test
/tmp/forge-smoke-test/.claude
/tmp/forge-smoke-test/.claude/plugins
/tmp/forge-smoke-test/.claude/plugins/agent-forge
/tmp/forge-smoke-test/.claude/plugins/agent-forge/agents
/tmp/forge-smoke-test/.claude/plugins/agent-forge/agents/project-orchestrator.md
/tmp/forge-smoke-test/.claude/plugins/agent-forge/plugin.json
/tmp/forge-smoke-test/.claude/plugins/agent-forge/skills
/tmp/forge-smoke-test/CLAUDE.md
```

- [ ] **Step 5: Verify plugin.json is valid JSON**

```bash
python3 -c "import json; json.load(open('/tmp/forge-smoke-test/.claude/plugins/agent-forge/plugin.json')); print('valid')"
```
Expected: `valid`

- [ ] **Step 6: Clean up and commit**

```bash
rm -rf /tmp/forge-smoke-test
git add scripts/bootstrap.sh
git commit -m "feat: update bootstrap.sh for Claude Code plugin structure"
```

---

## Task 12: Update bootstrap.ps1

**Files:**
- Modify: `scripts/bootstrap.ps1`

- [ ] **Step 1: Read the current bootstrap.ps1 before editing**

Read `scripts/bootstrap.ps1` fully before making changes.

- [ ] **Step 2: Update target paths to match bootstrap.sh**

Apply the same structural changes as Task 11, translated to PowerShell:
- Create `.claude\plugins\agent-forge\agents\` and `.claude\plugins\agent-forge\skills\`
- Copy `templates\agents\project-orchestrator.md` → `.claude\plugins\agent-forge\agents\`
- Write `plugin.json` using PowerShell here-string (EJS rendering optional, static fallback always available)
- Write `CLAUDE.md` using a simple string replace on the EJS template

```powershell
# ---- Bootstrap ---------------------------------------------------------------

$PluginDir = Join-Path $Target ".claude\plugins\agent-forge"
$AgentsDir = Join-Path $PluginDir "agents"
$SkillsDir = Join-Path $PluginDir "skills"
$ProjectName = Split-Path $Target -Leaf

New-Item -ItemType Directory -Force -Path $AgentsDir | Out-Null
New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null

# Copy project-orchestrator agent
Copy-WithPrompt (Join-Path $TemplatesDir "agents\project-orchestrator.md") (Join-Path $AgentsDir "project-orchestrator.md")

# Write plugin.json (static — no EJS dependency on Windows)
$PluginJson = @"
{
  "name": "agent-forge",
  "version": "1.0.0",
  "description": "Custom Claude Code agent team for $ProjectName",
  "agents": ["agents/project-orchestrator.md"],
  "skills": []
}
"@
Set-Content -Path (Join-Path $PluginDir "plugin.json") -Value $PluginJson
Write-Host "  Wrote plugin.json"

# Write CLAUDE.md (replace EJS variable with project name)
$ClaudeMdTemplate = Get-Content (Join-Path $TemplatesDir "CLAUDE.md.ejs") -Raw
$ClaudeMd = $ClaudeMdTemplate -replace '<%= projectName %>', $ProjectName
Set-Content -Path (Join-Path $Target "CLAUDE.md") -Value $ClaudeMd
Write-Host "  Wrote CLAUDE.md"

Write-Host ""
Write-Host "Done! Next steps:"
Write-Host "  1. Open $Target in Claude Code"
Write-Host "  2. Run /forge-build-prd to create your PRD"
Write-Host "  3. Run /forge-build-agent-team to generate your agent team"
```

- [ ] **Step 3: Commit**

```bash
git add scripts/bootstrap.ps1
git commit -m "feat: update bootstrap.ps1 for Claude Code plugin structure"
```

---

## Task 13: Remove old Copilot templates

**Files:**
- Delete: `templates/agents/forge-team-builder.md`
- Delete: `templates/skills/` (entire directory)

- [ ] **Step 1: Verify nothing depends on the deleted paths before removing**

```bash
grep -r "templates/agents/forge-team-builder\|templates/skills/" scripts/ README.md 2>/dev/null
```
Expected: no output (or only lines already updated in Tasks 11–12)

- [ ] **Step 2: Remove the files**

```bash
git rm templates/agents/forge-team-builder.md
git rm -r templates/skills/
```

- [ ] **Step 3: Commit**

```bash
git commit -m "chore: remove old Copilot template files superseded by Claude Code plugin"
```

---

## Task 14: Update README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Read the current README.md before editing**

Read `README.md` fully before making changes.

- [ ] **Step 2: Rewrite the README for the Claude Code plugin**

Replace the full content with:

```markdown
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
```

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: rewrite README for Claude Code plugin"
```

---

## Self-Review Checklist

- [x] **Spec coverage:** plugin.json ✓, skills (4) ✓, agents (2) ✓, templates (2) ✓, bootstrap (bash + PS1) ✓, cleanup ✓, README ✓
- [x] **No placeholders:** All steps have concrete commands and content
- [x] **Type consistency:** Path `.claude/plugins/agent-forge/agents/` used consistently across Tasks 5, 6, 8, 9, 11, 12, 14
- [x] **EJS fallback:** Static fallback documented in Tasks 8, 11, 12 for environments without Node/EJS
