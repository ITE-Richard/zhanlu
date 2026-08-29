# context-index.md — 模組母版資料索引

- 專案識別：`firmware-ai-kit-source`
- 索引版次：`KIT-CONTEXT-v4`
- 原則：本檔只登記權威來源與用途，不複製來源內容。

## 程式碼與工具
| ID | 類型 | 路徑 | 用途 | 權威性 |
|---|---|---|---|---|
| CORE-01 | 共用核心 | `./AGENTS.md` | 三工具共同規則 | Primary |
| MANIFEST-01 | 模組清單 | `./.agents/module.json` | 版本、技能與白名單 | Primary |
| PACK-01 | 打包工具 | `./pack.ps1` | 建立可攜套件 | Primary |
| SETUP-01 | 安裝工具 | `./setup-ai-module.ps1` | 安全複製與初始化 | Primary |
| VERIFY-01 | 驗證工具 | `./verify-ai-module.ps1` | 結構、引用與封裝邊界檢查 | Primary |
| INSTALL-DOC-01 | 套件入口說明 | `./README.md` | 解壓、安裝、初始化與首次啟動步驟 | Primary |

## 專案文件
| ID | 類型 | 路徑 | 用途 | 權威性 |
|---|---|---|---|---|
| DOC-01 | 使用說明 | `./.agents/README.md` | 安裝、資料責任與驗收 | Primary |
| TEMPLATE-01 | 專案範本 | `./.agents/templates/` | 建立新專案層 | Primary |
| SKILL-01 | 技能本體 | `./.agents/skills/` | 任務與領域方法 | Primary |

## 外部基準、硬體文件與驗證證據
- 母版沒有外部基準、SPEC、schematic、BOM、log、waveform 或實板結果。
- 新專案應將資料放在 repository 合法位置，並在自己的 `context-index.md` 登記。

## 資料掛載點
| ID | 路徑 | 母版狀態 | 新專案用途 |
|---|---|---|---|
| RESOURCE-01 | `./.agents/resources/` | 僅 `.gitignore` | 選用的規格或證據掛載點；內容預設不進版控 |
| REFERENCE-01 | `./.agents/reference-projects/` | 僅 `.gitignore` | 選用的唯讀基準掛載點；內容預設不進版控 |

## 索引驗證碼
- 本次驗證碼：`KIT-CONTEXT-7D31`
- 本章節置於最末，作為索引完整載入 sentinel。
