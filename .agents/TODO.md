# 模組母版維護進度與待確認事項

> 本檔追蹤的是**這套 AI 協作規範模組本身**的維護狀態，不是任何 EC 專案的移植進度。
> 新 EC 專案的 TODO 一律由 [templates/TODO.md](./templates/TODO.md) 重建。
> 打包腳本 `pack.ps1` 刻意排除本檔。

## 模組健康度總表

| # | 項目 | 狀態 | 說明 |
|---|------|------|------|
| 1 | 三工具入口 | 已完成 | `CLAUDE.md`(@import) / `AGENTS.md`(Codex) / `GEMINI.md`(Antigravity) 三條載入路徑齊備 |
| 2 | 通用／專案分層 | 已完成 | 通用層全文無絕對路徑、無單一專案名稱；兩層只透過 `.agents/project.md`、`.agents/TODO.md` 銜接 |
| 3 | 空白範本 | 已完成 | `templates/project.md`、`templates/TODO.md` 可直接複製使用 |
| 4 | 技能包 | 已完成 | 本體 `.agents/skills/ite-ec-porting/SKILL.md`；`.claude/skills/ite-ec-porting/SKILL.md` 為載入器，不含內文 |
| 5 | 專案資源掛載點 | 已完成 | `reference-projects/`、`skills/*/references/` 只保留 `.gitkeep`，內容由 `.gitignore` 排除 |
| 6 | 打包 | 已完成 | `pack.ps1` 白名單打包 + 封裝邊界自檢，產出 `dist/ite-ec-ai-porting-kit-v3.7z` |
| 7 | 版本控制 | 已完成 | 本目錄已為獨立 git repository，規範異動可獨立留下中文 commit |

---

## 待辦

- [ ] **新專案實地驗收**：把 7z 解到一個真實 EC 專案，走完 `README.md`「套用到新專案」7 個步驟，
      確認三個工具的啟動確認都能輸出正確的規範版本與新驗證碼。
- [ ] **`.claude/skills` 載入器驗證**：確認 Claude Code 的 skill 清單能列出 `ite-ec-porting`，
      且呼叫後會被導向 `.agents/skills/ite-ec-porting/SKILL.md` 本體。
- [ ] **Codex 啟動確認實測**：Codex 不展開 import，需實測其是否依 `AGENTS.md`「Session 啟動確認」
      主動讀取 `.agents/project.md` 與 `.agents/TODO.md`。
- [ ] **Antigravity 目錄規則實測**：確認 `GEMINI.md` + `AGENTS.md` 會被自動載入，且專案層檔案有被補讀。
- [ ] **技能包泛用性**：`SKILL.md` 目前以 ITE EC 為範疇；若未來要涵蓋其他廠牌 EC，需評估
      是拆成第二個 skill，還是把 ITE 專屬檢查表下沉到各專案層。

---

## 待使用者決定

- [ ] `d:\Antigravity\_daytona-ai-layer-backup\` 內的 daytona 專案層備份（`project.md`、`TODO.md`、
      3 份 SPEC PDF、29MB golden reference）最終要放回 daytona 工作 repository，還是就地長期保存？
      確認前不要刪除，該處可能是唯一副本。
