<#
.SYNOPSIS
    Removes the project-layer backups that setup-zhanlu.ps1 -Update leaves behind.
.DESCRIPTION
    Every -Update copies .agents/project.md, .agents/context-index.md and .agents/TODO.md
    to .agents/.backup-<timestamp> before writing. Those copies are never cleaned up on
    their own, because the installed module is deliberately kept out of the target
    repository's version control and they are the only recovery point for a bad upgrade.

    This script deletes them once you have confirmed the upgrade is good. It only ever
    touches directories named .backup-* directly under .agents, and it refuses to run
    anywhere that does not look like a zhanlu installation.

    The backups are the sole recovery point for the active project layer, so the script
    confirms before deleting. Use -Confirm:$false to run it unattended, -WhatIf to see the
    plan without deleting, and -KeepLatest to retain the newest backups.
.PARAMETER TargetPath
    Root directory of the project to clean. Defaults to the directory holding this script,
    which is the project root for an installed module.
.PARAMETER KeepLatest
    Number of newest backups to keep. Defaults to 0, which removes all of them.
.EXAMPLE
    .\clean-backups.ps1 -WhatIf
.EXAMPLE
    .\clean-backups.ps1 -KeepLatest 1
.EXAMPLE
    .\clean-backups.ps1 -Confirm:$false
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [string]$TargetPath,

    [ValidateRange(0, 1000)]
    [int]$KeepLatest = 0
)

$ErrorActionPreference = 'Stop'

# Windows PowerShell leaves $PSScriptRoot empty while binding parameter defaults, so the
# fallback has to happen in the body or "powershell.exe -File" passes an empty path.
if ([string]::IsNullOrWhiteSpace($TargetPath)) {
    $TargetPath = $PSScriptRoot
}

if (-not (Test-Path -LiteralPath $TargetPath -PathType Container)) {
    throw "Target project directory does not exist: $TargetPath"
}
$targetRoot = (Resolve-Path -LiteralPath $TargetPath).Path.TrimEnd('\', '/')

# Refusing outside an installation keeps a mistyped path from walking an unrelated tree.
$agentsDirectory = Join-Path $targetRoot '.agents'
if (-not (Test-Path -LiteralPath (Join-Path $agentsDirectory 'module.json') -PathType Leaf)) {
    throw "No installed module found at $targetRoot (.agents/module.json is missing)."
}

# Timestamps are yyyyMMdd-HHmmss, so name order is chronological order.
$backups = @(Get-ChildItem -LiteralPath $agentsDirectory -Directory -Force -Filter '.backup-*' |
    Sort-Object Name -Descending)

if ($backups.Count -eq 0) {
    Write-Output "No project-layer backups found in $agentsDirectory"
    exit 0
}

$keep = @()
$remove = @($backups)
if ($KeepLatest -gt 0) {
    $keep = @($backups | Select-Object -First $KeepLatest)
    $remove = @($backups | Select-Object -Skip $KeepLatest)
}

Write-Output "Project-layer backups in $agentsDirectory"
foreach ($backup in $backups) {
    $files = @(Get-ChildItem -LiteralPath $backup.FullName -File -Recurse -Force)
    $bytes = ($files | Measure-Object -Property Length -Sum).Sum
    if ($null -eq $bytes) { $bytes = 0 }
    $action = if ($keep -contains $backup) { 'keep  ' } else { 'delete' }
    Write-Output ("  [{0}] {1}  {2} file(s), {3} bytes" -f $action, $backup.Name, $files.Count, $bytes)
}

if ($remove.Count -eq 0) {
    Write-Output "Nothing to delete; $($keep.Count) backup(s) kept."
    exit 0
}

$removed = 0
foreach ($backup in $remove) {
    # A reparse point would let a recursive delete escape .agents entirely.
    if ($backup.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        Write-Warning "Skipped reparse point, delete it yourself if intended: $($backup.FullName)"
        continue
    }
    if ($PSCmdlet.ShouldProcess($backup.FullName, 'Delete project-layer backup')) {
        Remove-Item -LiteralPath $backup.FullName -Recurse -Force
        Write-Output "Deleted: $($backup.Name)"
        $removed++
    }
}

Write-Output "Backups deleted: $removed / kept: $($backups.Count - $removed)"
