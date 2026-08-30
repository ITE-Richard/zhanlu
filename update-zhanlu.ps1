<#
.SYNOPSIS
    One-command upgrade: refreshes the kit from git, then updates the installed project.
.DESCRIPTION
    Wraps the two steps a flow-A installation needs to move to a new module version:

      1. git pull in the kit directory this script lives in, so the kit is current.
      2. setup-zhanlu.ps1 -Update against the installed project.

    The project is located the same way clean-backups.ps1 locates it: from the kit
    directory, the nearest ancestor whose .agents/module.json is an installed project
    (projectKind is not kit-source). Nothing about the active project layer changes -
    .agents/project.md, .agents/context-index.md and .agents/TODO.md are never written,
    and neither are .agents/resources/, .agents/reference-projects/ or skills you added
    yourself. Only the module's own shared files are overwritten.

    Run it with no arguments from anywhere inside the kit directory.
.PARAMETER TargetPath
    Root directory of the project to update. Defaults to the nearest installed project at
    or above the kit directory. Passing it disables the search.
.PARAMETER NoPull
    Skip the git pull. Use this for a kit that came from a 7z package, or to re-apply the
    kit you already have without touching the network.
.PARAMETER RemoveStale
    Delete files the previously installed manifest listed but the current one no longer
    contains. Without it such files are only reported, which matches setup-zhanlu.ps1.
.EXAMPLE
    .\update-zhanlu.ps1
.EXAMPLE
    .\update-zhanlu.ps1 -WhatIf
.EXAMPLE
    .\update-zhanlu.ps1 -RemoveStale
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$TargetPath,

    [switch]$NoPull,

    [switch]$RemoveStale
)

$ErrorActionPreference = 'Stop'

# A kit source carries its own .agents/module.json, so "the manifest exists" is not enough
# to prove a directory is an installed project. setup-zhanlu.ps1 rewrites projectKind to
# firmware on the installed copy, which is what actually separates the two.
function Test-InstalledProject {
    param([string]$Path)
    $manifestPath = Join-Path (Join-Path $Path '.agents') 'module.json'
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { return $false }
    try {
        $probe = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    } catch {
        return $false
    }
    return ($probe.projectKind -ne 'kit-source')
}

# Windows PowerShell leaves $PSScriptRoot empty while binding parameter defaults, so the
# kit directory has to be resolved in the body.
$kitRoot = (Resolve-Path -LiteralPath $PSScriptRoot).Path.TrimEnd('\', '/')
$installer = Join-Path $kitRoot 'setup-zhanlu.ps1'

if ([string]::IsNullOrWhiteSpace($TargetPath)) {
    $probeRoot = $kitRoot
    $found = ''
    if (Test-InstalledProject $probeRoot) {
        $found = $probeRoot
    }
    while (-not $found) {
        $parent = Split-Path -Parent $probeRoot
        if (-not $parent -or $parent -eq $probeRoot) { break }
        if (Test-InstalledProject $parent) { $found = $parent }
        $probeRoot = $parent
    }
    if (-not $found) {
        throw "No installed project found at or above $kitRoot. Pass -TargetPath, or use setup-zhanlu.ps1 without -Update for a first install."
    }
    $TargetPath = $found
}

if (-not (Test-Path -LiteralPath $TargetPath -PathType Container)) {
    throw "Target project directory does not exist: $TargetPath"
}
$targetRoot = (Resolve-Path -LiteralPath $TargetPath).Path.TrimEnd('\', '/')
if (-not (Test-InstalledProject $targetRoot)) {
    throw "$targetRoot is not an installed project. Run setup-zhanlu.ps1 without -Update to install first."
}

Write-Output "Kit:     $kitRoot"
Write-Output "Project: $targetRoot"

if ($NoPull) {
    Write-Output 'Skipping git pull (-NoPull).'
} else {
    $gitCommand = Get-Command git -ErrorAction SilentlyContinue
    if (-not $gitCommand) {
        Write-Warning 'git was not found; the kit was not refreshed. Continuing with the kit as it is.'
    } else {
        Push-Location -LiteralPath $kitRoot
        try {
            # Outside a repository git writes to stderr by design, which Windows PowerShell
            # turns into a terminating ErrorRecord while ErrorActionPreference is 'Stop'.
            $previousErrorAction = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'
            try {
                $insideWorkTree = & $gitCommand.Source rev-parse --is-inside-work-tree 2>$null
            } finally {
                $ErrorActionPreference = $previousErrorAction
            }
            # Being inside a work tree is not enough: a kit extracted from a 7z into the
            # project is inside the PROJECT's repository, and pulling there would drag the
            # user's firmware repo instead of the module. Only the root of the kit's own
            # repository may be pulled.
            $topLevel = ''
            if ($LASTEXITCODE -eq 0 -and $insideWorkTree -eq 'true') {
                $previousErrorAction = $ErrorActionPreference
                $ErrorActionPreference = 'Continue'
                try {
                    $topLevel = & $gitCommand.Source rev-parse --show-toplevel 2>$null
                } finally {
                    $ErrorActionPreference = $previousErrorAction
                }
                if ($null -eq $topLevel) { $topLevel = '' } else { $topLevel = ([string]$topLevel).Trim() }
            }
            $normalizedTopLevel = $topLevel.Replace('/', '\').TrimEnd('\')
            $normalizedKitRoot = $kitRoot.Replace('/', '\').TrimEnd('\')
            $kitIsOwnClone = $normalizedTopLevel -and
                [string]::Equals($normalizedTopLevel, $normalizedKitRoot, [System.StringComparison]::OrdinalIgnoreCase)

            if (-not $kitIsOwnClone) {
                if ($normalizedTopLevel) {
                    Write-Output "Kit is not its own git clone (it sits inside $topLevel); nothing to pull."
                } else {
                    Write-Output 'Kit is not a git clone (a 7z extraction, for example); nothing to pull.'
                }
            } elseif ($PSCmdlet.ShouldProcess($kitRoot, 'git pull')) {
                & $gitCommand.Source pull --ff-only
                if ($LASTEXITCODE -ne 0) {
                    # A stale kit would silently reinstall the version already in place, so
                    # a failed pull has to stop the run rather than be reported and ignored.
                    throw "git pull failed in $kitRoot with exit code $LASTEXITCODE. Resolve it, then run this script again."
                }
            }
        } finally {
            Pop-Location
        }
    }
}

if (-not (Test-Path -LiteralPath $installer -PathType Leaf)) {
    throw "Installer is missing after the pull: $installer. The kit may have renamed it; run the new installer directly with -Update."
}

$arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $installer, '-TargetPath', $targetRoot, '-Update')
if ($RemoveStale) { $arguments += '-RemoveStale' }
if ($WhatIfPreference) { $arguments += '-WhatIf' }

Write-Output ''
& powershell.exe @arguments
if ($LASTEXITCODE -ne 0) {
    throw "setup-zhanlu.ps1 -Update failed with exit code $LASTEXITCODE."
}

if (-not $WhatIfPreference) {
    Write-Output ''
    Write-Output 'Upgrade done. Reload the VSCode window so the tools rescan rules and skills.'
    Write-Output 'Old project-layer backups can be removed with clean-backups.ps1.'
}
