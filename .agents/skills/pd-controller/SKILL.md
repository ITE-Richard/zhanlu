---
name: pd-controller
description: USB Type-C／USB Power Delivery 控制器韌體領域知識。適用 attach、role、PDO、contract、VDM、保護、韌體更新與主控制器資料交換。
---

# PD Controller

## 必要事實
- 從 `../../context-index.md` 確認 PD controller 型號與 revision、port 拓樸、CC／VBUS 路徑、power role、data role、PDO、保護 IC 與通訊介面。
- 規範版本、vendor register map 與產品 power budget 不可混用。

## 檢查面
- Attach／detach、DRP／Try role、source／sink state machine 與 debounce。
- Source／sink capability、RDO、contract 更新、hard／soft reset 與 error recovery。
- VBUS discharge、OVP／OCP／OTP、dead-battery、VCONN 與 cable／e-marker。
- Alt mode／VDM／UCSI／host command、interrupt、shared memory 或 I2C 交換。
- 多埠 power budget、charger／battery／EC 協調與 boot-time blocking。

## 驗證
- 將 protocol trace、CC／VBUS waveform、contract、power role 與 fault injection 對應到需求。
- 不以單次成功充電取代不同方向、功率、線材與 recovery 路徑測試。
