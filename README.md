# Embedded Firmware AI Collaboration Kit v4.0.1

這是一套可移植到嵌入式韌體 repository 的 AI 協作模組，讓 Claude Code、Codex 與 Antigravity 共用同一份專案規則、專案資料、工作追蹤與 skills。

支援的工作包含 Bug 修正、程式碼整合、跨晶片／跨架構移植、硬體 bring-up、重構與程式碼審查；領域涵蓋 EC、USB PD、lighting、keyboard controller，以及 ITE EC 專門移植。

## 最短安裝流程

不要直接把壓縮檔覆蓋解壓到目標 repository。請先解壓到暫存或相鄰資料夾，再執行安裝器；安裝器會在寫入前檢查所有衝突。

```powershell
$archive = 'D:\transfer\firmware-ai-collaboration-kit-v4.0.1.7z'
$kitDir = 'D:\transfer\firmware-ai-kit-v4.0.1'
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

## 套件包含內容

- `AGENTS.md`、`CLAUDE.md`、`GEMINI.md`：三工具入口與共用核心。
- `.agents/module.json`：版本、skills 與可攜檔案白名單。
- `.agents/templates/`：新專案的 project、context-index 與 TODO 範本。
- `.agents/rules/`：Antigravity workspace rule。
- `.agents/skills/`：9 個 canonical skills。
- `.claude/skills/`：9 個 Claude skill 載入器。
- `setup-ai-module.ps1`：安全安裝與專案層初始化。
- `verify-ai-module.ps1`：結構、引用與 skill 驗證。
- `pack.ps1`：由白名單重建 7z 套件。
- `.agents/README.md`：安裝後保留在目標專案內的完整維護說明。

本檔 `README.md` 只提供壓縮套件的第一層使用說明，不會覆蓋或複製成目標 repository 的根目錄 README。

## 可以交由 AI 協助的內容

- 掃描 repository，整理可確認的 controller、架構、build 與 test 資訊。
- 建立或拆分 work item、相依關係與驗證清單。
- 依任務選擇 Bug fix、整合、移植、bring-up 及控制器領域 skill。
- 對照來源與目標程式碼，列出差異、風險與待補證據。

AI 不得猜測 pin、polarity、register value、timing、reset sequence、power rail ordering 或未提供的客戶需求。這些資料若無法從權威文件查得，必須由專案負責人補充。

## 不會打包的專案資料

母版作用中的 `.agents/project.md`、`.agents/context-index.md`、`.agents/TODO.md`，以及 SPEC、schematic、BOM、log、binary、build output、golden reference 與客戶資料不會進入套件。每個目標專案會由範本建立自己的專案層，避免不同專案互相污染。

## 手動驗證

在目標專案根目錄執行：

```powershell
powershell -ExecutionPolicy Bypass -File .\verify-ai-module.ps1
```

若要維護並重新打包本套件，請參考 `.agents/README.md`。
