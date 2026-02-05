# BusinessCardSnap 使用説明（日本語）

本書は 2GP (Unlocked) `BusinessCardSnap` のインストール、設定、利用手順を説明します。

---

## 1. インストール

### 1.1 事前に Einstein Generative AI を有効化

インストール前に **設定 → Einstein 設定** を開き、**Turn on Einstein** を **On** にしてください。

### 1.2 インストールリンク

- Production: `https://login.salesforce.com/packaging/installPackage.apexp?p0=04tKj000000fSvxIAE`
- Sandbox: `https://test.salesforce.com/packaging/installPackage.apexp?p0=04tKj000000fSvxIAE`

### 1.3 インストール時の選択肢

インストール画面で以下の選択が表示されます：

**ユーザーアクセス**
- 管理者のみインストール
- すべてのユーザーにインストール
- 特定のプロファイルにインストール

推奨：一般ユーザーも使う場合は **すべてのユーザーにインストール** を選択してください。  
**管理者のみ** を選んだ場合は、後から権限を付与できます。

**Advanced Options → Apex Compile**
- 組織内のすべての Apex をコンパイル（既定）
- パッケージ内の Apex のみをコンパイル

推奨：対象組織に既存の Apex エラーがある場合は、**パッケージ内のみ** を選ぶとインストールが阻害されにくくなります。

### 1.4 インストール完了の確認

- **設定 → インストール済みパッケージ** でステータスが **Installed** になっていることを確認します。

---

## 2. 前提条件

本パッケージは以下を使用します：

- **Prompt Builder / Einstein GPT**（OCR / LLM 解析）
- **ContentVersion / ContentDocument**（ファイルアップロード）

確認事項：

- Einstein GPT / Prompt Builder が有効
- ユーザーにファイルアップロード権限がある
- `CM_BusinessCard__c` と Lead にアクセス権がある

---

## 3. 主なコンポーネント

- **App Page**: `CM_BusinessCardSnap`
- **Screen Flow**: `CM_BusinessCard_To_Lead`
- **Auto-launched Flow**: `CM_BusinessCard_Create_Record_From_Event`
- **Scheduled Flow**: `CM_BusinessCard_Cleanup_Scheduled`
- **Prompt Template**: `CM_BusinessCard_Card_To_Lead`
- **Custom Object**: `CM_BusinessCard__c`
- **Platform Event**: `Business_Card_Processed__e`

---

## 4. 管理者設定

### 4.1 Flow の有効化

以下の Flow が **Active** であることを確認します：

- `CM_BusinessCard_To_Lead`
- `CM_BusinessCard_Create_Record_From_Event`
- `CM_BusinessCard_Cleanup_Scheduled`

### 4.2 App Page の設定

- **App Builder** で `CM_BusinessCardSnap` を開く
- `flowruntime:interview` が `CM_BusinessCard_To_Lead` を参照していることを確認
- Flow Arguments で `varLeadSource` を設定可能

### 4.3 定期クリーンアップ

`CM_BusinessCard_Cleanup_Scheduled` は既定で毎日実行されます。必要に応じて変更してください：

- `varRetentionDays`（既定 30）
- `varDeleteFiles`（既定 true）

---

## 5. 利用手順（Sales Console）

### 5.1 Sales Console に「AI 名刺アシスタント」を追加

1. **設定 → App Manager** を開く
2. **Sales Console** の **編集** をクリック
3. **ナビゲーション項目** で **AI 名刺アシスタント** を選択済みに移動
4. 保存して Sales Console を開く

### 5.2 AI 名刺アシスタントの操作

1. **AI 名刺アシスタント** タブを開く
2. **Upload Business Cards** で **Upload Files**（またはドラッグ&ドロップ）
3. アップロード完了後に **Done** をクリック
4. 「Uploaded X files」と **Batch ID** の表示を確認
5. **Next** をクリックして認識を開始
6. カードごとに抽出内容を確認・修正（**Description (Remark)** も編集可）
7. 同一会社のアカウントがある場合は選択：
   - **Create new Lead**
   - **Link existing Account and create Contact**
8. **Next** で送信
9. **Leads**（例：**Today's Leads**）で作成結果を確認

---

## 6. 言語サポート

### 6.1 言語ファイル

4 言語が提供されています（既定言語含む）：

- 中国語（繁体、既定）：`force-app/main/default/labels/CustomLabels.labels-meta.xml`
- English：`force-app/main/default/translations/en_US.translation-meta.xml`
- Japanese：`force-app/main/default/translations/ja.translation-meta.xml`
- Korean：`force-app/main/default/translations/ko.translation-meta.xml`

### 6.2 UI 言語設定（日本語 UI）

1) **言語の有効化**  
   設定 → 翻訳ワークベンチ → 有効化、選択：  
   - Chinese (Traditional)  
   - English  
   - Japanese  
   - Korean

2) **End‑User Languages の有効化**  
   設定 → 言語設定 → **Enable End‑User Languages** をオン

3) **ユーザーの UI 言語**  
   設定 → ユーザ → 対象ユーザ → **言語** を設定：  
   - 中国語（繁体）/ English / Japanese / Korean

---

## 7. よくある質問

### Q1: Flow で「varLeadSource が存在しない」と表示される
- `CM_BusinessCard_To_Lead` の `varLeadSource` を Input に設定してください。

### Q2: インストール時に Apex compile error が出る
- 既存 Apex のエラーが原因のことが多く、パッケージ本体とは無関係です。

### Q3: OCR の結果が出ない
- Einstein GPT / Prompt Builder が有効か確認
- `CM_BusinessCard_Card_To_Lead` の Prompt Template を確認

---

## 8. 免責事項

本プロジェクトは「現状有姿」で提供され、明示または黙示を問わずいかなる保証も行いません。著者および貢献者はサポート、保守、トラブルシューティングを提供せず、発生するエラーや問題に対応する義務も負いません。利用は自己責任で行ってください。本プロジェクトは Salesforce と提携・承認・後援関係にありません。「Salesforce」および関連商標は各所有者に帰属します。

---

## 9. アンインストール注意

アンインストールで以下が削除されます：

- Custom Object `CM_BusinessCard__c`
- Flow / LWC / Prompt Template / Tab

必要なデータは事前にエクスポートしてください。
