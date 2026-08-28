# TODO.md — 模組母版工作追蹤

- 專案識別：`firmware-ai-kit-source`
- 當前 work item：`KIT-001`

## Work items
| ID | 工作類型 | 功能域 | 項目 | 相依 | 狀態 | 完成條件 |
|---|---|---|---|---|---|---|
| KIT-001 | 重構 | AI 協作模組 | 將 ITE EC 移植母版泛化為跨控制器、跨工作類型模組 | 無 | 完成 | 結構、技能、安裝、驗證、打包全部通過 |

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
- `verify-ai-module.ps1`：通過，32 個 portable files、9 個 skills。
- 18 份 canonical skill / Claude loader：`quick_validate.py` 全數通過。
- 乾淨暫存目標安裝、初始化、二次安裝衝突保護：通過。
- `firmware-ai-collaboration-kit-v4.7z`：`7z t` 通過，解壓後 32 個檔案與 manifest 完全一致。

## 待實際環境驗收
- [ ] Claude Code 新專案啟動與技能列表。
- [ ] Codex 新專案啟動確認。
- [ ] Antigravity 新專案引用、workspace rule 與技能列表。
