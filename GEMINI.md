# GEMINI.md

本專案使用同一份跨工具韌體工程規範。Antigravity 應載入根目錄規則，並透過下列引用取得同一份專案資料：

@AGENTS.md
@.agents/module.json
@.agents/project.md
@.agents/context-index.md
@.agents/TODO.md

- `AGENTS.md` 是共用核心與唯一規則來源。
- `.agents/context-index.md` 是程式碼、文件、基準與證據的唯一資料路由。
- `.agents/skills/` 內的技能依任務描述漸進載入。
- `.agents/rules/project-context.md` 是 workspace rule 備援入口，不複製規則內文。

若任一引用未生效，先完整讀取五個檔案並明確回報缺口，不可直接開始實質工作。
