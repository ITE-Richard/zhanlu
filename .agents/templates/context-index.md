# context-index.md — 專案資料索引

- 專案識別：`__PROJECT_ID__`
- 索引版次：`__CONTEXT_REVISION__`
- 原則：只登記已確認來源；不確定項目標示待確認，不可猜測。

## 程式碼與建置
| ID | 類型 | 路徑／版本 | 用途 | 權威性 | 狀態 |
|---|---|---|---|---|---|
| CODE-01 | 目標原始碼 | `.` | 目前允許修改的 repository | Primary | 已確認 |
| BUILD-01 | 建置入口 | 待確認 | 正式建置方式 | Primary | 待確認 |

## 規格與硬體文件
| ID | 類型 | 路徑／版本 | 適用範圍 | 權威性 | 狀態 |
|---|---|---|---|---|---|
| SPEC-01 | 晶片規格 | 待確認 | 待確認；用途欄需帶章節與頁碼 | Primary | 待確認 |
| HW-01 | Schematic／BOM | 待確認 | 板級連線與元件 | Primary | 待確認 |

SPEC 為整份 PDF 時，先讀目錄頁建立章節與頁碼對照寫在「適用範圍」欄，例如
`eSPI 介面 ch.7 p.183-201；GPIO register ch.12 p.340-372`。沒有頁碼 AI 只能盲翻，
且單次讀取有頁數上限，數百頁的 datasheet 會讀不完。

## 基準來源
| ID | 類型 | 路徑／版本 | 用途 | 修改權限 | 狀態 |
|---|---|---|---|---|---|
| BASE-01 | Golden reference／upstream／last-known-good | 待確認 | 比較基準 | 唯讀 | 待確認 |

基準一律置於 `.agents/reference-projects/` 之下。其中的搜尋結果必須標示為唯讀基準，
不可與目標專案的結果混報。

## 問題與驗證證據
| ID | 類型 | 路徑／版本 | 用途 | 狀態 |
|---|---|---|---|---|
| EVIDENCE-01 | issue／log／waveform／test result | 待確認 | 問題重現與驗證 | 待確認 |

證據一律置於 `.agents/resources/` 之下，建議依 work item 分目錄：

```text
.agents/resources/evidence/<WORK-ITEM-ID>/
  measurement-note.md            人工撰寫，記錄量測條件（必要）
  la-<訊號>-<時間窗>.csv          LA 協定解碼後匯出
  uart-<情境>.log
  waveform-<訊號>.png
```

LA log 以協定解碼後的 CSV 為首選，只匯出出問題的時間窗；raw sample 匯出動輒數百萬列，
無法解析。`measurement-note.md` 必須記載 channel 對應到哪個 net、取樣率、觸發條件與
當時的韌體版本，缺少對應表時 AI 只能報告 channel 未知，無法連結到實際訊號。

## 資料衝突與限制
- 待確認。

## 索引驗證碼
- 本次驗證碼：`__CONTEXT_CODE__`
- 本章節置於最末，作為索引完整載入 sentinel。
