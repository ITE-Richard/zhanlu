# GEMINI.md

本專案使用同一份跨工具韌體工程規範。Antigravity 應載入根目錄規則；下列 `@` 路徑是檔案參照，不代表內容已展開：

@AGENTS.md
@.agents/module.json
@.agents/project.md
@.agents/context-index.md
@.agents/TODO.md

- `AGENTS.md` 是共用核心與唯一規則來源。
- `.agents/context-index.md` 是程式碼、文件、基準與證據的唯一資料路由。
- `.agents/skills/` 內的技能依任務描述漸進載入。
- `.agents/rules/project-context.md` 是 workspace rule 備援入口，不複製規則內文。

依 `AGENTS.md` 的 Session 載入確認實際讀取必要內容；若任一引用未生效，明確回報缺口，不可直接開始實質工作。
