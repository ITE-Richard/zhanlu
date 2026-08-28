---
name: lighting-controller
description: LED／RGB／背光控制器韌體領域知識。適用 PWM、constant-current、pattern engine、色彩、功耗、熱限制與主控制器同步。
---

# Lighting Controller

## 必要事實
- 確認 LED 拓樸、driver 型號、channel mapping、供電、最大電流、PWM／scan 頻率、色彩順序與校正資料。
- 從 `../../context-index.md` 取得 schematic、driver SPEC、光效需求與量測限制。

## 檢查面
- 初始化期間的 default off／亮度、reset、open／short fault 與 brownout 行為。
- PWM resolution、frequency、gamma、dithering、current limit 與低亮閃爍。
- Pattern／frame buffer 更新的 atomicity、同步、DMA／interrupt 與 race condition。
- Power state、thermal derating、battery mode、sleep leakage 與喚醒恢復。
- 主控制器命令、版本相容性、資料長度與錯誤回覆。

## 驗證
- 除功能目視外，量測頻率、duty、電流、功耗、溫升與長時間 pattern 穩定性。
- 色彩或亮度結論需註明校正工具、環境與容差。
