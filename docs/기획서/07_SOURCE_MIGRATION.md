# 07 원본 이식과 폐기: GlobalSeller OS

GlobalSeller OS는 신설 제품이라 "이식할 코드 베이스"가 없다. 원본은 (1) 클릭 가능한 프로토타입 `prototype/index.html`(화면·토큰·문구·점수 규칙), (2) 기획 업데이트 문서 `docs/planning-update-2026-10-23.md`(벤치마킹 규칙), (3) platform-docs의 nomad-commerce 기획서(마켓 어댑터·자격증명·안전 fetch·금지어 패턴), (4) `_platform-core`(코어 표와 RPC)다. 프로토타입은 단일 HTML(약 4,700줄)이고 서버·DB가 없으므로 **구조와 값만 옮기고 코드는 다시 쓴다.**

## 1. 원본별 자산 분류

### 1.1 프로토타입 (`prototype/index.html`, 디자인 원본)

| 자산 | 상태 | 처리 | 대상 위치 | 근거 |
|---|---|---|---|---|
| 디자인 토큰(`:root` 색·반경·그림자·서체, 다크 블록) | 동작 | 이식(값 그대로, 이름은 Tailwind CSS v4 토큰으로) | `apps/web/styles/tokens.css` | `prototype/index.html:12-96`, 08장 3절 |
| 반응형 3구간 글자 크기 | 동작 | 이식 | `apps/web/styles/tokens.css`(`@theme` + 미디어 쿼리) | `:587-612` |
| 셸(상단 바, 좌측 GNB, 모바일 가로 메뉴, 사용자 카드, 마켓 칩) | 목업 | 디벨롭(라우트 기반 선택 상태) | `apps/web/components/shell/` | `:1314`, `:1329`, `:4352` |
| GNB 메뉴 순서와 라벨 | 확정 | 이식(상수) | `packages/domain/nav.ts` | 구조 문서 1장 |
| 화면 11종 마크업(S-01~S-11, S-09 제외) | 목업 | 디벨롭(서버 컴포넌트 + 데이터) | `apps/web/app/(app)/<화면>/` | `:1392`, `:1613`, `:2028`, `:2425`, `:2806`, `:2928`, `:3033`, `:3149`, `:3241`, `:4163` |
| 하위 탭(수집함·개별·대량, 등록 현황·개별·일괄, 계정 8탭) | 목업 | 디벨롭(쿼리 `?tab=`, `/account/[tab]`) | 같음 | `:1632`, `:1754`, `:1895`, `:2047`, `:2117`, `:2304`, `:3314-4045` |
| 마켓 탭 공통 패턴(`setMk`, `data-only`, `data-market`) | 목업 | 디벨롭(컴포넌트 `MarketScope` + URL `market`) | `apps/web/components/market-scope/` | `:4422` |
| 마켓 카탈로그(이름·지역·고정비·수수료·연결 방식·요건) | 목업 | 이식(값 재확인 후 상수) | `packages/domain/markets.ts` | `:4492` |
| 마법사 점수 규칙(`mkEval`) | 동작 | 이식(같은 가중치, 단위 테스트로 결과 고정) | `packages/domain/readiness.ts` | `:4535` |
| 판매가 계산(`calcPrice`) | 동작(실수 연산) | 공식만 이식, 정수 최소 단위로 다시 작성 | `packages/domain/pricing.ts` | `:4400-4413`, 구조 문서 11.3절 |
| 화면 문구(라벨, 빈 상태, 안내 문장) | 확정 | 이식(문구 키로) | `apps/web/messages/ko.ts`(제안) | 화면 전체 |
| 리스크 검사 항목(항공 제한, 브랜드, 이미지 권한) | 목업 | 디벨롭(규칙 파일) | `packages/compliance/rules/` | `:1848-1850`, `:2399` |
| 마켓 건전성 지표 라벨과 목표치(ODR <1% 등) | 목업 | 이식(라벨), 목표치는 재확인 후 상수 | `packages/domain/health.ts` | `:2957-2978`, `:3062` |
| 예시 데이터(매출 $18,420, 주문 412건 등) | 목업 | 폐기(시드 데이터 페르소나로 대체) | `supabase/seed.sql` | `:3162-3166` |
| 스모크 테스트 | 동작 | 참고(Playwright E2E 시나리오 목록) | `tests/e2e/` | `tests/prototype-smoke.js` |

### 1.2 기획 업데이트 문서 (`docs/planning-update-2026-10-23.md`)

| 자산 | 처리 | 대상 | 근거 |
|---|---|---|---|
| 전체 탭 + 마켓별 탭 설계 포인트(전체 = 오늘 처리할 일, 마켓 = 계정 건전성) | 이식(규칙) | 03장, `MarketScope` | `docs/planning-update-2026-10-23.md:12-29` |
| 마법사 5단계와 추천 카드 구성 | 이식 | S-11, 01장 GS-F-059~062 | `:31-45` |
| 개별 등록·대량 수집 단계 | 이식 | S-02, 01장 GS-F-012~022 | `:47-54` |
| Sellbrite: 연결 직후 읽기 전용 가져오기, 같은 마켓 다계정 | 이식(규칙) | GS-F-061·062 | `:62` |
| 윈들리: 수집 순간 예상 마진 | 이식 | 개별 등록 우측 요약 | `:64` |
| 반자동 운영(리스크 검사 필수, 대량 수집도 수집함 보관) | 이식(규칙) | GS-F-016, GS-F-021 | `:65` |
| 쿠팡 파트너스 API 제약(최종 승인 후 키, 키워드만, 호출 제한) | 이식(범위 결정) | 키워드 수집 P1, 수집 경로 3종 | `:69-78` |

### 1.3 nomad-commerce 기획서 (설계 패턴만)

| 자산 | 처리 | GlobalSeller 대상 | 근거 |
|---|---|---|---|
| 마켓 어댑터 패키지 경계(`packages/commerce-markets/{coupang,smartstore}/`) | 패턴 이식. 마켓은 바꾼다(eBay, Amazon SP-API, Shopee) | `packages/markets/<market>/` + 공통 `MarketAdapter` 인터페이스 | `platform-docs/products/nomad-commerce/CLAUDE.md:46` |
| 마켓 자격증명 vault·마스킹 응답·연결 해제(`revoke_credential`) | 패턴 이식 | `apps/web/app/api/markets/accounts/`, 워커 복호화 | `platform-docs/products/nomad-commerce/CLAUDE.md:22`, `:69` |
| 안전 fetch(허용 도메인, DNS 후 사설 IP 차단, 리다이렉트 3회, 2MB, 10초) | 패턴 이식. 허용 도메인은 쿠팡·마켓 API·운송사 | `packages/net/` | `platform-docs/products/nomad-commerce/06_AGENT_PLAN.md` CM-06-008 행 |
| 금지어 매처(한글 `\b` 금지, 언어 중립 규칙 파일) | 패턴 이식. 규칙은 영어·해외 마켓 기준으로 새로 작성 | `packages/compliance/` | `platform-docs/products/nomad-commerce/CLAUDE.md:43`, `:31` |
| 워커 핸들러 자동 로드(`src/<영역>/handler.ts`), 공유 등록 지점 없음 | 패턴 이식 | `services/worker/src/<영역>/handler.ts` | `platform-docs/products/nomad-commerce/06_AGENT_PLAN.md` 1절 원칙 표 |
| 크레딧 선차감 위치(Route Handler 안), 멱등 키 규약 | 이식 | `apps/web/lib/credits/` | `platform-docs/products/nomad-commerce/CLAUDE.md:63-64` |
| 상세페이지 슬롯·이미지 생성, 쿠팡·스마트스토어 업로드, 플레이오토 엑셀, 아마존 소싱 | 해당 없음(방향이 다른 기능) | - | 같은 문서 1절 |
| 복사 금지 결함 목록 | 이식(4절에 GlobalSeller 해당분) | 이 문서 4절 | `platform-docs/products/nomad-commerce/07_SOURCE_MIGRATION.md` 4절 |

### 1.4 `_platform-core` (코어, 소비만)

| 자산 | 처리 | 대상 | 근거 |
|---|---|---|---|
| `MONOLITH_CORE_LITE.sql` | 복사(수정 금지), SECTION 9 affiliate 제외 | `supabase/migrations/` 첫 파일 | `platform-docs/products/_platform-core/MONOLITH_CORE_LITE.sql:2409-2414` |
| `session_context`, `consume_credits`·`refund_credits`, `jobs` claim, `encrypted_credentials`, `oauth_states`, Toss 결제 | 소비 | `apps/web/lib/session/`, `lib/credits/`, `services/worker/src/runtime/` | `CORE_SPEC.md` 2~9장 |
| 인증 단계 A·B·C 모듈 경계 | 소비 | `apps/web/lib/auth/` | `AUTH_ROADMAP.md` 3.1절 |
| AI 계층 표(`ai_*`), Dify, 음성 | MVP 미사용(표는 코어 SQL에 있으나 쓰지 않음) | - | 01장 2절 |

## 2. 이식 자산 상세

### 2.1 프로토타입 CSS 클래스 → 컴포넌트

컴포넌트 이름은 이 표가 정본이다. 03장 화면 명세와 08장 11절이 같은 이름을 쓴다. 기본 컴포넌트는 shadcn/ui(Tailwind CSS v4 지원 버전)를 재스타일하고, 제품 컴포넌트는 `apps/web/components/<영역>/`에 둔다.

| 프로토타입 클래스 | 컴포넌트 | 위치 | 비고 |
|---|---|---|---|
| `.topbar`, `.logo`, `.breadcrumb`, `.tab-bar` `.tab` | `AppTopbar`, `Breadcrumb`, `TopTabs` | `components/shell/` | 상단 탭 5개는 GNB와 같은 라우트 상수 |
| `.sidebar`, `.nav-section`, `.nav-item`, `.nav-badge` | `AppSidebar`, `NavItem` | `components/shell/` | 배지 숫자는 `market_tab_counts`·작업 수 |
| `.market-row` `.market-chip` | `MarketChip` | `components/shell/` | 클릭 → `/account/markets` |
| `.sidebar-user` | `SidebarUserCard` | `components/shell/` | |
| `.mnav` `.mnav-item` | `MobileNav` | `components/shell/` | 767px 이하 |
| `.page-hd`, `.page-title`, `.hd-actions` | `PageHeader` | `components/layout/` | |
| `.card` `.card-hd` `.card-body` | `Card` (shadcn) | `components/ui/` | |
| `.kpi-grid`, `.kpi`, `.kpi-bar` | `KpiGrid`, `KpiCard` | `components/kpi/` | 값 글자 크기는 08장 3.3절 |
| `.pill` (`ok`·`warn`·`err`·`info`·`gray`) | `StatusPill` | `components/ui/` | 상태 값 → 배리언트 매핑은 `packages/domain/status.ts` |
| `.mtag` | `MarketTag` | `components/market/` | 마켓 고유색 토큰 |
| `.btn` (`primary`·`ghost`·`xs`), `.btn-danger-sm`, `.icon-btn` | `Button` (shadcn) | `components/ui/` | 배리언트 `primary`·`ghost`·`danger`, 크기 `xs`·`sm`·`md`·`icon` |
| `.seg` `.seg-btn` `.seg-count` | `SegmentTabs` | `components/ui/` | 하위 탭, 주문 상태 그룹 |
| `.mtabs` `.mtab` `.mtab-n` `.mtab-add` | `MarketScope` | `components/market-scope/` | URL `market` 소유 |
| `.mstrip` `.ms-i` `.ms-act` | `MarketHealthStrip` | `components/market-scope/` | 전체 탭·마켓 탭 지표 |
| `.steps` `.step` `.step-n` | `Stepper` | `components/ui/` | 개별 등록, 대량 수집, 마법사 |
| `.sec-n` + `.card-title` | `FormSection` | `components/form/` | 번호 붙은 단계 카드 |
| `.pick` `.pick-grid` | `SelectCard` (checkbox) | `components/ui/` | 대상 마켓, 함께 가져올 항목 |
| `.src` `.src-grid` | `SelectCard` (radio) | `components/ui/` | 수집 방식, 상품 가져오기 |
| `.opt` | `ChoiceChip` | `components/ui/` | 마법사 진단 문항 |
| `.rec` | `MarketRecommendCard` | `components/markets/` | 적합도·상태·배지 |
| `.modal-bg` `.modal` `.modal-hd` `.modal-ft` | `Dialog` (shadcn) + `WizardDialog` | `components/ui/`, `components/markets/` | 인터셉트 라우트 모달 |
| `.dropzone` | `FileDropzone` | `components/form/` | CSV·XLSX |
| `.chips` `.chip` `.chip.ex` | `TokenInput` | `components/form/` | 키워드·제외어(한글 조합 중 Enter 무시) |
| `.fld` `.fld-l` `.inp`, `.fgrid` | `FormField`, `Input`, `Select`, `Textarea` | `components/ui/` | |
| `.edit-layout` `.edit-side` | `EditLayout` | `components/layout/` | 우측 고정 요약(1199px 이하에서 아래로) |
| `.src-prod` `.thumb` | `SourceProductSummary`, `Thumbnail` | `components/collect/` | |
| `.chk` `.chk-i` `.chk-ic` | `ValidationChecklist` | `components/listing/` | OK·WARN·FAIL |
| `.kv` `.kv-r` | `KeyValueList` | `components/ui/` | 가격 계산, 요약 |
| `.rule` `.toggle-switch` | `RuleRow`, `Switch` (shadcn) | `components/sync/`, `components/ui/` | |
| `.prog` `.prog-bar`, `.usage-item`, `.quota` | `ProgressRow`, `UsageBar`, `QuotaMeter` | `components/ui/` | |
| `.hbars` `.hb`, `.vbars` `.vb` | `HBarChart`, `VBarChart` | `components/charts/` | 단일 색상 막대, 값 직접 표시 |
| `.track` `.tr-i` | `ShipmentTimeline` | `components/shipping/` | |
| `.pipeline` `.pipe-step` | `PipelineSteps` | `components/orders/` | 주문 5단계 |
| `.act-item` | `ActivityItem` | `components/dashboard/` | |
| `.note` (`warn`) | `Callout` | `components/ui/` | |
| `table`, `.tbl-wrap`, `.order-tools`, `.search-form`, `.filter-select` | `DataTable`, `TableToolbar`, `SearchInput` | `components/table/` | 표는 카드 안 가로 스크롤 |
| `.acc-layout` `.acc-profile-card` `.acc-tab` | `AccountLayout`, `AccountTabNav` | `components/account/` | |
| `.plan-card`, `.market-connect-card`, `.key-field`, `.billing-row`, `.team-row`, `.lh-row` | `PlanCard`, `MarketAccountCard`, `SecretField`, `BillingRow`, `MemberRow`, `LoginHistoryRow` | `components/account/` | `SecretField`는 마스킹 값만 받는다 |
| `.api-card` | `IntegrationCard` | `components/settings/` | |

### 2.2 로직 이식

| 원본 함수 | 새 위치 | 바꾸는 점 |
|---|---|---|
| `calcPrice` (`prototype/index.html:4400`) | `packages/domain/pricing.ts` | 입력·출력을 정수 최소 단위(원, 센트)로, 반올림 규칙(.99·정수·10엔)을 함수 인자로, 마켓별 수수료는 `markets.ts`에서 |
| `mkEval`·`mkRender` (`:4535`, `:4563`) | `packages/domain/readiness.ts` + `MarketRecommendCard` | 가중치·상태 규칙 그대로, 마켓 데이터는 `markets.ts`, HTML 문자열 생성 대신 컴포넌트 |
| `setMk`·`applyRowFilter` (`:4422`) | `MarketScope` + 서버 쿼리 `market` 필터 | 클라이언트 DOM 필터 대신 서버에서 필터한 결과를 렌더 |
| `filterOrders` | `/orders?status=` 서버 쿼리 | 상태 그룹 → 상태 값 매핑은 구조 문서 5.1절 |
| `switchView` (`:4352`) | Next.js App Router 라우트 | 해시 라우팅 폐기 |

## 3. 폐기 목록과 사유

| # | 폐기 대상 | 사유 |
|---|---|---|
| 1 | 인라인 `onclick` 핸들러와 전역 함수 | 컴포넌트 이벤트로 대체 |
| 2 | `data-v` JSON에 박힌 마켓별 KPI 값(`prototype/index.html:2861` 등) | 데모 수치. 서버 집계로 대체 |
| 3 | `data-only` 속성으로 숨기는 마켓 전용 요소 | 마켓 코드 기반 조건부 렌더로 대체 |
| 4 | 해시 라우팅(`history.replaceState('#id')`, `:4362`) | App Router 경로 |
| 5 | S-09 아키텍처 구조도 화면(`:2649`) | 제품 사용자에게 필요 없음. `docs/설계/DESIGN_STRUCTURE.md` 6장으로 이동 |
| 6 | 화면 하단 "벤치마킹 기획 노트" `details`(`.bench`) | 기획 설명용. 03장과 기획 업데이트 문서에 이미 있음 |
| 7 | 이모지 아이콘(GNB·KPI 라벨·규칙 아이콘) | Lucide 아이콘으로 대체(08장 3.6절) |
| 8 | 예시 데이터 전부(상품·주문·송장·매출) | 시드 페르소나 데이터로 대체 |
| 9 | 마법사 완료 시 DOM에 탭을 직접 추가하는 코드(`:4628`) | `market_accounts` 행 생성 → 서버 재조회 |
| 10 | Google Fonts로 Pretendard 요청(`:4-5`) | Google Fonts에 Pretendard가 없는 것으로 보인다(미확인). `next/font/local`로 자체 호스팅 |
| 11 | `html,body{overflow:hidden}` + 본문 내부 스크롤(`:99`) | 브라우저 기본 스크롤로 되돌려 키보드·스크린리더 탐색을 지킨다(제안) |
| 12 | 프로토타입 API 설정 화면의 마켓별 비용·인증 설명 카드 | 마켓 카탈로그(`markets.ts`)와 마법사 추천 카드가 같은 정보를 보여 준다. S-08은 연동 상태만 |
| 13 | 마법사 TikTok Shop "승인 신청 안내" 버튼이 권한 승인으로 처리되는 동작 | 초청·승인제 마켓은 외부 안내 링크만(03장) |

### 3.1 프로토타입과 다르게 가는 화면 요소 (의도적 변경, 2026-10-25)

완성도 측정(프로토타입 요소 478개 대조)에서 기획서에 없던 12개는 누락이 아니라 아래 이유로 바꾼 것이다. `/sync-design`(`.claude/commands/sync-design.md`)은 이 표의 항목을 차이로 보고하지 않는다.

| # | 프로토타입 요소 (`prototype/index.html`) | 제품에서 | 이유 |
|---|---|---|---|
| C-1 | S-10 API 키 관리 › Amazon SP-API 카드 "Client ID (LWA)"(`:3637`) | 없음. 사용자는 S-11 3단계에서 "Amazon 로그인하고 권한 승인"만 누른다 | LWA 클라이언트 ID·시크릿은 GlobalSeller 앱 하나의 값이라 서버 env(`AMAZON_LWA_CLIENT_ID`, 02장 환경변수)에 둔다. 사용자 계정에는 승인 후 받은 리프레시 토큰만 `encrypted_credentials`에 저장 |
| C-2 | 같은 카드 "Client Secret (LWA)" | 없음 | C-1과 같다. 사용자 화면에 앱 시크릿을 받으면 유출면만 늘어난다 |
| C-3 | 같은 카드 "AWS IAM Access Key" | 없음 | SP-API는 더 이상 AWS IAM·Signature Version 4를 요구하지 않는다(개발서 9.2절, 02장 마켓 인증 표) |
| C-4 | eBay REST API 카드 "App ID (Client ID)" | 없음 | eBay 앱 키셋은 플랫폼 값(서버 env). 사용자는 OAuth 동의만 |
| C-5 | 같은 카드 "Cert ID (Client Secret)" | 없음 | C-4와 같다 |
| C-6 | Shopee 카드 "Partner ID" | 없음 | Shopee 파트너 앱은 플랫폼 하나. 사용자는 상점 권한 승인 링크로 연결(P1) |
| C-7 | 같은 카드 "Partner Key" | 없음 | C-6과 같다. 요청 서명은 워커가 서버 키로 한다 |
| C-8 | 수집 › 개별 등록 벤치마킹 노트 표 "참고 서비스" 열 | 없음 | 3장 6번(기획 노트 `details` 폐기). 내용은 `docs/planning-update-2026-10-23.md` 4장 |
| C-9 | 같은 표 "확인한 구조" 열, 대량 수집 노트 "참고"·"확인한 구조·제약" 열 | 없음 | C-8과 같다 |
| C-10 | 마법사 2단계 벤치마킹 노트 표 "참고 서비스" 열 | 없음 | C-8과 같다 |
| C-11 | 마법사 2단계 벤치마킹 노트 표 "확인한 구조" 열 | 없음 | C-8과 같다 |
| C-12 | S-08 API 설정 › 경쟁사 벤치마킹 카드 "플랫폼" 열(`:2438`) | 없음 | 3장 12번·03장 3.9절. 경쟁사 비교는 기획 문서로 이동 |

결과: S-10 "API 키 관리" 탭은 **API 키 방식 마켓(Qoo10, P2)** 계정만 보여 준다(03장 3.10절). 쿠팡 파트너스 키는 S-08 연동 설정에서 받는다. OAuth 마켓(eBay·Amazon·Shopee·Lazada)은 "마켓 연결" 탭에서 재연결·해제만 한다.

## 4. 복사 금지 결함

| 패턴 | 출처 | 왜 금지 | 대체 |
|---|---|---|---|
| 실수로 돈 계산(`parseFloat`, `Math.ceil(price) - 0.01`) | `prototype/index.html:4401-4405` | 반올림 오차, 마켓별 최소 단위 불일치 | `pricing.ts` 정수 연산, 구조 문서 11.3절 |
| 문자열 `innerHTML`로 목록·옵션 생성 | `prototype/index.html:4571`, `:4604`, `:4628` | 서버 데이터가 들어가면 XSS | React 렌더 |
| 클라이언트에서 플랜 한도·연결 상태 판정 | 프로토타입 전체(정적 값) | 우회 가능 | `plan_usage` RPC, 서버 판정(01장 GS-F-005) |
| 서버가 쿠팡 페이지를 대량 크롤링 | 기획 업데이트 5장(`docs/planning-update-2026-10-23.md:69-78`) | 약관 위반, 차단, 법적 위험 | 확장프로그램 담기, URL 단건 조회, 공식 API(01장 6장) |
| 마켓 토큰·API 키를 응답·로그·localStorage에 두기 | `platform-docs/products/nomad-commerce/07_SOURCE_MIGRATION.md` 4절 "localStorage 키 저장", "인증 없는 키 반환 API" 행 | 계정 탈취 | `encrypted_credentials`, 마스킹 응답, 복호화는 워커에서만 |
| 단일 env 마켓 키 | 같은 문서 "단일 env 마켓 키" 행 | 테넌트 격리 붕괴 | 계정별 자격증명 |
| 사용자 URL 직접 fetch, 원문 HTML 저장 | 같은 문서 "사용자 URL 직접 fetch" 행 | SSRF, 저작물 저장 | `packages/net` 안전 fetch, 필요한 필드만 추출 저장 |
| 한글에 `\b` 정규식 금지어 | 같은 문서 "한글에 `\b`" 행 | 필터 무효 | `packages/compliance` 매처 |
| `globalThis` 인메모리 잡, SSE + 브라우저 큐 | 같은 문서 해당 행 | 서버리스에서 유실 | 코어 `jobs` + 워커 + Realtime |
| 분리된 크레딧 차감 API, 비원자 차감 | 같은 문서 첫 두 행 | 무료 사용, 음수 잔액 | Route Handler 안 `consume_credits` |
| 요청 바디의 plan·model·role | 같은 문서 해당 행 | 비용 폭증, 권한 위조 | `session_context` + `plans.features` |
| 무서명 웹훅, `USING(true)` 정책 | 같은 문서 해당 행 | 타인 데이터 변조 | 서명 검증·멱등, 조직 정책 |
| 콜백 `next` 미검증, Host 헤더 origin | 같은 문서 해당 행 | 오픈 리다이렉트 | 화이트리스트 + env origin |
| LLM이 환율을 추정 | 같은 문서 "LLM 추정 환율" 행 | 가격 오류 | `fx_rates`(수출입은행, D-10) |
| AI 가상 후기·근거 없는 순위·"FDA approved" 자동 삽입 | 01장 6장 자동 삽입 금지 | 기만 광고, 마켓 정지 | 번역 프롬프트 금지 목록 + 컴플라이언스 검사 |
| 구매자 개인정보를 AI 요청·로그에 넣기 | 01장 6장 제3자 제공 | 개인정보 국외 이전 | 번역 입력 스키마에서 제외, 로그 마스킹 |

## 5. 아카이브 절차

| 단계 | 내용 |
|---|---|
| 1 | `prototype/index.html`과 `prototype/screenshots/`는 2026-10-23판으로 동결한다. 이후 화면 변경은 `apps/web`과 03장에서 하고, 프로토타입은 고치지 않는다(비교 기준) |
| 2 | `tests/prototype-smoke.js`는 프로토타입 회귀 확인용으로 남기고, 제품 E2E는 `tests/e2e/`에 새로 쓴다 |
| 3 | `/sync-design` 명령으로 프로토타입과 `apps/web` 화면의 차이를 점검한다(`../../.claude/commands/sync-design.md`) |
| 4 | 공개 베타 시점에 `prototype/`을 `archive/prototype-2026-10-23/`으로 옮길지 결정한다(GitHub Pages로 공개 중이면 링크 유지) |
| 5 | nomad-commerce·_platform-core 원본은 platform-docs에 있고 이 저장소에서 수정하지 않는다. 코어 SQL 복사본은 원본 커밋 해시를 파일 머리 주석에 남긴다 |

## 6. 인증 단계 관련 복사 금지

허용되는 Mock은 `platform-docs/products/_platform-core/AUTH_ROADMAP.md` 2장(로컬 Supabase 시드 계정으로 실제 JWT, `isMockAuthAllowed()` 가드, 배포 환경 404)뿐이다. 프로토타입에는 로그인이 없고 사용자 "김대영 · 리치노마드"가 하드코딩돼 있다.

| 패턴 | 출처 | 왜 금지 | 대체 |
|---|---|---|---|
| 하드코딩 사용자·역할(사용자 카드, 계정 화면 이름·이메일) | `prototype/index.html:1329`, `:3241` | 실제 세션과 무관한 표시 | `session_context` 결과로 렌더 |
| 쿠키·localStorage 역할·플랜 Mock(`mock-login`, `nomad_role`, `nomad_plan`) | `platform-docs/products/nomad-commerce/07_SOURCE_MIGRATION.md` 6절 | 권한 위조, 프로덕션 노출 | Stage A Mock 로그인(`/api/dev/login`, 시드 페르소나), 권한은 `session_context`만 |
| A·B단계 로그인 화면에 카카오·네이버 버튼 | `AUTH_ROADMAP.md` 0장 | 단계 순서 위반 | C1·C2 작업에서만 추가 |
| 기능 코드의 `if (mock)`·페르소나 이메일 분기 | `AUTH_ROADMAP.md` 2.5절 | Mock과 실제 경로가 갈림 | 단계 분기는 `apps/web/lib/auth/`, `app/(auth)/login/`, `app/auth/`, `app/api/dev/login/`에만 |
| 콜백 `next` 무검증 | 4절 행 | 오픈 리다이렉트 | `finishLogin` 화이트리스트 |
