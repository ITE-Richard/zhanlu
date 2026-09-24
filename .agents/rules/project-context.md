---
trigger: always_on
description: 載入湛盧共用核心與目前專案資料的入口。
---

# Project Context

本 workspace 的專案資料以下列檔案為唯一來源：

@../../AGENTS.md
@../module.json
@../project.md
@../context-index.md
@../TODO.md

上述 `@` 路徑只提供檔案參照。開始實質工作前依 `AGENTS.md` 的 Session 載入確認讀取必要內容；缺少或引用失效時停止實作並回報。
