<#
.SYNOPSIS
    Safely installs or updates the portable AI collaboration module in a target project.
.DESCRIPTION
    Install mode copies only module.json portableFiles and creates fresh project files
    from templates. It aborts before writing if any target file already exists.

    Update mode refreshes an already installed module in place. It overwrites portable
    files only and never touches the active project layer:
    .agents/project.md, .agents/context-index.md and .agents/TODO.md.
    The active project layer is copied to .agents/.backup-<timestamp> first, because the
    installed module is deliberately kept out of the target repository's version control
    and therefore has no other safety net.

    Both modes keep the module out of the target repository by writing an exclusion block
    to .git/info/exclude. The target's own .gitignore is never created or modified, so the
    module never becomes visible in the target project's history. When the kit directory
    itself sits inside the target project - the usual result of cloning the module into the
    project it serves - that directory is excluded as well.
.PARAMETER TargetPath
    Root directory of the target project.
.PARAMETER Update
    Refresh an existing installation instead of creating a new one.
.PARAMETER RemoveStale
    Update mode only. Delete files that the previously installed manifest listed but the
    current manifest no longer contains. Without this switch such files are only reported.
.EXAMPLE
    .\setup-zhanlu.ps1 -TargetPath D:\work\my-firmware
.EXAMPLE
    .\setup-zhanlu.ps1 -TargetPath D:\work\my-firmware -Update -WhatIf
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

# Cloning the module into the project it will serve leaves the clone inside the target
# work tree, where the target repository would otherwise see it as an untracked embedded
# repository. Its location is derived from the script's own path rather than guessed, so
# it can be excluded alongside the files the installer writes. A kit that lives outside
# the target yields nothing here and needs no rule.
$sourceInsideTarget = ''
$targetRootWithSeparator = $targetRoot + [System.IO.Path]::DirectorySeparatorChar
if ($resolvedSourceRoot.StartsWith($targetRootWithSeparator, [System.StringComparison]::OrdinalIgnoreCase)) {
    $sourceInsideTarget = $resolvedSourceRoot.Substring($targetRootWithSeparator.Length).Replace('\', '/') + '/'
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

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# Editor settings are generated from templates the first time they are missing. They are
# never part of the conflict check and never overwritten, so a target that already has its
# own .vscode/settings.json keeps it and the install still succeeds.
$generateOnce = @(
    @{ Template = '.agents/templates/vscode-settings.json'; Destination = '.vscode/settings.json' },
    @{ Template = '.agents/templates/workspace.code-workspace'; Destination = (Split-Path -Leaf $targetRoot) + '.code-workspace' }
)

# Paths that must never be tracked by the target repository.
$moduleGitPaths = @(
    '.agents/',
    '.claude/',
    'AGENTS.md',
    'CLAUDE.md',
    'GEMINI.md',
    'pack.ps1',
    'setup-zhanlu.ps1',
    'verify-zhanlu.ps1',
    'clean-backups.ps1'
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

    # The installed module is not in version control, so an update has no git safety net.
    $backupDirectory = Join-Path $targetRoot ('.agents\.backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
    New-Item -ItemType Directory -Path $backupDirectory -Force | Out-Null
    foreach ($relativePath in $activeFiles) {
        Copy-Item -LiteralPath (Join-Path $targetRoot $relativePath) `
            -Destination (Join-Path $backupDirectory (Split-Path -Leaf $relativePath)) -Force
    }
    Write-Output "Active project layer backed up to: $backupDirectory"
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

# The installed copy is a firmware project, not the kit source. Patching the value
# textually keeps the manifest's original formatting and non-ASCII text readable.
$targetManifestFile = Join-Path $targetRoot '.agents\module.json'
$manifestText = [System.IO.File]::ReadAllText($targetManifestFile)
$patchedManifestText = [regex]::Replace($manifestText, '"projectKind"\s*:\s*"[^"]*"', '"projectKind": "firmware"')
if ($patchedManifestText -ne $manifestText) {
    [System.IO.File]::WriteAllText($targetManifestFile, $patchedManifestText, $utf8NoBom)
}

$generatedFiles = @()
foreach ($entry in $generateOnce) {
    $destination = Join-Path $targetRoot $entry.Destination
    if (Test-Path -LiteralPath $destination) {
        Write-Output "Editor settings already present, left untouched: $($entry.Destination)"
        continue
    }
    $destinationDirectory = Split-Path -Parent $destination
    if (-not (Test-Path -LiteralPath $destinationDirectory)) {
        New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
    }
    Copy-Item -LiteralPath (Join-Path $targetRoot $entry.Template) -Destination $destination -Force
    Write-Output "Editor settings created: $($entry.Destination)"
    $generatedFiles += $entry.Destination
}

$excludeEntries = @($moduleGitPaths) + @($generatedFiles)
if ($sourceInsideTarget) {
    $excludeEntries += $sourceInsideTarget
}
$gitCommand = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitCommand) {
    Write-Warning 'git was not found; the module was NOT excluded from version control.'
    Write-Output  'Add these lines to <target>/.git/info/exclude manually:'
    foreach ($entry in $excludeEntries) { Write-Output "  /$entry" }
} else {
    Push-Location -LiteralPath $targetRoot
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
        if ($LASTEXITCODE -ne 0 -or $insideWorkTree -ne 'true') {
            Write-Output 'Target is not a git repository; version-control exclusion skipped.'
        } else {
            $gitCommonDir = (& $gitCommand.Source rev-parse --git-common-dir).Trim()
            if (-not [System.IO.Path]::IsPathRooted($gitCommonDir)) {
                $gitCommonDir = Join-Path $targetRoot $gitCommonDir
            }
            $pathPrefix = (& $gitCommand.Source rev-parse --show-prefix)
            if ($null -eq $pathPrefix) { $pathPrefix = '' } else { $pathPrefix = $pathPrefix.Trim() }
            if ($pathPrefix) {
                Write-Warning "Target is a subdirectory of a repository; patterns are prefixed with $pathPrefix"
            }

            $excludeFile = Join-Path $gitCommonDir 'info\exclude'
            $excludeDirectory = Split-Path -Parent $excludeFile
            if (-not (Test-Path -LiteralPath $excludeDirectory)) {
                New-Item -ItemType Directory -Path $excludeDirectory -Force | Out-Null
            }

            # Markers follow module.json name, so renaming the module needs no script edit.
            $markerNames = @([string]$manifest.name)
            if ($manifest.PSObject.Properties['legacyMarkerNames']) {
                $markerNames += @($manifest.legacyMarkerNames | ForEach-Object { [string]$_ })
            }
            $beginMarker = "# >>> $($markerNames[0]) >>>"
            $endMarker = "# <<< $($markerNames[0]) <<<"
            $existing = if (Test-Path -LiteralPath $excludeFile) {
                [System.IO.File]::ReadAllText($excludeFile)
            } else {
                ''
            }
            # Removing the current block and every retired one keeps repeated installs,
            # updates and module renames idempotent instead of stacking stale blocks.
            # Entries already exclusion-protected are carried over first, so an update
            # never un-ignores a generate-once file that this installer created earlier.
            $preservedEntries = @()
            foreach ($markerName in $markerNames) {
                $blockPattern = [regex]::Escape("# >>> $markerName >>>") + '.*?' + [regex]::Escape("# <<< $markerName <<<") + '\r?\n?'
                foreach ($match in [regex]::Matches($existing, $blockPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)) {
                    $preservedEntries += @($match.Value -split '\r?\n' | Where-Object { $_.StartsWith('/') })
                }
                $existing = [regex]::Replace($existing, $blockPattern, '', [System.Text.RegularExpressions.RegexOptions]::Singleline)
            }
            # Carried-over entries name files this installer wrote in an earlier run. One
            # that no longer exists was renamed or dropped from the manifest, so keeping
            # its rule would leave the block growing dead lines at every module rename.
            $preservedEntries = @($preservedEntries | Where-Object {
                $candidate = $_.TrimStart('/')
                if ($pathPrefix -and $candidate.StartsWith($pathPrefix)) {
                    $candidate = $candidate.Substring($pathPrefix.Length)
                }
                Test-Path -LiteralPath (Join-Path $targetRoot $candidate.TrimEnd('/'))
            })
            if ($existing.Length -gt 0 -and -not $existing.EndsWith("`n")) {
                $existing += "`n"
            }
            $patterns = @($excludeEntries | ForEach-Object { '/' + $pathPrefix + $_ })
            $patterns += @($preservedEntries | Select-Object -Unique | Where-Object { $patterns -notcontains $_ })
            $blockLines = @($beginMarker) + $patterns + @($endMarker)
            [System.IO.File]::WriteAllText($excludeFile, $existing + ($blockLines -join "`n") + "`n", $utf8NoBom)
            Write-Output "Module excluded from version control via: $excludeFile"
            if ($sourceInsideTarget) {
                Write-Output "Module source directory is inside the target and was excluded too: /$pathPrefix$sourceInsideTarget"
            }
        }
    } finally {
        Pop-Location
    }
}

$verifyScript = Join-Path $targetRoot 'verify-zhanlu.ps1'
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
    Write-Output 'The module is excluded from version control, so .agents/ is not covered by git.'
    Write-Output 'Include it in your own backup, and avoid running "git clean -x" in this project.'
}
