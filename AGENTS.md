# AGENTS.md — 嵌入式韌體 AI 協作通用核心

## 本檔定位
- 本檔是跨專案、跨控制器與跨工作類型的共用規則，也是 Codex 的專案入口。
- 本檔不得包含單一專案名稱、晶片型號、板級連線、實體路徑或當前工作進度。
- 專案事實寫在 `./.agents/project.md`，資料位置寫在 `./.agents/context-index.md`，工作狀態寫在 `./.agents/TODO.md`。
- Bug fix、程式碼整合、移植、bring-up 等方法放在 `./.agents/skills/`，不得回填本檔造成核心膨脹。

## 適用範圍
- 適用 Embedded Controller、PD、Lighting、Keyboard Controller 與其他嵌入式韌體專案。
- 支援問題分析、Bug fix、程式碼整合、功能開發、韌體移植、硬體 bring-up、重構與審查。
- 不假設專案一定有 golden reference、SPEC、實板或參考專案；缺少時必須明確列為限制。

## 模組分層
| 層級 | 權威來源 | 用途 |
|---|---|---|
| 共用核心 | `AGENTS.md` | 不可覆寫的安全、證據、變更與驗證原則 |
| 工具入口 | `CLAUDE.md` / `GEMINI.md` | 將工具導向同一份核心與專案資料 |
| 模組清單 | `.agents/module.json` | 模組版本、必讀檔案、欄位 schema 與可攜白名單 |
| 專案設定 | `.agents/project.md` | 目標專案已確認事實、能力與限制 |
| 資料索引 | `.agents/context-index.md` | 程式碼、文件、基準、證據的路徑與權威性 |
| 工作追蹤 | `.agents/TODO.md` | work item、相依、狀態、決策與驗證 |
| 技能 | `.agents/skills/<skill>/SKILL.md` | 任務方法與控制器領域知識 |

## 規則優先順序
1. 平台安全規則與使用者在當前對話的明確指令。
2. 本檔的共用不可覆寫原則。
3. `project.md` 的專案限制與 `context-index.md` 的資料權威性。
4. `TODO.md` 的當前 work item、範圍與相依關係。
5. 已啟用技能的方法與檢查表；技能不得擴張任務授權或覆寫上層規則。

## Session 載入確認
- 首次進行實質分析、修改或執行前，必須完整讀取下列檔案：
  1. `./AGENTS.md`
  2. `./.agents/module.json`
  3. `./.agents/project.md`
  4. `./.agents/context-index.md`
  5. `./.agents/TODO.md`
- 缺少任一檔案時停止實作，指出缺檔並依 `./.agents/README.md` 修復專案層。
- 讀取後依 `.agents/module.json` 的 `projectSchema` 檢查 `project.md` 欄位，結果分三態：
  - `ok`：必填欄位皆已填且合法。
  - `未填 <n> 欄`：欄位值為 `待確認`，列為警告，可繼續工作但需在回覆中列出缺口。
  - `不合法: <欄位清單>`：值不在 schema 允許範圍內，停止實質工作並要求修正。
- `projectSchema.appliesTo` 與 `projectKind` 不符時跳過欄位檢查，`schema` 回報 `n/a`。
- 完成讀取後輸出：`啟動確認：core=<版本> / project=<專案識別> / context=<索引版次> / work-item=<ID 或 none> / schema=<ok｜未填 n 欄｜不合法: 清單｜n/a> / missing=<none 或清單>`。
- 驗證值必須取自檔案實際內容，不可推測。確認應在首次實質工作前完成，不要求早於必要的檔案讀取工具呼叫。
- 收到「工作開始」時，重新讀取五個檔案，並依當前 work item 載入相關技能與索引資料。

## 語言與回覆
- 與使用者互動一律使用繁體中文。
- 回覆先給結論，再列關鍵依據、修改檔案、風險、驗證與待確認事項。
- 不主動建立需求外文件，不主動提供給其他 AI 工具的 prompt。
- 資訊不足時列出缺口；不可用猜測填補硬體、規格或驗證結果。

## 專案與資料原則
- 目標專案是目前允許修改的 repository；外部基準、vendor tree、golden reference 預設唯讀。
- 所有模組文件使用相對於專案根目錄的路徑；實體路徑只可出現在專案層且需有明確理由。
- `context-index.md` 是資料路由唯一來源。先依索引判定權威資料，再只讀當前工作所需內容。
- SPEC、schematic、BOM、log、waveform、issue、commit 或 reference code 的結論必須可追溯到來源位置。
- 若資料互相矛盾，先標示衝突與權威性，不可自行挑選方便的答案。
- 來自 `.agents/reference-projects/` 的搜尋或閱讀結果必須標示為唯讀基準，不可與目標專案的結果混列或混報。

## 工作類型與技能路由
- Bug fix：使用 `bug-fix`；先重現與定位根因，再做最小修正及 regression。
- 程式碼整合：使用 `code-integration`；確認來源版本、差異、衝突與介面相容性。
- 韌體移植：使用 `firmware-porting`；建立來源到目標對照並驗證行為對等。
- 硬體 bring-up：使用 `hardware-bringup`；以規格、初始化證據、log 與波形逐步啟用。
- 架構設計與重構：使用 `architecture-design`；先盤點現況與相依方向，再定義模組邊界與分階段遷移。
- 多專案收斂：先用 `architecture-design` 決定共用基底與差異層，再用 `code-integration` 執行搬移。
- 程式碼審查：使用 `firmware-code-review`；區分必須修正與建議，無法從程式碼判定的項目標為待驗證。
- 領域技能由 `project.md` 的控制器領域依 `projectSchema.skillRouting` 自動推導，不另設欄位：`EC` 載入 `ec-controller`，`PD` 載入 `pd-controller`，`Keyboard & Lighting` 同時載入 `keyboard-controller` 與 `lighting-controller`。
- ITE EC 跨晶片／跨框架移植可額外使用 `ite-ec-porting`；它不是所有工作的預設流程。
- 同一 work item 可組合一個任務技能與一個或多個領域技能。

## 通用工作流程
1. 從 `TODO.md` 確認當前 work item、範圍、相依項目與完成條件。
2. 從 `context-index.md` 取得必要的程式碼、規格、基準與驗證證據。
3. 閱讀相關技能，建立問題／來源／目標／驗證的對照。
4. 小範圍任務可直接提出簡短計畫；跨模組或高風險任務先提供 phase breakdown。
5. 僅修改目標專案內、屬於本 work item 的必要檔案。
6. 執行與風險相稱的 build、test、static analysis、log 或實板驗證。
7. 更新 `TODO.md` 的狀態、差異、決策、證據與尚未完成項目。
8. 實作型 work item 驗證乾淨後，stage 本項檔案並建立一筆中文 commit；不要 push。

## 變更邊界
- 不猜測 register value、pin、polarity、timing、delay、reset sequence 或 power rail ordering。
- 不為通過 build 而關閉 warning、繞過 assert、註解測試或忽略 error handling。
- 不修改 generated code、第三方 vendor code、binary、build output 或唯讀基準，除非使用者明確要求。
- 模組自身在目標專案內唯讀：`AGENTS.md`、`CLAUDE.md`、`GEMINI.md`、`.agents/module.json`、`.agents/skills/`、`.agents/templates/`、`.agents/rules/`、`.claude/` 與三支 `.ps1` 一律不得修改；共用規則的修改回到模組母版，再以 `-Update` 下發。
- 上述唯讀範圍的例外只有三份作用中文件（`.agents/project.md`、`.agents/context-index.md`、`.agents/TODO.md`）與兩個資料掛載點（`.agents/resources/`、`.agents/reference-projects/`）。
- 專案內部另有不得修改的路徑時，登記於 `project.md` 的額外唯讀區域。
- 不混合無關 work item，不重排無關程式碼；patch 必須可審查、可驗證、可回退。
- 需求是分析或診斷時只提供證據與結論，不自行擴張為實作。

## 驗證原則
- 每次修改至少提供一項可重現驗證；有建置系統時優先要求 build 無 error 且無新增 warning。
- 驗證結果分成：已完成靜態驗證、已完成動態／實板驗證、仍待驗證。
- 不得把未執行的測試寫成通過，也不得以編譯成功代替行為或硬體驗證。
- Bug fix 需確認原問題可重現或有等價證據，並加入針對根因的 regression。
- 整合與移植需比較來源與目標行為；bring-up 需保留 log、量測或波形依據。

## Git 規則
- 每筆 commit 只對應一個已完成且已驗證的 work item，message 使用簡潔中文。
- 目標專案的 commit 只包含韌體原始碼變更。模組檔案（`.agents/`、`.claude/` 與根目錄模組檔）不進目標專案版控，因此不 stage、不 commit，`TODO.md` 的更新也不併入 commit。
- 模組母版本身照常版控，本規則只適用安裝到目標專案的那一份。
- 發現模組檔案已被目標 repository 追蹤時，先回報並提供 `git rm -r --cached` 的修復步驟，不自行執行。
- Commit 前確認沒有混入使用者既有修改、機密資料、SPEC、reference 或 build output。
- 未經使用者明確要求，不 amend、不 push、不做破壞性 Git 操作。

## 可攜與安裝規則
- 不直接整包覆蓋目標 repository；使用 `setup-ai-module.ps1` 做檔案衝突檢查與專案層初始化。
- 可攜內容以 `.agents/module.json` 的 `portableFiles` 白名單為準，由 `pack.ps1` 實作並由 `verify-ai-module.ps1` 驗證。
- 母版作用中的 `project.md`、`context-index.md`、`TODO.md`、SPEC、reference 與證據不得進入可攜套件。
- 目標專案必須由 `.agents/templates/` 產生新的專案層，並填入新的專案識別與載入驗證碼。
- 安裝到目標專案時，模組檔案的忽略規則寫入該 repository 的 `.git/info/exclude`，不新增也不修改目標的 `.gitignore`，避免在版控中暴露模組檔名。
- `.agents/` 未進目標專案版控，工作歷史與證據只存在本機工作副本；需提醒使用者納入日常備份，並避免在目標專案執行 `git clean -x`。

## 溝通指令
- 「套用到新專案」：先執行或依照 `setup-ai-module.ps1` 盤點衝突，建立專案層，分列可自動查得與需使用者提供的資料，再執行驗證。
- 「工作開始」：重新完成 Session 載入確認，選定 work item 與技能，載入索引指向的必要證據後再工作。

## 規範版本
- 本次規範版本：`ZHANLU-CORE-v4`
- 本章節置於最末，作為完整載入驗證 sentinel。
