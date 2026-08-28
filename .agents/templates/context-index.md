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
| SPEC-01 | 晶片規格 | 待確認 | register / pin / clock / peripheral | Primary | 待確認 |
| HW-01 | Schematic／BOM | 待確認 | 板級連線與元件 | Primary | 待確認 |

## 基準來源
| ID | 類型 | 路徑／版本 | 用途 | 修改權限 | 狀態 |
|---|---|---|---|---|---|
| BASE-01 | Golden reference／upstream／last-known-good | 待確認 | 比較基準 | 唯讀 | 待確認 |

## 問題與驗證證據
| ID | 類型 | 路徑／版本 | 用途 | 狀態 |
|---|---|---|---|---|
| EVIDENCE-01 | issue／log／waveform／test result | 待確認 | 問題重現與驗證 | 待確認 |

## 資料衝突與限制
- 待確認。

## 索引驗證碼
- 本次驗證碼：`__CONTEXT_CODE__`
- 本章節置於最末，作為索引完整載入 sentinel。
