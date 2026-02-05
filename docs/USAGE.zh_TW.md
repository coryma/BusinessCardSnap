# BusinessCardSnap 使用說明（繁體中文）

本文件說明安裝後的基本設定與使用流程。適用版本：2GP (Unlocked) `BusinessCardSnap`。

---

## 1. 安裝

### 1.1 安裝前必須先啟用 Einstein Generative AI

在安裝前，請先到 **設定 → Einstein 設定**，將 **Turn on Einstein** 設為 **On**。

### 1.2 安裝連結

- Production：`https://login.salesforce.com/packaging/installPackage.apexp?p0=04tKj000000fSvxIAE`
- Sandbox：`https://test.salesforce.com/packaging/installPackage.apexp?p0=04tKj000000fSvxIAE`

### 1.3 安裝選項（安裝畫面）

安裝時會看到以下選項：

**使用者存取**（User Access）
- Install for Admins Only（僅管理員）
- Install for All Users（所有使用者）
- Install for Specific Profiles（指定 Profile）

建議：若你要讓一般使用者可使用，選 **Install for All Users**。  
若先選 **Admins Only**，之後可在需要時再手動分配存取權限。

**Advanced Options → Apex Compile**
- Compile all Apex in the org（預設）
- Compile only the Apex in the package（僅編譯本套件）

建議：如果目標 org 有既有 Apex 編譯錯誤，可選 **Compile only the Apex in the package** 以避免安裝被阻擋。

### 1.4 安裝完成確認

- 安裝完成後，請在 **設定 → 已安裝套件** 確認狀態為 **Installed**。

---

## 2. 前置條件

此套件會使用以下功能：

- **Prompt Builder / Einstein GPT**（用於名片 OCR / LLM 解析）
- **ContentVersion / ContentDocument**（檔案上傳）

建議確認：

- Organization 已啟用 Einstein GPT / Prompt Builder
- 使用者具備上傳檔案權限
- 使用者具備存取 `CM_BusinessCard__c` 與 Lead 的權限

---

## 3. 主要元件

- **App Page**: `CM_BusinessCardSnap`
- **Screen Flow**: `CM_BusinessCard_To_Lead`
- **Auto-launched Flow**: `CM_BusinessCard_Create_Record_From_Event`
- **Scheduled Flow**: `CM_BusinessCard_Cleanup_Scheduled`
- **Prompt Template**: `CM_BusinessCard_Card_To_Lead`
- **Custom Object**: `CM_BusinessCard__c`
- **Platform Event**: `Business_Card_Processed__e`

---

## 4. 管理員設定

### 4.1 啟用 Flow

請確認以下 Flow 為 **Active**：

- `CM_BusinessCard_To_Lead`
- `CM_BusinessCard_Create_Record_From_Event`
- `CM_BusinessCard_Cleanup_Scheduled`

> 若 Flow 未啟用，請在 Flow Builder 中啟用。

### 4.2 設定 App Page

- 在 **App Builder** 開啟 `CM_BusinessCardSnap` App Page
- 確認 `flowruntime:interview` 指向 `CM_BusinessCard_To_Lead`
- 可在 Flow Arguments 中設定 `varLeadSource`（LeadSource 預設值）

### 4.3 設定排程清除

`CM_BusinessCard_Cleanup_Scheduled` 預設每日執行一次。可依需求調整：

- `varRetentionDays`（預設 30 天）
- `varDeleteFiles`（預設 true）

---

## 5. 使用流程（Sales Console）

### 5.1 將「AI 名片辨識小助手」加入 Sales Console

1. 進入 **設定 → 應用程式管理員**（App Manager）
2. 找到 **Sales Console**，點 **編輯**
3. 在 **導覽項目** 中將 **AI 名片辨識小助手** 移到已選項目
4. 儲存後開啟 Sales Console

### 5.2 使用 AI 名片辨識小助手

1. 開啟 **AI 名片辨識小助手** 分頁
2. 在 **Upload Business Cards** 區塊點 **Upload Files**（或拖拉檔案）
3. 等上傳完成後點 **Done**
4. 確認畫面顯示「Uploaded X files」與 **Batch ID**
5. 點 **Next** 開始辨識
6. 逐張檢視並修正辨識欄位（含 **Description (Remark)**）
7. 若系統找到同公司帳戶，選擇：
   - **Create new Lead**
   - **Link existing Account and create Contact**
8. 點 **Next** 提交
9. 到 **Leads** 清單（例如 **Today's Leads**）確認建立結果

---

## 6. 語系支援

### 6.1 語言檔案

目前提供四種語言（含預設語言）：

- 中文（繁體，預設語言）：`force-app/main/default/labels/CustomLabels.labels-meta.xml`
- English：`force-app/main/default/translations/en_US.translation-meta.xml`
- Japanese：`force-app/main/default/translations/ja.translation-meta.xml`
- Korean：`force-app/main/default/translations/ko.translation-meta.xml`

如需其他語系，請新增對應的 `translations/*.translation-meta.xml`。

### 6.2 UI 語言設定（繁體中文介面）

1) **啟用語言**  
   設定 → 翻譯工作台 → 啟用，勾選：  
   - Chinese (Traditional)  
   - English  
   - Japanese  
   - Korean

2) **開啟 End‑User Languages**  
   設定 → 語言設定 → 勾選 **Enable End‑User Languages**

3) **使用者介面語言**  
   設定 → 使用者 → 選擇使用者 → **語言** 設定為：  
   - 中文（繁體）/ English / Japanese / Korean

---

## 7. 常見問題

### Q1: Flow 執行出現「不存在輸入變數 varLeadSource」
- 請確認 `CM_BusinessCard_To_Lead` 變數 `varLeadSource` 已設定為 Input。

### Q2: 安裝時出現 Apex compile failure
- 通常是目標 Org 內既有 Apex 類別編譯失敗造成，與套件內容無關。

### Q3: OCR 無結果或失敗
- 請確認 Einstein GPT / Prompt Builder 已啟用
- 檢查 Prompt Template `CM_BusinessCard_Card_To_Lead` 是否可用

---

## 8. 免責聲明

本專案以「現狀」提供，不提供任何明示或默示之保證。作者與貢獻者不提供支援、維護或疑難排除服務，亦無義務處理任何錯誤或問題。使用者需自行承擔風險。本專案與 Salesforce 無任何隸屬、背書或贊助關係；「Salesforce」及其相關商標皆屬其各自擁有者。

---

## 9. 卸載注意事項

卸載後會移除：

- Custom Object `CM_BusinessCard__c`
- Flow / LWC / Prompt Template / Tab

若需要保留資料，請先匯出。
