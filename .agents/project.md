# project.md — 專案設定（ec-ai-porting-kit 模組母版）

> **本 repository 不是 EC 工作專案，而是 AI 協作規範模組的母版（kit source）。**
> 這裡沒有任何 EC 韌體原始碼；本檔存在的目的，是讓 `CLAUDE.md` 的 import 在母版內仍然成立，
> 並提供維護此模組時的設定與載入驗證碼。
>
> 打包腳本 `pack.ps1` **刻意排除本檔與 `TODO.md`**，所以解壓到新專案後不會帶入母版資訊。
> 若你是在新 EC 專案看到這段文字，代表有人整包複製了母版資料夾而非使用 7z：
> 請立刻依 `./.agents/README.md` 由 `./.agents/templates/` 重建 `project.md` 與 `TODO.md`，
> 並更換載入驗證碼，不可沿用本檔內容。

## 專案識別
- 專案代號：`ec-ai-porting-kit`
- Repository：本目錄（AI 協作規範模組母版）
- 產品線：不適用（本模組為工具，非產品韌體）

## 晶片與架構
| 項目 | 參考專案 | 當前專案 |
|------|----------|----------|
| SoC | 不適用 | 不適用 |
| CPU | 不適用 | 不適用 |
| 韌體架構 | 不適用 | 不適用 |
| Host interface | 不適用 | 不適用 |

- 本母版不綁定任何晶片型號；晶片資訊一律由各 EC 專案自行在其 `project.md` 填寫。

## 路徑設定
- 當前專案路徑：`.`
- 參考專案路徑：不適用（母版內 `./.agents/reference-projects/` 必須保持為空掛載點）
- 進度追蹤：`./.agents/TODO.md`
- 移植技能包：`./.agents/skills/ite-ec-porting/SKILL.md`
- Claude Code 技能載入器：`./.claude/skills/ite-ec-porting/SKILL.md`
- 打包腳本：`./pack.ps1`

## SPEC 文件
| 用途 | 路徑 |
|------|------|
| （不適用） | 母版內 `./.agents/skills/ite-ec-porting/references/` 必須保持為空掛載點 |

## 建置與驗證
- 建置指令：不適用（本模組無編譯產物）
- 打包指令：`powershell -ExecutionPolicy Bypass -File .\pack.ps1`
- 產出：`dist/ite-ec-ai-porting-kit-v3.7z`
- 驗收方式：解壓到乾淨目錄，確認不含 `project.md` / `TODO.md` / SPEC / golden reference，
  再依 `.agents/README.md` 的步驟以新 session 驗收啟動確認。

## 移植目標順序
> 不適用。本母版不執行 EC 移植；移植目標順序由各專案於自己的 `project.md` 定義。
> `./.agents/templates/project.md` 內附有 16 項預設順序可供新專案起手。

## 平台特別備註
- 維護本模組時，「參考專案 / 當前專案」的名詞定義不成立，`AGENTS.md` 中與 EC 移植相關的
  執行順序、差異分析、實板驗證等條款在此不適用；適用的是 `.agents/README.md` 的「維護規則」。
- 通用層（`AGENTS.md` / 入口檔 / `README.md` / `templates/` / `SKILL.md`）不可寫入任何
  單一專案的名稱、晶片型號或實體路徑。
- `reference-projects/` 與 `skills/*/references/` 在母版內只保留 `.gitkeep`，內容由 `.gitignore` 排除。

## 載入驗證碼
- 本次驗證碼：`KIT-CORE-9F2A31`
- 本章節刻意置於檔案最末，用途是證明工具確實把整份 `project.md` 載入 context。
- 需重新驗證載入是否仍有效時，直接更換此驗證碼即可，舊碼隨即失效。
- 複製到新專案時**必須換一組新的驗證碼**，避免沿用舊專案的碼而誤判載入成功。
