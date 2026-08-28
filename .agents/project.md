# project.md — 模組母版專案設定

> 本 repository 是嵌入式韌體 AI 協作模組的母版，不是產品韌體專案。
> `pack.ps1` 刻意排除本檔；新專案必須由範本建立自己的 `project.md`。

## 專案識別
- 專案識別：`firmware-ai-kit-source`
- Repository：本目錄
- 產品類型：AI 協作模組母版
- 目前 work item：`KIT-001`

## 控制器與架構
- 控制器領域：不適用；母版可支援 EC、PD、Lighting、Keyboard 與其他嵌入式控制器。
- 目標晶片：不適用。
- 韌體架構：不適用。
- 建置系統：不適用。

## 專案能力
- Build：不適用。
- Test：`powershell -ExecutionPolicy Bypass -File .\verify-ai-module.ps1`
- Package：`powershell -ExecutionPolicy Bypass -File .\pack.ps1`
- 產出：`./dist/firmware-ai-collaboration-kit-v4.7z`

## 支援工作類型
- Bug fix、程式碼整合、功能開發、韌體移植、硬體 bring-up、重構與程式碼審查。

## 啟用技能
- 母版維護時僅載入當前工作直接相關技能。
- 可攜套件包含 `module.json` 登記的全部任務型、領域型與 ITE 專門技能。

## 專案限制
- 母版不得包含任何產品專案的 SPEC、schematic、BOM、log、binary、golden reference 或實體路徑。
- `.agents/resources/` 與 `.agents/reference-projects/` 在母版只保留 `.gitkeep`。
- 作用中的 `project.md`、`context-index.md` 與 `TODO.md` 不得進入可攜套件。

## 載入驗證碼
- 本次驗證碼：`KIT-V4-4A7C21`
- 本章節置於最末，作為完整載入 sentinel；複製到新專案時必須產生新碼。
