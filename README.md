# Embedded Firmware AI Collaboration Kit v4.1.0

這是一套可移植到嵌入式韌體 repository 的 AI 協作模組，讓 Claude Code、Codex 與 Antigravity 共用同一份專案規則、專案資料、工作追蹤與 skills。

支援的工作包含 Bug 修正、程式碼整合、跨晶片／跨架構移植、硬體 bring-up、架構設計、多專案收斂與程式碼審查；領域涵蓋 EC、USB PD、lighting、keyboard controller，以及 ITE EC 專門移植。

## 前置需求

- Windows 與 Windows PowerShell 5.1 以上；三支腳本都以 `powershell.exe` 執行。
- 7-Zip：解壓本套件需要；要重新打包 (`pack.ps1`) 時同樣需要 `7z.exe` 在 PATH 或安裝於預設路徑。
- 目標專案建議已在 Git 版控下，安裝與升級改了什麼可以直接用 `git status` 看出來。
- 安裝完成後若 VSCode 已經開著目標專案，請重新載入視窗，工具才會重新掃描規則與 skill。

## 最短安裝流程

不要直接把壓縮檔覆蓋解壓到目標 repository。請先解壓到暫存或相鄰資料夾，再執行安裝器；安裝器會在寫入前檢查所有衝突。

```powershell
$archive = 'D:\transfer\firmware-ai-collaboration-kit-v4.1.0.7z'
$kitDir = 'D:\transfer\firmware-ai-kit-v4.1.0'
$target = 'D:\work\target-firmware-project'

7z x $archive "-o$kitDir"
powershell -ExecutionPolicy Bypass -File "$kitDir\setup-ai-module.ps1" `
  -TargetPath $target
```

安裝成功時會顯示 `Install complete`，並自動完成結構驗證。若目標專案已存在任何將安裝的 AI 規則或 skill，安裝器會在寫入前停止，不會局部覆蓋。

## 安裝後必做

在目標專案中填寫：

1. `.agents/project.md`：controller、SoC、架構、建置方式、硬體限制與可用驗證方式。
2. `.agents/context-index.md`：程式碼、SPEC、schematic、log、工具及唯讀參考專案的位置與權威性。
3. `.agents/TODO.md`：目前 work item、範圍、相依、完成條件、風險及驗證證據。

接著以 VSCode 開啟目標 repository，啟動 Claude Code、Codex 或 Antigravity，並輸入「工作開始」。Agent 應先回報：

```text
啟動確認：core=<版本> / project=<專案識別> / context=<索引版次> / work-item=<ID 或 none> / missing=<none 或清單>
```

若缺少必要檔案或引用失效，Agent 應停止實作並指出缺口。

## 三個工具如何載入

| 工具 | 專案入口 | Skill 位置 |
|---|---|---|
| Claude Code | `CLAUDE.md` | `.claude/skills/` 載入器導向 `.agents/skills/` |
| Codex | `AGENTS.md` | `.agents/skills/` |
| Antigravity | `GEMINI.md`、`.agents/rules/project-context.md` | `.agents/skills/` |

三個入口都導向同一份 `AGENTS.md`、`.agents/project.md`、`.agents/context-index.md` 與 `.agents/TODO.md`，避免不同 Agent 各自維護互相矛盾的規則。

## 內建技能

每個 work item 先選一個任務技能，再視需要加上一個或多個領域技能。

| 技能 | 用途 |
|---|---|
| `bug-fix` | 重現、根因定位、最小修正與 regression |
| `code-integration` | upstream、vendor SDK、patch、branch 或另一 repository 的整合 |
| `firmware-porting` | 跨晶片、跨板級、跨框架的功能移植與行為對等驗證 |
| `hardware-bringup` | 新晶片或新板的最小啟動路徑與逐步啟用 |
| `architecture-design` | 分層、模組邊界、介面契約、硬體抽象與多專案收斂 |
| `firmware-code-review` | patch、移植成果與整合結果的審查 |
| `ec-controller` | power、host interface、battery、charger、thermal、fan、ACPI |
| `pd-controller` | Type-C attach、PDO、contract、VDM 與保護流程 |
| `lighting-controller` | PWM、constant-current、pattern、功耗與熱限制 |
| `keyboard-controller` | matrix scan、debounce、ghosting、hotkey、host protocol、wake |
| `ite-ec-porting` | ITE EC 跨晶片或 legacy／Zephyr 跨框架移植，搭配 `firmware-porting` |

常見組合：多個既有專案要收斂時，先用 `architecture-design` 決定共用基底與差異層，再用 `code-integration` 執行搬移。

審查技能刻意命名為 `firmware-code-review` 而不是 `code-review`，避免與 Claude Code 內建的同名 skill 互相遮蔽。

## 升級既有專案

已經裝過本模組的專案，不要重新執行乾淨安裝，改用 `-Update`：

```powershell
# 先看計畫，不寫入任何檔案
powershell -ExecutionPolicy Bypass -File "$kitDir\setup-ai-module.ps1" `
  -TargetPath $target -Update -WhatIf

# 確認後實際升級
powershell -ExecutionPolicy Bypass -File "$kitDir\setup-ai-module.ps1" `
  -TargetPath $target -Update
```

`-Update` 只覆寫共用檔案，並列出哪些是新增、哪些會被覆寫、哪些內容相同。`.agents/project.md`、`.agents/context-index.md` 與 `.agents/TODO.md` 絕不會被寫入，專案事實、資料索引與工作進度完整保留。

新版白名單移除的檔案會列為 stale，預設只回報；確認後加上 `-RemoveStale` 才刪除，並一併清掉變空的目錄。

若曾在目標專案手改過 `AGENTS.md` 或任一 skill，升級會覆蓋這些修改。共用規則的修改應該回到母版，不要留在單一專案。

## 一台機器多個專案

每個 repository 各裝一份，不要多個專案共用同一份 `.agents/`。共用檔案（核心規則與 skills）在各專案內容相同，差異只在專案層三份文件，這樣每個專案的事實、索引與工作進度才不會互相污染。

換到新版模組時，對每個專案各跑一次 `-Update` 即可，專案層不受影響。

## 套件包含內容

- `AGENTS.md`、`CLAUDE.md`、`GEMINI.md`：三工具入口與共用核心。
- `.agents/module.json`：版本、skills 與可攜檔案白名單。
- `.agents/templates/`：新專案的 project、context-index 與 TODO 範本。
- `.agents/rules/`：Antigravity workspace rule。
- `.agents/skills/`：11 個 canonical skills。
- `.claude/skills/`：11 個 Claude skill 載入器。
- `.agents/resources/`、`.agents/reference-projects/`：資料掛載點，各自帶一份 `.gitignore`。
- `setup-ai-module.ps1`：安全安裝、專案層初始化與 `-Update` 升級。
- `verify-ai-module.ps1`：結構、引用與 skill 驗證。
- `pack.ps1`：由白名單重建 7z 套件。
- `.agents/README.md`：安裝後保留在目標專案內的完整維護說明。

本檔 `README.md` 只提供壓縮套件的第一層使用說明，不會覆蓋或複製成目標 repository 的根目錄 README。

## 可以交由 AI 協助的內容

- 掃描 repository，整理可確認的 controller、架構、build 與 test 資訊。
- 建立或拆分 work item、相依關係與驗證清單。
- 依任務選擇 Bug fix、整合、移植、bring-up、架構設計、審查及控制器領域 skill。
- 對照來源與目標程式碼，列出差異、風險與待補證據。

AI 不得猜測 pin、polarity、register value、timing、reset sequence、power rail ordering 或未提供的客戶需求。這些資料若無法從權威文件查得，必須由專案負責人補充。

## 不會打包的專案資料

母版作用中的 `.agents/project.md`、`.agents/context-index.md`、`.agents/TODO.md`，以及 SPEC、schematic、BOM、log、binary、build output、golden reference 與客戶資料不會進入套件。每個目標專案會由範本建立自己的專案層，避免不同專案互相污染。

安裝後，`.agents/resources/` 與 `.agents/reference-projects/` 各自帶一份 `.gitignore`（內容為 `*` 加 `!.gitignore`），放進去的 SPEC、log、waveform 與 golden reference 預設不會進版控，也不需要修改目標專案既有的根 `.gitignore`。

## 故障排除

| 症狀 | 檢查方式 |
|---|---|
| Agent 沒有輸出啟動確認 | 確認 VSCode 開的是 repository 根目錄，且根目錄看得到 `AGENTS.md` 與 `.agents/`；直接輸入「工作開始」強制重讀五個檔案 |
| 安裝後工具仍看不到規則或 skill | 重新載入 VSCode 視窗；工具通常在啟動時才掃描專案規則 |
| Claude Code 少了某個 skill | 確認 `.claude/skills/<名稱>/SKILL.md` 存在，且 frontmatter 的 `name` 與資料夾同名 |
| 某個 skill 突然消失或行為不對 | 可能與工具內建 skill 撞名；改用帶專案前綴的名稱，並同步更新 `module.json` 與兩處 SKILL.md |
| `Target files already exist; nothing was written` | 目標已經裝過模組，改用 `-Update` |
| `No installed module found` | 目標沒裝過模組，拿掉 `-Update` 做乾淨安裝 |
| `still contains template token: __XXX__` | 專案層三份文件還沒填，把範本 token 換成實際內容 |
| `7z.exe was not found` | 安裝 7-Zip，或把 `7z.exe` 加入 PATH |
| 升級後專案事實不見了 | `-Update` 不會寫入作用中三份文件；若內容確實變了，代表有人手動覆蓋，請從版控還原 |

## 手動驗證

在目標專案根目錄執行：

```powershell
powershell -ExecutionPolicy Bypass -File .\verify-ai-module.ps1
```

若要維護並重新打包本套件，請參考 `.agents/README.md`。
