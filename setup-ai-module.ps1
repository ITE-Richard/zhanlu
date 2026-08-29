<#
.SYNOPSIS
    Safely installs or updates the portable AI collaboration module in a target project.
.DESCRIPTION
    Install mode copies only module.json portableFiles and creates fresh project files
    from templates. It aborts before writing if any target file already exists.

    Update mode refreshes an already installed module in place. It overwrites portable
    files only and never touches the active project layer:
    .agents/project.md, .agents/context-index.md and .agents/TODO.md.
.PARAMETER TargetPath
    Root directory of the target project.
.PARAMETER Update
    Refresh an existing installation instead of creating a new one.
.PARAMETER RemoveStale
    Update mode only. Delete files that the previously installed manifest listed but the
    current manifest no longer contains. Without this switch such files are only reported.
.EXAMPLE
    .\setup-ai-module.ps1 -TargetPath D:\work\my-firmware
.EXAMPLE
    .\setup-ai-module.ps1 -TargetPath D:\work\my-firmware -Update -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetPath,

    [switch]$Update,

    [switch]$RemoveStale
)

$ErrorActionPreference = 'Stop'
$sourceRoot = $PSScriptRoot
$manifestPath = Join-Path $sourceRoot '.agents\module.json'
$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json

if ($RemoveStale -and -not $Update) {
    throw '-RemoveStale is only valid together with -Update.'
}

if (-not (Test-Path -LiteralPath $TargetPath -PathType Container)) {
    throw "Target project directory does not exist: $TargetPath"
}

$targetRoot = (Resolve-Path -LiteralPath $TargetPath).Path.TrimEnd('\', '/')
$resolvedSourceRoot = (Resolve-Path -LiteralPath $sourceRoot).Path.TrimEnd('\', '/')
if ($targetRoot -eq $resolvedSourceRoot) {
    throw 'The source kit and target project must be different directories.'
}

$portableFiles = @($manifest.portableFiles)
if ($portableFiles.Count -eq 0) {
    throw 'module.json portableFiles must not be empty.'
}
$packageOnlyFiles = @($manifest.packageOnlyFiles)
$invalidPackageOnlyFiles = @($packageOnlyFiles | Where-Object { $portableFiles -notcontains $_ })
if ($invalidPackageOnlyFiles.Count -gt 0) {
    throw "packageOnlyFiles must also exist in portableFiles:`n  $($invalidPackageOnlyFiles -join "`n  ")"
}
$installFiles = @($portableFiles | Where-Object { $packageOnlyFiles -notcontains $_ })

$activeFiles = @(
    '.agents/project.md',
    '.agents/context-index.md',
    '.agents/TODO.md'
)

$missing = foreach ($relativePath in $portableFiles) {
    if (-not (Test-Path -LiteralPath (Join-Path $sourceRoot $relativePath) -PathType Leaf)) {
        $relativePath
    }
}
if ($missing) {
    throw "Source kit is missing files:`n  $($missing -join "`n  ")"
}

# Hashing uses .NET directly so that -WhatIf does not propagate into provider cmdlets
# and flood the update plan with unrelated "What if" lines.
function Get-FileSha256([string]$Path) {
    if (-not [System.IO.File]::Exists($Path)) {
        return $null
    }
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        $stream = [System.IO.File]::OpenRead($Path)
        try {
            return [System.BitConverter]::ToString($sha256.ComputeHash($stream)).Replace('-', '')
        } finally {
            $stream.Dispose()
        }
    } finally {
        $sha256.Dispose()
    }
}

$staleFiles = @()

if ($Update) {
    $targetManifestPath = Join-Path $targetRoot '.agents\module.json'
    if (-not (Test-Path -LiteralPath $targetManifestPath -PathType Leaf)) {
        throw "No installed module found at $targetRoot. Run without -Update to install."
    }
    $missingActive = foreach ($relativePath in $activeFiles) {
        if (-not (Test-Path -LiteralPath (Join-Path $targetRoot $relativePath) -PathType Leaf)) {
            $relativePath
        }
    }
    if ($missingActive) {
        throw "Installed module is incomplete; update aborted. Missing active project files:`n  $($missingActive -join "`n  ")"
    }

    $targetManifest = Get-Content -LiteralPath $targetManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $installedPortableFiles = @($targetManifest.portableFiles)
    $staleFiles = @($installedPortableFiles |
        Where-Object { $portableFiles -notcontains $_ } |
        Where-Object { $activeFiles -notcontains $_ } |
        Where-Object { Test-Path -LiteralPath (Join-Path $targetRoot $_) -PathType Leaf })

    $newFiles = @()
    $changedFiles = @()
    $unchangedFiles = @()
    foreach ($relativePath in $installFiles) {
        $destination = Join-Path $targetRoot $relativePath
        if (-not (Test-Path -LiteralPath $destination -PathType Leaf)) {
            $newFiles += $relativePath
        } elseif ((Get-FileSha256 $destination) -ne (Get-FileSha256 (Join-Path $sourceRoot $relativePath))) {
            $changedFiles += $relativePath
        } else {
            $unchangedFiles += $relativePath
        }
    }

    Write-Output "Update plan for: $targetRoot"
    Write-Output "  installed: $($targetManifest.name) $($targetManifest.version) ($($targetManifest.coreVersion))"
    Write-Output "  incoming:  $($manifest.name) $($manifest.version) ($($manifest.coreVersion))"
    Write-Output "  new: $($newFiles.Count) / overwritten: $($changedFiles.Count) / unchanged: $($unchangedFiles.Count)"
    foreach ($relativePath in $newFiles) { Write-Output "    [new]       $relativePath" }
    foreach ($relativePath in $changedFiles) { Write-Output "    [overwrite] $relativePath" }
    Write-Output '  preserved (never written by -Update):'
    foreach ($relativePath in $activeFiles) { Write-Output "    [keep]      $relativePath" }
    if ($staleFiles.Count -gt 0) {
        $staleAction = if ($RemoveStale) { 'delete' } else { 'report only' }
        Write-Output "  stale files from the installed manifest ($staleAction):"
        foreach ($relativePath in $staleFiles) { Write-Output "    [stale]     $relativePath" }
        if (-not $RemoveStale) {
            Write-Output '  Re-run with -RemoveStale to delete them.'
        }
    }

    if (-not $PSCmdlet.ShouldProcess($targetRoot, "Update $($manifest.name) to $($manifest.version)")) {
        return
    }
} else {
    $conflicts = foreach ($relativePath in @($installFiles) + $activeFiles) {
        if (Test-Path -LiteralPath (Join-Path $targetRoot $relativePath)) {
            $relativePath
        }
    }
    if ($conflicts) {
        throw "Target files already exist; nothing was written:`n  $($conflicts -join "`n  ")`nUse -Update to refresh an existing installation."
    }

    if (-not $PSCmdlet.ShouldProcess($targetRoot, "Install $($manifest.name) $($manifest.version)")) {
        return
    }
}

foreach ($relativePath in $installFiles) {
    $source = Join-Path $sourceRoot $relativePath
    $destination = Join-Path $targetRoot $relativePath
    $destinationDirectory = Split-Path -Parent $destination
    if (-not (Test-Path -LiteralPath $destinationDirectory)) {
        New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
    }
    Copy-Item -LiteralPath $source -Destination $destination -Force
}

if ($Update -and $RemoveStale) {
    foreach ($relativePath in $staleFiles) {
        $stalePath = Join-Path $targetRoot $relativePath
        Remove-Item -LiteralPath $stalePath -Force
        # Prune directories the removed file left empty, stopping at the target root.
        $directory = Split-Path -Parent $stalePath
        while ($directory -and $directory.TrimEnd('\', '/') -ne $targetRoot) {
            if (@(Get-ChildItem -LiteralPath $directory -Force).Count -gt 0) {
                break
            }
            $parent = Split-Path -Parent $directory
            Remove-Item -LiteralPath $directory -Force
            $directory = $parent
        }
    }
}

if (-not $Update) {
    $projectId = (Split-Path -Leaf $targetRoot).ToLowerInvariant() -replace '[^a-z0-9]+', '-'
    $projectId = $projectId.Trim('-')
    if ([string]::IsNullOrWhiteSpace($projectId)) {
        $projectId = 'firmware-project'
    }

    $validationCode = "PROJECT-$(([guid]::NewGuid().ToString('N').Substring(0, 8)).ToUpperInvariant())"
    $contextCode = "CONTEXT-$(([guid]::NewGuid().ToString('N').Substring(0, 8)).ToUpperInvariant())"
    $contextRevision = "$projectId-CONTEXT-v1"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)

    $projectTemplate = Get-Content -LiteralPath (Join-Path $targetRoot '.agents\templates\project.md') -Raw -Encoding UTF8
    $projectContent = $projectTemplate.Replace('__PROJECT_ID__', $projectId)
    $projectContent = $projectContent.Replace('__REPOSITORY_NAME__', (Split-Path -Leaf $targetRoot))
    $projectContent = $projectContent.Replace('__VALIDATION_CODE__', $validationCode)
    [System.IO.File]::WriteAllText((Join-Path $targetRoot '.agents\project.md'), $projectContent, $utf8NoBom)

    $contextTemplate = Get-Content -LiteralPath (Join-Path $targetRoot '.agents\templates\context-index.md') -Raw -Encoding UTF8
    $contextContent = $contextTemplate.Replace('__PROJECT_ID__', $projectId)
    $contextContent = $contextContent.Replace('__CONTEXT_REVISION__', $contextRevision)
    $contextContent = $contextContent.Replace('__CONTEXT_CODE__', $contextCode)
    [System.IO.File]::WriteAllText((Join-Path $targetRoot '.agents\context-index.md'), $contextContent, $utf8NoBom)

    $todoTemplate = Get-Content -LiteralPath (Join-Path $targetRoot '.agents\templates\TODO.md') -Raw -Encoding UTF8
    $todoContent = $todoTemplate.Replace('__PROJECT_ID__', $projectId)
    [System.IO.File]::WriteAllText((Join-Path $targetRoot '.agents\TODO.md'), $todoContent, $utf8NoBom)
}

$verifyScript = Join-Path $targetRoot 'verify-ai-module.ps1'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $verifyScript -RootPath $targetRoot
if ($LASTEXITCODE -ne 0) {
    $phase = if ($Update) { 'Module files were updated' } else { 'Module files were copied' }
    throw "$phase, but verification failed with exit code $LASTEXITCODE."
}

if ($Update) {
    Write-Output "Update complete: $targetRoot"
    Write-Output 'The active project layer was preserved; review .agents/TODO.md for work still in progress.'
} else {
    Write-Output "Install complete: $targetRoot"
    Write-Output 'Fill .agents/project.md, .agents/context-index.md, and .agents/TODO.md before firmware work.'
}
