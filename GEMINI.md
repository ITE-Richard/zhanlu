# GEMINI.md

本專案的 AI 協作規範採**通用層 / 專案層分離**設計，模組說明見 `.agents/README.md`。

Antigravity 會將同目錄的 `GEMINI.md` 與 `AGENTS.md` 一併視為 directory rules 自動載入，因此 `AGENTS.md` 應已在 context 中。

`AGENTS.md` 只包含跨專案通用規範。本專案專屬資訊不在其中，session 啟動時必須另行完整讀取：

- `./.agents/project.md`：晶片、參考專案、路徑、建置指令、移植目標順序、載入驗證碼。
- `./.agents/TODO.md`：移植進度與待確認事項。

啟動確認格式、規範版本、載入驗證碼與所有工作規則，一律以 `AGENTS.md` 與 `.agents/project.md` 為準。

若 context 中看不到 `AGENTS.md`，或任一專案層檔案未載入，必須先完整讀取 `./AGENTS.md`、`./.agents/project.md` 與 `./.agents/TODO.md` 再開始工作，並在回覆中指出自動載入失效。

本檔刻意不重複規範內容，避免多份來源漂移。規範異動只改 `AGENTS.md`，專案資訊異動只改 `.agents/project.md`。
