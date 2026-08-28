---
name: keyboard-controller
description: Keyboard Controller 韌體領域知識。適用 matrix scan、debounce、ghosting、Fn／hotkey、HID／PS2、背光協調與低功耗喚醒。
---

# Keyboard Controller

## 必要事實
- 從 `../../context-index.md` 確認 matrix rows／columns、diode 方向、KSO／KSI pin、scan rate、layout／SKU、host protocol 與 wake 需求。
- 區分鍵盤掃描、key mapping、hotkey policy、host report 與 lighting 互動層。

## 檢查面
- GPIO direction、idle level、settling、scan period、debounce、repeat 與 rollover。
- Ghost／mask、diode topology、stuck key、短路與開機按鍵處理。
- Fn layer、特殊鍵、地區／SKU table、N-key／6KRO 與 report ordering。
- USB HID／PS2／ACPI event／vendor command 的 protocol 與 reset recovery。
- S3／S5／deep sleep 掃描策略、wake key、功耗與恢復後首鍵行為。

## 驗證
- 使用 matrix 測試、長按／多鍵／快速輸入、protocol trace、sleep wake 與不同 SKU 回歸。
- 修改 scan timing 時同步驗證 CPU loading、功耗、debounce 與遺漏率。
