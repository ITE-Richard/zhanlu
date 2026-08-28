---
name: ite-ec-porting
description: ITE Embedded Controller 專案移植技能包載入器。用於把已驗證的 EC 韌體（legacy 原廠 SDK 或既有專案）移植到另一顆 ITE EC（IT51526 / IT51386 / IT8298 / IT8233 等）或另一套框架（Zephyr）。涵蓋差異分析方法、SPEC 查證流程、逐項移植檢查表與驗證要求。
---

# ite-ec-porting 載入器

本檔只是 Claude Code 的掛載點，**不含技能內容本體**，避免同一份方法論出現兩個來源而漂移。

技能本體位於專案根目錄的 `.agents/skills/ite-ec-porting/SKILL.md`（Codex 與 Antigravity 依 `.agents/project.md`
登記的路徑直接讀取同一份檔案）。

## 使用方式

1. 先完整讀取 `./.agents/skills/ite-ec-porting/SKILL.md`，以該檔內容為準。
2. 依 `./AGENTS.md` 與 `./.agents/project.md` 的規定執行；本載入器不覆寫任何規範。
3. 若 `./.agents/skills/ite-ec-porting/SKILL.md` 不存在，代表套件解壓不完整，先回報缺檔，不可憑印象代替。

## 維護規則

- 技能內容異動一律只改 `.agents/skills/ite-ec-porting/SKILL.md`。
- 本檔只在 `name` / `description` 需要調整時才動，不得複製技能內文進來。
