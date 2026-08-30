# TODO.md — 模組母版工作追蹤

- 專案識別：`zhanlu-source`
- 當前 work item：`KIT-013`

## Work items
| ID | 工作類型 | 功能域 | 項目 | 相依 | 狀態 | 完成條件 |
|---|---|---|---|---|---|---|
| KIT-001 | 重構 | AI 協作模組 | 將 ITE EC 移植母版泛化為跨控制器、跨工作類型模組 | 無 | 完成 | 結構、技能、安裝、驗證、打包全部通過 |
| KIT-002 | Bug fix | Antigravity 載入 | 修正 workspace rule 未引用共用核心並完成三工具環境驗收 | KIT-001 | 完成 | Antigravity 規則可追溯至 `AGENTS.md`、regression 通過、三工具驗收有明確證據 |
| KIT-003 | 文件／封裝 | 可攜套件 | 新增套件根目錄 README，重建可直接安裝到其他專案的 7z | KIT-002 | 完成 | README 位於封裝根目錄、不覆蓋目標 README、乾淨與既有 README 目標安裝通過、封裝清單與完整性通過 |
| KIT-004 | Bug fix | 資料邊界 | 為 `.agents/resources/` 與 `.agents/reference-projects/` 隨套件提供 gitignore 保護 | KIT-003 | 完成 | 目標專案安裝後掛載點內容預設不進版控、不覆蓋目標根 `.gitignore`、驗證與安裝通過 |
| KIT-005 | 功能開發 | 安裝工具 | `setup-ai-module.ps1` 新增 `-Update` 升級模式，保留專案層三份作用中文件 | KIT-004 | 完成 | 升級只覆寫可攜檔案、作用中文件零改動、無可攜檔案時拒絕升級、乾淨安裝行為不變 |
| KIT-006 | 功能開發 | 技能 | 新增 `architecture-design` 與 `firmware-code-review` 技能並補齊路由表 | KIT-005 | 完成 | canonical skill、Claude loader、`module.json`、`AGENTS.md` 與 `.agents/README.md` 路由一致且驗證通過 |
| KIT-007 | 文件／封裝 | 可攜套件 | README 補前置需求、技能清單、升級與故障排除，版本升版並重建 7z | KIT-006 | 完成 | README 內容與實作一致、版本號一致、乾淨安裝與升級安裝實測通過、封裝清單與完整性通過 |
| KIT-008 | 文件 | 可攜套件 | README 補「套用到新專案要填什麼、資料放哪」的逐步指引 | KIT-007 | 完成 | 三份專案層文件的填寫欄位、資料放置位置與首次啟動驗收皆有明確指引，且母版驗證通過 |
| KIT-009 | 功能開發 | 專案層 schema | project.md 欄位收斂為 enum／pattern，並由 AI 於啟動確認驗證 | KIT-008 | 完成 | schema 寫入 module.json、範本改寫、AGENTS.md 補欄位驗證與技能自動推導、README 同步 |
| KIT-010 | 功能開發 | 資料邊界 | 目標專案安裝的模組一律不進版控 | KIT-009 | 完成 | 安裝時寫入目標 .git/info/exclude、verify 以 git ls-files 檢出誤追蹤、AGENTS.md Git 規則改寫、README 補風險警告 |
| KIT-011 | 重構 | 模組識別 | 模組更名為湛盧 zhanlu，五層名稱統一並處理既有安裝遷移 | KIT-010 | 完成 | 名稱五層一致、舊標記可自動清除、舊版套件升級不洩漏、封裝與驗證通過 |
| KIT-012 | 文件 | 可攜套件 | README 補 GitHub clone 安裝通道，明確區分「取得模組」與「安裝模組」 | KIT-011 | 完成 | clone 流程、`zhanlu/` 排除缺口、驗收方式與故障排除皆有指引，母版驗證通過 |
| KIT-013 | Bug fix／重構 | 安裝工具 | 安裝器自動排除 kit 目錄、修正 exclude 區塊堆疊、兩支腳本更名為 zhanlu | KIT-012 | 完成 | 區塊永遠一組、kit 在目標內自動排除且在目標外不多寫規則、更名可由舊版升級遷移、封裝與驗證通過 |

## KIT-013 完成紀錄

### 需求（2026-08-30 使用者決議）
- 安裝時就要把 clone 進目標專案的 kit 目錄一併排除，不接受 KIT-012「列為預期輸出、要使用者手動補一行」的作法。
- 兩支腳本名稱中的 `ai-module` 改為 `zhanlu`，與 KIT-011 的單一字根收斂一致。

### 修正一：安裝器自動排除 kit 目錄
- 先前判斷「安裝器無從得知 kit clone 在哪」是錯的：kit 位置就是 `$PSScriptRoot`，屬於可推導事實而非猜測。
- 實作：比對 `$resolvedSourceRoot` 是否位於 `$targetRoot` 之下（`OrdinalIgnoreCase`），是則取相對路徑加尾斜線寫入排除項。
- kit 在目標之外時不產生任何規則，行為與先前一致；`tools/zhanlu` 這類較深的位置也會寫出正確相對路徑。
- 目標為 repository 子目錄時，該條目與其他條目一樣套用 `--show-prefix` 前綴。

### 修正二：exclude 區塊堆疊（v4.3.0 起的既有 bug）
- **症狀**：每次安裝或升級都在 `.git/info/exclude` 追加一組 `# >>> zhanlu >>>` 區塊，舊區塊不會被移除；被帶進新區塊的 generate-once 條目也一併遺失。
- **根因**：清除舊區塊的 regex 尾段寫成跨行的單引號字串，其內容取決於 `setup-*.ps1` 自身的行尾。該檔在 `core.autocrlf=true` 下工作副本為 CRLF（401 行對 401 個 CR），字串因此成為 `CR LF ? CR LF ?`，regex 語意變成「必須有兩個 CR」。而 exclude 檔是由 `-join "\`n"` 寫出的純 LF，永遠比對不到，`Matches` 恆為 0，`Replace` 不動任何內容。
- **為何 KIT-011 沒抓到**：當時只在單次寫入後檢查區塊數，沒有做「安裝後再升級」的連續驗證。
- **修法**：改用顯式 regex escape `'\r?\n?'` 與 `'\r?\n'`（字面反斜線），與原始檔行尾脫鉤。
- **附帶修正**：carried-over 條目改為過濾掉目標中已不存在的路徑，否則更名後 `/setup-ai-module.ps1` 這類死條目會永久留在區塊內。

### 修正三：腳本更名
- `setup-ai-module.ps1` → `setup-zhanlu.ps1`，`verify-ai-module.ps1` → `verify-zhanlu.ps1`；`pack.ps1` 名稱不含 `ai-module`，不動。
- 同步更新 `module.json` 白名單、`moduleGitPaths`、`pack.ps1`、`AGENTS.md`、兩份 README、`project.md`、`context-index.md`。
- `TODO.md` 的歷史紀錄依 KIT-011 決議不改寫：那些行記錄的是當時確實執行過的指令。
- 舊版安裝的遷移由既有 stale 機制承擔：舊名稱在新 manifest 中不存在，`-Update -RemoveStale` 會刪除；未加該旗標則只回報。

### 版本
- 升至 `4.4.0`：portableFiles 內容變更且含檔名更動，屬 release 級。

### 驗證證據
- 三支腳本 AST parse：全部通過。
- 母版 `verify-zhanlu.ps1 -PackageSource`：exit 0，39 portable／1 package-only／11 skills。
- **堆疊 bug 重現**：以 HEAD（v4.3.0）安裝後再 `-Update`，`.git/info/exclude` 出現 2 組區塊，第二組遺失 `/.vscode/settings.json` 與 `/<專案>.code-workspace`；`git status` 另有 `?? zhanlu/`。
- **修正後**：install → 1 組；`-Update` ×2 → 仍 1 組；generate-once 條目保留；`git status` 全空。
- **kit 在目標內（`zhanlu/`）**：寫出 `/zhanlu/`，`git status` 全空。
- **kit 在較深位置（`tools/zhanlu/`）**：寫出 `/tools/zhanlu/`，升級後仍 1 組，`git status` 全空。
- **kit 在目標外（regression）**：不輸出 kit 目錄訊息、不多寫任何規則，`git status` 全空。
- **v4.3.0 → v4.4.0 真實遷移**：先以 v4.3.0 製造 2 組堆疊區塊與舊腳本名，再以 v4.4.0 `-Update -RemoveStale`；結果 new 2／overwritten 4／unchanged 32，stale 正確列出並刪除兩支舊腳本，區塊收斂為 1 組，死條目 `/setup-ai-module.ps1`、`/verify-ai-module.ps1` 已濾除，`/zhanlu/` 已加入，`git status` 全空。
- 目標端 `verify-zhanlu.ps1`：exit 0。負向測試 `git add -f AGENTS.md` 後以 exit 1 回報 module files are tracked，修復指令已使用新腳本名。
- `pack.ps1`：exit 0，`zhanlu-v4.4.0.7z`，34262 bytes，39 個檔案。
- `7z t`：Everything is Ok，Files: 39；SHA-256 `8A8EDD01B9D44B2CA8F542E6D310AEA566EB18DFB24BA69872A1F49E55ADCDFE`。

### 尚未處理
- 使用者的 `ite-ec-app-Clevo-clevo-zhanlu` 仍是 v4.3.0 安裝，需 `git pull` 後以 `-Update -RemoveStale` 遷移；在那之前該專案 `git status` 會持續出現 `?? zhanlu/`。
- `.agents/README.md` 的安裝章節仍只描述 7z 解壓路線，未提 clone 通道（KIT-012 遺留）。

## KIT-012 完成紀錄

### 問題來源（2026-08-30 使用者實測）
- 使用者把模組 `git clone` 進目標專案，得到 `<專案>/zhanlu/`，三個工具開啟時完全沒載入規則。
- 根因：三工具都只掃描 repository 根目錄的 `AGENTS.md`／`CLAUDE.md`／`GEMINI.md`／`.agents/`，子資料夾不在掃描範圍。**取得模組不等於安裝模組**，clone 之後仍需執行 `setup-ai-module.ps1`。
- 次要風險：若 AI 真的讀到 `zhanlu/CLAUDE.md`，其相對 import 會解析到母版自己的專案層，讓 AI 拿到 `專案識別：zhanlu-source` 而在錯誤前提下工作。
- 文件缺口：README 原本只涵蓋壓縮套件與母版資料夾兩種來源，GitHub clone 這條通道完全沒寫。

### 實作內容
- 〈前置需求〉：`git` 由「安裝器排除版控需要」提升為取得模組的必要條件；7-Zip 降級為僅壓縮套件路線需要。
- 〈從母版複製 vs 從套件安裝〉更名為〈取得模組的三種方式〉，開頭加「取得模組 ≠ 安裝模組」的關鍵觀念區塊，表格新增 GitHub repository 一列。
- 〈最短安裝流程〉拆為〈安裝流程 A：從 GitHub clone（建議）〉、〈安裝流程 B：從壓縮套件〉與〈兩種流程共通〉三節。流程 A 收錄使用者實測的四步驟，含 `git status` 驗收與 `?? zhanlu/` 的預期輸出。
- 〈升級既有專案〉補 clone 內建升級來源的兩行流程（`git pull` + `-Update -TargetPath ..`），並警告專案內會有兩份模組、改規則要回母版。
- 〈目標專案不會 commit 到模組〉補明安裝器不負責排除 clone 目錄的理由與後果。
- 〈故障排除〉新增三列：只 clone 沒安裝、AI 讀到 `zhanlu-source`、`git status` 出現 `?? zhanlu/`；並同步更名後的章節交叉引用。
- 〈套件包含內容〉的 README 定位補上 GitHub repository 第一層說明。

### 設計決議
- `zhanlu/` 不由安裝器自動寫入排除：安裝器無從得知使用者把模組 clone 到哪、那個目錄該不該保留，自動猜測會誤刪或誤忽略使用者自有目錄。改為在 README 明確要求手動補一行，並列為預期輸出而非錯誤。
- clone 放專案內或專案外都支援，README 兩者並陳；放專案內的好處是升級來源自帶，代價是多一行排除設定。

### 驗證證據
- 使用者於 `ite-ec-app-Clevo-clevo-zhanlu`（`clevo` branch，899 tracked files，安裝前工作樹與 `.git/info/exclude` 均確認乾淨）實測流程 A。
- 安裝前 `setup-ai-module.ps1 -WhatIf`：exit 0，零衝突。
- 安裝結果：三個入口檔與母版逐位元組一致；canonical skills 11／Claude loaders 11；`projectKind` 由 `kit-source` 改寫為 `firmware`；專案層三份文件由範本產生，專案識別 `ite-ec-app-clevo-clevo-zhanlu`，驗證碼 `PROJECT-2C7AAAD6`／`CONTEXT-8FFE4AB2` 為新產生而非母版的碼。
- `.git/info/exclude`：`# >>> zhanlu >>>` 標記區塊 1 組、10 條規則，未堆疊；目標 `.gitignore`（17 B）未被動過。
- 目標端 `verify-ai-module.ps1`：exit 0，`zhanlu 4.3.0`／`ZHANLU-CORE-v4`／39 portable／11 skills。
- 安裝後 `git status --porcelain` 僅 `?? zhanlu/`，與 README 新寫的預期輸出一致。
- 母版 `verify-ai-module.ps1 -PackageSource`：exit 0，39 portable files／1 package-only file／11 skills。

### 尚未處理
- 版本未升版、7z 未重建：本次只改 package-only 的 `README.md`，不影響 `portableFiles` 內容，是否併入下次發版待使用者決定。
- `.agents/README.md` 第 49 行仍只描述 7z 解壓路線，未提 clone；該檔是安裝後留在目標專案的維護說明，是否同步待使用者決定。

## KIT-011 完成紀錄

### 命名決議（2026-08-30 使用者決議）
- 模組更名為「湛盧 zhanlu」。湛盧為十大名劍之首、仁道之劍，持劍者無道則劍自去；對應本模組的不可覆寫原則：不守規則、不留證據、靠猜作答就不為其所用。
- 更名前的名稱有五種變體（`aI module`、`embedded-firmware-ai-collaboration-kit`、`firmware-ai-collaboration-kit`、`firmware-ai-kit-source`、`FIRMWARE-AI-CORE-v4`），彼此不一致，本次收斂為單一字根 `zhanlu`。
- 版本同步升至 `4.3.0`：套件識別與 core sentinel 都變更，屬 release 級變更。
- `TODO.md` 內既有的 work item ID 前綴 `KIT-` 與歷史封裝檔名、SHA-256 一律不改寫，那是已發生事實的證據。

### 名稱對照
| 層級 | 舊值 | 新值 |
|---|---|---|
| 模組名 | `embedded-firmware-ai-collaboration-kit` | `zhanlu` |
| 套件檔 | `firmware-ai-collaboration-kit-v4.2.0.7z` | `zhanlu-v4.3.0.7z` |
| 母版識別 | `firmware-ai-kit-source` | `zhanlu-source` |
| core sentinel | `FIRMWARE-AI-CORE-v4` | `ZHANLU-CORE-v4` |
| 索引版次 | `KIT-CONTEXT-v4` | `ZHANLU-CONTEXT-v4` |
| exclude 標記 | `# >>> embedded-firmware-ai-collaboration-kit >>>` | `# >>> zhanlu >>>` |
| workspace 檔 | `aI module.code-workspace` | `zhanlu.code-workspace` |

### 遷移機制
- `setup-ai-module.ps1` 的 exclude 標記不再寫死，改由 `module.json` 的 `name` 推導；日後再更名只改 JSON。
- `module.json` 新增 `legacyMarkerNames`，記錄已退役的標記名稱；升級時把當前與所有歷史標記區塊一併移除再重寫，不會堆疊。

### 測試期間發現並修正的 bug
- **升級會使 generate-once 檔案脫離忽略**：`-Update` 時 `.vscode/settings.json` 與 `<專案>.code-workspace` 已存在，不會進入 `$generatedFiles`，重寫 exclude 區塊時就被漏掉，導致目標專案升級一次後這兩個檔案變成可被 commit，違反 KIT-010 的版控隔離。
- 修法：改寫前先從舊標記區塊撈回既有條目，與新條目取聯集後再寫回，不靠推測檔案來源，也不會誤把目標專案自有的 `.vscode/settings.json` 納入忽略。

### 驗證證據
- `setup-ai-module.ps1` AST parse：通過。
- `verify-ai-module.ps1 -PackageSource`：通過，`zhanlu 4.3.0`、`ZHANLU-CORE-v4`、39 個 portable files、1 個 package-only file、11 個 skills。
- 殘留掃描：全 repo 僅 `module.json` 的 `legacyMarkerNames` 保留舊名稱（刻意），`TODO.md` 歷史紀錄依決議保留。
- 全新安裝（改名後母版，乾淨 git 目標）：exit 0，exclude 標記為 `# >>> zhanlu >>>`，`git add -A` 後 staged 0 筆。
- 真實遷移（`dist/firmware-ai-collaboration-kit-v4.2.0.7z` 安裝後以改名母版 `-Update`）：overwritten 5 / unchanged 33，作用中三份文件保留；舊標記已清除、標記區塊 1 組未堆疊、`/.vscode/settings.json` 與 `/t_legacy.code-workspace` 條目保留、staged 0 筆。
- `pack.ps1`：exit 0，`zhanlu-v4.3.0.7z`，32348 bytes，39 個檔案。
- `7z t`：Everything is Ok，Files: 39；SHA-256 `A21D999DDDFA49BD34628606973E4877CDDC1C87455F510BCAD0BE08B347E59B`。

### 尚未處理
- 母版資料夾本身仍是 `D:\Antigravity\aI module`；資料夾被 IDE 與 shell 佔用，需由使用者關閉編輯器後手動更名為 `zhanlu`。
- `dist/firmware-ai-collaboration-kit-v4.2.0.7z` 仍在，`pack.ps1` 已提示；是否刪除待使用者決定。

## KIT-009／KIT-010 完成紀錄

### 實作內容
- `.agents/module.json` 升版 4.2.0，新增 `projectKind` 與 `projectSchema`（9 個欄位、工作類型 enum、技能路由表）。
- `.agents/templates/project.md` 由 24 欄收斂為 10 欄，各段補欄位說明區塊，說明與可填值分行以免混淆填寫位置。
- `.agents/templates/context-index.md` 補 SPEC 章節頁碼要求、基準唯讀標示與量測證據目錄結構。
- `AGENTS.md` 七處修改：schema 三態檢查、啟動確認新增 `schema=` 欄、基準搜尋結果標示、模組自身唯讀範圍與例外、技能自動推導、Git 規則改寫、安裝規則補 `.git/info/exclude` 與備份提醒。
- `bug-fix` 與 `hardware-bringup` 技能新增「量測證據格式」章節。
- `setup-ai-module.ps1`：安裝與升級後把目標 `module.json` 的 `projectKind` 改寫為 `firmware`；新增 generate-once 的編輯器設定；寫入目標 `.git/info/exclude` 標記區塊；升級前備份三份作用中文件。
- `verify-ai-module.ps1`：新增 `git ls-files` regression，僅在 `projectKind` 不是 `kit-source` 時啟用。
- 兩份 README 同步改寫，含 PDF 能力更正、LA 證據格式、版控邊界與四則新增故障排除。

### 編輯器設定決議
- `.vscode/settings.json` 與 `*.code-workspace` 改為隨套件帶到新專案，母版兩者一併進版控（root `.gitignore` 移除對應忽略）。
- 兩者以 `.agents/templates/vscode-settings.json` 與 `.agents/templates/workspace.code-workspace` 為來源，屬 generate-once：只在目標缺少時產生，永不覆寫，也不納入安裝衝突檢查。
- 若納入一般可攜檔案，已有 `.vscode/settings.json` 的目標會在衝突檢查階段整個安裝失敗；generate-once 同時滿足「帶到新專案」與「不破壞既有設定」。
- workspace 檔以目標資料夾名產生，例如目標 `ec-fw` 產生 `ec-fw.code-workspace`。

### 測試期間發現並修正的 bug
- 非 git 目標安裝失敗：`git rev-parse --is-inside-work-tree 2>$null` 在 `ErrorActionPreference='Stop'` 下，Windows PowerShell 會把原生指令的 stderr 包成 ErrorRecord 而變成終止性錯誤，導致 exit code 1。修正為在該次探測前後暫時改為 `Continue`，兩支腳本同步處理。

### 驗證證據
- 三支腳本 AST parse：全部通過。
- `verify-ai-module.ps1 -PackageSource`（母版）：通過，39 個 portable files、1 個 package-only file、11 個 skills；`projectKind=kit-source`，git 追蹤檢查正確跳過。
- 乾淨 git 目標安裝：exit 0；產生 `.vscode/settings.json` 與 `ec-fw.code-workspace`；`.git/info/exclude` 寫入 10 條規則；目標 `module.json` 的 `projectKind` 改寫為 `firmware`。
- 版控隱形驗證：`git add -A` 後 staged 檔案 0 筆、`git status --porcelain` 0 行，模組完全不出現在目標 repository。
- 目標端 verify：exit 0。
- 負向測試：`git add -f AGENTS.md` 後 verify 以 exit 1 回報「module files are tracked」並附 `git rm -r --cached` 修復指令。
- 既有 `.vscode/settings.json` 的目標：安裝 exit 0，原檔內容逐位元組不變，僅另外產生 workspace 檔。
- 非 git 目標：安裝 exit 0，輸出「Target is not a git repository; version-control exclusion skipped.」。
- `-Update`：exit 0，overwritten 1（`module.json` 因 `projectKind` 差異必然重寫）、unchanged 37；三份作用中文件內容不變，備份目錄含 3 個檔案；`.git/info/exclude` 標記區塊仍為 1 組，未重複堆疊。
- 升級後目標 `projectKind` 仍為 `firmware`，改寫在升級路徑同樣生效。
- 二次乾淨安裝：exit 1，列出 41 個既有檔案並提示改用 `-Update`。
- `pack.ps1`：exit 0，`firmware-ai-collaboration-kit-v4.2.0.7z`，31780 bytes，39 個檔案。
- `7z t`：Everything is Ok，Files: 39；SHA-256 `50141E60345672B5737410AD8D0628508E137FB51B3B9C959CCBE537B5A3AF49`。
- 解壓內容與 manifest 比對：expected 39 / actual 39，差異 0；套件內 `projectKind` 維持 `kit-source`，schema 9 個欄位完整。

### 尚未處理
- `dist/firmware-ai-collaboration-kit-v4.1.0.7z` 仍在，`pack.ps1` 已提示；是否刪除待使用者決定。
- KIT-010 未決風險中的「work item 歷史備份機制」仍未設計，目前僅以 README 警告與 `-Update` 備份因應。

## KIT-009 已確認設計（2026-08-29 使用者決議）
- 產品類型 enum：`NB`；擴充其他產品型態以後再說。
- 控制器領域 enum 單選：`EC`／`PD`／`Keyboard & Lighting`；EC 與 PD 是兩份獨立程式碼，不會同時成立。
- 目標晶片 pattern：`^IT\d{4,5}[A-Z]{0,3}$`；封裝後綴不強制，詳細規格以 SPEC 為準，型號填錯由使用者負責。
- 韌體架構保留現有選項，各選項補說明；說明另置區塊，不寫在值那一行以免混淆填寫位置。
- 專案能力只保留 Build，填可直接執行的指令；Test／Flash／Debug／Static analysis／產出全數刪除。
- 支援工作類型六項各自 enum：`啟用`／`按需求`／`不適用`；enum 值待使用者 review 後確認。
- 刪除欄位：目前 work item（TODO.md 為唯一來源）、CPU／核心、Host／外部介面、不可修改區域、啟用技能。
- 不可修改區域改寫進 AGENTS.md；唯讀範圍為模組共用檔案，可寫例外為專案層三份文件與兩個資料掛載點。
- 啟用技能由控制器領域自動推導：EC→`ec-controller`，PD→`pd-controller`，Keyboard & Lighting→`keyboard-controller`+`lighting-controller`；`ite-ec-porting` 在 EC 且 work item 為移植時加掛。
- 唯讀基準強制置於 `.agents/reference-projects/` 之下；機密資料與硬體證據強制置於 `.agents/resources/` 之下。
- 必要硬體證據只填有無主板與可取得的量測類型；具體檔名與路徑歸 `context-index.md`，避免兩份真相。
- schema 寫入 `.agents/module.json`：該檔已在 requiredSessionFiles，AI 每個 session 必讀；日後擴充只改 JSON，不動腳本與 AGENTS.md 的通用性宣告。
- 驗證層由 AI 在啟動確認執行，不讓 verify 腳本解析 project.md 欄位，因此 project.md 維持人類可讀格式。
- `待確認` 定義為合法的「尚未填寫」值，只列警告不報錯，避免乾淨安裝當場失敗。
- 啟動確認輸出擴充 `schema=<ok 或不合法欄位清單>`。
- AGENTS.md 需新增：`.agents/reference-projects/` 的搜尋結果必須標示為唯讀基準，不可與目標專案結果混報。
- 證據格式規則寫入 `hardware-bringup` 與 `bug-fix` 技能：LA log 以協定解碼後 CSV 為首選、只匯出出問題的時間窗、必附量測筆記記載 channel 對 net 對應、取樣率、觸發條件與韌體版本。
- SPEC 為整份 PDF：先讀目錄頁建立章節與頁碼對照寫入 `context-index.md`，之後按需讀取指定頁段。

## KIT-010 已確認設計（2026-08-29 使用者決議）
- 目標工作專案中 `.agents/`、`.claude/` 與 6 個 root 模組檔案（AGENTS.md、CLAUDE.md、GEMINI.md 與三支 ps1）一律不得 commit；母版本身不受影響，照常版控。
- ignore 規則寫入目標的 `.git/info/exclude`，不新增也不修改目標的 `.gitignore`；理由是 `.gitignore` 會進版控，會在 repo 中暴露模組檔名。
- `.git/info/exclude` 是 git 預設既有檔案，安裝時以 `git rev-parse --git-common-dir` 定位後附加標記區塊，可正確處理 worktree 與 submodule 的 `.git` 為檔案的情形。
- 目標不是 git repository 時跳過此步驟。
- verify 新增 regression：以 `git ls-files` 檢查模組檔案是否已被目標 repo 追蹤，追蹤到即報錯。
- AGENTS.md 工作流程第 8 條需改寫：commit 只含韌體原始碼變更，不再 stage TODO.md。

## KIT-010 未決風險（使用者要求追蹤）
- **work item 歷史遺失**：模組不進版控後，TODO.md 的工作歷史、決策與驗證證據只存在本機工作副本，磁碟損壞或重新 clone 即全數遺失。需要另外的備份或匯出機制，尚未設計。
- **`git clean -xdf` 會無聲刪除整個模組**：該指令專門清除被 ignore 的檔案，會一併刪掉 `.agents/resources/` 內的 SPEC 與證據。README 需明確警告。
- **團隊共享失效**：`.git/info/exclude` 只對該 clone 有效，其他成員需各自安裝並各自填寫專案事實。目標專案為單人使用或團隊共用尚未確認。
- **KIT-004 產出可能冗餘**：整個 `.agents/` 被 ignore 後，`.agents/resources/.gitignore` 與 `.agents/reference-projects/.gitignore` 失去作用，保留為第二道防線或移除待決。
- **build script 掃描污染**：目標專案若以整目錄掃描收集原始碼，可能誤編 `.agents/reference-projects/` 內的基準程式碼。

## KIT-008 現況
- [x] README 新增〈從母版複製 vs 從套件安裝〉，明確禁止整包複製母版資料夾並給出補救步驟。
- [x] 〈安裝後必做〉擴充為四個步驟：project.md 逐欄填寫、context-index.md 資料放置對照、TODO.md work item 寫法、首次啟動驗收。
- [x] 補資料放置對照表，涵蓋原始碼、SPEC、schematic、證據、golden reference 與過大參考樹。
- [x] 補「AI 讀不了 PDF」「衝突要標權威性」「沒登記等於不存在」三項常見漏失。
- [x] 補 work item 五種狀態、可驗證完成條件寫法與範例列。
- [x] 補以驗證碼確認 Agent 真的讀完檔案的驗收方式，以及「套用到新專案」指令。
- [x] 故障排除新增 `project=` 不符與 `work-item=none` 兩列。
- [ ] 版本升版與重建 7z：待使用者決定是否併入本次或累積後再發版。

## KIT-008 驗證證據
- 使用者回報的缺口：README 只有三行「安裝後必做」，未說明複製到新專案時要改哪些檔案、資訊寫在哪、檔案放哪。
- 母版原有文件確認：`setup-ai-module.ps1` 只自動填專案識別、repository 名稱、載入驗證碼、索引版次與索引驗證碼五個範本欄位，其餘欄位一律維持 `待確認`；README 先前未說明這件事，使用者無從得知還要補什麼。
- `verify-ai-module.ps1 -PackageSource`：通過，37 個 portable files、1 個 package-only file、11 個 skills。

## KIT-007 現況
- [x] README 補前置需求（PowerShell 5.1、7-Zip、VSCode 重新載入視窗）。
- [x] README 補 11 個技能的清單與用途，以及多專案收斂的組合方式。
- [x] README 補升級章節、一台機器多專案的建議，以及 9 項故障排除對照。
- [x] 套件版本升至 `4.1.0`，`module.json`、`project.md` 與兩份 README 版本字串一致。
- [x] 修正 `pack.ps1` 在 8.3 短路徑 TEMP 下 staging 比對失敗的 bug。
- [x] `pack.ps1` 打包後提醒 `dist/` 內殘留的舊封裝。
- [x] 重建 7z 並完成套件端對端安裝驗收。

## KIT-007 驗證證據
- `pack.ps1` bug：`$env:TEMP` 為 8.3 短路徑而 `Get-ChildItem` 的 `FullName` 已展開為長路徑，兩者相差 5 字元，`Substring($stage.Length)` 切出多餘前綴，造成 37 個檔案全部誤判為差異而無法打包。改用 `Get-ChildItem -Name` 取相對路徑後通過。
- `verify-ai-module.ps1 -PackageSource`：通過，37 個 portable files、1 個 package-only file、11 個 skills。
- `firmware-ai-collaboration-kit-v4.1.0.7z`：`7z t` 通過，37 個檔案；SHA-256 `283E6DCC05593BA1D5FAB76B652AB640E8A877A5C9CE89E517C7DDA71671D64E`。
- 解壓內容與 manifest 完全一致，差異 0。
- 乾淨 git 專案安裝：11 個 canonical skill 與 11 個 loader 落地，package-only 根 README 未複製；放入 `.agents/resources/ec-spec.txt` 後 `git add -A` 未帶入 index。
- 已有 README 的專案安裝：原 README 內容未被更動。
- 二次安裝：exit code 1 阻擋，並提示改用 `-Update`。
- 由套件對已安裝目標執行 `-Update`：exit code 0，36 個檔案內容相同、零覆寫，作用中三份文件保留。

## KIT-007 使用者確認事項
- [x] Codex 與 Antigravity 的 skill discovery：使用者於 2026-08-29 確認兩個工具在 v4.1.0 下載入正常，不需補工具專屬 loader。
- [x] `dist/` 舊封裝已刪除，只保留 `firmware-ai-collaboration-kit-v4.1.0.7z`。
- [x] KIT-007 的追蹤更新已依使用者指示併入同一筆 commit。

## KIT-006 現況
- [x] 新增 `architecture-design` canonical skill，涵蓋分層、模組邊界、介面契約與多專案收斂。
- [x] 新增 `firmware-code-review` canonical skill，涵蓋正確性、邊界、併發時序、硬體互動與資源。
- [x] 新增兩份 Claude loader，並更新 `module.json` 的 skills 與可攜白名單。
- [x] 補齊 `AGENTS.md` 與 `.agents/README.md` 的工作路由，消除核心宣稱支援重構與審查卻無技能的落差。
- [x] 審查技能改名為 `firmware-code-review`，避開 Claude Code 內建 `code-review` 的撞名遮蔽。
- [x] `-RemoveStale` 補上空目錄清理，改名後不留空的 skill 目錄。

## KIT-006 驗證證據
- 撞名證據：技能命名為 `code-review` 時 Claude Code 只掛載 `architecture-design`，內建 `code-review` 被遮蔽；改名為 `firmware-code-review` 後兩者同時可用。
- Frontmatter strict check：11 個 skill 的 canonical 與 loader 共 22 份檔案，`name` 與目錄一致、`description` 非空、無多餘欄位。
- `verify-ai-module.ps1 -PackageSource`：通過，37 個 portable files、1 個 package-only file、11 個 skills。
- 全新目標乾淨安裝：11 個 canonical skill 與 11 個 loader 完整落地。
- 既有目標 `-Update -RemoveStale`：新增 2 檔、覆寫 4 檔、刪除 2 個 stale 檔並清掉空目錄，作用中三份文件維持保留。
- 多專案收斂路由：`architecture-design` 先定界線、`code-integration` 執行搬移，已寫入核心與維護說明。

## KIT-005 現況
- [x] `setup-ai-module.ps1` 新增 `-Update` 與 `-RemoveStale`，安裝與升級共用同一份白名單與驗證。
- [x] 升級前輸出計畫：新增、覆寫、內容相同、保留與 stale 檔案分類。
- [x] 作用中三份專案層文件在升級路徑完全不寫入。
- [x] hash 比對改用 .NET，避免 `-WhatIf` 傳染到 provider cmdlet 產生雜訊。
- [x] `.agents/README.md` 補升級章節與邊界說明。
- [x] 以實際 v4.0.1 套件安裝的目標做端對端升級驗證。

## KIT-005 驗證證據
- 升級來源：`dist/firmware-ai-collaboration-kit-v4.0.1.7z` 解壓後安裝的目標，含使用者手填的 `project.md` 內容。
- `-Update -WhatIf`：正確列出 2 個新增、3 個覆寫、27 個相同、3 個保留、2 個 stale；執行後目標零變更（`.gitkeep` 仍在、`.gitignore` 未建立）。
- `-Update -RemoveStale`：exit code 0，`.gitkeep` 移除、`.gitignore` 建立，內建驗證通過。
- 作用中文件 SHA-256 升級前後一致：`project.md`、`context-index.md`、`TODO.md` 皆未變動，手填內容保留。
- 負向測試：無模組目錄下 `-Update` 以 exit code 1 拒絕；已安裝目標做乾淨安裝以 exit code 1 拒絕並提示改用 `-Update`；`-RemoveStale` 未搭配 `-Update` 以 exit code 1 拒絕。
- Regression：全新空目錄乾淨安裝仍 exit code 0，專案識別與載入驗證碼正常產生。

## KIT-004 現況
- [x] 以 `.agents/resources/.gitignore` 與 `.agents/reference-projects/.gitignore` 取代 `.gitkeep`，內容為 `*` 加 `!.gitignore`。
- [x] 更新 `module.json` 可攜白名單與母版根目錄 `.gitignore`（掛載點改為自我保護，並忽略編輯器產物）。
- [x] 更新 `.agents/README.md`、`context-index.md` 與 `project.md` 的資料邊界說明。
- [x] 驗證母版、乾淨目標安裝與掛載點忽略行為。

## KIT-004 驗證證據
- `verify-ai-module.ps1 -PackageSource`：通過，33 個 portable files、1 個 package-only file、9 個 skills。
- 乾淨 git 目標安裝：`setup-ai-module.ps1` exit code 0，複製 32 個可攜檔案並產生 3 份專案層文件。
- 掛載點保護：在目標放入 `.agents/resources/secret-spec.pdf.txt` 與 `.agents/reference-projects/golden.c` 後執行 `git add -A`，兩者皆未進入 index。
- `git check-ignore -v`：兩個路徑分別命中 `.agents/resources/.gitignore:3` 與 `.agents/reference-projects/.gitignore:3`。
- 目標專案根 `.gitignore` 未被建立或修改，不影響既有專案的忽略規則。

## KIT-003 現況
- [x] 建立壓縮套件根目錄 `README.md`，包含安裝、初始化、技能路由與資料邊界。
- [x] 將根目錄 README 標示為 package-only，避免覆蓋目標專案既有 README。
- [x] 驗證母版、skills、封裝清單與 7z 完整性。
- [x] 驗證空白及有既有 README 的目標安裝與二次安裝衝突保護。
- [x] 建立聚焦中文 commit。

## KIT-003 驗證證據
- `verify-ai-module.ps1 -PackageSource`：通過，33 個 portable files、1 個 package-only file、9 個 skills。
- 18 份 canonical skill／Claude loader：`quick_validate.py` 全數通過。
- `firmware-ai-collaboration-kit-v4.0.1.7z`：`7z t` 通過，33 個檔案與 manifest 完全一致；SHA-256 `B481CFC43CEB52255F0177EC989291D3B2BBB9792949236C433ACA20C747E25D`。
- 空白目標安裝通過，package-only 根目錄 README 未複製到目標專案。
- 已有 README 的目標安裝通過，原內容保持不變；二次安裝以 exit code 1 在寫入前阻擋。

## KIT-002 現況
- [x] 以官方文件確認 Antigravity workspace rules 與 skills 的權威路徑。
- [x] 重現 `.agents/rules/project-context.md` 未引用根目錄 `AGENTS.md`，且舊驗證未偵測。
- [x] 補上共用核心引用並新增缺漏引用 regression。
- [x] 重建及驗證 v4 可攜套件。
- [x] 完成 Claude Code、Codex 與 Antigravity 環境驗收。

## KIT-001 現況
- [x] 確認三工具載入機制與現有封裝邊界。
- [x] 重寫共用核心與三工具入口。
- [x] 建立通用專案設定、資料索引與工作範本。
- [x] 建立任務型與領域型技能。
- [x] 建立安全安裝與驗證腳本。
- [x] 產生並檢查 v4 可攜套件。
- [x] 完成 Git commit。

## 決策與差異
- ITE EC 移植保留為可選專門技能，不再是核心預設工作模式。
- 專案資料以 `project.md`、`context-index.md`、`TODO.md` 三份權威來源分工。
- 三工具入口不複製核心內文；各自導向同一份檔案。

## 驗證證據
- `verify-ai-module.ps1 -PackageSource`：通過，33 個 portable files、1 個 package-only file、9 個 skills。
- 18 份 canonical skill / Claude loader：`quick_validate.py` 全數通過。
- 乾淨暫存目標安裝、初始化、二次安裝衝突保護：通過。
- `firmware-ai-collaboration-kit-v4.0.1.7z`：`7z t` 通過，解壓後 33 個檔案與 manifest 完全一致。

## 三工具環境驗收
- [x] Claude Code 2.1.251：新專案 `CLAUDE.md` import 符合官方載入契約，9 個 project skill loader 通過原生 strict validation。
- [x] Codex CLI 0.150.0-alpha.12.2：獨立新專案的本機 prompt-input 載入 1 份目標 `AGENTS.md`、9 個 repo skills，父 repository 污染為 0。
- [x] Antigravity IDE 1.107.0：官方 `.agents/rules` 與 `.agents/skills` 路徑相符；新專案有 1 個 workspace rule、9 個 skills，rule 可追溯至 `AGENTS.md`。
- [x] v4.1.0（11 skills）：Claude Code 於本 session 直接掛載 `architecture-design` 與 `firmware-code-review`；Codex 與 Antigravity 由使用者於 2026-08-29 確認載入正常。

## KIT-002 驗證證據
- 修正前：workspace rule 未引用 `AGENTS.md`，舊版 `verify-ai-module.ps1` 仍回報通過。
- 修正後：移除 `@../../AGENTS.md` 的負向 fixture 會以 exit code 1 回報缺少共用來源引用。
- `verify-ai-module.ps1`：通過，32 個 portable files、9 個 skills。
- `firmware-ai-collaboration-kit-v4.7z`：`7z t` 通過，32 個檔案；SHA-256 `A234434B0AD36E1C0443BD4AEC42AE69E824226DAAE88A9B3FC18B09EA6D972B`。
- 三工具均採不呼叫模型的本機 discovery／validator 驗收，未將專案內容送往外部服務。
