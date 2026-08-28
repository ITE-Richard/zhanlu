---
name: hardware-bringup
description: 新晶片、新板或新控制器韌體 bring-up。適用從權威文件建立安全的最小啟動路徑，逐步啟用周邊並以 log、量測與波形驗證。
---

# Hardware Bring-up

## 進場條件
- 從 `../../context-index.md` 確認 silicon／board revision、SPEC、schematic、power tree、build、flash 與 debug 路徑。
- 缺少會影響供電、boot strap、reset 或 pin safety 的資料時，不驅動未知輸出。

## 啟用順序
1. 確認工具鏈、最小映像、燒錄、reset 與 console。
2. 確認 clock、memory、watchdog 與基本 fault path。
3. 以安全 default state 初始化 pinmux／GPIO，再逐個啟用周邊。
4. 依 power tree 與相依關係啟用外部 IC、電源與通訊介面。
5. 每一步保留可觀察 checkpoint，失敗時回到最後已知正常狀態。

## 證據
- 記錄韌體版本、板號、供電與量測條件。
- 將 console、register dump、電壓、時序與波形對應到完成條件。
- Build 或 UART 輸出正常不等於整板功能驗證完成。

## 停止條件
- 偵測過流、異常溫升、電壓跌落、未知 pin drive 或 reset loop 時停止擴大啟用範圍。
