# project.md — 專案設定（<專案代號>）

> 本檔是**專案專屬設定**；複製整套規範到新專案後，本檔與 `TODO.md` 都必須由空白範本重新建立。
> 通用工作規範一律以 `./AGENTS.md` 為準，本檔不重複規範內容。
> 填寫規則：不確定的欄位寫「待確認」，不可猜測；所有路徑一律使用相對路徑。

## 專案識別
- 專案代號：`<project-name>`
- Repository：`<repo-name>`
- 產品線：<平台 / 客戶 / 機種>

## 晶片與架構
| 項目 | 參考專案 | 當前專案 |
|------|----------|----------|
| SoC | <例：IT51386 / IT8298 / IT8233> | <例：IT51526> |
| CPU | <架構> | <架構> |
| 韌體架構 | <Legacy 原廠 SDK / RTOS / Zephyr> | <Legacy 原廠 SDK / RTOS / Zephyr> |
| Host interface | <eSPI / LPC> | <eSPI / LPC> |

## 路徑設定
- 當前專案路徑：`.`
- 參考專案路徑：`./.agents/reference-projects/<reference-project-name>`（唯讀 golden reference，不可修改）
- 進度追蹤：`./.agents/TODO.md`
- 移植技能包：`./.agents/skills/ite-ec-porting/SKILL.md`

## SPEC 文件
| 用途 | 路徑 |
|------|------|
| 當前專案 SoC | `./.agents/skills/ite-ec-porting/references/<current-soc>.pdf` |
| 參考專案 SoC | `./.agents/skills/ite-ec-porting/references/<reference-soc>.pdf` |
| 其他（PD / UCSI 等，選填） | `./.agents/skills/ite-ec-porting/references/<other>.pdf` |

## 建置與驗證
- 建置指令：`<例：Build.bat <project>>`
- 對應底層指令：`<例：west build -p always -b <board>>`
- 產出：`<output.bin>`
- 框架版本基準：`<例：Zephyr 4.4.99 / SDK 版本>`
- 專案來源目錄：`<例：projects/<project>/>`
- 板級設定檔：`<例：projects/<project>/boards/<board>.overlay>`

## 移植目標順序
> 依專案實際需求調整增減與排序；`AGENTS.md` 的執行順序規則會直接引用本節。
1. GPIO 設定
2. Power sequence
3. Host eSPI bus functionality
4. Keyboard matrix / Fn hotkey
5. Power switch
6. Lid device
7. Smart battery
8. Smart charger
9. ACPI EC
10. ADC scan data
11. Thermal sensors
12. Fan control
13. Power bank
14. eSPI OOB PECI power limit policy
15. eRPMC
16. Type-C PD

## 平台特別備註
> 只寫已由 SPEC、schematic、程式碼或使用者確認過的事實。包含但不限於：
> debug console 腳位、不存在或被 remap 的腳位、SMBus/I2C 通道配置、IO expander、
> 充電 IC / PD IC 型號、時脈差異、本專案不實作或暫緩的項目與原因。
- <備註 1>
- <備註 2>

## 載入驗證碼
- 本次驗證碼：`<PROJECT>-EC-<6 碼英數>`
- 本章節刻意置於檔案最末，用途是證明工具確實把整份 `project.md` 載入 context。
- 需重新驗證載入是否仍有效時，直接更換此驗證碼即可，舊碼隨即失效。
- 複製到新專案時**必須換一組新的驗證碼**，避免沿用舊專案的碼而誤判載入成功。
