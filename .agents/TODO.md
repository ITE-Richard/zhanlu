# TODO.md — 模組母版工作追蹤

- 專案識別：`firmware-ai-kit-source`
- 當前 work item：`KIT-003`

## Work items
| ID | 工作類型 | 功能域 | 項目 | 相依 | 狀態 | 完成條件 |
|---|---|---|---|---|---|---|
| KIT-001 | 重構 | AI 協作模組 | 將 ITE EC 移植母版泛化為跨控制器、跨工作類型模組 | 無 | 完成 | 結構、技能、安裝、驗證、打包全部通過 |
| KIT-002 | Bug fix | Antigravity 載入 | 修正 workspace rule 未引用共用核心並完成三工具環境驗收 | KIT-001 | 完成 | Antigravity 規則可追溯至 `AGENTS.md`、regression 通過、三工具驗收有明確證據 |
| KIT-003 | 文件／封裝 | 可攜套件 | 新增套件根目錄 README，重建可直接安裝到其他專案的 7z | KIT-002 | 完成 | README 位於封裝根目錄、不覆蓋目標 README、乾淨與既有 README 目標安裝通過、封裝清單與完整性通過 |

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
