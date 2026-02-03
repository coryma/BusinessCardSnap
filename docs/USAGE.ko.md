# BusinessCardSnap 사용 설명서 (한국어)

이 문서는 2GP (Unlocked) `BusinessCardSnap` 설치, 설정, 사용 방법을 설명합니다.

---

## 1. 설치

### 1.1 설치 전 Einstein Generative AI 활성화

설치 전에 **설정 → Einstein 설정**에서 **Turn on Einstein**을 **On**으로 설정하세요.

### 1.2 설치 링크

- Production: `https://login.salesforce.com/packaging/installPackage.apexp?p0=04tKj000000fSvEIAU`
- Sandbox: `https://test.salesforce.com/packaging/installPackage.apexp?p0=04tKj000000fSvEIAU`

### 1.3 설치 옵션

설치 화면에서 아래 옵션을 확인할 수 있습니다:

**사용자 액세스**
- 관리자만 설치
- 모든 사용자에게 설치
- 특정 프로필에 설치

권장: 일반 사용자가 사용할 경우 **모든 사용자에게 설치**를 선택하세요.  
**관리자만**을 선택했다면 이후 권한을 부여할 수 있습니다.

**Advanced Options → Apex Compile**
- 조직의 모든 Apex 컴파일(기본값)
- 패키지 내 Apex만 컴파일

권장: 대상 org에 기존 Apex 컴파일 오류가 있으면 **패키지 내 Apex만 컴파일**을 선택하세요.

### 1.4 설치 완료 확인

- **설정 → 설치된 패키지**에서 상태가 **Installed**인지 확인합니다.

---

## 2. 사전 조건

이 패키지는 다음 기능을 사용합니다:

- **Prompt Builder / Einstein GPT** (OCR / LLM 파싱)
- **ContentVersion / ContentDocument** (파일 업로드)

확인 사항:

- Einstein GPT / Prompt Builder 활성화
- 사용자에게 파일 업로드 권한 부여
- `CM_BusinessCard__c` 및 Lead 접근 권한 부여

---

## 3. 주요 구성 요소

- **App Page**: `CM_BusinessCardSnap`
- **Screen Flow**: `CM_BusinessCard_To_Lead`
- **Auto-launched Flow**: `CM_BusinessCard_Create_Record_From_Event`
- **Scheduled Flow**: `CM_BusinessCard_Cleanup_Scheduled`
- **Prompt Template**: `CM_BusinessCard_Card_To_Lead`
- **Custom Object**: `CM_BusinessCard__c`
- **Platform Event**: `Business_Card_Processed__e`

---

## 4. 관리자 설정

### 4.1 Flow 활성화

다음 Flow가 **Active**인지 확인하세요:

- `CM_BusinessCard_To_Lead`
- `CM_BusinessCard_Create_Record_From_Event`
- `CM_BusinessCard_Cleanup_Scheduled`

### 4.2 App Page 설정

- **App Builder**에서 `CM_BusinessCardSnap`을 엽니다
- `flowruntime:interview`가 `CM_BusinessCard_To_Lead`를 가리키는지 확인
- Flow Arguments에서 `varLeadSource` 설정 가능

### 4.3 정기 정리 설정

`CM_BusinessCard_Cleanup_Scheduled`는 기본적으로 매일 실행됩니다. 필요에 따라 조정하세요:

- `varRetentionDays` (기본 30)
- `varDeleteFiles` (기본 true)

---

## 5. 사용 방법 (Sales Console)

### 5.1 Sales Console에 "AI 명함 어시스턴트" 추가

1. **설정 → App Manager** 이동
2. **Sales Console**에서 **편집** 클릭
3. **탐색 항목**에서 **AI 명함 어시스턴트**를 선택된 항목으로 이동
4. 저장 후 Sales Console 실행

### 5.2 AI 명함 어시스턴트 사용

1. **AI 명함 어시스턴트** 탭 열기
2. **Upload Business Cards**에서 **Upload Files**(또는 드래그 앤 드롭)
3. 업로드 완료 후 **Done** 클릭
4. "Uploaded X files" 및 **Batch ID** 표시 확인
5. **Next** 눌러 인식 시작
6. 카드별 추출 내용 확인/수정 (**Description (Remark)** 포함)
7. 동일 회사의 계정이 있으면 선택:
   - **Create new Lead**
   - **Link existing Account and create Contact**
8. **Next**로 제출
9. **Leads**(예: **Today's Leads**)에서 생성 결과 확인

---

## 6. 언어 지원

### 6.1 언어 파일

4개 언어 제공(기본 언어 포함):

- 중국어(번체, 기본): `force-app/main/default/labels/CustomLabels.labels-meta.xml`
- English: `force-app/main/default/translations/en_US.translation-meta.xml`
- Japanese: `force-app/main/default/translations/ja.translation-meta.xml`
- Korean: `force-app/main/default/translations/ko.translation-meta.xml`

### 6.2 UI 언어 설정(한국어 UI)

1) **언어 활성화**  
   설정 → 번역 워크벤치 → 활성화, 선택:  
   - Chinese (Traditional)  
   - English  
   - Japanese  
   - Korean

2) **End‑User Languages 활성화**  
   설정 → 언어 설정 → **Enable End‑User Languages** 체크

3) **사용자 UI 언어**  
   설정 → 사용자 → 사용자 선택 → **언어** 설정:  
   - 중국어(번체) / English / Japanese / Korean

---

## 7. FAQ

### Q1: Flow 오류 “varLeadSource 입력 변수가 없습니다”
- `CM_BusinessCard_To_Lead`의 `varLeadSource`를 Input으로 설정하세요.

### Q2: 설치 시 Apex compile error 발생
- 대상 org의 기존 Apex 오류 때문인 경우가 많습니다.

### Q3: OCR 결과가 없음
- Einstein GPT / Prompt Builder 활성화 확인
- `CM_BusinessCard_Card_To_Lead` 프롬프트 템플릿 확인

---

## 8. 면책 조항

본 프로젝트는 "있는 그대로" 제공되며, 명시적이거나 묵시적인 어떠한 보증도 제공하지 않습니다. 작성자 및 기여자는 지원, 유지보수 또는 문제 해결 서비스를 제공하지 않으며, 발생할 수 있는 오류나 문제에 대해 대응할 의무가 없습니다. 사용은 전적으로 사용자 책임입니다. 본 프로젝트는 Salesforce와 제휴, 승인, 후원 관계가 아니며, "Salesforce" 및 관련 상표는 각 소유자에게 귀속됩니다.

---

## 9. 제거(언인스톨) 주의사항

제거 시 다음이 삭제됩니다:

- Custom Object `CM_BusinessCard__c`
- Flow / LWC / Prompt Template / Tab

필요한 데이터는 사전에 내보내세요.
