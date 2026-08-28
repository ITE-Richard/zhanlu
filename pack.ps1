<#
.SYNOPSIS
    產生跨專案可攜的 EC AI 移植套件 7z。
.DESCRIPTION
    以白名單方式打包「通用層」，並在壓縮前檢查暫存區沒有任何專案層資料。
    可攜套件不得包含：.agents/project.md、.agents/TODO.md、references/ 內的 SPEC、
    reference-projects/ 內的 golden reference、firmware/binary/build output。
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\pack.ps1
#>
[CmdletBinding()]
param(
    [string]$Version = 'v3',
    [string]$OutDir  = 'dist'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $root

# --- 白名單：只有這些檔案會進入可攜套件 ---
$include = @(
    'AGENTS.md',
    'CLAUDE.md',
    'GEMINI.md',
    'pack.ps1',
    '.agents/README.md',
    '.agents/templates/project.md',
    '.agents/templates/TODO.md',
    '.agents/skills/ite-ec-porting/SKILL.md',
    '.agents/skills/ite-ec-porting/references/.gitkeep',
    '.agents/reference-projects/.gitkeep',
    '.claude/skills/ite-ec-porting/SKILL.md'
)

# --- 黑名單：出現在暫存區即中止打包 ---
$forbidden = @(
    '.agents/project.md',
    '.agents/TODO.md'
)

$missing = @()
foreach ($f in $include) {
    if (-not (Test-Path -LiteralPath $f)) { $missing += $f }
}
if ($missing.Count -gt 0) {
    Write-Error ("缺少必要檔案，打包中止：`n  " + ($missing -join "`n  "))
}

$stage = Join-Path $env:TEMP ("ec-ai-kit-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $stage -Force | Out-Null

try {
    foreach ($f in $include) {
        $dst = Join-Path $stage $f
        $dstDir = Split-Path -Parent $dst
        if (-not (Test-Path -LiteralPath $dstDir)) {
            New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
        }
        Copy-Item -LiteralPath $f -Destination $dst
    }

    # 封裝邊界自檢
    foreach ($f in $forbidden) {
        if (Test-Path -LiteralPath (Join-Path $stage $f)) {
            Write-Error "暫存區出現專案層檔案 $f，打包中止。"
        }
    }
    $leak = Get-ChildItem -Path $stage -Recurse -File |
            Where-Object { $_.Extension -match '^\.(pdf|bin|hex|elf|obj|exe|7z|zip)$' }
    if ($leak) {
        Write-Error ("暫存區出現不該封裝的檔案：`n  " + (($leak | ForEach-Object { $_.FullName }) -join "`n  "))
    }

    if (-not (Test-Path -LiteralPath $OutDir)) {
        New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
    }
    $out = Join-Path (Resolve-Path $OutDir) ("ite-ec-ai-porting-kit-" + $Version + ".7z")
    if (Test-Path -LiteralPath $out) { Remove-Item -LiteralPath $out -Force }

    $sevenZip = @(
        'C:\Program Files\7-Zip\7z.exe',
        'C:\Program Files (x86)\7-Zip\7z.exe'
    ) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if (-not $sevenZip) {
        $cmd = Get-Command 7z.exe -ErrorAction SilentlyContinue
        if ($cmd) { $sevenZip = $cmd.Source }
    }
    if (-not $sevenZip) {
        Write-Error '找不到 7z.exe，請安裝 7-Zip 或將其加入 PATH。'
    }

    Push-Location $stage
    try {
        & $sevenZip a -t7z -mx=9 -r $out '.\*' | Out-Null
        if ($LASTEXITCODE -ne 0) { Write-Error "7z 打包失敗，exit code $LASTEXITCODE。" }
    } finally {
        Pop-Location
    }

    Write-Output ""
    Write-Output "打包完成：$out"
    Write-Output ("大小：{0:N0} bytes" -f (Get-Item -LiteralPath $out).Length)
    Write-Output "封裝內容："
    & $sevenZip l $out
} finally {
    if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Recurse -Force }
}
