# Embedded Controller AI 移植套件

本目錄與根目錄的 `AGENTS.md` / `CLAUDE.md` / `GEMINI.md` 組成一套**可跨 Embedded Controller 專案重複使用**的 AI 協作規範。
設計原則：**通用層與專案層完全分離**，複製到新專案時只需重寫專案層。

標準目錄名稱是 `.agents/`。若來源專案使用 `.agent/`，移植時統一改為 `.agents/`，避免入口檔與相對路徑失效。

## 目錄結構

```
AGENTS.md                              [通用] Codex 入口與工作規範核心
CLAUDE.md                              [通用] Claude Code 入口（@import）
GEMINI.md                              [通用] Antigravity / Gemini 入口
pack.ps1                               [通用] 白名單打包腳本，產生跨案 7z
.gitignore                             [母版] 排除打包輸出與專案資源掛載點內容（不進 7z）
.claude/
└── skills/
    └── ite-ec-porting/
        └── SKILL.md                   [通用] Claude Code 技能載入器（只指向本體）
.agents/
├── README.md                          [通用] 本檔，模組說明與套用步驟
├── project.md                         [專案] ★ 目前專案設定，必須重建
├── TODO.md                            [專案] 移植進度與待確認事項
├── templates/
│   ├── project.md                     [通用] 專案設定空白範本
│   └── TODO.md                        [通用] 進度追蹤空白範本
├── skills/
│   └── ite-ec-porting/
│       ├── SKILL.md                   [通用] ITE EC 移植技能包（唯一內容來源）
│       └── references/                [專案] 該專案用到的 datasheet
└── reference-projects/
    └── <name>/                        [專案] 唯讀 golden reference
```

`.claude/skills/` 是 Claude Code 唯一會自動掃描的技能目錄，因此技能必須放一份載入器在那裡才會出現在 skill 清單；
但載入器**只含 frontmatter 與指向本體的說明**，實際方法論永遠只有 `.agents/skills/<skill>/SKILL.md` 一份，
Codex 與 Antigravity 也讀同一份，不會產生兩個來源。

### 模組母版本身的 project.md / TODO.md

在**模組母版 repository**（也就是產生 7z 的這一份）裡，`project.md` 與 `TODO.md` 描述的是「模組維護」而非任何 EC 專案，
用途是讓 `CLAUDE.md` 的 import 在母版內仍然成立。`pack.ps1` 刻意排除這兩個檔案，所以它們不會流入新專案。
若在新 EC 專案看到自稱母版的 `project.md`，代表有人整包複製資料夾而非使用 7z，必須依下方步驟由範本重建。

## 分層責任

| 層級 | 內容 | 誰會改 |
|------|------|--------|
| 通用層 | 工作流程、執行順序規則、git 規則、差異分析清單、修改邊界、驗證要求、程式風格、回覆格式 | 規範本身升級時才改 |
| 專案層 | 晶片型號、參考專案、路徑、建置指令、移植目標順序、平台備註、驗證碼、進度 | 每個專案各自維護 |

通用層不可寫入指向單一專案的名稱、晶片設定或實體路徑；領域說明中的泛用型號範例不在此限。專案層不可重複抄寫通用規則。
兩層之間只透過固定路徑 `./.agents/project.md` 與 `./.agents/TODO.md` 銜接。

## 可攜式 7z 內容

跨案套件檔名為 `ite-ec-ai-porting-kit-v3.7z`，由母版根目錄的 `pack.ps1` 以**白名單**產生，只包含可安全重用的內容：

```text
AGENTS.md
CLAUDE.md
GEMINI.md
pack.ps1
.agents/README.md
.agents/templates/project.md
.agents/templates/TODO.md
.agents/skills/ite-ec-porting/SKILL.md
.agents/skills/ite-ec-porting/references/.gitkeep   (空掛載點)
.agents/reference-projects/.gitkeep                 (空掛載點)
.claude/skills/ite-ec-porting/SKILL.md
```

產生方式（於母版根目錄）：

```powershell
powershell -ExecutionPolicy Bypass -File .\pack.ps1
```

`pack.ps1` 會在壓縮前做兩道封裝邊界自檢：暫存區若出現 `.agents/project.md`、`.agents/TODO.md`，
或任何 `.pdf` / `.bin` / `.hex` / `.elf` / `.obj` / `.exe` / 壓縮檔，直接中止並回報。
**不可手動整包壓縮母版資料夾**，那會把專案層資料一併帶走。

下列資料刻意不放進可攜套件：

- `.agents/project.md` 與 `.agents/TODO.md`：內容屬於目前專案，不能污染新專案。
- `.agents/skills/*/references/` 內的 SPEC：需按新專案晶片重新配置。
- `.agents/reference-projects/` 內的 golden reference：通常體積大，也可能受授權限制。
- firmware、binary、build output、patch 與一般原始碼：不屬於 AI 規範套件。

這些專案資料仍可在各自 repository 中 commit；「可 commit」不代表應放進跨案 7z。

## 套用到新專案的步驟

適用任何 ITE EC 專案（IT51526 / IT51386 / IT8298 / IT8233 …），架構為 Zephyr 或原廠 legacy SDK 皆可。

1. 把 `ite-ec-ai-porting-kit-v3.7z` 解壓到新專案根目錄，使 `AGENTS.md` 與主要建置入口位於同一層。Windows PowerShell 範例：

   ```powershell
   7z x .\ite-ec-ai-porting-kit-v3.7z -o'D:\path\to\new-ec-project'
   ```

   若目標已有同名 AI 檔案，先人工比對再覆寫；不要靜默取代既有規範。

2. 由空白範本建立新的專案層：

   ```powershell
   Copy-Item .agents\templates\project.md .agents\project.md
   Copy-Item .agents\templates\TODO.md .agents\TODO.md
   ```

3. 建立或確認 `.agents/skills/ite-ec-porting/references/` 與 `.agents/reference-projects/` 目錄。
4. 放入新專案所需的 datasheet，並在 `project.md` 的「SPEC 文件」登記相對路徑。
5. 放入已驗證的 golden reference，並在 `project.md` 的「路徑設定」登記；未經許可不可修改其內容。
6. 開啟新 session 後下達「套用到新專案」。AI 應先盤點 repository，填寫或修正 `project.md`、建立 `TODO.md`，並列出不能從現有證據確認的缺口。
7. 更換 `project.md` 最末的載入驗證碼，再以新 session 驗收。第一次正式工作回覆必須輸出：

   ```text
   已讀取：AGENTS.md (...) / .agents/project.md (...) / .agents/TODO.md (...) ｜ 規範版本：EC-PORTING-CORE-v3 ｜ 驗證碼：<新專案驗證碼>
   ```

   缺少任一檔案、版本或驗證碼都代表初始化尚未完成。

## 使用者與新專案 AI 的責任分工

### 使用者必須提供或確認

- 當前專案與 golden reference 的合法來源及可讀路徑。
- 當前與參考 SoC 的精確型號；若 suffix、封裝或 silicon revision 會影響腳位，也要提供。
- 官方 SPEC，以及 repository 無法證明的 schematic、GPIO table、power tree、BOM、PD／charger／IO expander 型號。
- 哪個舊專案已完成驗證、可作為 golden reference。
- 實板型號、燒錄方式、量測條件與可接受的驗證標準。
- 不能放入 git 或 7z 的機密、授權與檔案大小限制。

### 可交給新專案 AI 從證據整理

- Repository 名稱、框架、目錄結構、建置入口、board／DTS／Kconfig／linker 設定。
- 參考專案與當前專案的功能落點對照。
- 依依賴關係擬定移植目標順序與 `TODO.md` 初稿。
- 從 SPEC 核對 SoC 資源差異，並把章節或檔案位置記入進度。
- 產生新的載入驗證碼、檢查相對路徑，並執行現有環境可完成的靜態檢查與 build。

### AI 不可自行猜測

- 不存在於 repository 或 SPEC 的 register value、腳位、polarity、delay、reset sequence、power rail ordering。
- 未提供 schematic／BOM 時的板級 IC 型號與連線。
- 未取得 log、波形或實板結果時，宣稱硬體驗證通過。
- 未經指定，把任意舊專案當成 golden reference。

## 各 AI 工具的載入方式

| 工具 | 載入機制 | 注意事項 |
|------|----------|----------|
| Claude Code | `CLAUDE.md` 以 `@` import 載入三個必讀檔 | 若 import 失效，需自行完整讀取並回報 |
| Codex | 直接讀取 `AGENTS.md` | 不展開 import，必須另行讀取 `.agents/project.md`、`.agents/TODO.md` |
| Antigravity / Gemini | 目錄規則自動載入 `GEMINI.md` 與 `AGENTS.md` | 同樣需另行讀取 `.agents/` 下的專案層檔案 |

技能包的載入方式：

| 工具 | 載入機制 | 注意事項 |
|------|----------|----------|
| Claude Code | 掃描 `.claude/skills/`，可用 `/ite-ec-porting` 呼叫載入器 | 載入器只是指標，仍須讀 `.agents/skills/ite-ec-porting/SKILL.md` 本體 |
| Codex / Antigravity | 依 `.agents/project.md`「路徑設定」登記的路徑直接讀本體 | 不經過 `.claude/`，讀到的是同一份檔案 |

因此 `AGENTS.md` 的「Session 啟動確認」把三個必讀檔案寫成明確清單，並用「規範版本 + 驗證碼」雙重確認：
規範版本證明通用層載入完整，驗證碼證明專案層載入完整。

## 維護規則

- 規範異動只改 `AGENTS.md`；同時調整 `## 規範版本` 的版本字串。
- 工具載入差異只改對應入口檔，不在入口重複工作規範。
- 專案資訊異動只改 `.agents/project.md`。
- 進度異動只改 `.agents/TODO.md`。
- skill 內容只改 `.agents/skills/<skill>/SKILL.md` 本體；`.claude/skills/<skill>/SKILL.md` 只在 `name` / `description` 需要調整時才動，不得複製內文。
- skill 保留領域方法、SPEC 核對清單與架構轉換判斷，不重複專案資料。
- 更新通用層後以 `pack.ps1` 重新產生 7z；該腳本的白名單與自檢清單是封裝邊界的唯一實作，新增通用檔案時必須同步更新腳本的 `$include`。
- 母版 repository 內 `reference-projects/` 與 `skills/*/references/` 永遠只保留 `.gitkeep`，任何專案資料都不放進母版。
- AI 規範修改可獨立成一筆中文 commit；不要和 EC 功能移植混在同一筆，且未經要求不要 push。
