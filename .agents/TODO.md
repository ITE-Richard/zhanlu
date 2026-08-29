# TODO.md — 模組母版工作追蹤

- 專案識別：`firmware-ai-kit-source`
- 當前 work item：`KIT-007`

## Work items
| ID | 工作類型 | 功能域 | 項目 | 相依 | 狀態 | 完成條件 |
|---|---|---|---|---|---|---|
| KIT-001 | 重構 | AI 協作模組 | 將 ITE EC 移植母版泛化為跨控制器、跨工作類型模組 | 無 | 完成 | 結構、技能、安裝、驗證、打包全部通過 |
| KIT-002 | Bug fix | Antigravity 載入 | 修正 workspace rule 未引用共用核心並完成三工具環境驗收 | KIT-001 | 完成 | Antigravity 規則可追溯至 `AGENTS.md`、regression 通過、三工具驗收有明確證據 |
| KIT-003 | 文件／封裝 | 可攜套件 | 新增套件根目錄 README，重建可直接安裝到其他專案的 7z | KIT-002 | 完成 | README 位於封裝根目錄、不覆蓋目標 README、乾淨與既有 README 目標安裝通過、封裝清單與完整性通過 |
| KIT-004 | Bug fix | 資料邊界 | 為 `.agents/resources/` 與 `.agents/reference-projects/` 隨套件提供 gitignore 保護 | KIT-003 | 完成 | 目標專案安裝後掛載點內容預設不進版控、不覆蓋目標根 `.gitignore`、驗證與安裝通過 |
| KIT-005 | 功能開發 | 安裝工具 | `setup-ai-module.ps1` 新增 `-Update` 升級模式，保留專案層三份作用中文件 | KIT-004 | 完成 | 升級只覆寫可攜檔案、作用中文件零改動、無可攜檔案時拒絕升級、乾淨安裝行為不變 |
| KIT-006 | 功能開發 | 技能 | 新增 `architecture-design` 與 `firmware-code-review` 技能並補齊路由表 | KIT-005 | 完成 | canonical skill、Claude loader、`module.json`、`AGENTS.md` 與 `.agents/README.md` 路由一致且驗證通過 |
| KIT-007 | 文件／封裝 | 可攜套件 | README 補前置需求、技能清單、升級與故障排除，版本升版並重建 7z | KIT-006 | 尚未開始 | README 內容與實作一致、版本號一致、乾淨安裝與升級安裝實測通過、封裝清單與完整性通過 |

## KIT-006 現況
- [x] 新增 `architecture-design` canonical skill，涵蓋分層、模組邊界、介面契約與多專案收斂。
- [x] 新增 `firmware-code-review` canonical skill，涵蓋正確性、邊界、併發時序、硬體互動與資源。
- [x] 新增兩份 Claude loader，並更新 `module.json` 的 skills 與可攜白名單。
- [x] 補齊 `AGENTS.md` 與 `.agents/README.md` 的工作路由，消除核心宣稱支援重構與審查卻無技能的落差。
- [x] 審查技能改名為 `firmware-code-review`，避開 Claude Code 內建 `code-review` 的撞名遮蔽。
- [x] `-RemoveStale` 補上空目錄清理，改名後不留空的 skill 目錄。

## KIT-006 驗證證據
- 撞名證據：技能命名為 `code-review` 時 Claude Code 只掛載 `architecture-design`，內建 `code-review` 被遮蔽；改名為 `firmware-code-review` 後兩者同時可用。
- Frontmatter strict check：11 個 skill 的 canonical 與 loader 共 22 份檔案，`name` 與目錄一致、`description` 非空、無多餘欄位。
- `verify-ai-module.ps1 -PackageSource`：通過，37 個 portable files、1 個 package-only file、11 個 skills。
- 全新目標乾淨安裝：11 個 canonical skill 與 11 個 loader 完整落地。
- 既有目標 `-Update -RemoveStale`：新增 2 檔、覆寫 4 檔、刪除 2 個 stale 檔並清掉空目錄，作用中三份文件維持保留。
- 多專案收斂路由：`architecture-design` 先定界線、`code-integration` 執行搬移，已寫入核心與維護說明。

## KIT-005 現況
- [x] `setup-ai-module.ps1` 新增 `-Update` 與 `-RemoveStale`，安裝與升級共用同一份白名單與驗證。
- [x] 升級前輸出計畫：新增、覆寫、內容相同、保留與 stale 檔案分類。
- [x] 作用中三份專案層文件在升級路徑完全不寫入。
- [x] hash 比對改用 .NET，避免 `-WhatIf` 傳染到 provider cmdlet 產生雜訊。
- [x] `.agents/README.md` 補升級章節與邊界說明。
- [x] 以實際 v4.0.1 套件安裝的目標做端對端升級驗證。

## KIT-005 驗證證據
- 升級來源：`dist/firmware-ai-collaboration-kit-v4.0.1.7z` 解壓後安裝的目標，含使用者手填的 `project.md` 內容。
- `-Update -WhatIf`：正確列出 2 個新增、3 個覆寫、27 個相同、3 個保留、2 個 stale；執行後目標零變更（`.gitkeep` 仍在、`.gitignore` 未建立）。
- `-Update -RemoveStale`：exit code 0，`.gitkeep` 移除、`.gitignore` 建立，內建驗證通過。
- 作用中文件 SHA-256 升級前後一致：`project.md`、`context-index.md`、`TODO.md` 皆未變動，手填內容保留。
- 負向測試：無模組目錄下 `-Update` 以 exit code 1 拒絕；已安裝目標做乾淨安裝以 exit code 1 拒絕並提示改用 `-Update`；`-RemoveStale` 未搭配 `-Update` 以 exit code 1 拒絕。
- Regression：全新空目錄乾淨安裝仍 exit code 0，專案識別與載入驗證碼正常產生。

## KIT-004 現況
- [x] 以 `.agents/resources/.gitignore` 與 `.agents/reference-projects/.gitignore` 取代 `.gitkeep`，內容為 `*` 加 `!.gitignore`。
- [x] 更新 `module.json` 可攜白名單與母版根目錄 `.gitignore`（掛載點改為自我保護，並忽略編輯器產物）。
- [x] 更新 `.agents/README.md`、`context-index.md` 與 `project.md` 的資料邊界說明。
- [x] 驗證母版、乾淨目標安裝與掛載點忽略行為。

## KIT-004 驗證證據
- `verify-ai-module.ps1 -PackageSource`：通過，33 個 portable files、1 個 package-only file、9 個 skills。
- 乾淨 git 目標安裝：`setup-ai-module.ps1` exit code 0，複製 32 個可攜檔案並產生 3 份專案層文件。
- 掛載點保護：在目標放入 `.agents/resources/secret-spec.pdf.txt` 與 `.agents/reference-projects/golden.c` 後執行 `git add -A`，兩者皆未進入 index。
- `git check-ignore -v`：兩個路徑分別命中 `.agents/resources/.gitignore:3` 與 `.agents/reference-projects/.gitignore:3`。
- 目標專案根 `.gitignore` 未被建立或修改，不影響既有專案的忽略規則。

## KIT-003 現況
- [x] 建立壓縮套件根目錄 `README.md`，包含安裝、初始化、技能路由與資料邊界。
- [x] 將根目錄 README 標示為 package-only，避免覆蓋目標專案既有 README。
- [x] 驗證母版、skills、封裝清單與 7z 完整性。
- [x] 驗證空白及有既有 README 的目標安裝與二次安裝衝突保護。
- [x] 建立聚焦中文 commit。

## KIT-003 驗證證據
- `verify-ai-module.ps1 -PackageSource`：通過，33 個 portable files、1 個 package-only file、9 個 skills。
- 18 份 canonical skill／Claude loader：`quick_validate.py` 全數通過。
- `firmware-ai-collaboration-kit-v4.0.1.7z`：`7z t` 通過，33 個檔案與 manifest 完全一致；SHA-256 `B481CFC43CEB52255F0177EC989291D3B2BBB9792949236C433ACA20C747E25D`。
- 空白目標安裝通過，package-only 根目錄 README 未複製到目標專案。
- 已有 README 的目標安裝通過，原內容保持不變；二次安裝以 exit code 1 在寫入前阻擋。

## KIT-002 現況
- [x] 以官方文件確認 Antigravity workspace rules 與 skills 的權威路徑。
- [x] 重現 `.agents/rules/project-context.md` 未引用根目錄 `AGENTS.md`，且舊驗證未偵測。
- [x] 補上共用核心引用並新增缺漏引用 regression。
- [x] 重建及驗證 v4 可攜套件。
- [x] 完成 Claude Code、Codex 與 Antigravity 環境驗收。

## KIT-001 現況
- [x] 確認三工具載入機制與現有封裝邊界。
- [x] 重寫共用核心與三工具入口。
- [x] 建立通用專案設定、資料索引與工作範本。
- [x] 建立任務型與領域型技能。
- [x] 建立安全安裝與驗證腳本。
- [x] 產生並檢查 v4 可攜套件。
- [x] 完成 Git commit。

## 決策與差異
- ITE EC 移植保留為可選專門技能，不再是核心預設工作模式。
- 專案資料以 `project.md`、`context-index.md`、`TODO.md` 三份權威來源分工。
- 三工具入口不複製核心內文；各自導向同一份檔案。

## 驗證證據
- `verify-ai-module.ps1 -PackageSource`：通過，33 個 portable files、1 個 package-only file、9 個 skills。
- 18 份 canonical skill / Claude loader：`quick_validate.py` 全數通過。
- 乾淨暫存目標安裝、初始化、二次安裝衝突保護：通過。
- `firmware-ai-collaboration-kit-v4.0.1.7z`：`7z t` 通過，解壓後 33 個檔案與 manifest 完全一致。

## 三工具環境驗收
- [x] Claude Code 2.1.251：新專案 `CLAUDE.md` import 符合官方載入契約，9 個 project skill loader 通過原生 strict validation。
- [x] Codex CLI 0.150.0-alpha.12.2：獨立新專案的本機 prompt-input 載入 1 份目標 `AGENTS.md`、9 個 repo skills，父 repository 污染為 0。
- [x] Antigravity IDE 1.107.0：官方 `.agents/rules` 與 `.agents/skills` 路徑相符；新專案有 1 個 workspace rule、9 個 skills，rule 可追溯至 `AGENTS.md`。

## KIT-002 驗證證據
- 修正前：workspace rule 未引用 `AGENTS.md`，舊版 `verify-ai-module.ps1` 仍回報通過。
- 修正後：移除 `@../../AGENTS.md` 的負向 fixture 會以 exit code 1 回報缺少共用來源引用。
- `verify-ai-module.ps1`：通過，32 個 portable files、9 個 skills。
- `firmware-ai-collaboration-kit-v4.7z`：`7z t` 通過，32 個檔案；SHA-256 `A234434B0AD36E1C0443BD4AEC42AE69E824226DAAE88A9B3FC18B09EA6D972B`。
- 三工具均採不呼叫模型的本機 discovery／validator 驗收，未將專案內容送往外部服務。
