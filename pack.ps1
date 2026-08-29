<#
.SYNOPSIS
    Builds the portable AI collaboration module archive from module.json.
#>
[CmdletBinding()]
param(
    [string]$OutDir = 'dist'
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$manifestPath = Join-Path $root '.agents\module.json'
$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$portableFiles = @($manifest.portableFiles)

if ($portableFiles.Count -eq 0) {
    throw 'module.json portableFiles must not be empty.'
}
$uniquePortableFiles = @($portableFiles | Select-Object -Unique)
if ($uniquePortableFiles.Count -ne $portableFiles.Count) {
    throw 'module.json portableFiles contains duplicate entries.'
}

foreach ($relativePath in $portableFiles) {
    if ([System.IO.Path]::IsPathRooted($relativePath) -or ($relativePath -split '[/\\]') -contains '..') {
        throw "portableFiles must use safe relative paths: $relativePath"
    }
    if (-not (Test-Path -LiteralPath (Join-Path $root $relativePath) -PathType Leaf)) {
        throw "Portable file is missing: $relativePath"
    }
}

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'verify-ai-module.ps1') -RootPath $root -PackageSource
if ($LASTEXITCODE -ne 0) {
    throw "Module validation failed with exit code $LASTEXITCODE. Packaging stopped."
}

$sevenZip = @(
    'C:\Program Files\7-Zip\7z.exe',
    'C:\Program Files (x86)\7-Zip\7z.exe'
) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $sevenZip) {
    $command = Get-Command 7z.exe -ErrorAction SilentlyContinue
    if ($command) {
        $sevenZip = $command.Source
    }
}
if (-not $sevenZip) {
    throw '7z.exe was not found. Install 7-Zip or add it to PATH.'
}

$stage = Join-Path $env:TEMP ("firmware-ai-kit-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $stage | Out-Null

try {
    foreach ($relativePath in $portableFiles) {
        $source = Join-Path $root $relativePath
        $destination = Join-Path $stage $relativePath
        $destinationDirectory = Split-Path -Parent $destination
        if (-not (Test-Path -LiteralPath $destinationDirectory)) {
            New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
        }
        Copy-Item -LiteralPath $source -Destination $destination
    }

    # -Name yields paths relative to the staging root. Do not derive them by trimming
    # FullName: TEMP can be an 8.3 short path while FullName is expanded, and the two
    # lengths then disagree.
    $stageFiles = @(Get-ChildItem -LiteralPath $stage -Recurse -File -Name | ForEach-Object {
        $_.Replace('\', '/')
    })
    $difference = Compare-Object -ReferenceObject ($portableFiles | Sort-Object) -DifferenceObject ($stageFiles | Sort-Object)
    if ($difference) {
        throw "Staging contents differ from portableFiles:`n$($difference | Out-String)"
    }

    $forbiddenActiveFiles = @(
        '.agents/project.md',
        '.agents/context-index.md',
        '.agents/TODO.md'
    )
    foreach ($relativePath in $forbiddenActiveFiles) {
        if (Test-Path -LiteralPath (Join-Path $stage $relativePath)) {
            throw "Staging contains an active project file: $relativePath"
        }
    }

    $leaks = Get-ChildItem -LiteralPath $stage -Recurse -File | Where-Object {
        $_.Extension -match '^\.(pdf|bin|hex|elf|obj|exe|7z|zip|rar|map|o|a|lib|dll|img|rom|srec)$'
    }
    if ($leaks) {
        throw "Staging contains forbidden file types:`n  $($leaks.FullName -join "`n  ")"
    }

    $outDirectory = if ([System.IO.Path]::IsPathRooted($OutDir)) { $OutDir } else { Join-Path $root $OutDir }
    if (-not (Test-Path -LiteralPath $outDirectory)) {
        New-Item -ItemType Directory -Path $outDirectory -Force | Out-Null
    }
    $outDirectory = (Resolve-Path -LiteralPath $outDirectory).Path
    $archive = Join-Path $outDirectory ([string]$manifest.archiveName)
    if (Test-Path -LiteralPath $archive) {
        Remove-Item -LiteralPath $archive -Force
    }

    Push-Location $stage
    try {
        & $sevenZip a -t7z -mx=9 $archive '.\*' | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "7z packaging failed with exit code $LASTEXITCODE."
        }
    } finally {
        Pop-Location
    }

    & $sevenZip t $archive | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "7z integrity test failed with exit code $LASTEXITCODE."
    }

    Write-Output "Archive created: $archive"
    Write-Output "Size: $((Get-Item -LiteralPath $archive).Length) bytes"
    Write-Output "File count: $($portableFiles.Count)"

    # Older archives stay on disk so nothing is destroyed here, but they are easy to
    # hand over by mistake. Name them so the maintainer can clear them deliberately.
    $otherArchives = @(Get-ChildItem -LiteralPath $outDirectory -Filter '*.7z' -File |
        Where-Object { $_.Name -ne [string]$manifest.archiveName })
    if ($otherArchives.Count -gt 0) {
        Write-Output "Warning: $($otherArchives.Count) older archive(s) remain in $outDirectory."
        foreach ($item in $otherArchives) { Write-Output "  [old] $($item.Name)" }
        Write-Output '  Delete them so only the current package can be distributed.'
    }
} finally {
    if (Test-Path -LiteralPath $stage) {
        Remove-Item -LiteralPath $stage -Recurse -Force
    }
}
