<#
.SYNOPSIS
    Validates module structure, entry files, skills, and active project documents.
#>
[CmdletBinding()]
param(
    [string]$RootPath
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($RootPath)) {
    $RootPath = $PSScriptRoot
}
$root = (Resolve-Path -LiteralPath $RootPath).Path
$errors = New-Object System.Collections.Generic.List[string]

function Add-ValidationError([string]$Message) {
    $script:errors.Add($Message)
}

function Require-File([string]$RelativePath) {
    $path = Join-Path $root $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Add-ValidationError "Missing file: $RelativePath"
        return $false
    }
    return $true
}

$manifestRelativePath = '.agents/module.json'
if (-not (Require-File $manifestRelativePath)) {
    $errors | ForEach-Object { Write-Output "  [FAIL] $_" }
    exit 1
}

try {
    $manifest = Get-Content -LiteralPath (Join-Path $root $manifestRelativePath) -Raw -Encoding UTF8 | ConvertFrom-Json
} catch {
    Add-ValidationError "module.json parse error: $($_.Exception.Message)"
}

if ($manifest) {
    foreach ($relativePath in @($manifest.requiredSessionFiles)) {
        [void](Require-File $relativePath)
    }
    foreach ($relativePath in @($manifest.portableFiles)) {
        [void](Require-File $relativePath)
    }

    $uniquePortableFiles = @($manifest.portableFiles | Select-Object -Unique)
    if ($uniquePortableFiles.Count -ne @($manifest.portableFiles).Count) {
        Add-ValidationError 'module.json portableFiles contains duplicate entries.'
    }

    if (Require-File 'AGENTS.md') {
        $core = Get-Content -LiteralPath (Join-Path $root 'AGENTS.md') -Raw -Encoding UTF8
        if ($core -notmatch [regex]::Escape([string]$manifest.coreVersion)) {
            Add-ValidationError "AGENTS.md does not contain coreVersion: $($manifest.coreVersion)"
        }
    }

    $expectedImports = @(
        '@AGENTS.md',
        '@.agents/module.json',
        '@.agents/project.md',
        '@.agents/context-index.md',
        '@.agents/TODO.md'
    )
    foreach ($entryFile in @('CLAUDE.md', 'GEMINI.md')) {
        if (Require-File $entryFile) {
            $entryContent = Get-Content -LiteralPath (Join-Path $root $entryFile) -Raw -Encoding UTF8
            foreach ($import in $expectedImports) {
                if ($entryContent -notmatch [regex]::Escape($import)) {
                    Add-ValidationError "$entryFile is missing shared-source reference: $import"
                }
            }
        }
    }

    foreach ($skill in @($manifest.skills)) {
        $canonical = ".agents/skills/$skill/SKILL.md"
        $loader = ".claude/skills/$skill/SKILL.md"
        if (Require-File $canonical) {
            $skillContent = Get-Content -LiteralPath (Join-Path $root $canonical) -Raw -Encoding UTF8
            if ($skillContent -notmatch '(?s)^---\s*\r?\n.*?name:\s*[^\r\n]+\r?\n.*?description:\s*[^\r\n]+\r?\n.*?---') {
                Add-ValidationError "$canonical has invalid YAML frontmatter."
            }
        }
        if (Require-File $loader) {
            $loaderContent = Get-Content -LiteralPath (Join-Path $root $loader) -Raw -Encoding UTF8
            if ($loaderContent -notmatch [regex]::Escape($canonical)) {
                Add-ValidationError "$loader does not reference canonical skill: $canonical"
            }
        }
    }
}

foreach ($activeFile in @('.agents/project.md', '.agents/context-index.md', '.agents/TODO.md')) {
    if (Require-File $activeFile) {
        $content = Get-Content -LiteralPath (Join-Path $root $activeFile) -Raw -Encoding UTF8
        if ($content -match '__[A-Z0-9_-]+__') {
            Add-ValidationError "$activeFile still contains template token: $($Matches[0])"
        }
    }
}

if ($errors.Count -gt 0) {
    Write-Output "Validation failed: $($errors.Count) error(s)"
    $errors | ForEach-Object { Write-Output "  [FAIL] $_" }
    exit 1
}

Write-Output "Validation passed: $($manifest.name) $($manifest.version)"
Write-Output "  coreVersion: $($manifest.coreVersion)"
Write-Output "  portableFiles: $(@($manifest.portableFiles).Count)"
Write-Output "  skills: $(@($manifest.skills).Count)"
exit 0
