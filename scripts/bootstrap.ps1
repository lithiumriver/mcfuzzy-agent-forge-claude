#Requires -Version 5.1
<#
.SYNOPSIS
    Deploy mcfuzzy-agent-forge templates into a target repository.

.DESCRIPTION
    Copies agent and skill template files from this repository into a target
    repository's .claude/plugins/agent-forge/ directory so Claude Code can use them.

    What it copies:
      templates/agents/project-orchestrator.md  -> TARGET/.claude/plugins/agent-forge/agents/
      Generates plugin.json and CLAUDE.md from templates

.PARAMETER Target
    Path to the target repository root. Prompted if not supplied.

.PARAMETER Force
    Overwrite existing files without prompting.

.EXAMPLE
    .\scripts\bootstrap.ps1 -Target C:\Projects\my-app
    .\scripts\bootstrap.ps1 -Target ../my-app -Force
#>
[CmdletBinding()]
param (
    [string]$Target = "",
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplatesDir = Join-Path $ScriptDir "..\templates" | Resolve-Path

# ---------------------------------------------------------------------------
# Resolve target directory
# ---------------------------------------------------------------------------
if (-not $Target) {
    $Target = Read-Host "Target repository path [.]"
    if (-not $Target) { $Target = "." }
}

$Target = Convert-Path $Target -ErrorAction SilentlyContinue
if (-not $Target -or -not (Test-Path $Target -PathType Container)) {
    Write-Error "Target directory does not exist: $Target"
    exit 1
}

# ---------------------------------------------------------------------------
# Helper: copy a single file, respecting -Force / interactive prompt
# ---------------------------------------------------------------------------
function Copy-TemplateFile {
    param (
        [string]$Src,
        [string]$Dest
    )

    if ((Test-Path $Dest -PathType Leaf) -and -not $Force) {
        $answer = Read-Host "  Overwrite existing $(Split-Path -Leaf $Dest)? [y/N]"
        if ($answer -notin @('y', 'Y')) {
            Write-Host "  Skipped:  $Dest"
            return
        }
    }

    $destDir = Split-Path -Parent $Dest
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    Copy-Item -Path $Src -Destination $Dest -Force
    Write-Host "  Copied:   $Dest"
}

# ---- Bootstrap ---------------------------------------------------------------

$PluginDir = Join-Path $Target ".claude\plugins\agent-forge"
$AgentsDir = Join-Path $PluginDir "agents"
$SkillsDir = Join-Path $PluginDir "skills"
$ProjectName = Split-Path $Target -Leaf

New-Item -ItemType Directory -Force -Path $AgentsDir | Out-Null
New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null

# Copy project-orchestrator agent
Copy-TemplateFile (Join-Path $TemplatesDir "agents\project-orchestrator.md") (Join-Path $AgentsDir "project-orchestrator.md")

# Write plugin.json (static — no EJS dependency on Windows by default)
$PluginJson = @"
{
  "name": "agent-forge",
  "version": "1.0.0",
  "description": "Custom Claude Code agent team for $ProjectName",
  "agents": ["agents/project-orchestrator.md"],
  "skills": []
}
"@
Set-Content -Path (Join-Path $PluginDir "plugin.json") -Value $PluginJson -Encoding UTF8
Write-Host "  Wrote plugin.json"

# Write CLAUDE.md (replace EJS variable with project name)
$ClaudeMdTemplate = Get-Content (Join-Path $TemplatesDir "CLAUDE.md.ejs") -Raw
$ClaudeMd = $ClaudeMdTemplate -replace '<%= projectName %>', $ProjectName
Set-Content -Path (Join-Path $Target "CLAUDE.md") -Value $ClaudeMd -Encoding UTF8
Write-Host "  Wrote CLAUDE.md"

Write-Host ""
Write-Host "Done! Next steps:"
Write-Host "  1. Open $Target in Claude Code"
Write-Host "  2. Run /forge-build-prd to create your PRD"
Write-Host "  3. Run /forge-build-agent-team to generate your agent team"
