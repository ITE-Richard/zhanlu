# 待確認事項與移植進度總表

> 本檔為**專案專屬進度追蹤**，格式固定、內容每案重寫。
> 項目編號與名稱必須與 `./.agents/project.md`「移植目標順序」一致。
> 所有專案內檔案連結一律使用相對路徑，例如 `[prj_gpio.h](../projects/<project>/prj_gpio.h)`。

## 移植目標順序逐項現況與差異總表

| # | 項目 | 狀態 | 參考專案 vs 當前專案關鍵差異與現況 |
|---|------|------|------|
| 1 | GPIO 設定 | 尚未開始 | |
| 2 | Power sequence | 尚未開始 | |
| 3 | Host eSPI bus functionality | 尚未開始 | |
| 4 | Keyboard matrix / Fn hotkey | 尚未開始 | |
| 5 | Power switch | 尚未開始 | |
| 6 | Lid device | 尚未開始 | |
| 7 | Smart battery | 尚未開始 | |
| 8 | Smart charger | 尚未開始 | |
| 9 | ACPI EC | 尚未開始 | |
| 10 | ADC scan data | 尚未開始 | |
| 11 | Thermal sensors | 尚未開始 | |
| 12 | Fan control | 尚未開始 | |
| 13 | Power bank | 尚未開始 | |
| 14 | eSPI OOB PECI power limit policy | 尚未開始 | |
| 15 | eRPMC | 尚未開始 | |
| 16 | Type-C PD | 尚未開始 | |

- 狀態用語統一為：`尚未開始` / `進行中` / `已完成，持續追蹤` / `已完成`。

---

### 交叉影響與待決定事項

#### 交叉影響
- <某項完成後解鎖或影響哪些項目>

#### 待使用者決定
- [ ] <需要使用者拍板的選項與 trade-off>

---

## 0. SoC 世代差異總表（<參考專案 SoC> vs <當前專案 SoC>）

依官方 Datasheet 核對基準：見 `./.agents/project.md` 的「SPEC 文件」。

### 重大確認與更正
- [ ] <已核對確認的結論>

### 晶片架構差異
- [ ] <差異項目與影響>

### 已確認相容項目
- <確認一致或為超集的資源>

---

## 1. <項目名稱>

- [x] **（已解決）<結論>**：<做法與落點>
- [ ] <未解決事項與缺口>

<!-- 依 project.md 的移植目標順序，逐項複製本區塊 -->
