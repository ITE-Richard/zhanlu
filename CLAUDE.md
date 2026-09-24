# CLAUDE.md

本專案使用同一份跨工具韌體工程規範。以下檔案由 Claude Code 在 session 啟動時展開：

@AGENTS.md
@.agents/module.json
@.agents/project.md
@.agents/context-index.md

- `AGENTS.md` 是共用核心與唯一規則來源。
- `.agents/project.md` 是目標專案已確認事實與限制。
- `.agents/context-index.md` 是程式碼、文件、基準與證據的唯一資料路由。
- `.agents/TODO.md` 是 work item、相依與驗證狀態；依 `AGENTS.md` 的 Session 載入確認按需讀取，不在啟動時展開整份歷史。
- 任務方法與領域知識依需求從 `.agents/skills/` 載入；`.claude/skills/` 只提供 Claude 的技能掛載點。

若任何 import 未生效，先依 `AGENTS.md` 的 Session 載入確認補讀並回報載入缺口，不可直接開始實質工作。
