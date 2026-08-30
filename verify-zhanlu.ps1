<#
.SYNOPSIS
    Validates module structure, entry files, skills, and active project documents.
#>
[CmdletBinding()]
param(
    [string]$RootPath,
    [switch]$PackageSource
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

    $uniquePortableFiles = @($manifest.portableFiles | Select-Object -Unique)
    if ($uniquePortableFiles.Count -ne @($manifest.portableFiles).Count) {
        Add-ValidationError 'module.json portableFiles contains duplicate entries.'
    }

    $packageOnlyFiles = @($manifest.packageOnlyFiles)
    $uniquePackageOnlyFiles = @($packageOnlyFiles | Select-Object -Unique)
    if ($uniquePackageOnlyFiles.Count -ne $packageOnlyFiles.Count) {
        Add-ValidationError 'module.json packageOnlyFiles contains duplicate entries.'
    }
    foreach ($relativePath in $packageOnlyFiles) {
        if (@($manifest.portableFiles) -notcontains $relativePath) {
            Add-ValidationError "packageOnlyFiles entry is not in portableFiles: $relativePath"
        }
    }

    $filesToRequire = if ($PackageSource) {
        @($manifest.portableFiles)
    } else {
        @($manifest.portableFiles | Where-Object { $packageOnlyFiles -notcontains $_ })
    }
    foreach ($relativePath in $filesToRequire) {
        [void](Require-File $relativePath)
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

    $antigravityRule = '.agents/rules/project-context.md'
    if (Require-File $antigravityRule) {
        $ruleContent = Get-Content -LiteralPath (Join-Path $root $antigravityRule) -Raw -Encoding UTF8
        $expectedRuleImports = @(
            '@../../AGENTS.md',
            '@../module.json',
            '@../project.md',
            '@../context-index.md',
            '@../TODO.md'
        )
        foreach ($import in $expectedRuleImports) {
            if ($ruleContent -notmatch [regex]::Escape($import)) {
                Add-ValidationError "$antigravityRule is missing shared-source reference: $import"
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

# An installed module must stay out of the target repository's version control. The kit
# source is the opposite case: there the module is meant to be tracked, so it is skipped.
# setup-zhanlu.ps1 rewrites projectKind to 'firmware' in every installed copy.
if ($manifest -and $manifest.projectKind -ne 'kit-source') {
    $gitCommand = Get-Command git -ErrorAction SilentlyContinue
    if ($gitCommand) {
        Push-Location -LiteralPath $root
        try {
            # Windows PowerShell turns a native command's redirected stderr into an ErrorRecord,
            # which is terminating while ErrorActionPreference is 'Stop'. Outside a repository
            # git writes to stderr by design, so the preference is relaxed for this probe only.
            $previousErrorAction = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'
            try {
                $insideWorkTree = & $gitCommand.Source rev-parse --is-inside-work-tree 2>$null
            } finally {
                $ErrorActionPreference = $previousErrorAction
            }
            if ($LASTEXITCODE -eq 0 -and $insideWorkTree -eq 'true') {
                $moduleGitPaths = @(
                    '.agents',
                    '.claude',
                    'AGENTS.md',
                    'CLAUDE.md',
                    'GEMINI.md',
                    'pack.ps1',
                    'setup-zhanlu.ps1',
                    'verify-zhanlu.ps1'
                )
                $trackedFiles = @(& $gitCommand.Source ls-files -- $moduleGitPaths)
                if ($LASTEXITCODE -eq 0 -and $trackedFiles.Count -gt 0) {
                    Add-ValidationError (
                        "module files are tracked by this repository ($($trackedFiles.Count) file(s)); " +
                        "untrack them with: git rm -r --cached $($moduleGitPaths -join ' ')"
                    )
                }
            }
        } finally {
            Pop-Location
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
Write-Output "  packageOnlyFiles: $(@($manifest.packageOnlyFiles).Count)"
Write-Output "  skills: $(@($manifest.skills).Count)"
exit 0
