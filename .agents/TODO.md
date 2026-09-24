# TODO.md — 模組母版工作追蹤

- 專案識別：`zhanlu-source`
- 當前 work item：`KIT-021`

## Work items
| ID | 工作類型 | 功能域 | 項目 | 相依 | 狀態 | 完成條件 |
|---|---|---|---|---|---|---|
| KIT-001 | 重構 | AI 協作模組 | 將 ITE EC 移植母版泛化為跨控制器、跨工作類型模組 | 無 | 完成 | 結構、技能、安裝、驗證、打包全部通過 |
| KIT-002 | Bug fix | Antigravity 載入 | 修正 workspace rule 未引用共用核心並完成三工具環境驗收 | KIT-001 | 完成 | Antigravity 規則可追溯至 `AGENTS.md`、regression 通過、三工具驗收有明確證據 |
| KIT-003 | 文件／封裝 | 可攜套件 | 新增套件根目錄 README，重建可直接安裝到其他專案的 7z | KIT-002 | 完成 | README 位於封裝根目錄、不覆蓋目標 README、乾淨與既有 README 目標安裝通過、封裝清單與完整性通過 |
| KIT-004 | Bug fix | 資料邊界 | 為 `.agents/resources/` 與 `.agents/reference-projects/` 隨套件提供 gitignore 保護 | KIT-003 | 完成 | 目標專案安裝後掛載點內容預設不進版控、不覆蓋目標根 `.gitignore`、驗證與安裝通過 |
| KIT-005 | 功能開發 | 安裝工具 | `setup-ai-module.ps1` 新增 `-Update` 升級模式，保留專案層三份作用中文件 | KIT-004 | 完成 | 升級只覆寫可攜檔案、作用中文件零改動、無可攜檔案時拒絕升級、乾淨安裝行為不變 |
| KIT-006 | 功能開發 | 技能 | 新增 `architecture-design` 與 `firmware-code-review` 技能並補齊路由表 | KIT-005 | 完成 | canonical skill、Claude loader、`module.json`、`AGENTS.md` 與 `.agents/README.md` 路由一致且驗證通過 |
| KIT-007 | 文件／封裝 | 可攜套件 | README 補前置需求、技能清單、升級與故障排除，版本升版並重建 7z | KIT-006 | 完成 | README 內容與實作一致、版本號一致、乾淨安裝與升級安裝實測通過、封裝清單與完整性通過 |
| KIT-008 | 文件 | 可攜套件 | README 補「套用到新專案要填什麼、資料放哪」的逐步指引 | KIT-007 | 完成 | 三份專案層文件的填寫欄位、資料放置位置與首次啟動驗收皆有明確指引，且母版驗證通過 |
| KIT-009 | 功能開發 | 專案層 schema | project.md 欄位收斂為 enum／pattern，並由 AI 於啟動確認驗證 | KIT-008 | 完成 | schema 寫入 module.json、範本改寫、AGENTS.md 補欄位驗證與技能自動推導、README 同步 |
| KIT-010 | 功能開發 | 資料邊界 | 目標專案安裝的模組一律不進版控 | KIT-009 | 完成 | 安裝時寫入目標 .git/info/exclude、verify 以 git ls-files 檢出誤追蹤、AGENTS.md Git 規則改寫、README 補風險警告 |
| KIT-011 | 重構 | 模組識別 | 模組更名為湛盧 zhanlu，五層名稱統一並處理既有安裝遷移 | KIT-010 | 完成 | 名稱五層一致、舊標記可自動清除、舊版套件升級不洩漏、封裝與驗證通過 |
| KIT-012 | 文件 | 可攜套件 | README 補 GitHub clone 安裝通道，明確區分「取得模組」與「安裝模組」 | KIT-011 | 完成 | clone 流程、`zhanlu/` 排除缺口、驗收方式與故障排除皆有指引，母版驗證通過 |
| KIT-013 | Bug fix／重構 | 安裝工具 | 安裝器自動排除 kit 目錄、修正 exclude 區塊堆疊、兩支腳本更名為 zhanlu | KIT-012 | 完成 | 區塊永遠一組、kit 在目標內自動排除且在目標外不多寫規則、更名可由舊版升級遷移、封裝與驗證通過 |
| KIT-014 | 功能開發／文件 | 維護工具 | 新增 `clean-backups.ps1` 清除專案層備份，README 補「升級會動到什麼」對照 | KIT-013 | 完成 | 只刪 `.agents/.backup-*`、非安裝目錄拒絕執行、`-WhatIf`／`-KeepLatest` 正確、升級不動使用者資料有實測佐證、封裝與驗證通過 |
| KIT-015 | Bug fix | 維護工具 | `clean-backups.ps1` 從 clone 目錄執行時找錯 `.agents/` | KIT-014 | 完成 | 從 clone 執行會往上定位到已安裝專案並印出位置、指向 kit 時明確拒絕、既有選項行為不變 |
| KIT-016 | 功能開發 | 維護工具 | 新增 `update-zhanlu.ps1`，把 `git pull` + `-Update` 收成一行 | KIT-015 | 完成 | 免參數即可執行、自動定位專案、pull 失敗中止、非自有 clone 不誤 pull、選項可透傳、封裝與驗證通過 |
| KIT-017 | 文件／封裝 | 發布 | 建立 GitHub Release v4.6.0，附可攜套件 | KIT-016 | 完成 | tag 推送、release 建立、7z asset 上傳且 SHA-256 相符 |
| KIT-018 | 功能開發 | 專案層 schema | 「目標晶片」支援一顆或多顆 ITE IC 型號 | KIT-017 | 完成 | schema、範本與 README 語意一致；單顆／多顆／錯誤分隔／非法型號 regression 通過；母版驗證與封裝通過 |
| KIT-019 | Bug fix | 專案層 schema | 多顆目標晶片改用全形逗號 `，` 分隔 | KIT-018 | 完成 | schema、驗證、範本與 README 一致；全形逗號通過，頓號與半形逗號拒絕；母版驗證與封裝通過 |
| KIT-020 | 文件／封裝 | 發布 | 將已驗證的 v4.7.1 推送並發布 GitHub Release | KIT-019 | 完成 | main、annotated tag 與 Release 可查，下載回驗 asset 的大小、SHA-256 與 7z 完整性均通過 |
| KIT-021 | Bug fix／重構 | 三工具載入 | 修正 Antigravity rule 並精簡啟動工作紀錄 | KIT-020 | 完成 | 載入規則與 verifier 一致、歷史零遺失、封裝及安裝回歸通過 |

## 當前項目：KIT-021（完成）
- 問題／需求：修正 Antigravity workspace rule 的載入相容性，降低啟動時強制讀取的歷史資料量。
- 範圍：共用入口、驗證器、母版工作紀錄、範本與使用說明；不改 11 個技能本體或已安裝專案的作用中文件。
- 使用技能：`bug-fix`、`architecture-design`。
- 完成條件：rule frontmatter regression、載入邊界驗證、歷史搬移一致性、封裝與安裝回歸通過。

## KIT-021 驗證紀錄
- 根因與修正：Antigravity 現行 rule 契約要求 `trigger` frontmatter，原 `.agents/rules/project-context.md` 未提供；加入 `always_on` 與封閉 frontmatter 的驗證。Antigravity 的 `@` 為檔案參照，入口文字改為明確要求實際讀取。
- 啟動資料：Claude 不再預先匯入完整 TODO；共用核心改為前四份文件全文、TODO 當前段與相依按需載入。母版舊紀錄搬至 `.agents/history/KIT-001-KIT-020.md`，搬移前後歷史段 30,458 個字元逐字相同；作用中 TODO 由 54,197 bytes 降至約 7.5 KB。
- `verify-zhanlu.ps1 -PackageSource` 與 `git diff --check` 通過；缺少 trigger、未關閉 frontmatter、Claude 恢復整份 TODO 匯入的負向測試均被驗證器拒絕。
- v4.7.1 暫存安裝升級到 v4.8.0、v4.8.0 全新安裝與兩個目標的驗證器均通過；升級前後三份作用中文件的 SHA-256 與備份一致。
- `pack.ps1` 通過，`dist/zhanlu-v4.8.0.7z` 為 39,615 bytes、41 個檔案；SHA-256 `A6905BBC0E4CA1D5B85EAA74B582392C4AFE94CC7E337C7F6EE929FB86D70797`。舊版封裝保留，未發布 Release、未推送。
- Claude Code 動態載入（2026-09-24，使用者提供的本專案 VS Code session 回覆）：啟動確認為 `core=ZHANLU-CORE-v4 / project=zhanlu-source / context=ZHANLU-CONTEXT-v4 / work-item=KIT-021 / schema=n/a / missing=none`。該 session 回報 `CLAUDE.md` 自動展開前四份檔案，讀到核心、專案與索引 sentinel；`TODO.md` 未預先匯入，而是依規則按需讀取檔頭、總表與當前段。此為使用者提供的模型回報，非本機獨立觀察的載入追蹤。
- Antigravity 動態啟動（2026-09-24，使用者提供的本專案 VS Code session 回覆）：啟動確認為 `core=ZHANLU-CORE-v4 / project=zhanlu-source / context=ZHANLU-CONTEXT-v4 / work-item=KIT-021 / schema=n/a / missing=none`；該 session 回報讀取五份必要檔案、識別母版 schema 為 `n/a`，並載入 `bug-fix`、`architecture-design`。此證明該環境可完成啟動流程，但回覆未提供規則來源或注入清單，不能單憑結果證明 `project-context.md` 確曾注入或排除多入口重複。該回覆稱 KIT-021 尚未 commit，與本 repository 已有 `1cac31b` 不符；Git 狀態以本機查驗為準。
- Antigravity 受控動態驗收（2026-09-24，使用者提供的新對話輸出）：暫時在 `GEMINI.md` 與 `.agents/rules/project-context.md` 各加入不同標記，僅輸入「工作開始」後，session 在啟動確認下方同時回傳 `entry-gemini=G-7F31` 與 `entry-rule=R-B2C8`。提供的操作紀錄顯示讀取五份必要檔案及兩項技能，未列出讀取兩個入口檔案的工具呼叫。這支持兩個入口皆在啟動時注入；不能由模型回覆精確量出 prompt token 或證明底層去重機制。
- 多入口評估：兩處入口皆含指向同一批檔案的短導引，確有少量重複；`@檔名` 只作檔案參照，不展開核心全文。保留 workspace rule 作為備援入口，未觀察到啟動錯誤；檢查時兩個暫時標記已從檔案移除，未進入套件。

## 歷史索引
- KIT-001～KIT-020 的詳細紀錄與原有未決事項：`.agents/history/KIT-001-KIT-020.md`。
- 依目前 work item 需要再讀取歷史紀錄；本檔保留總表與當前狀態。
