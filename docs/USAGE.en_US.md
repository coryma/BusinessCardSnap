# BusinessCardSnap User Guide (English)

This document describes installation, setup, and usage for the 2GP (Unlocked) `BusinessCardSnap` package.

---

## 1. Installation

### 1.1 Enable Einstein Generative AI first

Before installing, go to **Setup → Einstein Setup** and turn **Turn on Einstein** to **On**.

### 1.2 Install links

- Use the latest install links published in `README.md` under **Download / Install (2GP)**.
- If this guide and `README.md` differ, follow `README.md`.

### 1.3 Install options (install screen)

You’ll see these options during installation:

**User Access**
- Install for Admins Only
- Install for All Users
- Install for Specific Profiles

Recommendation: If end users will use the app, choose **Install for All Users**.  
If you choose **Admins Only**, you can grant access later.

**Advanced Options → Apex Compile**
- Compile all Apex in the org (default)
- Compile only the Apex in the package

Recommendation: If the target org has existing Apex compile errors, choose **Compile only the Apex in the package** to avoid blocking installation.

### 1.4 Confirm installation

- After installation, verify status in **Setup → Installed Packages**.

---

## 2. Prerequisites

This package uses:

- **Prompt Builder / Einstein GPT** (for OCR / LLM parsing)
- **ContentVersion / ContentDocument** (file upload)

Make sure:

- Einstein GPT / Prompt Builder is enabled
- Users can upload files
- Users have access to `CM_BusinessCard__c` and Lead

---

## 3. Main Components

- **App Page**: `CM_BusinessCardSnap`
- **Screen Flow**: `CM_BusinessCard_To_Lead`
- **Auto-launched Flow**: `CM_BusinessCard_Create_Record_From_Event`
- **Scheduled Flow**: `CM_BusinessCard_Cleanup_Scheduled`
- **Prompt Template**: `CM_BusinessCard_Card_To_Lead`
- **Custom Object**: `CM_BusinessCard__c`
- **Platform Event**: `Business_Card_Processed__e`

---

## 4. Admin Setup

### 4.1 Activate Flows

Ensure these flows are **Active**:

- `CM_BusinessCard_To_Lead`
- `CM_BusinessCard_Create_Record_From_Event`
- `CM_BusinessCard_Cleanup_Scheduled`

### 4.2 Configure App Page

- Open `CM_BusinessCardSnap` in **App Builder**
- Confirm `flowruntime:interview` points to `CM_BusinessCard_To_Lead`
- Set `varLeadSource` in Flow Arguments if needed

### 4.3 Cleanup schedule

`CM_BusinessCard_Cleanup_Scheduled` runs daily by default. Adjust as needed:

- `varRetentionDays` (default 30)
- `varDeleteFiles` (default true)

---

## 5. User Flow (Sales Console)

### 5.1 Add "AI Business Card Assistant" to Sales Console

1. Go to **Setup → App Manager**.
2. Find **Sales Console**, click **Edit**.
3. In **Navigation Items**, move **AI Business Card Assistant** to **Selected Items**.
4. Save and open the Sales Console app.

### 5.2 Use AI Business Card Assistant

1. Open the **AI Business Card Assistant** tab.
2. In **Upload Business Cards**, click **Upload Files** (or drag and drop images).
3. Wait for the upload dialog to finish, then click **Done**.
4. Confirm the message shows "Uploaded X files" and a **Batch ID**.
5. Click **Next** to start recognition.
6. Review and edit the extracted fields for each card (including **Description (Remark)**).
7. If a matching company exists, choose one:
   - **Create new Lead**
   - **Link existing Account and create Contact**
8. Click **Next** to submit.
9. Check created records in **Leads** (for example, **Today's Leads**).

---

## 6. Language Support

### 6.1 Language files

Four languages are provided (including default):

- Chinese (Traditional, default): `force-app/main/default/labels/CustomLabels.labels-meta.xml`
- English: `force-app/main/default/translations/en_US.translation-meta.xml`
- Japanese: `force-app/main/default/translations/ja.translation-meta.xml`
- Korean: `force-app/main/default/translations/ko.translation-meta.xml`

### 6.2 UI language settings (English UI)

1) **Enable languages**  
   Setup → Translation Workbench → Enable, select:  
   - Chinese (Traditional)  
   - English  
   - Japanese  
   - Korean

2) **Enable End‑User Languages**  
   Setup → Language Settings → check **Enable End‑User Languages**

3) **User interface language**  
   Setup → Users → select user → **Language**:  
   - Chinese (Traditional) / English / Japanese / Korean

---

## 7. FAQ

### Q1: Flow error “input variable varLeadSource doesn’t exist”
- Make sure `varLeadSource` in `CM_BusinessCard_To_Lead` is marked as Input.

### Q2: Install fails with Apex compile errors
- Usually caused by existing Apex errors in the target org, not this package.

### Q3: OCR returns no results
- Ensure Einstein GPT / Prompt Builder is enabled
- Verify prompt template `CM_BusinessCard_Card_To_Lead` is available

---

## 8. Disclaimer

This project is provided "as is", without warranty of any kind, express or implied. The authors and contributors do not provide support, maintenance, or troubleshooting services and have no obligation to address errors or issues that may arise. Use at your own risk. This project is not affiliated with, endorsed by, or sponsored by Salesforce. "Salesforce" and related trademarks belong to their respective owners.

---

## 9. Uninstall Notes

Uninstall removes:

- Custom Object `CM_BusinessCard__c`
- Flows / LWC / Prompt Template / Tab

Export data first if you need to retain it.
