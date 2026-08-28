# AGENTS.md — Embedded Controller 移植工作規範（通用核心）

## 本檔定位
- 本檔是**跨專案共用的通用規範**，不含任何專案名稱、晶片型號、板級細節或實體路徑。
- 複製到另一個 EC 專案時，本檔**原樣沿用、不需修改**。
- 所有專案專屬資訊一律寫在 `./.agents/project.md`，進度追蹤一律寫在 `./.agents/TODO.md`。
- 規範異動只改本檔；專案資訊異動只改 `./.agents/project.md`。兩者不可互相重複內容，避免來源漂移。

## 模組架構
| 層級 | 檔案 | 性質 | 複製到新專案時 |
|------|------|------|----------------|
| 入口 | `CLAUDE.md` / `GEMINI.md` / `AGENTS.md` | 通用 | 原樣複製 |
| 通用規範 | `AGENTS.md`（本檔） | 通用 | 原樣複製 |
| 專案設定 | `.agents/project.md` | 專案專屬 | 由 `.agents/templates/project.md` 重新填寫 |
| 進度追蹤 | `.agents/TODO.md` | 專案專屬 | 由 `.agents/templates/TODO.md` 重新建立 |
| 技能包 | `.agents/skills/<skill>/SKILL.md` | 通用 | 原樣複製 |
| 技能載入器 | `.claude/skills/<skill>/SKILL.md` | 通用 | 原樣複製 |
| 打包腳本 | `pack.ps1` | 通用 | 原樣複製 |
| Datasheet | `.agents/skills/<skill>/references/` | 專案專屬 | 換成該專案晶片的 SPEC |
| 參考專案 | `.agents/reference-projects/<name>/` | 專案專屬 | 換成該專案的 golden reference |
- 技能載入器只含 frontmatter 與指向本體的說明，不得複製技能內文，避免同一份方法論出現兩個來源。
- 新專案套用步驟見 `./.agents/README.md`。

## 可攜式封裝邊界
- 跨專案 7z 只封裝通用入口、通用規範、使用說明、空白範本、skill 指令本體與載入器、打包腳本。
- 打包一律以 `pack.ps1` 的白名單執行，不可手動整包壓縮專案目錄；該腳本在壓縮前會自檢封裝邊界，發現專案層檔案即中止。
- 不封裝目前專案的 `.agents/project.md`、`.agents/TODO.md`、SPEC、golden reference、build output 或其他專案資料。
- 新專案解壓後，必須由 `.agents/templates/` 建立新的 `project.md` 與 `TODO.md`；不得把舊專案的作用中檔案當成範本沿用。
- skill 的 `references/` 與 `.agents/reference-projects/` 是專案資源掛載點，不屬於通用 skill 本體；每案都要重新放入並在 `project.md` 登記。
- 可攜套件的內容清單、解壓方式與新專案責任分工，以 `./.agents/README.md` 為準。

## Session 啟動確認
- 每個新 session 的第一次回覆，開頭必須先輸出一行讀取確認，再進入正常回覆內容。
- 啟動時必讀檔案（缺一不可）：
  1. `./AGENTS.md`（本檔）
  2. `./.agents/project.md`
  3. `./.agents/TODO.md`
- 格式：`已讀取：<檔名> (<位元組數>) / <檔名> (<位元組數>) … ｜ 規範版本：<規範版本> ｜ 驗證碼：<驗證碼>`
- `<規範版本>` 取自本檔最末 `## 規範版本` 章節，證明通用規範已完整載入。
- `<驗證碼>` 取自 `./.agents/project.md` 最末 `## 載入驗證碼` 章節，證明專案設定已完整載入。
- 兩者都必須取自檔案實際內容，不可自行編造、推測或省略。
- 只列出本 session 確實讀取過的檔案。未讀取的檔案不可列入。
- 若應讀取的檔案讀取失敗或不存在，必須明確指出該檔名與狀況，不可略過或沉默帶過。
- 此確認每個 session 只輸出一次，後續回覆不重複。
- 收到「工作開始」時，須重新輸出一次確認，並包含該指令要求重讀的所有檔案。

## 語言與回覆方式
- 與使用者互動時一律使用繁體中文。
- 回覆先給結論，再列出關鍵依據、風險、待確認事項。
- 不主動產生額外文件；只有在使用者於當前對話明確要求時才建立文件。
- 不主動提供給其他 AI 工具的 prompt；本專案由當前 AI 工具（Claude Code / Codex / Antigravity）直接完成工作。
- 若需求不明、硬體資訊不足、或缺少關鍵檔案，先提出缺口與確認問題，不要猜測。

## 名詞定義
- 參考專案：已完成實作且已完成驗證的舊專案，為 golden reference。實際路徑與晶片型號見 `./.agents/project.md`。
- 當前專案：目前實際修改與移植的 target project，即本規範所在的專案根目錄。
- 未特別說明時，專案移植、修改、重構、驗證等工作，都是指當前專案。
- 未經使用者明確要求，不可修改參考專案內容。

## 路徑規則
- 當前專案根目錄即本檔所在目錄；當前工作目錄預設為專案根目錄。
- 本規範與所有 `.agents/` 下文件一律使用相對於專案根目錄的相對路徑，不可寫死絕對路徑或磁碟機代號，以便整套規範直接複製到其他專案沿用。
- 參考專案路徑、SPEC 路徑、參考專案架構等實際值，一律以 `./.agents/project.md` 為準，不可寫進本檔。
- 進行比對、分析、移植時，參考專案視為唯讀來源，當前專案視為可修改目標。
- 若使用者在對話中另外提供檔案或資料夾路徑，優先閱讀那些路徑，但不得因此覆蓋上述名詞定義。

## 工作總原則
- 每次開始任務時，先確認參考專案內容與當前專案內容，理解兩邊對應模組、目錄與功能落點後再開始實作。
- 先做差異分析，再提出 migration plan，再進入實作。
- 先閱讀參考專案對應功能的實作與驗證線索，再閱讀當前專案與對應框架模組。
- 不可只靠函式名稱、檔名、或模組名稱推測兩邊行為等價。
- 多模組、大範圍、跨子系統任務，先輸出 phase breakdown，不要直接大改。
- 所有修改都要保留可追溯性：來源功能位置、目標落點、差異原因、驗證方式。
- 本專案目標是將參考專案完整移植到當前專案，而不是只完成局部功能、範例功能、或僅能編譯的版本。
- 參考專案是 golden reference；當前專案的功能、行為、事件流程、時序與驗證結果應盡量與參考專案一致。
- 若當前專案與參考專案出現差異，需先確認是 SoC 差異、框架差異、板級差異，還是移植缺漏。

## 執行順序規則
- 移植目標順序定義在 `./.agents/project.md` 的 `## 移植目標順序` 章節。
- 該章節列出的項目必須按照順序進行，不可任意跳項或重新排序，除非使用者明確要求。
- 每次只處理一個 item，完成後再進入下一個 item。
- 若當前 item 仍有未解決問題、未完成驗證、或仍有編譯警告 / 錯誤，不可提前進入下一項。
- 每完成或更新一個 item，同步更新 `./.agents/TODO.md` 的狀態與差異說明。

## 功能優先順序
- 先處理系統能穩定啟動與維持運作的基礎項：build、board config、GPIO、init flow、power sequence、host interface（eSPI / LPC）。
- 再處理平台事件與輸入：keyboard matrix、power switch、lid、ACPI event。
- 再處理 battery / charger / ADC / thermal / fan。
- 最後處理進階與附加功能：power bank、PECI policy、eRPMC、Type-C PD。
- 若某功能依賴 power state、host event、ACPI EC space、interrupt 或特定 init 順序，必須等相依基礎完成後再實作。

## 每項完成後的固定流程
- 每完成一個 item 的移植後，先進行編譯確認。
- 編譯結果必須確認沒有 error，也沒有新增 warning。
- 若編譯失敗，或出現 warning，必須先修正到乾淨後才能進入 git 流程。
- 編譯確認無誤後，將本次修改的檔案做 Stage Changed。
- Stage 完成後，建立 git commit。
- Commit message 一律使用中文撰寫。
- Commit 後不要 push；未經使用者明確要求，不可執行 push。

## Git 提交規則
- 每次 commit 只對應一個已完成且已驗證的移植項目。
- 不可把多個移植項目混在同一個 commit。
- Commit message 要能反映本次完成的移植項目與目的，使用簡潔中文。
- 範例：
  - `完成 GPIO 移植與編譯驗證`
  - `完成 Power sequence 移植與編譯驗證`
  - `完成 eSPI 功能移植與編譯驗證`
- 未經使用者明確要求，不可 amend 歷史 commit，不可 push，不可做破壞性 git 操作。

## 必做差異分析
- **SoC 差異**（參考專案晶片 vs 當前專案晶片，型號見 `./.agents/project.md`）：GPIO port 數量與腳位存在性、interrupt / wake-up、clock / PLL 頻率、power domain、host interface、ADC 解析度與通道、PWM/tach、I2C/SMBus 控制器數量、PECI、Type-C/PD 相關資源、H2RAM / shared memory 語意。
- **韌體架構差異**（參考專案架構 vs 當前專案架構）：init model、執行緒 / 排程模型、device model、設定描述方式、logging、driver binding、hook 機制。
- **板級差異**：pinmux、GPIO polarity、default level、boot strap、power rail control、PWRBTN#、LID、AC presence、battery/charger 路徑、IO expander、PD interrupt pin、fan/thermal channel。
- **驗證差異**：參考專案如何驗證、有哪些 log/waveform/sequence evidence、當前專案如何建立對應驗證。
- 所有晶片層差異必須以 `./.agents/project.md` 指定的 SPEC 文件為依據核對，不可憑印象或命名推論。

## 架構移轉規則
- 當前專案與參考專案的韌體架構（Legacy bare-metal / RTOS / Zephyr 等）定義在 `./.agents/project.md`。
- 若兩邊架構不同，不可把參考專案的全域初始化流程、輪詢迴圈、全域旗標、裸中斷流程直接平移。
- 平移前先評估是否應轉為執行緒、work queue、timer、callback 或 driver API。
- 不可在未確認執行 context 的情況下，把參考專案的 delay、busy wait、或 ISR 行為直接搬過來。
- 任何目標架構特有做法，都要說明與參考專案行為如何對應。
- 當前專案若為 Zephyr：優先從 devicetree、Kconfig、board defconfig、driver binding、init priority、kernel context 理解系統。
- 當前專案若為 Legacy / 原廠 SDK：優先從 chip register header、main loop、interrupt table、hook table、linker script 理解系統。

## 各功能移植要求
- GPIO：確認 board GPIO configuration、pin direction、polarity、default level、boot strap、GCR configuration、interrupt trigger type、目標晶片是否真的存在該腳位。
- Power sequence：明確比對 G3、S5、S3、S0 狀態切換與 AC mode EC boot-up trigger，不可只靠函式名稱推測流程一致。
- Host interface（eSPI / LPC）：比對 host event、VW、OOB message、reset / warmboot hook、ACPI EC 互動與對應事件機制。
- Keyboard：確認 matrix table、scan 流程、Fn hotkey、debounce、多 SKU 鍵盤表切換、event dispatch。
- Battery / charger：確認 configuration registers、adapter current、charging policy、plug in/out 流程、memory update 機制。
- Thermal / fan：確認 sensor channel、tachometer、PWM/control policy、temperature table、關聯 power state。
- Type-C PD：確認 PD board ID、adapter PDO data、controller init library、interrupt pin assign、與 EC 資料交換路徑。
- 其他專案特有子系統：依 `./.agents/project.md` 的平台備註處理。

## 需要優先閱讀的內容
- 參考專案中與目標功能直接相關的 module、header、board config、GPIO table、power sequence、host interface、ACPI、battery/charger、PD 程式碼。
- 當前專案中的建置與設定入口：board / DTS / Kconfig / defconfig / prj.conf / CMakeLists 或等價的專案設定檔，以及 `drivers/`, `soc/`, `arch/` 等平台層。
- 與 bring-up、驗證、波形、log、測試流程有關的文件與紀錄。

## 修改邊界
- 不可猜測 register value、timing、delay、reset sequence、power rail ordering。
- 不可為了讓 build 通過而關閉 warning、註解測試、繞過 assert、忽略 error handling。
- 不可在未確認硬體語意前，重命名或重組關鍵 power、host、interrupt 流程。
- 不可一次混合多個功能域的大型修改；應保持 patch 可審查、可驗證、可回退。
- 不修改 generated code、第三方 vendor code、binary、tool output，除非使用者明確要求。
- 不修改參考專案；參考專案只用於閱讀、比對、抽取行為與驗證依據。

## 驗證要求
- 每次修改都要附最小驗證結果：build、關鍵 log、對應測試步驟、或靜態檢查結果。
- 對 power sequence、host interface、GPIO、interrupt、battery/charger、fan/thermal 等功能，盡量提供可比對參考專案的證據。
- 若目前無法做實板驗證，必須明確標示：
  - 已完成的靜態驗證
  - 已完成的程式碼路徑檢查
  - 仍待實板驗證的項目
- 若功能與參考專案仍有差異，要明確列出差異、風險、可能影響範圍。

## 程式風格
- 遵守現有 codebase 風格，不重排無關程式碼。
- 不需要在程式碼裡面寫太多註解。
- 每個註解最多三行，且只在必要時說明硬體限制、時序原因、workaround 背景或非直觀設計。
- 優先寫清楚、可驗證、可維護的程式，不用註解堆砌說明顯而易見的事情。
- 若有 formatter、linter、static analysis 工具，優先遵守現有工具與規則。

## 回覆格式
- 先給結論。
- 再列出：修改檔案、移植來源、目標落點、差異說明、風險、已完成驗證、待確認事項。
- 若任務範圍大，先提供 migration plan 與 phase breakdown。
- 若需要使用者決策，提供明確選項與 trade-off，不要只丟開放式問題。

## 溝通指令定義
- 「工作開始」：
  - 重新確認 `./AGENTS.md`、`./.agents/project.md`、`./.agents/TODO.md`。
  - 重新完整確認參考專案與當前專案所有設計，並依照 `./.agents/project.md`「移植目標順序」中的各項目依序列出。
  - 不能只讀規範與 TODO，要完整重新確認參考專案與當前專案的實際內容，再列出兩個專案設計的差異與問題。所有晶片差異一律回到 `./.agents/project.md` 指定的 SPEC 文件查證。
- 「套用到新專案」：
  - 依 `./.agents/README.md` 的步驟盤點新專案，建立或重建 `./.agents/project.md` 與 `./.agents/TODO.md`。
  - 明確分列「可由 repository / SPEC 自動查得」與「必須由使用者提供」的資訊；不可自行猜測晶片型號、參考專案、板級設計或驗證結果。

## 規範版本
- 本次規範版本：`EC-PORTING-CORE-v3`
- 本章節刻意置於檔案最末，用途是證明工具確實把整份 `AGENTS.md` 載入 context，而非只讀開頭或僅由模型自行宣稱已讀。
- 專案層的載入驗證碼另定義於 `./.agents/project.md`。
- 若某工具的 session 啟動確認未同時附上正確的規範版本與驗證碼，即代表載入不完整，須先修正載入機制，不可直接開始工作。
