# CLAUDE.md

本專案的 AI 協作規範採**通用層 / 專案層分離**設計，模組說明見 `.agents/README.md`。

下列 import 由 harness 直接展開並載入 context，不依賴模型自行讀取：

@AGENTS.md
@.agents/project.md
@.agents/TODO.md

- `AGENTS.md`：跨專案通用工作規範（複製到其他 EC 專案時原樣沿用）。
- `.agents/project.md`：本專案專屬設定（晶片、參考專案、路徑、移植目標順序、載入驗證碼）。
- `.agents/TODO.md`：本專案移植進度與待確認事項。

啟動確認格式、規範版本、載入驗證碼與所有工作規則，一律以 `AGENTS.md` 與 `.agents/project.md` 為準。

若任何 import 未生效（context 中看不到對應內容），必須先完整讀取 `./AGENTS.md`、`./.agents/project.md` 與 `./.agents/TODO.md` 再開始工作，並在回覆中指出 import 失效。

本檔刻意不重複規範內容，避免多份來源漂移。規範異動只改 `AGENTS.md`，專案資訊異動只改 `.agents/project.md`。
