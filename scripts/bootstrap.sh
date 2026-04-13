#!/usr/bin/env bash
# bootstrap.sh — Deploy mcfuzzy-agent-forge templates into a target repository.
#
# Usage:
#   ./scripts/bootstrap.sh [TARGET_DIR] [--force]
#
# Arguments:
#   TARGET_DIR   Path to the target repository root (default: prompted)
#   --force      Overwrite existing files without prompting
#
# What it does:
#   Copies templates/agents/project-orchestrator.md → TARGET_DIR/.claude/plugins/agent-forge/agents/
#   Renders templates/plugin.json.ejs  → TARGET_DIR/.claude/plugins/agent-forge/plugin.json
#   Renders templates/CLAUDE.md.ejs    → TARGET_DIR/CLAUDE.md

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$(cd "$SCRIPT_DIR/../templates" && pwd)"
TARGET_DIR=""
FORCE=false

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    --*)     echo "Unknown option: $arg" >&2; exit 1 ;;
    *)       [[ -z "$TARGET_DIR" ]] && TARGET_DIR="$arg" ;;
  esac
done

# Prompt if no target supplied
if [[ -z "$TARGET_DIR" ]]; then
  read -rp "Target repository path [.]: " TARGET_DIR
  TARGET_DIR="${TARGET_DIR:-.}"
fi

TARGET_DIR="$(realpath "$TARGET_DIR")"

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Error: Target directory does not exist: $TARGET_DIR" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Helper: copy a single file, respecting --force / interactive prompt
# ---------------------------------------------------------------------------
copy_file() {
  local src="$1"
  local dest="$2"

  if [[ -f "$dest" ]] && [[ "$FORCE" != true ]]; then
    read -rp "  Overwrite existing $(basename "$dest")? [y/N]: " answer
    if [[ "${answer,,}" != "y" ]]; then
      echo "  Skipped: $dest"
      return
    fi
  fi

  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  echo "  Copied:  $dest"
}

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

# Render plugin.json
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
  cat > "$PLUGIN_DIR/plugin.json" <<PLUGINJSON
{
  "name": "agent-forge",
  "version": "1.0.0",
  "description": "Custom Claude Code agent team for $PROJECT_NAME",
  "agents": ["agents/project-orchestrator.md"],
  "skills": []
}
PLUGINJSON
  echo "  Wrote plugin.json (static fallback)"
fi

# Render CLAUDE.md
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
  sed "s/<%= projectName %>/$PROJECT_NAME/g" "$TEMPLATES_DIR/CLAUDE.md.ejs" > "$CLAUDE_MD"
  echo "  Wrote CLAUDE.md (static fallback)"
fi

echo ""
echo "Done! Next steps:"
echo "  1. Open $TARGET_DIR in Claude Code"
echo "  2. Run /forge-build-prd to create your PRD"
echo "  3. Run /forge-build-agent-team to generate your agent team"
