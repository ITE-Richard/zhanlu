<#
.SYNOPSIS
    Safely installs the portable AI collaboration module into a target project.
.DESCRIPTION
    Copies only module.json portableFiles and creates fresh project files from templates.
    The script aborts before writing if any target file already exists.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetPath
)

$ErrorActionPreference = 'Stop'
$sourceRoot = $PSScriptRoot
$manifestPath = Join-Path $sourceRoot '.agents\module.json'
$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json

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

$conflicts = foreach ($relativePath in @($installFiles) + $activeFiles) {
    if (Test-Path -LiteralPath (Join-Path $targetRoot $relativePath)) {
        $relativePath
    }
}
if ($conflicts) {
    throw "Target files already exist; nothing was written:`n  $($conflicts -join "`n  ")"
}

if (-not $PSCmdlet.ShouldProcess($targetRoot, "Install $($manifest.name) $($manifest.version)")) {
    return
}

foreach ($relativePath in $installFiles) {
    $source = Join-Path $sourceRoot $relativePath
    $destination = Join-Path $targetRoot $relativePath
    $destinationDirectory = Split-Path -Parent $destination
    if (-not (Test-Path -LiteralPath $destinationDirectory)) {
        New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
    }
    Copy-Item -LiteralPath $source -Destination $destination
}

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

$verifyScript = Join-Path $targetRoot 'verify-ai-module.ps1'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $verifyScript -RootPath $targetRoot
if ($LASTEXITCODE -ne 0) {
    throw "Module files were copied, but verification failed with exit code $LASTEXITCODE."
}

Write-Output "Install complete: $targetRoot"
Write-Output 'Fill .agents/project.md, .agents/context-index.md, and .agents/TODO.md before firmware work.'
