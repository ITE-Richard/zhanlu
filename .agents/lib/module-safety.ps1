# Shared path and installation-list checks. Keep executable sources ASCII for PS 5.1.
function ConvertTo-ModuleRelativePath([string]$Path) {
    $normalized = $Path.Replace('\', '/')
    $parts = @($normalized -split '/')
    if ([string]::IsNullOrWhiteSpace($normalized) -or
        [System.IO.Path]::IsPathRooted($normalized) -or
        $normalized -match '[\x00-\x1f<>:"|?*]' -or
        @($parts | Where-Object { $_ -in @('', '.', '..') -or $_ -match '[. ]$' }).Count -gt 0) {
        throw "Module paths must be safe relative file paths: $Path"
    }
    return $normalized
}

function Resolve-ModulePath([string]$Root, [string]$RelativePath) {
    $relative = ConvertTo-ModuleRelativePath $RelativePath
    $rootPath = [System.IO.Path]::GetFullPath($Root).TrimEnd('\', '/')
    $rootPrefix = $rootPath + [System.IO.Path]::DirectorySeparatorChar
    $fullPath = [System.IO.Path]::GetFullPath((Join-Path $rootPath $relative))
    if (-not $fullPath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Module path is outside the root: $RelativePath"
    }
    # Check every existing component, including the root, before copying or deleting.
    $probePath = $fullPath
    while ($probePath) {
        if (Test-Path -LiteralPath $probePath) {
            $item = Get-Item -LiteralPath $probePath -Force
            if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                throw "Module path traverses a reparse point: $probePath"
            }
            if ($probePath -ne $fullPath -and -not $item.PSIsContainer) {
                throw "Module parent path is not a directory: $probePath"
            }
        }
        if ($probePath -eq $rootPath) { break }
        $probePath = Split-Path -Parent $probePath
    }
    return $fullPath
}

function Get-ModulePortableFiles($Manifest) {
    $files = @($Manifest.portableFiles)
    if ($files.Count -eq 0) { throw 'module.json portableFiles must not be empty.' }
    $seen = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($file in $files) {
        $relative = ConvertTo-ModuleRelativePath ([string]$file)
        if (-not $seen.Add($relative)) { throw "Duplicate portableFiles entry: $relative" }
        $relative
    }
}

function Get-ModuleInstallFiles($Manifest) {
    $portable = @(Get-ModulePortableFiles $Manifest)
    $packageOnly = @($Manifest.packageOnlyFiles | ForEach-Object { ConvertTo-ModuleRelativePath ([string]$_) })
    foreach ($file in $packageOnly) {
        if ($portable -notcontains $file) { throw "packageOnlyFiles entry is not in portableFiles: $file" }
    }
    $portable | Where-Object { $packageOnly -notcontains $_ }
}

function Get-ModuleGitPaths($Manifest) {
    # Protect the whole local data/skill trees, plus every installed portable file.
    @('.agents/', '.claude/')
    Get-ModuleInstallFiles $Manifest | Where-Object { $_ -notmatch '^\.(agents|claude)/' }
}

function ConvertTo-GitIgnoreLiteralPath([string]$Path) {
    return [regex]::Replace($Path.Replace('\', '/'), '([*?\[\] ])', '\$1')
}
