---
name: ite-ec-porting
description: ITE Embedded Controller 跨晶片或跨框架移植的專門技能，適用 ITE EC 與 legacy／Zephyr 差異核對。
---

# ite-ec-porting 載入器

本檔只是 Claude Code 的掛載點，不含技能內容本體。
完整讀取 `./.agents/skills/ite-ec-porting/SKILL.md` 並以該檔為唯一技能本體；一般移植同時讀取 `firmware-porting` 與 `ec-controller`。

## 使用方式

1. 先完整讀取 `./.agents/skills/ite-ec-porting/SKILL.md`，以該檔內容為準。
2. 依 `./AGENTS.md` 與 `./.agents/project.md` 的規定執行；本載入器不覆寫任何規範。
3. 若 `./.agents/skills/ite-ec-porting/SKILL.md` 不存在，代表套件解壓不完整，先回報缺檔，不可憑印象代替。

## 維護規則

- 技能內容異動一律只改 `.agents/skills/ite-ec-porting/SKILL.md`。
- 本檔只在 `name` / `description` 需要調整時才動，不得複製技能內文進來。
