# 03 화면과 UX: GlobalSeller OS

작성일 2026-10-25. 장 구조는 `platform-docs/products/_platform-core/DOC_TEMPLATE.md` 2.4절을 따른다. 화면 ID·라우트·상태 값·API 이름은 `docs/설계/DESIGN_STRUCTURE.md`(이하 DS)가 정본이고, 화면의 카드·필드·문구는 프로토타입 `prototype/index.html`(이하 PT)을 근거로 옮겼다. 근거 줄 번호는 2026-10-25 저장본 기준이다.

## 1. 정보 구조와 화면 목록

역할은 코어 `org_members.role`(`owner`, `admin`, `member`, `viewer`, `MONOLITH_CORE_LITE.sql:172`)을 쓴다. 플랜 코드는 `free`, `starter`, `pro`, `enterprise`(`01_PRD.md` 4장)이고 한도 초과는 `GS003`(403)이다. PT 팀 탭의 "관리자·편집자·뷰어"(`prototype/index.html:4045`)는 각각 `admin`·`member`·`viewer`로 옮긴다. 플랜 접근은 `01_PRD.md` 4장 플랜 한도(상품 수, 마켓 수, AI 번역, 멤버)로 서버가 판정하고, 화면은 RPC `plan_usage` 결과만 보여 준다(DS 11.2절).

| 경로 | 화면 | 역할 접근 | 플랜 접근 | 우선순위 | 근거 |
|---|---|---|---|---|---|
| `/` | 대기자 등록 랜딩(1장) | 공개 | - | P0 | 4장(제안) |
| `/legal/terms`, `/legal/privacy` | 약관·개인정보처리방침 | 공개 | - | P0 | `AUTH_ROADMAP.md` 5장 |
| `/login`, `/auth/callback` | 로그인. 단계별 구성은 7장 | 공개 | - | P0(A·B), C는 P2 | `AUTH_ROADMAP.md` 2·5·7장 |
| `/dashboard` | S-01 대시보드 | 멤버 | 전 플랜 | P0 | DS 1장, `prototype/index.html:1392` |
| `/collect?tab=box` | S-02 수집함 | 멤버 | 전 플랜(상품 수 한도) | P0 | `prototype/index.html:1632` |
| `/collect?tab=single` | S-02 개별 등록(단건 수집) | owner/admin/member | 전 플랜 | P0 | `prototype/index.html:1754` |
| `/collect?tab=bulk` | S-02 대량 수집 | owner/admin/member | 키워드·정기 수집은 P1 | P0(URL 목록·확장), P1(키워드·정기) | `prototype/index.html:1895`, DS 10장 |
| `/listings?tab=status` | S-03 등록 현황 | 멤버 | 전 플랜 | P0 | `prototype/index.html:2047` |
| `/listings?tab=single` | S-03 개별 등록(6단계) | owner/admin/member | AI 번역 한도 | P0 | `prototype/index.html:2117` |
| `/listings?tab=bulk` | S-03 일괄 등록 | owner/admin/member | AI 번역 한도 | P0 | `prototype/index.html:2304` |
| `/sync?market=` | S-04 재고·가격 동기화 | 보기 멤버, 규칙 편집 owner/admin | 전 플랜 | P0 | `prototype/index.html:2806` |
| `/orders?market=&status=` | S-05 주문 통합 관리 | 보기 멤버, 처리 owner/admin/member | 전 플랜 | P0 | `prototype/index.html:2928` |
| `/shipping?market=&shipment=` | S-06 배송·물류 추적 | 보기 멤버, 송장 등록 owner/admin/member | 전 플랜 | P0 | `prototype/index.html:3033` |
| `/profit?period=` | S-07 수익 분석 | owner/admin | 전 플랜 | P0 | `prototype/index.html:3149` |
| `/settings/integrations` | S-08 연동 설정(쿠팡 파트너스 키, 확장프로그램 토큰, 운송사 추적) | owner/admin | 전 플랜 | P0(확장 토큰), P1(파트너스 키) | `prototype/index.html:2425`, DS 1장 |
| `/account/profile` | S-10 내 프로필 | 본인 | - | P0 | `prototype/index.html:3314` |
| `/account/plan` | S-10 구독 플랜·사용량 | owner/admin | - | P0 | `prototype/index.html:3426` |
| `/account/markets` | S-10 마켓 연결 | 보기 멤버, 연결·해제 owner/admin | 마켓 수 한도 | P0 | `prototype/index.html:3510` |
| `/account/api-keys` | S-10 API 키 관리(API 키 방식 마켓만) | owner/admin | - | P1 | `prototype/index.html:3617` |
| `/account/billing` | S-10 결제 수단·결제 내역 | owner/admin | - | P0 | `prototype/index.html:3733` |
| `/account/notifications` | S-10 알림 설정 | 본인 | Slack은 Pro 이상(제안) | P1 | `prototype/index.html:3821` |
| `/account/security` | S-10 보안(비밀번호, 2FA, 로그인 이력, 위험 구역) | 본인, 계정 삭제는 owner | - | P0(로그인 이력·세션), P1(2FA) | `prototype/index.html:3917` |
| `/account/team` | S-10 팀 멤버 관리 | owner/admin | 멤버 수 한도 | P0 | `prototype/index.html:4045` |
| `/markets/connect` (인터셉트 `@modal/(.)markets/connect`) | S-11 마켓 추가 마법사 | owner/admin | 마켓 수 한도 | P0 | `prototype/index.html:4163`, DS 4장 |
| `/dev/components` | 컴포넌트 미리보기(라이트·다크) | 개발 환경만 | - | P0 | `08_DESIGN_SYSTEM.md` |
| S-09 구조도 | 제품에서 제외, DS 6장으로 이동 | - | - | - | `prototype/index.html:2649` |

### 1.1 화면별 영역·컴포넌트·데이터 출처

| 화면 | 기능 ID(`01_PRD.md` 3장) | 영역(위 → 아래) | 주요 컴포넌트(`07_SOURCE_MIGRATION.md` 2.1절) | 데이터 출처 |
|---|---|---|---|---|
| S-01 | GS-F-009~011 | 페이지 헤더, KPI 5칸(매출, 등록 상품, 처리 주문, 평균 마진율, 동기화 상태), 마켓별 월간 매출 추이, 최근 활동, 최근 등록 상품 표 | `PageHeader`, `KpiGrid`, `VBarChart`, `ActivityItem`, `DataTable` | `v_profit_monthly`, `listings`, `orders`, `sync_events`, `audit_log` |
| S-02 수집함 | GS-F-017 | 검색 폼(키워드, 카테고리, 마진율, 등록 마켓), 수집 → 등록 파이프라인 6단계, 수집 결과 표 | `SearchInput`, `PipelineSteps`, `DataTable` | `source_products`, `collect_groups`, `/api/pricing/preview` |
| S-02 개별 등록 | GS-F-012~016 | 스텝 4단계, 상품 불러오기(URL·확장프로그램), 불러온 정보(옵션 표, 함께 가져올 항목), 리스크 검사, 우측 예상 마진·저장 | `Stepper`, `SegmentTabs`, `DataTable`, `SelectCard`, `ValidationChecklist`, `EditLayout` | `/api/collect/single` → `collect_jobs` → `source_products`, `source_product_options`, `packages/compliance` |
| S-02 대량 수집 | GS-F-018~022 | 제약 안내 띠, 수집 방식 4종 + API 한도 게이지, 키워드 칩, 업로드 드롭존, 조건 필터, 수집 작업 표, 제외 사유 막대 | `Callout`, `SelectCard`, `QuotaMeter`, `TokenInput`, `FileDropzone`, `FormSection`, `DataTable`, `HBarChart` | `collect_jobs`, `collect_presets`, `/api/collect/upload` |
| S-03 등록 현황 | GS-F-023 | 마켓별 요약 카드 3개, 등록 상품 전체 목록 | `KpiCard`, `DataTable` | `listings`, `market_accounts` |
| S-03 개별 등록 | GS-F-024~030 | 스텝 6단계, 원본 상품, 대상 마켓, AI 번역·콘텐츠(EN/JA), 가격·마진 계산, 카테고리·속성, 이미지, 우측 검증·요약 | `Stepper`, `SelectCard`, `FormSection`, `KeyValueList`, `FormField`, `Thumbnail`, `ValidationChecklist` | `listings`, `price_rules`, `fx_rates`, `/api/pricing/preview`, `/api/listings/[id]/validate` |
| S-03 일괄 등록 | GS-F-031~033 | 스텝 4단계, 안내 띠, 상품 가져오기 3방식 + 선택 표, 공통 등록 규칙(템플릿), 사전 검증 결과, 등록 실행 현황 | `SelectCard`, `DataTable`, `FormSection`, `ValidationChecklist`, `ProgressRow` | `listing_batches`, `listing_batch_items`, `price_rules`, `shipping_templates` |
| S-04 | GS-F-034~039 | 페이지 헤더(지금 동기화), `MarketScope`, KPI 5칸, 최근 변동 내역 표, 동기화 규칙 카드(기본 + 마켓 전용), 마켓별 동기화 상태(전체 탭만) | `MarketScope`, `MarketHealthStrip`, `KpiGrid`, `DataTable`, `RuleRow`, `Switch`, `ProgressRow` | `sync_events`, `sync_rules`, `market_accounts`, `market_health_snapshots`, `fx_rates` |
| S-05 | GS-F-034, 040~045 | 페이지 헤더, `MarketScope`, 5단계 파이프라인, KPI 5칸, 상태 세그먼트 + 검색, 주문 표 | `MarketScope`, `MarketHealthStrip`, `PipelineSteps`, `KpiGrid`, `SegmentTabs`, `TableToolbar`, `DataTable` | `orders`, `order_items`, `purchases`, `market_health_snapshots`, RPC `market_tab_counts` |
| S-06 | GS-F-034, 046~049 | 페이지 헤더, `MarketScope`, KPI 5칸, 배송 건 목록, 구간별 추적 타임라인, 운송사 비교 | `MarketScope`, `MarketHealthStrip`, `KpiGrid`, `DataTable`, `ShipmentTimeline` | `shipments`, `shipment_events`, `shipping_templates` |
| S-07 | GS-F-050~052 | 기간 선택, KPI 5칸, 월별 순이익 막대, 매출 1달러당 비용 구조, 마켓별 순이익 막대, 수익 인사이트, 순이익 상위 상품 | `KpiGrid`, `VBarChart`, `KeyValueList`, `HBarChart`, `Callout`, `DataTable` | `v_profit_monthly`, `/api/profit` |
| S-08 | GS-F-053~054 | 쿠팡 파트너스 API 카드, 확장프로그램 연결, 운송사 추적 설정, 마켓 API 사양 카드(읽기 전용 안내) | `IntegrationCard`, `SecretField` | `encrypted_credentials`(마스킹), `/api/extension/token` |
| S-10 | GS-F-002~003, 055~058 | 좌측 프로필 카드(아바타, 통계 4칸, 탭 8개), 우측 탭 패널 | `AccountLayout`, `AccountTabNav`, `PlanCard`, `UsageBar`, `MarketAccountCard`, `SecretField`, `BillingRow`, `Switch`, `LoginHistoryRow`, `MemberRow` | `profiles`, `organizations`, `subscriptions`, `plan_usage`, `market_accounts`, `payments`, `notification_prefs`, `org_members`, `audit_log` |
| S-11 | GS-F-059~062 | 모달: 헤더, 스텝 5단계, 단계 패널, 하단 이전·위치·다음 | `WizardDialog`, `Stepper`, `ChoiceChip`, `MarketRecommendCard`, `KeyValueList` | `readiness_answers`, `/api/markets/catalog`, `packages/domain/readiness.ts`, `market_accounts` |


셸 공통: `AppTopbar`, `Breadcrumb`, `TopTabs`, `AppSidebar`, `NavItem`, `MarketChip`, `SidebarUserCard`, `MobileNav`, `PageHeader`(GS-F-006, GS-F-007).

## 2. 사용자 플로우

### 2.1 가입 → 부트스트랩 → 첫 수집 → 첫 등록 (필수)

| 단계 | 화면 | 사용자 행동 | 시스템 동작 | 실패 분기 |
|---|---|---|---|---|
| 1 | `/login` | Stage A: 페르소나 버튼 / Stage B: Google 또는 이메일 | A는 `POST /api/dev/login`, B는 `/auth/callback` → `finishLogin` → 코어 부트스트랩(조직, `app_entitlements` `globalseller`, 가입 크레딧) | `error=callback` → 로그인 화면 오류 띠(7장) |
| 2 | `/onboarding/terms`(B부터) | 약관·개인정보처리방침 동의 | 동의 감사 행 | 미동의 시 `/dashboard` 진입 차단 |
| 3 | `/dashboard` | 빈 대시보드에서 "첫 상품 수집" 버튼 | 마켓 0개면 상단 안내 띠 "마켓을 연결하면 등록할 수 있습니다" + S-11 바로가기 | - |
| 4 | `/collect?tab=single` | 쿠팡 URL 붙여넣기 → 불러오기 | `/api/collect/single` → 잡 `globalseller.collect` → Realtime으로 불러온 정보 표시 | 쿠팡 URL 아님 → 필드 오류 "쿠팡 상품 주소가 아닙니다". 수집 실패 → 카드 오류 + 다시 시도 |
| 5 | 같은 화면 | 옵션 선택, 리스크 검사 확인, "수집함에 저장" | `source_products.status` `collected` → `reviewing`, 리스크 플래그 저장 | 상품 수 한도 초과 → 업그레이드 안내(5장) |
| 6 | S-11 | "마켓 연결" → 진단 → eBay 연결 | 4장·2.6절 | OAuth 거부 → 3단계에 오류 표시 |
| 7 | `/listings?tab=single` | "저장 후 바로 해외 등록" 또는 수집함 행 "등록" | 초안 `listings`(`draft`), AI 번역 잡, 가격 미리보기 | AI 번역 한도 초과 → 5장 |
| 8 | 같은 화면 | 6단계 확인 → "N개 마켓에 등록" | `validate` → `ready` → `submit` → `queued` → 워커 `submitting` → `live` | 검증 실패 → 우측 체크리스트 빨강·해당 섹션으로 스크롤. 마켓 오류 → `error` + 원문 메시지 |

### 2.2 대량 수집

| 단계 | 화면 | 사용자 행동 | 시스템 동작 | 실패 분기 |
|---|---|---|---|---|
| 1 | `/collect?tab=bulk` | 수집 방식 선택(URL 목록 / 확장프로그램 / 키워드 P1 / 정기 P1) | 키워드 선택 시 API 한도 게이지 표시 | 파트너스 키 미등록 → 키워드 카드 비활성 + S-08 링크 |
| 2 | 같은 화면 | CSV·XLSX 업로드 또는 키워드 칩 입력 | `/api/collect/upload` 서명 URL → 업로드 → 행 수 미리보기 | 형식 오류 → 줄 번호 목록 |
| 3 | 같은 화면 | 조건 필터(가격, 리뷰, 평점, 마진, 무게, 배송 유형, 제외어·브랜드) 지정, 예상 수집량 확인 | 프리셋 저장 시 `collect_presets` | - |
| 4 | 같은 화면 | "수집 시작" | `collect_jobs`(`queued`) → 워커가 항목별 수집 → 필터 적용 → 통과 상품 수집함 | 호출 한도 초과 → 작업 `running` 유지, 다음 시간대 재개(진행 표에 "한도 대기") |
| 5 | 같은 화면 | 작업 표·제외 사유 확인 → "통과 상품 수집함에서 보기" | `collect_jobs.counts` 집계 | 작업 실패 → 상태 `failed`, 재시도 버튼 |

### 2.3 일괄 등록

| 단계 | 화면 | 사용자 행동 | 시스템 동작 | 실패 분기 |
|---|---|---|---|---|
| 1 | `/listings?tab=bulk` | 가져오기 방식 선택, 표에서 상품 체크 | 선택 수 카운터 | 0개 선택 → 다음 비활성 |
| 2 | 같은 화면 | 공통 규칙(대상 마켓, 목표·최소 마진, 끝자리, 번역 톤, 재고 버퍼, 배송 템플릿) 또는 템플릿 선택 | `POST /api/listings/batches` → 항목별 사전 검증 | - |
| 3 | 같은 화면 | 사전 검증 결과 확인(바로 가능 / 자동 보완 / 마진 미달 제외 / 항공 제한 / 상표권) → "N개 등록 실행" | `/api/listings/batches/[id]/run` → 항목별 잡 `globalseller.listing`, 마켓 API 한도에 맞춰 순차 전송 | 제외 항목 → "엑셀로 받기" |
| 4 | 같은 화면 | 등록 실행 현황(마켓별 진행 막대) | Realtime 진행률 | 항목 실패 → `listing_batch_items.error`, 재시도 |

### 2.4 동기화 승인

| 단계 | 화면 | 사용자 행동 | 시스템 동작 | 실패 분기 |
|---|---|---|---|---|
| 1 | - | 없음(크론 30분) | `globalseller.sync`가 원본 재확인 → `sync_events`(`detected`) → 규칙 적용(`applied`/`held`/`skipped`) | 원본 접근 실패 → `failed` |
| 2 | `/sync?market=all` | KPI "마진 경고" 확인 → 최근 변동 내역에서 `held` 행 | 상태 "검토 필요" 노란 배지 | - |
| 3 | 같은 화면 | 행 "승인" | `/api/sync/events/[id]/approve` → RPC `approve_sync_event` → 반영 잡 | 승인 사이 원본 재변동 → "다시 계산된 값으로 승인" 확인 |
| 4 | `/sync?market=<계정>` | 마켓 탭에서 마켓 전용 규칙 토글 | `PUT /api/sync/rules`(계정 덮어쓰기) | 권한 부족 → 토글 비활성 |
| 5 | 같은 화면 | 실패 행 → "재연결" | `/account/markets`로 이동 | 토큰 만료 → `market_accounts.status=token_expired` |

### 2.5 주문 → 발주 → 송장

| 단계 | 화면 | 사용자 행동 | 시스템 동작 | 실패 분기 |
|---|---|---|---|---|
| 1 | - | 없음(크론 10분) | `globalseller.orders_import` → `orders`(`received` → `purchase_pending`) | 마켓 API 오류 → 계정 지표 띠 경고 |
| 2 | `/orders?status=purchase_pending` | 주문 확인 → "쿠팡 발주" | 쿠팡 상품 페이지 새 탭 + 발주 기록 모달(쿠팡 주문번호, 원가) | - |
| 3 | 같은 화면 | 발주 기록 저장 | `/api/orders/[id]/purchase` → RPC `record_purchase` → `purchased` | 원가가 수집 원가보다 10% 이상 높음 → 경고(제안) |
| 4 | `/shipping` | 배대지 입고 후 송장 등록(개별·일괄 업로드) | `/api/shipments` → `shipments`(`pending`) → 잡 `globalseller.tracking`, 주문 `shipped` | 송장 형식 오류 → 행 오류 |
| 5 | `/orders` | "발송 확인 일괄 전송" | `/api/orders/confirm-shipment` → 마켓에 송장 업로드 | 발송 기한 초과 → 계정 지표 띠 지연 발송률 |
| 6 | `/shipping?shipment=<id>` | 배송 건 클릭 → 구간별 추적 | `shipment_events` 타임라인 | 지연 → `delayed` 빨간 배지 |

### 2.6 마켓 추가 마법사 (DS 4장)

| 단계 | 화면 | 사용자 행동 | 시스템 동작 | 실패 분기 |
|---|---|---|---|---|
| 1 | S-11 1단계 | 7문항 답변 | `PUT /api/markets/readiness` | - |
| 2 | S-11 2단계 | 추천 카드 확인 → "연결하기 / 계정 추가 / 국가 추가 / 승인 신청 안내" | `packages/domain/readiness.ts` 점수(0~97) 정렬, 1순위 카드 강조 | 마켓 수 한도 → 카드 버튼 대신 "업그레이드" |
| 3 | S-11 3단계 | 판매 국가·별칭 지정 → OAuth 버튼 또는 API 키 입력 | OAuth: `/api/markets/connect/start` → 마켓 → `/api/markets/callback/[market]` → 토큰 암호화 / 키: `/api/markets/accounts` + `/test` | 권한 승인 전 "다음" 비활성(`prototype/index.html:4163` 동작 그대로), 콜백 실패 → 3단계 오류 |
| 4 | S-11 4단계 | 기존 리스팅 가져오기, 주문 수집 주기, 템플릿, 통화, 재고 버퍼 | `market_accounts.settings`, 잡 `globalseller.listing_import` | - |
| 5 | S-11 5단계 | 다음 행동 선택 | S-04~S-06에 탭 추가(Realtime), 감사 `market_account.connected` | - |

### 2.7 결제 (필수)

| 단계 | 화면 | 사용자 행동 | 시스템 동작 | 실패 분기 |
|---|---|---|---|---|
| 1 | `/account/plan` | 플랜 카드에서 업그레이드 | 코어 Toss 주문 생성 | - |
| 2 | Toss 결제창 | 카드 등록·결제 | 코어 `confirm_payment_order` → 구독 전환 | 실패 → `/account/plan?error=payment` |
| 3 | `/account/billing` | 결제 내역·영수증 확인 | `payments` 목록 | 웹훅 지연 → "처리 중" 배지 |
| 4 | 한도 화면 | 한도 초과 시 업그레이드 유도 | `plan_usage` 재조회 | - |

## 3. 화면별 명세

공통: 모든 `(app)` 화면은 8장 셸 안에 있다. KPI 칸, 카드, 표, 배지, 마켓 태그의 모양은 `08_DESIGN_SYSTEM.md` 컴포넌트를 쓴다. "크레딧" 열은 그 화면 행동이 쓰는 플랜 한도 또는 크레딧이다(`01_PRD.md` 4장).

### 3.1 S-01 대시보드 (`prototype/index.html:1392-1612`)

| 요소 | 내용 | 데이터 | 행동 | 크레딧 |
|---|---|---|---|---|
| 헤더 | "역직구 판매 대시보드", 기간·운영 마켓 부제, 보고서 버튼(`prototype/index.html:1400`) | `market_accounts` | 보고서 → `/profit`의 리포트 내보내기 | - |
| KPI 5칸 | 이번 달 매출, 등록 상품, 처리 주문, 평균 마진율, 동기화 상태(`prototype/index.html:1408-1432`) | `v_profit_monthly`, `listings`, `orders`, `sync_events` | 칸 클릭 → 해당 화면 | - |
| 마켓별 월간 매출 추이 | 최근 6개월, USD(`prototype/index.html:1445`) | `v_profit_monthly` | 막대 호버 → 값 | - |
| 최근 활동 | 수집·등록·동기화·주문 이벤트 목록(`prototype/index.html:1500`) | `audit_log`, `sync_events` | 행 클릭 → 대상 화면 | - |
| 최근 등록 상품 | 상품명, 수집처(쿠팡 태그), 등록 마켓, 쿠팡가, 판매가, 마진, 상태 + "전체 목록 →"(`prototype/index.html:1554-1562`) | `listings` + `source_products` | 행 클릭 → `/listings?tab=single&id=`, 전체 목록 → `/listings?tab=status` | - |

### 3.2 S-02 쿠팡 상품 수집 (`prototype/index.html:1613-2027`)

헤더 버튼 2개: "＋ 개별 등록"(→ `tab=single`), "⇣ 대량 수집"(→ `tab=bulk`). 하위 탭: 수집함(개수) / 개별 등록 / 대량 수집(진행 수).

| 하위 탭 | 카드 | 필드·컬럼 | 버튼·행동 | 데이터 | 크레딧 |
|---|---|---|---|---|---|
| 수집함 | 검색 폼 | 키워드, 카테고리, 마진율 하한, 등록 마켓 | 검색 실행 | `GET /api/source-products` | - |
| 수집함 | 파이프라인 | 수집 → 마진 분석 → AI 번역 → 이미지 처리 → 마켓 등록 → 동기화 | 안내 전용 | - | - |
| 수집함 | 결과 표 | 상품명(배송 유형·별점), 쿠팡 가격, 예상 판매가(USD), 예상 마진, 추천 마켓, 리뷰 수, 액션 | 등록(→ S-03 개별), 검토, 제외 | `source_products` + `/api/pricing/preview` | - |
| 개별 등록 | 1 상품 불러오기 | URL 입력 / 확장프로그램 세그먼트(`prototype/index.html:1768`) | 불러오기, 확장프로그램 설치 안내 | `POST /api/collect/single` | 상품 수 한도 |
| 개별 등록 | 2 불러온 상품 정보 | 이미지, 상품명, 상품번호·판매자, 배송 유형·평점·카테고리 배지, 판매가·정가·재고, 옵션 표(체크·옵션·가격·재고, "수집할 옵션만 체크하세요"), 함께 가져올 항목 4개: 대표·추가 이미지(기본 켬), 상품 고시정보(기본 켬), 상세 이미지 글자 추출 OCR(번역 참고용, 기본 끔), 리뷰 AI 요약(기본 켬)(`prototype/index.html:1792`) | 옵션 체크, 항목 체크 | `source_products`, `source_product_options` | - |
| 개별 등록 | 3 해외 판매 리스크 검사 | 항공 제한, 브랜드 판매 승인, 이미지 사용 권한, 수입국 규정, 중복 수집(`prototype/index.html:1843`) | 읽기 전용(주의 건수 배지) | `packages/compliance` 결과 → `source_products.risk_flags` | - |
| 개별 등록 | 우측 요약 | 예상 마진(원가+배송비, 마켓별 권장가, 예상 순마진), 저장할 그룹(선택 또는 새 그룹, `collect_groups`), 메모 | 수집함에 저장, 저장 후 바로 해외 등록 | `PATCH /api/source-products/[id]` | - |
| 대량 수집 | 제약 안내 띠 | 파트너스 API 최종 승인·키워드 전용·호출 제한, 필터는 수집 후 적용 | - | - | - |
| 대량 수집 | 1 수집 방식 | 키워드 / URL·상품번호 목록 / 확장프로그램 담기 / 정기 수집 카드, 검색 API 한도 게이지(`prototype/index.html:1911`), 키워드 칩, 업로드 드롭존 | 방식 선택, 칩 추가(Enter, 한글 조합 중 무시)·삭제, 파일 끌어놓기, 양식 받기 | `POST /api/collect/upload`, 한도는 `rate_limit_buckets` | 상품 수 한도 |
| 대량 수집 | 2 조건 필터 | 가격 범위, 최소 리뷰 수, 최소 평점, 예상 마진 하한, 추정 무게 상한, 배송 유형, 제외 키워드·브랜드 칩, 중복 제외, 항공 제한 제외, 수집 후 AI 번역, 통과 상품 일괄 등록 대기열로(`prototype/index.html:1942`) | 프리셋 선택·저장, 수집 시작, 조건 저장 → 정기 수집 등록 | `collect_presets`, `POST /api/collect/jobs` | AI 번역 선택 시 번역 한도 |
| 대량 수집 | 3 수집 작업 | 작업, 방식, 진행 막대, 수집/통과, 상태(`prototype/index.html:1984`) | 취소, 재시도 | `collect_jobs`(Realtime) | - |
| 대량 수집 | 4 제외 사유 | 마진 미달, 리뷰 부족, 중복, 제외어·브랜드, 항공 제한 막대 | 통과 상품 수집함에서 보기 | `collect_jobs.counts` | - |

### 3.3 S-03 해외 마켓 등록 (`prototype/index.html:2028-2424`)

헤더 버튼: "+ 개별 등록", "+ 일괄 등록". 하위 탭: 등록 현황(개수) / 개별 등록 / 일괄 등록(대기 수).

| 하위 탭 | 카드 | 필드·컬럼 | 버튼·행동 | 데이터 | 크레딧 |
|---|---|---|---|---|---|
| 등록 현황 | 마켓별 요약 3칸 | 마켓, 활성 리스팅 수, 신규 수, 비중 막대(`prototype/index.html:2051-2063`) | 카드 클릭 → 마켓 필터 | `listings` 집계 | - |
| 등록 현황 | 등록 상품 전체 목록 | 상품명(외부 id), 등록 마켓, 현지 가격, 마진율, 조회수, 판매수, 상태(`prototype/index.html:2072`) | 행 클릭 → 개별 편집 | `listings` | - |
| 개별 등록 | 1 원본 상품 | 원본 요약, 수집 목록에서 변경 | 변경 | `source_products` | - |
| 개별 등록 | 2 대상 마켓 | 연결 계정 체크 카드(마켓 이름 + 통화·언어, 예: Amazon US USD·영문, Amazon JP JPY·일문, eBay US USD·영문, Shopee SG SGD·영문, Shopee TH THB·태국어). 연결 안 된 마켓은 카드 대신 "＋ 마켓 연결"(S-11). MVP 계정은 eBay US·Amazon US, Shopee는 P1 | 체크 | `market_accounts` | 마켓 수 한도 |
| 개별 등록 | 3 AI 번역·콘텐츠 | 언어 세그먼트(EN/JA), 상품명 Title(글자 수/200), 핵심 특징 Bullet Points(5개 권장, 줄마다 1개), 검색 키워드, 브랜드/제조국(`prototype/index.html:2172`) | AI 재생성 | `POST /api/listings/[id]/translate` | AI 번역 1회 |
| 개별 등록 | 4 가격·마진 계산 | 쿠팡 원가(₩), 국제 배송비(₩), 환율(₩/USD), 마켓 수수료(%), 목표 마진(%), 가격 끝자리, 계산 결과 4행, 마켓별 판매가 표(`prototype/index.html:2208`) | 입력 즉시 재계산 | `POST /api/pricing/preview`(`packages/domain/pricing.ts`) | - |
| 개별 등록 | 5 카테고리·필수 속성 | 마켓별 카테고리(AI 추천), 용량/수량, GTIN(필수 표시) | 입력 | `listings.attributes` | - |
| 개별 등록 | 6 이미지 | 대표·추가 이미지, 흰 배경 일괄 변환, 규격 안내 | 대표 지정, 변환 | Storage `<org_id>/globalseller/listings/` | 이미지 처리 한도(제안) |
| 개별 등록 | 우측 검증·요약 | 체크리스트 6행, 대상 마켓 수, 판매가, 재고 연동 | N개 마켓에 등록, 임시 저장 | `/validate`, `/submit` | - |
| 일괄 등록 | 1 상품 가져오기 | 수집함 선택 / CSV·엑셀 / 카테고리·키워드 전체, 선택 표(체크·상품·쿠팡가·마진·준비 상태) | 전체 선택, 행 체크 | `source_products` | - |
| 일괄 등록 | 2 공통 등록 규칙 | 템플릿 선택, 대상 마켓, 목표·최소 마진, 끝자리, 번역 톤, 재고 버퍼, 배송 템플릿 | 템플릿 저장 | `price_rules`, `shipping_templates` | - |
| 일괄 등록 | 3 사전 검증 결과 | 바로 등록 / 자동 보완 / 마진 미달 / 항공 제한 / 상표권 건수(`prototype/index.html:2391`) | N개 등록 실행, 제외 엑셀로 받기 | `listing_batch_items` | AI 번역 N회 |
| 일괄 등록 | 4 등록 실행 현황 | 마켓별 진행 막대, 안내 문구 | - | `listing_batches`(Realtime) | - |

### 3.4 마켓 탭 화면 공통 (S-04 · S-05 · S-06)

DS 3장 `MarketScope` 패턴(GS-F-034). 탭 바 = 전체 + 연결된 `market_accounts`(연결 순서) + "＋ 마켓 추가". 탭 숫자는 RPC `market_tab_counts`(S-04 리스팅 수, S-05 미완료 주문 수, S-06 배송 중 수). 선택 탭이 URL `market`에 남아 새로고침·공유해도 유지된다. 탭 아래 지표 띠(`MarketHealthStrip`, GS-F-045)는 전체 탭이면 "오늘 처리할 일", 마켓 탭이면 그 계정의 `market_health_snapshots` 최신 행. KPI 숫자, 목록 필터, 규칙 카드 제목이 모두 같은 `market` 값으로 다시 계산된다. 오류 상태 계정(토큰 만료)은 탭에 빨간 "!" 배지(`prototype/index.html:2820`).

### 3.5 S-04 재고·가격 동기화 (`prototype/index.html:2806-2927`)

| 요소 | 내용 | 데이터 | 행동 | 크레딧 |
|---|---|---|---|---|
| 헤더 | 마지막·다음 실행 시각, 버튼 문구가 탭에 따라 "전체 동기화" / "<마켓>만 동기화" | `sync_rules`, 크론 시각 | `POST /api/sync/run` | - |
| 지표 띠(전체) | 연결 상태, 승인 대기, 기준 환율, 적용 규칙 | `market_accounts`, `sync_events`, `fx_rates` | - | - |
| 지표 띠(마켓) | 마지막 동기화, API 사용률, 가격 보호/환율/끝자리/품절 리스팅 유지 등 마켓별 4칸, 실패 시 재연결 버튼 | `market_health_snapshots` | 재연결 → `/account/markets` | - |
| KPI 5칸 | 동기화 대상, 가격 변동 감지, 품절 감지, 마진 경고, 동기화 실패(`prototype/index.html:2861-2865`) | `listings`, `sync_events` | - | - |
| 최근 변동 내역 | 상품, 마켓, 변동, 쿠팡 이전 → 이후, 마켓 반영, 시각, 상태 + 유형 필터(`prototype/index.html:2871`) | `GET /api/sync/events` | `held` 행 승인 | - |
| 동기화 규칙 | 기본 규칙 4행(주기, 품절 시, 원가 상승 시, 마진 20% 미만 변경) + 마켓 전용 규칙(Amazon 최저·최고가 보호, 바이박스 추적, 엔화 10엔 단위 반올림(JP 전용), eBay 품절 리스팅 유지, Shopee 토큰 자동 갱신·국가별 가격) | `sync_rules` | 토글, 주기 선택 | - |
| 마켓별 동기화 상태 | 전체 탭에만, 마켓별 API 한도 막대 | `market_health_snapshots` | - | - |

### 3.6 S-05 주문 통합 관리 (`prototype/index.html:2928-3032`)

| 요소 | 내용 | 데이터 | 행동 | 크레딧 |
|---|---|---|---|---|
| 헤더 | 엑셀 내보내기, 선택 주문 쿠팡 발주 | `orders` | 내보내기, 일괄 발주 | - |
| 지표 띠(전체) | 오늘 발송 기한 도래, 미답변 문의, 송장 미등록, 계정 상태 경고 | `orders`, `market_health_snapshots` | - | - |
| 지표 띠(마켓) | 마켓별 4칸 + 버튼, 정본 DESIGN_STRUCTURE 3.1절. Amazon US: 주문 결함률 ODR(<1%), 지연 발송률(<4%), 발송 전 취소율(<2.5%), 발송 기한 Ship-by / Amazon JP: ODR, 지연 발송률, 고객 문의 24시간 응답률, 발송 기한(出荷期限) / eBay: 판매자 등급, 거래 결함률, 지연 배송률, 미응답 메시지 / Shopee: 늦은 발송률 LSR, 미발송률 NFR, 발송 준비 기간 DTS, 채팅 응답률 | `market_health_snapshots.metrics`, `market_accounts.settings` | Amazon US: 발송 확인 일괄 전송, Seller Central ↗ / Amazon JP: 일문 응대 템플릿(문구 복사), セラーセントラル ↗ / eBay: 메시지함(마켓 메시지 페이지 열기), Seller Hub ↗ / Shopee: SLS 송장 출력(P1), Seller Centre ↗. ↗는 `seller_center_url` 새 탭 | - |
| 파이프라인 5단계 | 주문 수신 → 쿠팡 발주 → 배대지 입고 → 해외 발송 → 배송 완료(단계별 건수) | `market_tab_counts` | 단계 클릭 → 상태 필터 | - |
| KPI 5칸 | 오늘 신규 주문, 발주 대기, 이달 주문, 이달 주문 금액(객단가), 취소·반품(`prototype/index.html:2995-2999`) | `orders` | - | - |
| 상태 세그먼트 | 전체 / 발주 대기 / 배대지 / 발송됨 / 취소·반품(DS 5.1절 그룹), 마켓 탭과 조합 시 숫자 재계산 | `orders` | 선택 → URL `status` | - |
| 주문 표 | 체크, 주문번호, 마켓, 상품(쿠팡가·발송 기한), 금액, 배송지, 상태, 처리(쿠팡 발주 / 추적 / 처리) | `GET /api/orders` | 쿠팡 발주 → 발주 기록 모달, 추적 → S-06, 처리 → 클레임 모달 | - |

### 3.7 S-06 배송·물류 추적 (`prototype/index.html:3033-3148`)

| 요소 | 내용 | 데이터 | 행동 | 크레딧 |
|---|---|---|---|---|
| 헤더 | 송장 업로드(탭에 따라 문구 변경), 배대지 출고 요청 | - | 업로드 모달, 출고 요청(P1, 배대지 연동 전에는 체크리스트) | - |
| 지표 띠 | 정본 DESIGN_STRUCTURE 3.1절. 전체: 오늘 배대지 출고 마감, 마켓에 송장 미등록, 사용 운송사 수, 통관 보류 / Amazon US: 유효 추적률(>95%), 정시 배송률(>90%), 배송 템플릿, 핸들링 타임 / Amazon JP: 유효 추적률, 정시 배송률, 배송 템플릿, 리드타임(出荷作業日数) / eBay: 추적번호 업로드율, 핸들링 타임, 배송 서비스, 지연 배송 / Shopee: 배송 방식(SLS), 국내 집하지 입고 기한(DTS), 송장 출력 대기, 지연 배송 | `shipments`, `market_health_snapshots.metrics`, `market_accounts.settings` | - | - |
| KPI 5칸 | 배송 중, 배대지 입고 대기, 통관 중, 배송 지연, 평균 배송일(`prototype/index.html:3088-3092`) | `shipments` | - | - |
| 배송 건 목록 | 송장번호, 마켓, 운송사, 목적지, 현재 구간, 예상 도착, 상태 | `GET /api/shipments` | 행 클릭 → 타임라인, URL `shipment` | - |
| 구간별 추적 | 쿠팡 발주·출고 → 배대지 입고·검수 → 국제 발송 → 현지 통관 → 현지 배송 → 배송 완료(`prototype/index.html:3117`) | `shipment_events` | - | - |
| 운송사 비교 | 운송사, 노선, 평균 배송일, 평균 운임, 지연율, 추적 범위. 마켓 탭이면 그 마켓에서 쓰는 운송사만 | `shipping_templates`, `shipments` 집계 | - | - |

### 3.8 S-07 수익 분석 (`prototype/index.html:3149-3240`)

| 요소 | 내용 | 데이터 | 행동 |
|---|---|---|---|
| 헤더 | 기간 선택(이번 달·지난 달·최근 90일), 리포트 내보내기 | - | URL `period` |
| KPI 5칸 | 매출, 순이익, 순마진, 객단가, 반품 손실(`prototype/index.html:3162-3166`) | `v_profit_monthly` | - |
| 월별 순이익 | 최근 6개월 단일 색 막대, 현재 달 강조 | `v_profit_monthly` | 호버 값 |
| 매출 1달러당 비용 구조 | 상품 원가, 마켓 수수료, 국제 배송비, 광고비, 환전·결제 수수료, 순이익(금액·비율) | `v_profit_monthly` | - |
| 마켓별 순이익 | 가로 막대 + 순마진 | `v_profit_monthly` | 막대 클릭 → `/orders?market=` |
| 수익 인사이트 | 규칙 기반 문장 3개(최고 마진 마켓, 배송비 비중 경고, 승인 대기 동기화 링크) | `/api/profit` | 링크 |
| 순이익 상위 상품 | 상품, 주요 마켓, 판매수, 매출, 순이익, 순마진 | `/api/profit` | - |

광고비는 MVP에서 수동 입력 값만 쓴다(제안, 마켓 광고 API 연동은 Phase 2).

### 3.9 S-08 연동 설정 (`prototype/index.html:2425-2648`)

| 요소 | 내용 | 데이터 | 행동 |
|---|---|---|---|
| 쿠팡 파트너스 API (Coupang Partners API) | 비용(무료·최종 승인 후 발급), 인증 방식, Access/Secret 입력(마스킹), 상태 | `encrypted_credentials` | 저장, 연결 테스트 |
| 확장프로그램 | 설치 안내, 토큰 발급·재발급, 마지막 사용 시각 | `/api/extension/token` | 발급 |
| 운송사 추적 | 운송사 목록과 추적 방식(공개 조회 / API 키) | `shipping_templates` | 저장 |
| 마켓 API 안내 | Amazon SP-API, eBay, Shopee, Lazada, TikTok Shop 사양 카드(비용·인증·상태). 연결 자체는 S-10·S-11 | `/api/markets/catalog` | 연결하기 → S-11 |

PT의 "경쟁사 벤치마킹" 카드(`prototype/index.html:2438`)는 제품 화면에서 뺀다(기획 문서로 이동).

### 3.10 S-10 내 계정 (`prototype/index.html:3241-4162`)

좌측 프로필 카드: 아바타, 이름, 이메일, 플랜 배지, 통계 4칸(등록 상품, 연결 마켓, 이달 매출, 팀 멤버), 탭 8개. 모바일은 카드가 위, 탭이 가로 스크롤.

| 탭 | 카드 | 필드 | 행동 | 데이터 |
|---|---|---|---|---|
| 내 프로필 | 기본 정보, 사업자 정보(인증 배지), 인터페이스 설정 | 이름, 브랜드명, 이메일, 연락처, 시간대, 기본 통화 / 사업자등록번호, 상호명, 사업장 주소, 업태, 종목 / 언어, 테마 | 수정, 변경사항 저장 | `profiles`, `organizations` |
| 구독 플랜 | 현재 플랜(갱신일·자동 갱신), 플랜 카드(`free`·`starter`·`pro`·`enterprise`, 프로토타입은 유료 3개. 가격은 원화 표시 — 39,000원·99,000원·249,000원, D-01 확정·`01_PRD.md` 4.1절), 이번 달 사용량 5개 | Starter·Pro·Enterprise / 상품 등록, AI 번역, 이미지 처리, API 호출, 팀 멤버 | 업그레이드(2.7절) | `subscriptions`, `plan_usage` |
| 마켓 연결 | 마켓 연결 카드 그리드 | 마켓, 계정, 상태 배지, 토큰 만료·갱신 주기 | ＋마켓 추가(S-11), 재연결, 연결하기(S-11 3단계 바로) | `market_accounts` |
| API 키 관리 | API 키 방식 마켓 카드 | 키 필드(표시/숨기기/복사), 방식 표기 | 저장, 삭제 | `encrypted_credentials`(마스킹 값만) |
| 결제 내역 | 결제 수단, 결제 내역 | 카드 끝 4자리·만료, 내용·금액·상태·영수증 | 카드 추가, 전체 내보내기, 영수증 | `payments`, `billing_keys` |
| 알림 설정 | 이메일 6종, Slack | 주문 수신, API 오류, 일간·주간 리포트, 가격 이상, 구독 갱신 / Slack 채널 | 토글, Slack 연결(P1) | `notification_prefs` |
| 보안 | 2FA 경고 띠, 비밀번호 변경, 2FA, 최근 로그인 이력, 위험 구역 | 현재·새·새 비밀번호 확인 / TOTP 앱(Google Authenticator 등)·SMS 인증 / 기기·위치·시각 / 모든 세션 로그아웃, 계정 삭제 | 변경, 토글, 세션 초기화, 계정 삭제(확인 단계 화면 안에서) | Supabase Auth, `audit_log` |
| 팀 멤버 관리 | 역할 설명 띠, 멤버 행, 초대 폼 | 이름·이메일·상태·역할 선택 / 이메일·역할 | 역할 변경, 삭제, 재발송, 초대 발송 | `org_members`, 코어 `invite_member`·`change_member_role`·`remove_member` |

비밀번호 변경은 이메일 가입자만 보인다(Google 가입자는 숨김). 2FA는 P1(Supabase MFA, 제안). 계정 삭제·세션 초기화는 `confirm()` 대신 화면 안 확인 단계를 둔다.

### 3.11 S-11 마켓 추가 마법사 (`prototype/index.html:4163-4330`)

| 단계 | 구성 | 행동 | 데이터 |
|---|---|---|---|
| 1 여건 진단 | 안내 띠, 7문항(라디오·체크 칩). 문항·답변 값·기본 선택 정본은 DESIGN_STRUCTURE 4.1절: 사업자 형태(개인사업자·법인사업자·아직 없음), 통신판매업 신고(완료·아직), 해외 판매대금 받을 계좌(글로벌 수취 계좌·국내 은행 외화 계좌·아직 없음), 해외 결제 가능한 신용카드(있음·없음), 판매하고 싶은 지역(북미·일본·동남아·유럽, 복수), 주력 상품 카테고리(뷰티·식품·리빙·주방·전자기기·공예·전통, 복수), 마켓 월 고정비 예산(0원·월 $50 이하·상관없음). 복수 문항을 모두 끄면 다음 버튼 비활성 | 답변 선택, "추천 마켓 보기" | `readiness_answers` |
| 2 추천 마켓 | 요약(바로 연결 N곳·준비 필요 M곳), 추천 카드 목록(로고, 이름, 상태 배지, 추천·지원사업 배지, 월 고정비·수수료·소요 기간, 준비 필요, 팁, 적합도, 버튼), 정책 변동 안내, 벤치마킹 노트(접기) | 카드 버튼, "추천 1순위 연결" | `/api/markets/catalog`, `packages/domain/readiness.ts` |
| 3 계정 연결 | 마켓 요약, 판매 국가, 계정 별칭, 요청 권한 4종, OAuth 버튼 또는 API 키 2칸·연결 테스트, 연결 확인 띠 | 승인 / 테스트. 승인 전 "다음" 비활성 | `/api/markets/connect/start`, `/api/markets/accounts` |
| 4 초기 설정 | 기존 리스팅 가져오기(읽기 전용) 토글, 주문 자동 수집 주기, 가격 규칙·배송 템플릿, 판매 통화, 재고 버퍼, 운영 메뉴 탭 추가 토글 | "연결 완료" | `market_accounts.settings` |
| 5 완료 | 완료 문구, 다음 행동 3카드(상품 등록하기, 주문 관리 보기, 다른 마켓 추가) | 이동 | - |

키보드: Esc 닫기, 배경 클릭 닫기, 열릴 때 모달에 포커스. 모바일은 화면 꽉 찬 시트, 스텝이 두 줄로 접힌다(`prototype/index.html:4163`).

### 3.12 디자인 시스템

| 항목 | 내용 |
|---|---|
| 정본 | `08_DESIGN_SYSTEM.md`. 토큰은 Tailwind CSS v4 `@theme`로 `apps/web/styles/tokens.css`에만 둔다 |
| 출처 | PT의 OKLCH 3층 토큰(브랜드·표면·상태·차트·마켓 색), Pretendard + JetBrains Mono |
| 기본 컴포넌트 | 이름 정본은 `07_SOURCE_MIGRATION.md` 2.1절: `Button`, `Card`, `KpiCard`, `StatusPill`, `MarketTag`, `SegmentTabs`, `MarketScope`, `MarketHealthStrip`, `DataTable`, `Switch`, `SecretField`, `TokenInput`, `FileDropzone`, `Stepper`, `Dialog`·`WizardDialog`, `ShipmentTimeline`, `ProgressRow`, `HBarChart`·`VBarChart` |
| 미리보기 | `/dev/components`(개발 환경만, 라이트·다크) |

## 4. 메인페이지(랜딩) 디자인 방향

MVP는 공개 랜딩을 크게 만들지 않는다. 검증 단계라 **대기자 등록 페이지 1장**을 권장한다(제안, 린 검증 원칙: 개발 전 수요 확인).

| 항목 | 내용 |
|---|---|
| 목적 | 역직구 셀러 대기자 이메일 수집, 관심 마켓·월 판매 규모 2문항 |
| 구성 | 한 줄 가치("쿠팡 상품을 아마존·eBay에, 재고·가격은 자동으로"), 대시보드 스크린샷 1장(프로토타입 S-04 마켓 탭 화면), 3단계 설명(수집 → 등록 → 운영), 대기자 폼, 약관 링크 |
| 레퍼런스 | `platform-docs/products/_design-guide/REFERENCES.md`의 SaaS 대시보드 절에서 고른다. URL은 그 문서에 있는 것만 쓴다 |
| 브리프 | 셀러의 하루를 줄이는 운영 도구. 장식보다 숫자(실제 화면)를 보여 준다 |
| 토큰 플랜 | 앱과 같은 토큰. 브랜드 파랑 1색 + 중성 회색 + 마켓 색은 태그에만 |
| 기본값 회피 | 보라 그라데이션 히어로, 근거 없는 수치("매출 3배"), 별 파티클 금지. 3D 히어로는 Phase 2(제안) |
| 카피 | `01_PRD.md` 6장 금지 문구 통과(수익 보장, 정책 승인 보장 금지) |

## 5. 상태, 오류, 빈 화면

| 상황 | 표시 | 위치 |
|---|---|---|
| 잡 진행(수집·번역·등록·일괄) | 진행 막대 + 건수, Realtime 갱신. 30초 이상 무응답이면 "처리 중입니다. 창을 닫아도 계속 진행됩니다" | S-02, S-03 |
| 플랜 한도 초과(상품 수, 마켓 수, AI 번역, 멤버) | 403 `GS003` → 한도 카드 "Pro 플랜 한도 2,000개 중 2,000개 사용" + 업그레이드 버튼 | 해당 행동 위치 |
| 크레딧 부족(402, 코어 `CR001`) | "크레딧이 부족합니다" + 크레딧팩 링크 | AI 재생성, 일괄 번역 |
| 리스크 검사 | 경고(노랑)는 확인 후 진행, 차단(빨강)은 등록 불가 + 사유 | S-02 3단계, S-03 검증·사전 검증 |
| 마켓 토큰 만료 | 마켓 탭 "!" 배지, 지표 띠 "접근 토큰 만료" + 재연결 버튼 | S-04~S-06, S-10 |
| 마켓 API 한도 | "마켓 API 호출 한도에 맞춰 대기 중" + 예상 재개 시각 | S-03 일괄, S-04 |
| 쿠팡 API 한도 | 게이지 빨강 + "다음 시간대(HH:00)에 이어서 수집" | S-02 대량 |
| 네트워크 오류 | 카드 안 오류 + 다시 시도, 입력 값 유지 | 전체 |
| 빈 화면: 수집함 | "아직 수집한 상품이 없습니다. 쿠팡 상품 주소를 붙여 넣어 시작하세요" + 개별 등록 버튼 | S-02 |
| 빈 화면: 등록 현황 | "등록한 상품이 없습니다. 수집함에서 상품을 고르세요" | S-03 |
| 빈 화면: 마켓 0개 | 탭 바에 "전체"와 "＋ 마켓 추가"만. 본문 "연결된 마켓이 없습니다. 마켓을 연결하면 동기화·주문·배송을 마켓별로 볼 수 있습니다" + 마법사 버튼 | S-04~S-06 |
| 빈 화면: 마켓 탭 목록 0건 | 표 안 한 줄: S-04 "이 마켓의 최근 변동이 없습니다", S-05 "이 조건에 해당하는 주문이 없습니다", S-06 "이 마켓의 배송 건이 없습니다"(`prototype/index.html` 각 `empty-row`) | S-04~S-06 |
| 빈 화면: 새로 연결한 마켓 | KPI 0, 지표 띠 "기존 리스팅 가져오는 중(읽기 전용)" | S-04~S-06 |
| 확인이 필요한 행동 | 브라우저 `confirm()` 대신 화면 안 확인 단계(계정 삭제, 연결 해제, 세션 초기화) | S-10 |

## 6. 접근성과 반응형

| 구간 | 폭 | 페이지 제목 | KPI 값 | 본문 | KPI 칸 | 2단 카드 | GNB |
|---|---|---|---|---|---|---|---|
| 모바일 | ~767px | 16px | 19px | 13px | 2칸 | 1단 | 상단 가로 스크롤 메뉴 10개 |
| 태블릿 | 768~1199px | 18px | 21px | 14px | 3칸 | 1단 | 좌측 200px |
| 데스크탑 | 1200px~ | 20px | 24px | 14px | 5칸 | 2단(본문 + 320px) | 좌측 220px + 상단 탭 5개 |

근거: DS 2장 표, `prototype/index.html`의 반응형 미디어 쿼리.

| 항목 | 기준 |
|---|---|
| 가로 넘침 | 본문 가로 스크롤 0. 넓은 표는 카드 안 `overflow-x: auto`(PT 스모크 테스트 `tests/prototype-smoke.js` 6항목과 같은 검사) |
| 키보드 | 탭·세그먼트·마켓 탭은 버튼 요소, 방향키 이동은 P1. 모달은 Esc·포커스 이동 |
| 대비 | 본문 4.5:1 이상, 배지는 글자색 + 배경 혼합으로 라이트·다크 모두 확인 |
| 색 단독 의미 금지 | 상태 배지는 점 + 문구, 차트는 값 라벨 |
| 한글 입력 | 칩 입력은 `isComposing` 중 Enter 무시(PT 동작) |
| 다크 모드 | 시스템 설정 기본 + 수동 전환, 토큰으로만 |

## 7. 로그인 화면 단계별 구성

정본 `platform-docs/products/_platform-core/AUTH_ROADMAP.md` 2장, 5.2절, 7장. GlobalSeller는 open 앱(가입 즉시 사용)이다. 로그인 뒤 화면은 단계와 무관하게 같다.

| 단계 | `/login` 구성 | `/auth/callback` | 비고 |
|---|---|---|---|
| A(MVP 개발, 로컬) | "개발용 로그인" 패널: 공통 페르소나(`owner`, `admin`, `member`, `viewer`, `outsider`, `no_app`, `suspended`, `ops`) + 제품 페르소나 `pro`(Pro 플랜·마켓 3개 연결 시드), `empty`(마켓 0개, 빈 화면 확인용)(제안). 실제 제공자 버튼은 렌더하지 않는다 | 없음(`POST /api/dev/login`) | 모든 화면 상단 고정 배지 `MOCK AUTH · 로컬 전용`. 운영 빌드에서 패널·배지 코드 미렌더 |
| B(공개 베타 전) | "Google로 계속하기" + 이메일 폼(로그인·가입 탭, 비밀번호 재설정) + 약관 링크 | `finishLogin` 후 `/onboarding/terms` → `/dashboard` | 이메일 가입·인증 메일 안내·재설정 화면은 B에서 만든다 |
| C1·C2(G2 후, Phase 2) | B + "카카오로 계속하기", "네이버로 계속하기"(검수 전 숨김) | 같은 콜백(네이버 브리지면 별도) | 버튼 순서 Google, 카카오, 네이버, 이메일(제안) |

| 오류 코드 | 원인 | 문구 |
|---|---|---|
| `error=callback` | 코드 없음·재사용·만료 | "로그인을 완료하지 못했습니다. 다시 시도해 주세요" |
| `error=state` | (C2 브리지) state 불일치 | "로그인 요청이 만료됐습니다. 처음부터 다시 시도해 주세요" |
| `error=email_in_use` | (C2 브리지) 같은 이메일 다른 방법 가입자 | "이미 다른 방법으로 가입한 이메일입니다. 그 방법으로 로그인한 뒤 설정에서 연결하세요" |
| 403 suspended | 정지 계정 | "이용이 정지된 계정입니다. 고객센터로 문의하세요"(제안) |

## 8. 대시보드 셸과 GNB

### 8.1 헤더

| 위치 | 요소 | 동작 |
|---|---|---|
| 왼쪽 | 로고(GlobalSeller OS, 부제), 구분선, 브레드크럼(홈 › 현재 화면) | 로고 → `/dashboard`. 모바일은 브레드크럼 숨김 |
| 가운데(데스크탑만) | 주요 탭 5개: 대시보드, 상품 수집, 해외 등록, 주문, 수익 | 클릭 → 해당 라우트 |
| 오른쪽 | 알림, 테마 전환, 아바타 | 알림 → `/orders`, 아바타 → `/account/profile` |

### 8.2 GNB 메뉴 순서 (`prototype/index.html:1329`)

| 그룹 | 메뉴 | 라우트 | 배지 |
|---|---|---|---|
| 메인 | 대시보드 | `/dashboard` | - |
| 상품 관리 | 쿠팡 상품 수집 | `/collect` | 검토 대기 수(노랑) |
| 상품 관리 | 해외 마켓 등록 | `/listings` | - |
| 상품 관리 | 재고·가격 동기화 | `/sync` | 승인 대기 + 실패 수(노랑) |
| 상품 관리 | 주문 통합 관리 | `/orders` | 발주 대기 수(파랑) |
| 상품 관리 | 배송·물류 추적 | `/shipping` | 지연 수(있을 때만) |
| 마켓 연결 | 마켓 칩 목록(연결 상태) | 칩 → `/account/markets` | 연결됨·만료·미연결 |
| 분석·설정 | 수익 분석 | `/profit` | - |
| 분석·설정 | 연동 설정 | `/settings/integrations` | - |
| 하단 | 사용자 카드(이름·역할·톱니) | `/account/profile` | - |

### 8.3 셸 동작 규칙

| 규칙 | 내용 |
|---|---|
| 선택 동기화 | 상단 탭, 좌측 GNB, 모바일 메뉴는 현재 라우트(pathname 첫 세그먼트) 하나로 선택 상태를 정한다. 클라이언트 전역 상태로 따로 들고 있지 않는다(PT `data-view` 동작을 라우트로 대체) |
| 탭 상태 | 하위 탭(`tab`), 마켓 탭(`market`), 상태(`status`)는 URL 쿼리. 뒤로가기로 이전 탭 복원 |
| 모바일 메뉴 | 767px 이하에서 헤더 아래 가로 스크롤. 선택 항목을 가운데로 스크롤 |
| 스크롤 | 라우트 변경 시 본문 맨 위로 |
| 배지 숫자 | 서버 컴포넌트에서 `market_tab_counts`·집계 1회, Realtime으로 갱신 |
| 셸 밖 화면 | `/login`, `/auth/*`, `/onboarding/*`, `/`(랜딩), `/legal/*` |
| 모달 | S-11은 인터셉트 라우트로 셸 위에 뜨고, 직접 URL로 들어오면 전체 화면 페이지로 렌더 |
