---
name: ec-controller
description: Embedded Controller 韌體領域知識。適用 power state、host interface、keyboard、battery、charger、thermal、fan、ACPI 與板級事件的分析、修改或驗證。
---

# EC Controller

## 邊界地圖
- 先確認 host interface（eSPI／LPC）、power states、ACPI EC space、GPIO／wake、keyboard、battery／charger、thermal／fan 的實際落點。
- 以 `../../context-index.md` 登記的 EC SPEC、schematic、GPIO table、power sequence 與 host 文件為準。

## 交叉影響
- GPIO default、polarity、wake 與 interrupt 可能直接影響 power rail、PWRBTN#、LID 與 AC presence。
- G3／S5／S3／S0 狀態、host reset、VW／SCI／SMI、ACPI event 與初始化順序必須一起檢查。
- Battery、charger、thermal、fan policy 必須綁定正確 power state、sensor channel 與保護條件。
- Keyboard matrix、debounce、Fn hotkey、SKU table 與 host event 必須區分掃描層與平台事件層。

## 驗證
- 除 build 外，依功能提供 host 行為、EC log、GPIO／power waveform、battery／charger trace 或 fan／thermal 量測。
- 未取得實板證據時，明確限制為靜態路徑驗證。
