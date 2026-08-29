# Embedded Firmware AI Collaboration Kit

本模組把同一套專案規則、專案事實、資料索引與工作流程提供給 Claude Code、Codex 與 Antigravity。它不限定 EC，也適用於 PD、lighting、keyboard controller 及其他嵌入式韌體；工作類型可為 bug fix、程式碼整合、韌體移植或硬體 bring-up。

## 單一真相來源

| 內容 | 唯一來源 | 是否隨套件複製 |
|---|---|---|
| 跨專案共同原則 | `AGENTS.md` | 是 |
| 套件清單與版本 | `.agents/module.json` | 是 |
| 目標專案事實 | `.agents/project.md` | 否，安裝時由範本建立 |
| 資料位置與閱讀順序 | `.agents/context-index.md` | 否，安裝時由範本建立 |
| 工作項目與驗證狀態 | `.agents/TODO.md` | 否，安裝時由範本建立 |
| 通用工作方法 | `.agents/skills/*/SKILL.md` | 是 |
| Claude skill 載入器 | `.claude/skills/*/SKILL.md` | 是，只指向通用 skill |
| SPEC、schematic、log 等 | `.agents/resources/` | 只複製 `.gitignore`，內容每案掛載 |
| golden reference | `.agents/reference-projects/` | 只複製 `.gitignore`，內容每案掛載或登記外部唯讀路徑 |

`CLAUDE.md`、`GEMINI.md` 與 `.agents/rules/project-context.md` 只負責導向上述共同來源，不複製規則內文。Codex 直接從 `AGENTS.md` 進入；不同工具的自動載入能力若有差異，仍以 `AGENTS.md` 的 session 啟動確認為共同檢查點。

## 目錄結構

```text
AGENTS.md
CLAUDE.md
GEMINI.md
README.md                 # 壓縮套件入口說明；不複製到目標專案根目錄
pack.ps1
setup-ai-module.ps1
verify-ai-module.ps1
.agents/
  module.json
  README.md
  project.md               # 本專案作用中設定，不進套件
  context-index.md         # 本專案作用中索引，不進套件
  TODO.md                  # 本專案作用中工作狀態，不進套件
  templates/
  rules/
  skills/
  resources/               # 專案專屬資料掛載點；自帶 .gitignore
  reference-projects/      # 專案專屬參考專案掛載點；自帶 .gitignore
.claude/skills/             # Claude 輕量載入器
```

## 套用到任意目標專案

建議先把 7z 解壓到暫存資料夾，再從暫存資料夾執行安裝器；不要直接覆蓋目標 repository。

```powershell
7z x .\firmware-ai-collaboration-kit-v4.0.1.7z -o'.\firmware-ai-kit-v4.0.1'
powershell -ExecutionPolicy Bypass -File .\firmware-ai-kit-v4.0.1\setup-ai-module.ps1 `
  -TargetPath 'D:\path\to\target-project'
```

安裝器會先完成全量衝突檢查，任何目標檔案已存在時都會中止，不會局部覆蓋。成功後會：

1. 依 `.agents/module.json` 白名單複製通用檔案；`packageOnlyFiles` 只留在壓縮套件，不複製到目標專案。
2. 由範本建立新的 `.agents/project.md`、`.agents/context-index.md` 與 `.agents/TODO.md`。
3. 寫入目標資料夾名稱及新的驗證碼。
4. 執行 `verify-ai-module.ps1`。

接著由維護者填寫三份作用中文件：

- `project.md`：controller、SoC、架構、建置方式、硬體限制與驗證能力。
- `context-index.md`：程式碼、SPEC、schematic、log、工具、參考專案的位置與閱讀順序。
- `TODO.md`：當前 work item、完成條件、驗證證據與未決風險。

無法由 repository 或文件查得的板級事實必須向使用者確認，不可由 AI 猜測。

## 升級已安裝的模組

`setup-ai-module.ps1` 的預設模式只做全新安裝，任何目標檔案已存在就會中止。要把既有專案更新到新版模組，改用 `-Update`：

```powershell
# 先看計畫，不寫入任何檔案
powershell -ExecutionPolicy Bypass -File .\setup-ai-module.ps1 `
  -TargetPath 'D:\path\to\target-project' -Update -WhatIf

# 確認後實際升級
powershell -ExecutionPolicy Bypass -File .\setup-ai-module.ps1 `
  -TargetPath 'D:\path\to\target-project' -Update
```

`-Update` 的邊界：

- 只覆寫 `portableFiles`，並列出哪些是新增、哪些會被覆寫、哪些內容相同。
- 絕不寫入 `.agents/project.md`、`.agents/context-index.md` 與 `.agents/TODO.md`；專案事實、資料索引與工作進度完整保留。
- 目標沒有 `.agents/module.json`，或三份作用中文件不齊全時直接拒絕，避免把半套模組蓋成看似完整。
- 會比對目標已安裝的舊 `module.json`，列出新版白名單已移除的檔案；預設只回報，加上 `-RemoveStale` 才刪除。
- 升級結束會自動執行 `verify-ai-module.ps1`。

若曾在目標專案手改過 `AGENTS.md` 或任一 skill，升級會覆蓋這些修改。共用規則的修改應該回到母版，不要留在單一專案。

## 資料邊界與版控保護

`.agents/resources/` 與 `.agents/reference-projects/` 各自帶一份 `.gitignore`，內容為：

```gitignore
*
!.gitignore
```

安裝時這兩份 `.gitignore` 會一併複製到目標專案，所以掛載點內的 SPEC、schematic、BOM、log、waveform、binary 與 golden reference 預設不會進版控，也不需要修改目標專案的根 `.gitignore`。

需要把某份證據提交到目標 repository 時，於對應掛載點的 `.gitignore` 明確加上例外，例如：

```gitignore
*
!.gitignore
!issue-1234-repro.log
```

不要用 `git add -f` 繞過保護；那會讓後續維護者看不出這份資料是刻意提交的。

## 工作路由

每個工作先選一個 task skill，再視需要加上一個 controller skill：

| 類型 | Skill |
|---|---|
| Bug 修正 | `bug-fix` |
| 程式碼／分支／供應商元件整合 | `code-integration` |
| 跨晶片或跨架構移植 | `firmware-porting` |
| 新板或新硬體啟動 | `hardware-bringup` |
| EC／PD／lighting／keyboard domain | 對應的 `*-controller` |
| ITE EC 特殊移植 | `ite-ec-porting`，搭配 `firmware-porting` |

skill 是方法，不承載專案事實；所有具體型號、路徑、register 依據與驗證結果仍回到專案層文件。

## 驗證與打包

驗證目前資料夾：

```powershell
powershell -ExecutionPolicy Bypass -File .\verify-ai-module.ps1 -PackageSource
```

建立可攜套件：

```powershell
powershell -ExecutionPolicy Bypass -File .\pack.ps1
```

`pack.ps1` 只接受 `.agents/module.json` 的 `portableFiles` 白名單，打包前後都會驗證，並以 `7z t` 測試封裝。作用中的 `project.md`、`context-index.md`、`TODO.md`、SPEC、golden reference、binary 與 build output 都不會進入套件。

## 維護原則

- 共同規則只改 `AGENTS.md`；不要在入口檔重複規則。
- 新增或改名 skill 時，同步更新 canonical skill、Claude loader 與 `module.json`。
- 新增可攜檔案只改 `module.json`，不要在 `pack.ps1` 再維護第二份清單。
- 修改後先跑驗證，再重建套件；不要用 `7z u` 更新舊封裝。
- 專案層資料可提交到目標專案，但不得回灌到通用 7z。
