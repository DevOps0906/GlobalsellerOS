# 06 에이전트 작업 계획: GlobalSeller OS

작성일 2026-10-25. 장 구조는 `platform-docs/products/_platform-core/DOC_TEMPLATE.md` 2.7절을 따른다. 작업 ID는 `GS-06-###`(SQLSTATE 접두사 `GS`, `docs/설계/DESIGN_STRUCTURE.md` 0장). 화면·라우트·모듈 경로·상태 값·큐 이름은 `docs/설계/DESIGN_STRUCTURE.md`(이하 DS)가 정본이다. 작업 수는 55개(사람 작업 1개 포함)로, DOC_TEMPLATE 권장 15~40개를 넘는다. 마켓 어댑터·워커 핸들러·화면을 검증 가능한 크기로 나눴기 때문이다(nomad-commerce 60개와 같은 이유, `platform-docs/products/nomad-commerce/06_AGENT_PLAN.md:5`). `tasks/task-###.md`는 이 표의 사본이고 번호가 같다(task-001 = GS-06-001).

이 저장소의 멀티에이전트 구성은 `docs/MULTI_AGENT.md`(tablet-kiosk-core `docs/11-multi-agent.md`를 옮긴 것)를 따른다. **팀장 = 주 세션 `claude-opus-5-5`**(`.claude/settings.json`), **모든 팀원 = `claude-sonnet-5-5`**(`.claude/agents/*.md`). 그래서 DOC_TEMPLATE의 "권장 모델" 열 대신 "담당 에이전트"와 검증 에이전트 열을 둔다. 실수 비용이 큰 작업(DOC_TEMPLATE 1장의 Fable 등급: 결제, 권한, RLS, 데이터 모델, 토큰 금고, 돈 계산)은 모델을 올리는 대신 **착수 전 `plan-challenger` + 변경 후 `security-auditor`·`test-writer`**를 붙여 보완한다.

## 1. 원칙과 소유 경계

| 원칙 | 내용 |
|---|---|
| 디렉토리 단위 소유 | 작업마다 디렉토리(또는 파일)를 하나 이상 소유하고 다른 작업의 소유 경로를 고치지 않는다. 필요한 변경은 소유 작업에 1줄 요청으로 보내고 보고에 적는다 |
| 공유 등록 지점 없음 | 워커 핸들러는 `services/worker/src/<영역>/handler.ts` 규약으로 자동 로드(GS-06-010). GNB는 `packages/domain/nav.ts`(GS-06-003) 상수만 읽는다. 여러 작업이 같이 고치는 인덱스 파일을 만들지 않는다 |
| 패키지 경계 | 웹·워커·확장은 `packages/*`만 공유한다. 마켓 API는 `packages/markets/<market>/`, 쿠팡은 `packages/sources/`, 외부 fetch는 `packages/net/`으로만 나간다(DS 6장·7장) |
| 에이전트 경계 | `apps/web/` = `nextjs-expert`, `services/worker/`·`packages/{markets,sources,net,compliance}`·`apps/extension/` = `worker-expert`, `supabase/` = `supabase-expert`, `packages/domain/` = `sub-agent-1`, 값 추출·형식 작업 = `sub-agent-2`, `tests/e2e/`·`tests/security/` = `test-writer`(DS 7장) |
| 돈·비밀 | 금액은 정수 최소 단위(DS 11.3절), 가격 공식은 `packages/domain/pricing.ts` 하나. 마켓 토큰은 `encrypted_credentials`에만, 복호화는 워커와 연결 테스트 경로만 |
| DB 불변 | `supabase/migrations/`의 기존 번호 파일은 고치지 않는다. 스키마 변경은 GS-06-002 소유자가 새 번호 파일로 추가 |
| 테스트 동반 | P0 작업은 수용 기준에 자체 테스트를 포함하고, 교차 검증은 GS-06-009(RLS), GS-06-045(결제), GS-06-046(플로우), GS-06-047(보안)이 맡는다 |
| 검증 배치 | 모든 구현 작업 변경 후 `review-expert`. 결제·돈·토큰·DB·마켓 계약·워커 런타임은 착수 전 `plan-challenger`. 경계(웹 ↔ 워커 ↔ DB ↔ 어댑터)를 넘으면 `contract-reviewer`, 비밀·권한·개인정보면 `security-auditor`(형제 호출, 서로 결과 미참조) |
| 사람 작업 | GS-06-015(디자인 비주얼 검토), G1·G2 게이트 판정, 실 마켓 production 키 발급, 열린 결정(`01_PRD.md` 8장 D-01~D-17) |
| 화면 진입 조건 | 디자인 시스템 4단계(GS-06-016)가 끝나기 전에는 화면 작업(017, 018, 022, 029, 035~039, 041, 042, 044)을 시작하지 않는다 |
| 열린 결정 | 근거 칸에 "착수 전 결정 D-##"가 적힌 작업은 그 결정이 `01_PRD.md` 8장에서 확정된 뒤 시작한다. 팀장이 결정 결과를 task 파일에 적는다 |

## 2. 작업 목록

열: ID | 작업 | 소유 파일/디렉토리 | 선행 | 우선순위 | 규모 | 담당 에이전트 | 착수 전 검증 | 변경 후 검증 | 수용 기준 | 근거. 담당 에이전트는 모두 `claude-sonnet-5-5`이고, 팀장(Opus 5.5)이 분해·지시·검토·커밋을 맡는다.

| ID | 작업 | 소유 파일/디렉토리 | 선행 | 우선순위 | 규모 | 담당 에이전트 | 착수 전 검증 | 변경 후 검증 | 수용 기준 | 근거 |
|---|---|---|---|---|---|---|---|---|---|---|
| GS-06-001 | 모노레포·웹 앱 골격: pnpm 워크스페이스, `apps/web` Next.js 16 App Router, TypeScript strict, ESLint, Tailwind CSS v4 설정, 라우트 그룹 `(app)`·`(auth)`·`(marketing)` 빈 페이지 | `package.json`(루트), `pnpm-workspace.yaml`, `tsconfig.base.json`, `apps/web/{package.json,next.config.ts,tsconfig.json,app/layout.tsx,app/globals.css,eslint.config.mjs}` | 없음 | P0 | M | nextjs-expert | — | review-expert | `pnpm -F web build` 통과, `tsc --noEmit` 0 오류, `latest` 태그 의존성 0건, `tailwind.config.js` 0개(`@import "tailwindcss"`만), `/dashboard` 등 S-01~S-10 라우트가 빈 페이지로 200 | docs/설계/DESIGN_STRUCTURE.md 1장·7장, 02_ARCHITECTURE.md 1장, GS-F-006, 007 |
| GS-06-002 | DB 적용과 타입 생성: 코어 lite + `globalseller` 도메인 마이그레이션 + 시드를 로컬 Supabase에 적용, `config.toml` 스키마 노출, 타입 생성 | `supabase/migrations/`, `supabase/seed.sql`, `supabase/config.toml`, `apps/web/types/supabase.ts` | 없음 | P0 | M | supabase-expert | plan-challenger | review-expert, security-auditor | `supabase db reset` 오류 0건, 2회 연속 적용 성공, DS 8장 테이블 21개·뷰 2개 존재, 상태 check 제약이 DS 5.1절 값과 일치, `supabase gen types --schema public,globalseller` 결과 저장, 모든 `globalseller` 테이블 RLS 활성 | docs/설계/DESIGN_STRUCTURE.md 5.1절·8장·11.2절, 05_DATA_MODEL.md, GS-F-005, 착수 전 결정 D-02, D-12 |
| GS-06-003 | 도메인 상수 패키지: `markets.ts`(마켓 카탈로그: 코드·지역·통화와 최소 단위·인증 방식·수수료·월 고정비), `status.ts`(DS 5.1절 상태·S-05 그룹·`StatusPill` 배리언트), `nav.ts`(GNB·상단 탭·모바일 메뉴), `health.ts`(마켓 건전성 지표 정의와 목표값) | `packages/domain/{markets,status,nav,health}.ts`와 테스트, `packages/domain/package.json` | 없음 | P0 | M | sub-agent-1 | — | review-expert, contract-reviewer | 단위 테스트: 상태 값 목록이 DS 5.1절과 1:1(스냅샷), S-05 상태 그룹 4개가 DS 5.1절 매핑과 일치, 통화 소수 자리(USD 2, JPY 0, SGD 2), GNB 항목 순서가 03장 8.2절과 일치 | docs/설계/DESIGN_STRUCTURE.md 5.1절·8장·10장, 03_SCREENS_UX.md 8.2절, GS-F-006, 034, 045 |
| GS-06-004 | 가격 공식과 환산: `pricing.ts`(원가+배송비 → 환율 → 수수료·목표 마진 → 끝자리 → 순이익), 정수 최소 단위 연산 | `packages/domain/pricing.ts`, `packages/domain/pricing.test.ts` | GS-06-003 | P0 | S | sub-agent-1 | plan-challenger | review-expert, test-writer | 프로토타입 계산 예(원가 ₩12,900 + 배송 ₩6,500, 환율 1,385, 수수료 15%, 마진 30% → $25.99, 순이익 $8.08)와 같은 결과, 마진 40% → $31.99, 부동소수 연산 0건(정수·`bigint` 또는 decimal 라이브러리), JPY 10엔 반올림 옵션 테스트 | docs/설계/DESIGN_STRUCTURE.md 11.3절, prototype/index.html:2208, GS-F-026 |
| GS-06-005 | 안전 fetch 패키지: 허용 도메인, DNS 확인 후 사설 IP 차단, 리다이렉트 3회, 응답 5MB, 타임아웃 15초(02장 2절 제안값) | `packages/net/` | 없음 | P0 | S | worker-expert | plan-challenger | review-expert, security-auditor | 169.254.169.254, 10.0.0.0/8, 127.0.0.1, IPv6 루프백, DNS 리바인딩 테스트가 모두 차단, 허용 목록 밖 도메인 차단, 5MB 초과 응답 중단, 15초 초과 중단 | docs/설계/DESIGN_STRUCTURE.md 6장, 02_ARCHITECTURE.md 2장, GS-F-012 |
| GS-06-006 | 디자인 시스템 1단계: 프로토타입 CSS에서 토큰 인벤토리 추출(색 OKLCH·서체·간격·반경·그림자·브레이크포인트·구간별 글자 크기·컴포넌트 클래스 목록) | `docs/디자인/TOKENS_INVENTORY.md` | 없음 | P0 | S | sub-agent-2 | — | review-expert | 프로토타입 `:root` 토큰 전부(라이트·다크)가 표로 옮겨지고 값이 원문과 같음(무작위 10개 대조), 컴포넌트 클래스 목록에 누락 0(grep 결과와 개수 일치) | prototype/index.html `<style>`, 08_DESIGN_SYSTEM.md, GS-F-007 |
| GS-06-007 | 인증 Stage A: `lib/auth/`(`getAuthConfig`, `isMockAuthAllowed`, `listLoginOptions`, `finishLogin`), Mock 로그인 `POST /api/dev/login`, 개발용 페르소나 패널, `MOCK AUTH · 로컬 전용` 배지, `requireSession`, `proxy.ts`, 시드 사용자 스크립트 | `apps/web/app/(auth)/login/`, `apps/web/app/api/dev/login/`, `apps/web/lib/auth/`, `apps/web/lib/session/`, `apps/web/proxy.ts`, `scripts/dev/` | GS-06-001, GS-06-002 | P0 | M | nextjs-expert | plan-challenger | review-expert, security-auditor | `owner` 로그인 → `session_context('globalseller').entitled=true`, `outsider`로 다른 조직 `globalseller` 행 0, `viewer` 쓰기 403, `next=//evil.com` → `/dashboard`, `AUTH_MODE=mock`+운영 빌드 실패, `AUTH_MODE=live`에서 `/api/dev/login` 404, 시드 스크립트는 원격 URL이면 exit 1, 두 번 실행해도 가입 크레딧 1회 | platform-docs/products/_platform-core/AUTH_ROADMAP.md 2장·3.1절·9장, 03_SCREENS_UX.md 7장, GS-F-001 |
| GS-06-008 | 환경변수 검증(zod)과 `.env.example`: 웹·워커 필수 키, 누락 시 기동 실패, 서버 전용 키 분리 | `apps/web/lib/env.ts`, `services/worker/src/env.ts`, `.env.example`, `services/worker/.env.example` | GS-06-001 | P0 | S | sub-agent-2 | — | review-expert, security-auditor | 02장 환경변수 표의 키가 `.env.example`에 이름만 있음(값 0), 필수 키 누락 시 기동 실패 테스트, `NEXT_PUBLIC_` 접두사에 비밀 키 0건, LLM·마켓 키는 워커 env에만 | 02_ARCHITECTURE.md 환경변수 절, CLAUDE.md 5장 |
| GS-06-009 | RLS·권한 회귀 테스트: 조직 격리, 역할별 쓰기, service_role 전용 RPC, 마켓 토큰 비노출 | `supabase/tests/` | GS-06-002 | P0 | M | supabase-expert | — | review-expert, security-auditor | 05장 RLS 표의 모든 정책 항목 통과, 다른 조직 `market_accounts`·`orders`·`source_products` 조회 0행, `viewer`의 INSERT·UPDATE 거부, `encrypted_credentials` 암호문 컬럼을 authenticated가 읽지 못함, CI에서 실패 시 머지 차단 | 05_DATA_MODEL.md RLS 절, platform-docs SECURITY_BASELINE 15장, GS-F-002, 005 |
| GS-06-010 | 워커 런타임: 잡 claim 루프(SKIP LOCKED), 핸들러 자동 로드(`src/<영역>/handler.ts`), 조직별 동시성, 하트비트·취소, 크론 스케줄러와 환율 크론(`src/cron/fx.ts`) | `services/worker/{package.json,tsconfig.json}`, `services/worker/src/runtime/`, `services/worker/src/cron/{index,scheduler,fx}.ts` | GS-06-002, GS-06-003 | P0 | M | worker-expert | plan-challenger | review-expert, contract-reviewer | 같은 잡을 워커 2개가 동시에 잡지 않음(동시성 테스트), 워커 재시작 후 진행 중 잡 재개, 조직당 동시 실행 상한 지킴, 크론 6종(DS 9장) 등록, 환율 실패 시 직전 값 유지·`fx_rates` 새 행 0 | docs/설계/DESIGN_STRUCTURE.md 9장, 02_ARCHITECTURE.md 잡과 워커 절, GS-F-033, 착수 전 결정 D-10 |
| GS-06-011 | `MarketAdapter` 인터페이스와 가짜 마켓(fake) 구현: 토큰 갱신, 리스팅 생성·수정·종료, 가격·재고 변경, 주문 조회, 발송 확인, 건강 지표, 오류 분류 | `packages/markets/types.ts`, `packages/markets/testing/`(계약 테스트 스위트), `packages/markets/fake/` | GS-06-003, GS-06-005 | P0 | M | worker-expert | plan-challenger | review-expert, contract-reviewer | 인터페이스가 04장 외부 어댑터 절과 1:1, 가짜 마켓으로 리스팅 생성 → 가격 변경 → 주문 조회 → 발송 확인 시나리오 통과, 오류를 `retryable`·`auth`·`validation`·`rate_limit` 4종으로 분류 | 04_API.md 외부 API 어댑터 절, GS-F-030 |
| GS-06-012 | 쿠팡 소스 파서: 상품 URL·상품번호 정규화, 사용자가 준 URL 단건 조회 결과·확장프로그램 전송 데이터 정규화(상품명·가격·정가·재고·배송 유형·평점·리뷰 수·이미지·옵션·고시정보), CSV·XLSX 목록 파서 | `packages/sources/coupang-url/`, `packages/sources/file-import/` | GS-06-005 | P0 | M | worker-expert | plan-challenger | review-expert | 저장한 쿠팡 페이지 픽스처 10개에서 필드 추출 정확도 100%, 쿠팡이 아닌 URL 거부, CSV·XLSX 1,000행 5초 이내 파싱, 형식 오류 행은 줄 번호와 사유로 반환 | docs/설계/DESIGN_STRUCTURE.md 5장, prototype/index.html:1792, GS-F-012, 018 |
| GS-06-013 | 리스크 규칙 패키지: 항공 배송 제한, 브랜드 판매 제한 목록, 제외 키워드, 이미지 사용 권한, 수입국 규정 체크를 규칙 파일 + 매처로 | `packages/compliance/` | GS-06-003 | P0 | M | worker-expert | — | review-expert | 규칙 파일(JSON)과 매처 분리, 한글 단어 경계 오탐 테스트(정규식 `\b` 미사용), 결과를 `ok`·`warn`·`block` 3단계로 반환, 프로토타입 리스크 5항목이 모두 규칙으로 존재 | prototype/index.html:1843, 01_PRD.md 6장, GS-F-016, 착수 전 결정 D-07 |
| GS-06-014 | 디자인 시스템 2단계: `styles/tokens.css`(`@theme`, 라이트·다크) + 기본 컴포넌트(`components/ui/`) + `/dev/components` 미리보기 | `apps/web/styles/tokens.css`, `apps/web/components/ui/`, `apps/web/app/dev/components/` | GS-06-001, GS-06-006 | P0 | M | nextjs-expert | — | review-expert | 08장 토큰 전부가 `@theme` 변수로 존재, 컴포넌트에 hex·`bg-[#...]` 0건, `/dev/components`에서 08장 컴포넌트 목록 전부 라이트·다크로 렌더, 운영 빌드에서 `/dev/*` 404 | 08_DESIGN_SYSTEM.md, GS-06-006 인벤토리, GS-F-007 |
| GS-06-015 | 디자인 시스템 3단계: 사람 비주얼 검토(`/dev/components`를 프로토타입과 나란히 비교, 수정 목록 작성) | `docs/디자인/REVIEW_LOG.md` | GS-06-014 | P0 | S | 사람 | — | — | 검토 기록에 컴포넌트별 통과/수정 판정과 수치(색·간격·크기)가 적힘, 수정 항목은 GS-06-016으로 넘김 | 08_DESIGN_SYSTEM.md, GS-F-007 |
| GS-06-016 | 디자인 시스템 4단계: 검토 반영, 정답 확정, 하드코딩 색 린트 규칙, `docs/디자인/COMPONENTS.md` | `apps/web/styles/tokens.css`, `apps/web/components/ui/`, `docs/디자인/COMPONENTS.md`, `apps/web/eslint.config.mjs`(색 규칙 1줄 추가 요청 → GS-06-001) | GS-06-015 | P0 | S | nextjs-expert | — | review-expert | 검토 기록 수정 항목 전부 반영, 린트가 `bg-[#`·hex 리터럴을 오류로 막음, COMPONENTS.md에 컴포넌트별 배리언트·금지 사항 | 08_DESIGN_SYSTEM.md, docs/디자인/REVIEW_LOG.md, GS-F-007 |
| GS-06-017 | 대시보드 셸: `(app)/layout.tsx`, 헤더(로고·브레드크럼·상단 탭 5개·알림·테마·아바타), 좌측 GNB(메뉴·마켓 칩·사용자 카드), 모바일 가로 메뉴, 라우트 기반 선택 동기화, 배지 숫자 | `apps/web/app/(app)/layout.tsx`, `apps/web/components/shell/`(`AppTopbar`, `TopTabs`, `AppSidebar`, `NavItem`, `MarketChip`, `SidebarUserCard`, `MobileNav`), `apps/web/components/layout/` | GS-06-007, GS-06-016 | P0 | M | nextjs-expert | — | review-expert | 상단 탭·GNB·모바일 메뉴가 같은 라우트에서 함께 선택됨(E2E), 375·1024·1440 폭에서 본문 가로 넘침 0, GNB 순서가 03장 8.2절과 같음, 마켓 칩 → `/account/markets` | 03_SCREENS_UX.md 8장, docs/설계/DESIGN_STRUCTURE.md 2장, prototype/index.html:1298-1390, GS-F-006, 007 |
| GS-06-018 | `MarketScope`·`MarketHealthStrip` 공통 컴포넌트: 마켓 탭 바(전체·계정들·＋마켓 추가), 지표 띠, URL `market` 동기화, 빈 상태, 탭 배지(RPC `market_tab_counts`) | `apps/web/components/market-scope/` | GS-06-014, GS-06-016 | P0 | M | nextjs-expert | — | review-expert, contract-reviewer | 탭 변경 시 URL `market` 갱신·새로고침 후 유지, 계정 0개면 '전체'와 '＋ 마켓 추가'만 보이고 03장 5장 빈 상태 문구, 토큰 만료 계정 탭에 '!' 배지, 지표 띠 슬롯은 화면이 주입 | docs/설계/DESIGN_STRUCTURE.md 3장, 03_SCREENS_UX.md 3.4절, GS-F-034, 045 |
| GS-06-019 | 수집 API: `/api/collect/{single,jobs,jobs/[id]/cancel,upload,presets}`, `/api/source-products`, `/api/source-products/[id]`, `/api/extension/{token,items}` | `apps/web/app/api/collect/`, `apps/web/app/api/source-products/`, `apps/web/app/api/extension/` | GS-06-007, GS-06-012 | P0 | M | nextjs-expert | plan-challenger | review-expert, contract-reviewer, security-auditor | 상품 수 한도 초과 403(`GS003`), 같은 `request_id` 2회 → 잡 1건, 업로드는 서명 URL만(서버 파일 경유 0), 확장 토큰은 `extension:collect` 범위만·만료 30일(제안), `/api/extension/items` 요청당 50건 초과 400, 다른 조직 `source_products` 접근 404 | docs/설계/DESIGN_STRUCTURE.md 11.1절, 04_API.md Route Handler 절, GS-F-012, 013, 017, 018, 021 |
| GS-06-020 | 수집 워커 핸들러 `src/collect/`: 항목별 가져오기(`packages/net`·`packages/sources`), 조건 필터, 리스크 검사, 중복 제외, `source_products`·옵션 upsert, 작업 집계·제외 사유 | `services/worker/src/collect/` | GS-06-010, GS-06-012, GS-06-013, GS-06-019 | P0 | L | worker-expert | plan-challenger | review-expert, contract-reviewer | URL 목록 100건 작업이 진행률을 Realtime으로 갱신하고 완료 시 `counts`(수집·통과·제외 사유 5종) 합이 입력 수와 같음, 같은 상품 재수집 시 새 행 0(갱신만), 리스크 `block` 상품은 `excluded`, 쿠팡 요청 간격 1초 이상·조직당 동시 1건(01장 6장)을 테스트로 확인 | docs/설계/DESIGN_STRUCTURE.md 5장·9장, 03_SCREENS_UX.md 2.2절, GS-F-012, 016, 018, 021, 022 |
| GS-06-021 | 크롬 확장프로그램(MV3): 쿠팡 상품 페이지 '수집함에 담기', 검색 결과 페이지 체크 후 일괄 담기, 확장 토큰 로그인, 담기 결과 알림 | `apps/extension/` | GS-06-019 | P0 | M | worker-expert | plan-challenger | review-expert, security-auditor | 권한은 `activeTab`과 쿠팡 도메인 host 권한만, 토큰은 `chrome.storage.session`(제안)·코드에 비밀 0, 상품 페이지에서 1클릭 담기 → 수집함에 1행, 검색 결과에서 20개 체크 → 1요청, 사용자 행동 없는 자동 순회 0 | docs/설계/DESIGN_STRUCTURE.md 5장·7장, prototype/index.html:1768, GS-F-013, 착수 전 결정 D-06 |
| GS-06-022 | S-02 쿠팡 상품 수집 화면: 수집함·개별 등록·대량 수집 하위 탭, 헤더 버튼 2개, 진행 Realtime | `apps/web/app/(app)/collect/`, `apps/web/components/collect/` | GS-06-017, GS-06-019 | P0 | L | nextjs-expert | — | review-expert | 03장 3.2절 표의 카드·필드·버튼이 모두 있음(추적표 5장), URL `tab` 유지, 칩 입력 한글 조합 중 Enter 무시, 빈 상태 문구 일치, 키워드·정기 카드는 P1 표시로 비활성 | 03_SCREENS_UX.md 3.2절, prototype/index.html:1613-2027, GS-F-012~022 |
| GS-06-023 | 마켓 연결 API와 토큰 금고: `/api/markets/{catalog,readiness,connect/start,callback/[market],accounts,accounts/[id],accounts/[id]/test}`, OAuth state, 토큰 암호화 저장, eBay 계정 삭제 알림 웹훅 | `apps/web/app/api/markets/`, `apps/web/app/api/webhooks/ebay/`, `apps/web/lib/credentials/` | GS-06-007, GS-06-011 | P0 | M | nextjs-expert | plan-challenger | review-expert, security-auditor, contract-reviewer | 응답·로그·DB 평문 토큰 0건(grep 테스트), state 재사용·만료 거부, 마켓 수 한도 초과 403, 연결 해제 시 `revoke_credential`와 감사 1행, eBay 계정 삭제 알림 챌린지 응답 통과(SHA-256 응답 해시) | docs/설계/DESIGN_STRUCTURE.md 4장·11.1절, 04_API.md, GS-F-056, 061, 착수 전 결정 D-08 |
| GS-06-024 | eBay 어댑터: OAuth 토큰 갱신, Inventory API(인벤토리 아이템·오퍼·게시), 가격·수량 변경, Fulfillment API 주문 조회·발송 확인, 판매자 지표 | `packages/markets/ebay/` | GS-06-011 | P0 | L | worker-expert | plan-challenger | review-expert, contract-reviewer, security-auditor | GS-06-011 계약 테스트 스위트 통과(eBay 샌드박스 녹화 응답), 토큰 만료 1분 전 갱신, 레이트 리밋 응답 시 `rate_limit` 분류·재시도 대기, 샌드박스에서 리스팅 게시 → 가격 변경 → 종료 수동 점검 기록 | 04_API.md 외부 API 어댑터 절, 01_PRD.md 2장, GS-F-030, 040, 043, 045, 착수 전 결정 D-09 |
| GS-06-025 | Amazon SP-API 어댑터(US): LWA 토큰, Listings Items API 생성·수정, 가격·재고 패치, Orders API, 발송 확인, 계정 건전성 지표 | `packages/markets/amazon-sp/` | GS-06-011 | P0 | L | worker-expert | plan-challenger | review-expert, contract-reviewer, security-auditor | GS-06-011 계약 테스트 통과(SP-API 샌드박스 응답), 엔드포인트별 사용 한도에 맞춘 토큰 버킷, 개인정보(구매자 주소)는 필요한 필드만 저장 대상으로 반환, 마켓플레이스 id를 설정으로 받아 JP 확장 가능(GS-06-052) | 04_API.md 외부 API 어댑터 절, 01_PRD.md 2장, GS-F-030, 040, 043, 045, 착수 전 결정 D-08 |
| GS-06-026 | AI 번역 핸들러 `src/translate/`: 상품명·핵심 특징 5개·키워드·설명 생성(EN, JA는 P2), 글자 수 제한, 리스크 규칙 재검사, 사용량·크레딧 정산 | `services/worker/src/translate/`, `services/worker/src/translate/prompts/` | GS-06-010, GS-06-013 | P0 | M | worker-expert | plan-challenger | review-expert, security-auditor | 출력 zod 검증(상품명 200자 이하, 특징 5개), 금지 문구(효능 단정, 가짜 후기) 0건, LLM 키는 워커 env에만, 실패 시 선차감 환불 1행, 평가셋 20건에서 필수 필드 누락 0 | 01_PRD.md AI 번역 기능, 02_ARCHITECTURE.md AI 절, GS-F-025, 착수 전 결정 D-05 |
| GS-06-027 | 등록 API: `/api/listings`, `/[id]`, `/[id]/{validate,submit,translate}`, `/api/listings/batches`, `/batches/[id]/run`, `/api/pricing/preview`, `/api/price-rules`, `/api/shipping-templates` | `apps/web/app/api/listings/`, `apps/web/app/api/pricing/`, `apps/web/app/api/price-rules/`, `apps/web/app/api/shipping-templates/` | GS-06-004, GS-06-019, GS-06-023 | P0 | M | nextjs-expert | plan-challenger | review-expert, contract-reviewer | 검증 실패 시 `submit` 409와 실패 항목 목록, 같은 `request_id` 재전송 시 잡 1건, `translate`는 선차감·실패 환불, 일괄 등록 사전 검증이 5분류(바로·자동 보완·마진 미달·항공 제한·상표권)로 반환, 가격 미리보기가 `pricing.ts` 결과와 같음 | docs/설계/DESIGN_STRUCTURE.md 11.1절, 03_SCREENS_UX.md 2.3절, GS-F-024~032 |
| GS-06-028 | 등록·가져오기 워커: `src/listing/`(어댑터로 전송, `queued`→`submitting`→`live`/`error`, 마켓 한도 대기열), `src/listing-import/`(마법사 4단계 기존 리스팅 읽기 전용 가져오기) | `services/worker/src/listing/`, `services/worker/src/listing-import/` | GS-06-010, GS-06-011, GS-06-027 | P0 | M | worker-expert | plan-challenger | review-expert, contract-reviewer | 가짜 마켓으로 일괄 44건 전송 시 상태 전이가 DS 5.1절대로만 일어남, 마켓 `rate_limit`이면 대기 후 재개(실패로 세지 않음), 가져오기는 마켓에 쓰기 호출 0건, 실패 항목 원문 메시지 저장 | docs/설계/DESIGN_STRUCTURE.md 4장·5.1절·9장, GS-F-030, 033, 062 |
| GS-06-029 | S-03 해외 마켓 등록 화면: 등록 현황·개별 등록(6단계 + 우측 검증)·일괄 등록(4단계) 하위 탭 | `apps/web/app/(app)/listings/`, `apps/web/components/listings/` | GS-06-017, GS-06-027 | P0 | L | nextjs-expert | — | review-expert | 03장 3.3절 표 요소 전부(추적표 5장), 가격 입력 변경 즉시 재계산, 검증 실패 시 해당 섹션으로 스크롤·체크리스트 빨강, 일괄 등록 진행 Realtime | 03_SCREENS_UX.md 3.3절, prototype/index.html:2028-2424, GS-F-023~033 |
| GS-06-030 | 동기화 워커 `src/sync/`: 원본 재확인, 변동 유형 판정(가격 상승·하락·품절·재입고), 규칙 엔진(기본 + 계정 덮어쓰기), `sync_events` 기록, 반영 실행 | `services/worker/src/sync/` | GS-06-020, GS-06-028 | P0 | L | worker-expert | plan-challenger | review-expert, contract-reviewer, test-writer | 원가 상승으로 마진이 최소 마진 미만이 되면 `held`·마켓 호출 0, 품절 시 마켓 재고 0 반영, 가격 하락 시 '규칙상 유지'면 `skipped`, 계정 규칙이 기본 규칙보다 우선, 같은 변동 중복 이벤트 0 | docs/설계/DESIGN_STRUCTURE.md 5장·5.1절, 03_SCREENS_UX.md 2.4절, prototype/index.html:2897, GS-F-035~037 |
| GS-06-031 | 동기화 API: `/api/sync/{rules,run,events,events/[id]/approve}` | `apps/web/app/api/sync/` | GS-06-007, GS-06-030 | P0 | S | nextjs-expert | — | review-expert, contract-reviewer | 규칙 편집은 owner/admin만(member 403), 승인은 RPC `approve_sync_event`로 감사 1행, `run`은 계정당 10분 1회 레이트 리밋(제안), `events`는 `market`·유형 필터 | docs/설계/DESIGN_STRUCTURE.md 11.1절·11.2절, GS-F-036~039 |
| GS-06-032 | 주문 워커 `src/orders/`: 마켓별 신규 주문 수집(10분), `received`→`purchase_pending`, 발송 확인 일괄 전송, 구매자 개인정보 최소 저장 | `services/worker/src/orders/` | GS-06-024, GS-06-025, GS-06-010 | P0 | M | worker-expert | plan-challenger | review-expert, security-auditor, contract-reviewer | 같은 마켓 주문 재수집 시 새 행 0, 가짜 마켓 주문 5건 → `purchase_pending` 5건, 발송 확인 실패는 주문별 오류로 남고 나머지는 계속, 구매자 주소는 배송에 필요한 필드만·배송 완료 90일 후 마스킹(제안) | docs/설계/DESIGN_STRUCTURE.md 5.1절·9장, 01_PRD.md 6장, GS-F-040, 043, 044, 착수 전 결정 D-11 |
| GS-06-033 | 주문·송장 API: `/api/orders`, `/[id]/purchase`, `/[id]/claim`, `/confirm-shipment`, `/api/shipments`, `/api/shipments/[id]` | `apps/web/app/api/orders/`, `apps/web/app/api/shipments/` | GS-06-007, GS-06-032 | P0 | M | nextjs-expert | plan-challenger | review-expert, security-auditor | 발주 기록은 RPC `record_purchase`로 `purchased` 전이 1회(중복 요청 멱등), 원가는 원 정수만 허용, 송장 일괄 업로드 200행에서 형식 오류 행만 거부, viewer 쓰기 403 | docs/설계/DESIGN_STRUCTURE.md 11.1절, 03_SCREENS_UX.md 2.5절, GS-F-042~044, 046, 착수 전 결정 D-03 |
| GS-06-034 | 배송 추적·건강 지표·토큰 갱신 워커: `src/shipping/`(운송사 추적 이벤트), 크론 `src/cron/health.ts`(마켓 지표 일별 스냅샷), `src/cron/token-refresh.ts` | `services/worker/src/shipping/`, `services/worker/src/cron/{health,token-refresh}.ts` | GS-06-024, GS-06-025, GS-06-033 | P0 | M | worker-expert | — | review-expert, contract-reviewer | 송장 등록 직후 1회 + 1시간 주기 추적, 예상일 초과 시 `delayed`, 지표 스냅샷이 계정당 하루 1행, 토큰 만료 전 갱신 실패 시 계정 `token_expired`와 알림 1건 | docs/설계/DESIGN_STRUCTURE.md 9장, 03_SCREENS_UX.md 3.5~3.7절, GS-F-045, 047, 048 |
| GS-06-035 | S-04 재고·가격 동기화 화면: `MarketScope` + 지표 띠(전체·마켓별) + KPI 5칸 + 변동 내역 + 규칙 카드(기본 + 마켓 전용) + 마켓별 상태 | `apps/web/app/(app)/sync/`, `apps/web/components/sync/` | GS-06-018, GS-06-031 | P0 | M | nextjs-expert | — | review-expert | 03장 3.5절 요소 전부, 탭 변경 시 KPI·목록·규칙 카드 제목·헤더 버튼 문구가 모두 바뀜, `held` 행 승인 동작, 마켓 전용 규칙은 해당 마켓 탭에서만 보임 | 03_SCREENS_UX.md 3.5절, prototype/index.html:2806-2927, GS-F-034~039 |
| GS-06-036 | S-05 주문 통합 관리 화면: `MarketScope` + 마켓별 건전성 띠 + 5단계 파이프라인 + KPI + 상태 세그먼트 × 마켓 + 주문 표 + 발주 기록 모달 | `apps/web/app/(app)/orders/`, `apps/web/components/orders/` | GS-06-018, GS-06-033 | P0 | M | nextjs-expert | — | review-expert | 03장 3.6절 요소 전부, 마켓 탭 × 상태 조합에서 세그먼트 숫자 재계산, Shopee + 취소 등 0건 조합에 빈 행 문구, 발주 모달 저장 후 상태 '배대지' 그룹으로 이동 | 03_SCREENS_UX.md 3.6절, prototype/index.html:2928-3032, GS-F-040~045, 착수 전 결정 D-03 |
| GS-06-037 | S-06 배송·물류 추적 화면: `MarketScope` + 지표 띠 + KPI + 배송 건 목록 + 구간 타임라인 + 운송사 비교 + 송장 업로드 모달 | `apps/web/app/(app)/shipping/`, `apps/web/components/shipping/` | GS-06-018, GS-06-033 | P0 | M | nextjs-expert | — | review-expert | 03장 3.7절 요소 전부, 행 클릭 시 URL `shipment` 갱신·타임라인 표시, 마켓 탭 변경 시 첫 배송 건 자동 선택, 운송사 표가 마켓별로 걸러짐 | 03_SCREENS_UX.md 3.7절, prototype/index.html:3033-3148, GS-F-046~049, 착수 전 결정 D-04 |
| GS-06-038 | 수익 분석: `/api/profit` + S-07 화면(KPI, 월별 순이익, 비용 구조, 마켓별 순이익, 인사이트, 상위 상품) | `apps/web/app/api/profit/`, `apps/web/app/(app)/profit/`, `apps/web/components/profit/` | GS-06-017, GS-06-033 | P0 | M | nextjs-expert | — | review-expert, test-writer | 시드 데이터에서 비용 항목 합 = 매출(정수 연산, 오차 0), 마켓별 순이익 합 = 전체 순이익, 기간 쿼리 3종, owner/admin만 접근 | 03_SCREENS_UX.md 3.8절, prototype/index.html:3149-3240, 05_DATA_MODEL.md v_profit_monthly, GS-F-050~052 |
| GS-06-039 | S-01 대시보드: KPI 5칸, 마켓별 월간 매출 추이, 최근 활동, 최근 등록 상품, 마켓 0개 안내 띠 | `apps/web/app/(app)/dashboard/`, `apps/web/components/dashboard/` | GS-06-017, GS-06-038 | P0 | M | nextjs-expert | — | review-expert | 03장 3.1절 요소 전부, KPI 클릭 시 해당 화면 이동, 마켓 0개 페르소나(`empty`)에서 안내 띠와 마법사 버튼 | 03_SCREENS_UX.md 3.1절, prototype/index.html:1392-1612, GS-F-009~011 |
| GS-06-040 | 마켓 추가 마법사 점수 `readiness.ts`: 진단 7문항 × 마켓 카탈로그 → 적합도(3~97)·상태 5종·준비 필요 항목·팁 | `packages/domain/readiness.ts`, `packages/domain/readiness.test.ts` | GS-06-003 | P0 | S | sub-agent-1 | — | review-expert, test-writer | 프로토타입 동작과 같은 결과(기본 답변에서 바로 연결 가능 마켓·순서 스냅샷), 사업자 없음 → 사업자 필요 마켓이 '준비 후 연결', 연결된 계정은 '연결됨'으로 아래 정렬 | docs/설계/DESIGN_STRUCTURE.md 4장, prototype/index.html:4163-4330, GS-F-059, 060 |
| GS-06-041 | S-11 마켓 추가 마법사 화면: 인터셉트 라우트 모달 5단계, 진단 칩, 추천 카드, 연결(OAuth·API 키), 초기 설정, 완료 후 운영 화면 탭 생성 | `apps/web/app/(app)/@modal/(.)markets/connect/`, `apps/web/app/(app)/markets/connect/`, `apps/web/components/markets/`(`WizardDialog`, `MarketRecommendCard`) | GS-06-018, GS-06-023, GS-06-040 | P0 | M | nextjs-expert | — | review-expert, contract-reviewer | 03장 3.11절 단계별 요소 전부, 권한 승인 전 '다음' 비활성, Esc·배경 클릭 닫기, 직접 URL 진입 시 전체 화면, 완료 후 S-04~S-06에 새 탭(Realtime), 진입점 3곳에서 열림 | 03_SCREENS_UX.md 3.11절·2.6절, docs/설계/DESIGN_STRUCTURE.md 4장, GS-F-059~062 |
| GS-06-042 | S-10 내 계정 8개 탭 + S-08 연동 설정 화면: 프로필, 플랜·사용량, 마켓 연결, API 키, 결제 내역, 알림, 보안, 팀 / 쿠팡 파트너스 키·확장 토큰·운송사 | `apps/web/app/(app)/account/`, `apps/web/components/account/`, `apps/web/app/(app)/settings/integrations/`, `apps/web/app/api/notification-prefs/` | GS-06-017, GS-06-023 | P0 | L | nextjs-expert | — | review-expert, security-auditor | 03장 3.9·3.10절 요소 전부, 키 필드는 마스킹 값만 받음(평문 응답 0), 팀 초대·역할 변경은 코어 RPC 사용·감사 행, 계정 삭제는 화면 안 확인 단계(`confirm()` 0), 사용량 막대가 `plan_usage`와 같음 | 03_SCREENS_UX.md 3.9·3.10절, prototype/index.html:3241-4162, prototype/index.html:2425-2648, GS-F-002, 003, 053~058, 착수 전 결정 D-13 |
| GS-06-043 | 결제: 코어 Toss 흐름 연결(`/api/billing/*`, `/api/webhooks/toss`), 플랜 업그레이드·다운그레이드, 크레딧팩 | `apps/web/app/api/billing/`, `apps/web/app/api/webhooks/toss/` | GS-06-007, GS-06-042 | P0 | M | nextjs-expert | plan-challenger | review-expert, security-auditor, test-writer | 웹훅 서명 검증·`event_id` 멱등(같은 이벤트 2회 → 처리 1회), 금액은 서버 플랜 표에서만 결정(요청 바디 금액 무시), 결제 실패 시 구독 변경 0 | 01_PRD.md 4장, platform-docs CORE_SPEC 5장, GS-F-003, 004, 착수 전 결정 D-01, D-02 |
| GS-06-044 | 대기자 등록 랜딩과 법적 문서: `/`(대기자 폼 2문항), `/legal/terms`, `/legal/privacy` | `apps/web/app/(marketing)/`, `apps/web/app/api/waitlist/` | GS-06-016 | P0 | S | nextjs-expert | — | review-expert | 03장 4장 구성 그대로, 수익 보장·승인 보장 문구 0건(01장 6장 목록 grep), 대기자 이메일 중복 등록 시 1행, Lighthouse 성능 90 이상(제안) | 03_SCREENS_UX.md 4장, 01_PRD.md 6장 |
| GS-06-045 | 결제 E2E(Toss 테스트 키): 업그레이드, 실패, 웹훅 중복, 크레딧팩 | `tests/e2e/billing/` | GS-06-043 | P0 | M | test-writer | — | review-expert | 시나리오 4개 녹색, 웹훅 중복 시 원장 1행, 실패 결제 후 플랜 그대로 | 01_PRD.md 4장, GS-F-003, 004 |
| GS-06-046 | 핵심 플로우 E2E(Mock 페르소나 + 가짜 마켓): 로그인 → 수집 → 등록 → 동기화 승인 → 주문 → 발주 → 송장, 마켓 탭 3화면, 마법사, 모바일 넘침 | `tests/e2e/flows/` | GS-06-022, GS-06-029, GS-06-035, GS-06-036, GS-06-037, GS-06-041 | P0 | L | test-writer | — | review-expert | 03장 2.1~2.6절 플로우 전부 녹색, 마켓 탭 × 상태 조합 검증(`tests/prototype-smoke.js` 항목을 실제 앱으로 이식), 375px에서 S-01~S-10 가로 넘침 0 | 03_SCREENS_UX.md 2장, tests/prototype-smoke.js, GS-F-001~062(플로우) |
| GS-06-047 | 보안 회귀: 비밀 노출 검색(`NEXT_PUBLIC_`·토큰 평문·로그), RLS 재실행, 사설 IP fetch, 확장 토큰 범위, 레이트 리밋 | `tests/security/` | GS-06-009, GS-06-021, GS-06-023 | P0 | M | test-writer | — | security-auditor(전체 감사) | 저장소·빌드 산출물에서 비밀 패턴 0건, 클라이언트 번들에 마켓·LLM 키 0, 확장 토큰으로 수집 외 API 403, security-auditor 전체 감사 🔴 0 | CLAUDE.md 5장, 02_ARCHITECTURE.md, GS-F-001, 004, 061 |
| GS-06-048 | CI(GitHub Actions): 린트·타입·단위·빌드(웹·워커·확장)·SQL 적용·RLS·E2E(가짜 마켓) | `.github/workflows/` | GS-06-009, GS-06-046 | P0 | M | sub-agent-1 | — | review-expert | PR마다 모든 단계 실행, 하나라도 실패하면 머지 차단, 실행 시간 15분 이하(제안), 비밀은 GitHub Secrets만 | 06_AGENT_PLAN.md 7장 |
| GS-06-049 | 인증 Stage B: Google OAuth + 이메일 가입·인증 메일·비밀번호 재설정, `/auth/callback`(`finishLogin`), 약관 온보딩 `/onboarding/terms`, 배포 env `AUTH_MODE=live` | `apps/web/components/auth/`, `apps/web/app/auth/callback/`, `apps/web/app/(auth)/{signup,reset-password}/`, `apps/web/app/onboarding/terms/`, `docs/deploy/auth-checklist.md` | G1(사람 판정), GS-06-007, GS-06-044 | P0 | M | nextjs-expert | plan-challenger | review-expert, security-auditor | platform-docs/products/_platform-core/AUTH_ROADMAP.md 5.3절 B-1~B-6 그대로, 첫 Google 로그인 사용자가 약관 동의 전 `/dashboard` 진입 불가 | platform-docs/products/_platform-core/AUTH_ROADMAP.md 5장·9장, GS-F-001, 착수 전 결정 D-17 |
| GS-06-050 | 공개 베타 전환: 운영 Supabase·Vercel·워커 배포, eBay·Amazon production 키 전환, 모니터링·알림, 프로토타입 보관 표시 | `docs/deploy/`, `infra/` | GS-06-049, GS-06-045, GS-06-046, GS-06-047 | P0 | M | sub-agent-1 | plan-challenger | review-expert, security-auditor | 배포 체크리스트 전 항목 확인 기록, 운영 env에 Mock 관련 값 0, 실 마켓 1개(eBay)에서 리스팅 1건 게시·종료 수동 확인, 워커 장애 알림 1채널 | 06_AGENT_PLAN.md 7장, 착수 전 결정 D-06 |
| GS-06-051 | Shopee 어댑터(SG·TH): 상점 권한 승인, 접근 토큰 4시간 갱신, 리스팅·가격·재고, 주문, SLS 송장 | `packages/markets/shopee/` | GS-06-011, GS-06-034 | P1 | L | worker-expert | plan-challenger | review-expert, contract-reviewer, security-auditor | GS-06-011 계약 테스트 통과, 토큰 만료 전 자동 갱신(갱신 실패 시 `token_expired`), 국가별 통화·수수료 분리 계산 | 01_PRD.md 2장, GS-F-030, 037 |
| GS-06-052 | Amazon JP 확장: 마켓플레이스 id·JPY·10엔 반올림·일본어 번역(JA 프롬프트) | `packages/markets/amazon-sp/marketplaces/jp.ts`, `services/worker/src/translate/prompts/ja/` | GS-06-025, GS-06-026 | P2 | M | worker-expert | — | review-expert, contract-reviewer | JP 리스팅 계약 테스트 통과, 가격이 10엔 단위, JA 평가셋 20건 필수 필드 누락 0 | 01_PRD.md 2장, GS-F-025, 030 |
| GS-06-053 | Lazada 어댑터: 판매자 권한 승인(OAuth), 리스팅·가격·재고, 주문 | `packages/markets/lazada/` | GS-06-011 | P2 | L | worker-expert | plan-challenger | review-expert, contract-reviewer, security-auditor | GS-06-011 계약 테스트 통과 | 01_PRD.md 2장, GS-F-030 |
| GS-06-054 | 키워드 수집(쿠팡 파트너스 API)과 정기 수집: 키 등록, 호출 한도 게이지, 한도 대기·재개, 매일 새 상품만 수집 | `packages/sources/coupang-partners/`, `services/worker/src/collect/keyword.ts`, `services/worker/src/collect/schedule.ts` | GS-06-020 | P1 | M | worker-expert | plan-challenger | review-expert, security-auditor | 한도 초과 응답이 3회 이상 연속으로 나지 않음(사전 차단), 정기 수집은 이전 수집 상품 제외, 키는 `encrypted_credentials`에만 | prototype/index.html:1911, docs/planning-update-2026-10-23.md 5장, GS-F-019, 020 |
| GS-06-055 | 인증 Stage C: 카카오(C1)·네이버(C2) 로그인, `/settings/login` 연결·해제 | `apps/web/components/auth/kakao/`, `apps/web/app/auth/naver/`, `apps/web/lib/auth/naver/`, `apps/web/app/(app)/settings/login/` | G2(사람 판정), GS-06-049 | P2 | M | nextjs-expert | plan-challenger | review-expert, security-auditor | platform-docs/products/_platform-core/AUTH_ROADMAP.md 7.1.3절 C1-1~C1-5, 7.2.4절 C2-1~C2-6 그대로, 로그인 수단 1개 남은 상태에서 해제 거부 | platform-docs/products/_platform-core/AUTH_ROADMAP.md 7장, GS-F-001, 착수 전 결정 D-15, D-16 |

## 3. 웨이브(병렬 실행 순서)

| 웨이브 | 작업 ID | 병렬 수 | 진입 조건 | 산출물 |
|---|---|---|---|---|
| W0 기반 | 001, 002, 003, 004, 005, 006 | 6 | 없음(002는 D-02·D-12 확정) | 모노레포·웹 골격, DB 적용·타입, 도메인 상수, 가격 공식, 안전 fetch, 토큰 인벤토리(디자인 시스템 1단계) |
| W1 인증·워커 기반 | 007, 008, 009, 010, 011, 012, 013 | 7 | W0(001, 002, 003, 005) | 인증 Stage A, env, RLS 테스트, 워커 런타임·크론·환율, `MarketAdapter`·가짜 마켓, 쿠팡 파서, 리스크 규칙 |
| W1-D 디자인 시스템 | 014 → 015 → 016(직렬) | 1 | 001, 006 | 토큰·기본 컴포넌트, 사람 검토, 정답 확정. **화면 작업의 진입 조건** |
| W2 수집 | 017, 018, 019, 020, 021, 022 | 6 | W1(007, 010, 012, 013), 화면(017, 018, 022)은 016 | 셸, `MarketScope`, 수집·확장 API, 수집 워커, 확장프로그램, S-02 |
| W3 등록 | 023, 024, 025, 026, 027, 028, 029 | 7 | W2(019, 020), 011. 023·025는 D-08, 024는 D-09, 026은 D-05 | 마켓 연결·토큰 금고, eBay·Amazon 어댑터, AI 번역, 등록 API, 등록·가져오기 워커, S-03 |
| W4 운영 | 030, 031, 032, 033, 034, 035, 036, 037 | 8 | W3(024, 025, 028), 018. 032는 D-11, 033·036은 D-03, 037은 D-04 | 동기화 워커·API, 주문 워커·API, 추적·지표·토큰 갱신, S-04·S-05·S-06 |
| W5 수익·계정·마법사·결제 | 038, 039, 040, 041, 042, 043, 044 | 7 | W4(033), 023. 043은 D-01·D-02 | 수익, 대시보드, 마법사 점수·화면, 계정 8탭·연동 설정, 결제, 대기자 랜딩·법적 문서 |
| W6 E2E·보안 | 045, 046, 047, 048 | 4 | W5 전부 | 결제 E2E, 핵심 플로우 E2E, 보안 회귀, CI. **MVP 출시 조건(G1 판정 근거)** |
| W7 공개 베타 | 049(G1 통과 후 먼저), 050 | 2 | W6, 049는 사람의 G1 판정, 050은 049·045~047 | Google·이메일 로그인(Stage B), 운영 배포·실 마켓 키 전환. **공개 베타 조건** |
| W8 Phase 2 | 051, 052, 053, 054, 055(G2 통과 후) | 5 | 베타 출시, 055는 G2와 D-15·D-16 | Shopee, Amazon JP, Lazada, 키워드·정기 수집, 카카오·네이버 로그인 |

W2~W4 안에서도 같은 영역 화면은 API 작업 뒤에 둔다: 022는 019 뒤, 029는 027 뒤, 035는 031 뒤, 036·037은 033 뒤. 워커 작업(020, 028, 030, 032, 034)과 API 작업은 같은 웨이브에서 병렬로 시작하되 잡 payload 계약(`04_API.md` 잡 페이로드 절)을 먼저 고정한다.

## 4. 에이전트별 비율

DOC_TEMPLATE 4장의 "모델별 비율" 대신 담당 에이전트별 비율을 둔다(모든 팀원이 Sonnet 5.5라 모델별로는 100%다).

| 담당 에이전트 | 모델 | 작업 수 | 비율 | 규모 가중(S=1, M=2, L=3) 비율 |
|---|---|---|---|---|
| `nextjs-expert` | claude-sonnet-5-5 | 24 | 43.6% | 48 / 111 = 43.2% |
| `worker-expert` | claude-sonnet-5-5 | 18 | 32.7% | 41 / 111 = 36.9% |
| `supabase-expert` | claude-sonnet-5-5 | 2 | 3.6% | 4 / 111 = 3.6% |
| `sub-agent-1` | claude-sonnet-5-5 | 5 | 9.1% | 8 / 111 = 7.2% |
| `sub-agent-2` | claude-sonnet-5-5 | 2 | 3.6% | 2 / 111 = 1.8% |
| `test-writer` | claude-sonnet-5-5 | 3 | 5.5% | 7 / 111 = 6.3% |
| `사람` | 사람 | 1 | 1.8% | 1 / 111 = 0.9% |
| 합계 | - | 55 | 100% | 111 |

| 검증 에이전트 | 모델 | 붙는 작업 수 | 시점 |
|---|---|---|---|
| `plan-challenger` | claude-sonnet-5-5 | 26 | 착수 전 |
| `review-expert` | claude-sonnet-5-5 | 53 | 변경 후(사람 작업 015와 전체 감사로 대신하는 047을 뺀 전부) |
| `contract-reviewer` | claude-sonnet-5-5 | 19 | 변경 후, 경계 변경 |
| `security-auditor` | claude-sonnet-5-5 | 22 | 변경 후, 비밀·권한·개인정보 + 출시 전 전체 감사(047) |
| `test-writer` | claude-sonnet-5-5 | 5 (검증 역할) + 담당 3 | 리뷰가 "검증 근거 없음"을 냈을 때, 돈 계산 |

`nextjs-expert`와 `worker-expert`가 전체 규모의 약 80%를 맡는다. 화면이 많고(10개 화면 + 셸·모달) 마켓 어댑터·워커 핸들러가 제품의 핵심이기 때문이다. 두 에이전트의 작업은 웨이브마다 병렬로 나눠져 있어(예: W4에서 worker 4개, nextjs 4개) 한쪽이 병목이 되지 않는다. 팀장(Opus 5.5)의 몫은 작업 수에 넣지 않았다: 웨이브마다 계획 정리, 열린 결정 확인, 리뷰 결과 판정, 커밋.

## 5. 리뷰 작업 흡수표 → 프로토타입 대비 구현 추적표

GlobalSeller는 신설 제품이라 원본 코드 리뷰(`platform-docs/reviews/`) 5장 작업 목록이 없다(해당 없음). 대신 디자인 원본인 프로토타입의 화면 요소를 어느 작업이 구현하는지 추적한다. 줄 번호는 `prototype/index.html`.

| 프로토타입 요소 | 줄 | 구현 작업 | 검증 작업 |
|---|---|---|---|
| 상단 바·상단 탭 5개 | 1298 | GS-06-017 | GS-06-046 |
| 모바일 가로 메뉴 | 1314 | GS-06-017 | GS-06-046 |
| 좌측 GNB·마켓 칩·사용자 카드 | 1329 | GS-06-017 | GS-06-046 |
| S-01 KPI 5칸·월간 매출·최근 활동·최근 등록 상품 | 1392-1612 | GS-06-039(화면), GS-06-038(집계) | GS-06-046 |
| S-02 수집함(검색 폼·파이프라인·결과 표) | 1632 | GS-06-022, GS-06-019 | GS-06-046 |
| S-02 개별 등록(불러오기·옵션·리스크·예상 마진) | 1754 | GS-06-022, GS-06-019, GS-06-020, GS-06-012, GS-06-013, GS-06-004 | GS-06-046 |
| S-02 대량 수집(방식 4종·API 한도·칩·드롭존·필터·작업·제외 사유) | 1895 | GS-06-022, GS-06-019, GS-06-020, GS-06-021, GS-06-054(키워드·정기) | GS-06-046 |
| S-03 등록 현황(마켓 요약·목록) | 2047 | GS-06-029, GS-06-027 | GS-06-046 |
| S-03 개별 등록 6단계·우측 검증 | 2117 | GS-06-029, GS-06-027, GS-06-026, GS-06-004 | GS-06-046 |
| S-03 일괄 등록 4단계 | 2304 | GS-06-029, GS-06-027, GS-06-028 | GS-06-046 |
| S-08 API 설정(마켓 API 카드·쿠팡 파트너스) | 2425 | GS-06-042 | GS-06-047 |
| S-08 경쟁사 벤치마킹 카드 | 2438 | 제품 제외(기획 문서) | - |
| S-09 구조도 | 2649 | 제품 제외(DS 6장) | - |
| S-04 마켓 탭·지표 띠 | 2820 | GS-06-018, GS-06-035, GS-06-034(지표) | GS-06-046 |
| S-04 KPI·변동 내역·규칙 카드·마켓별 상태 | 2861-2927 | GS-06-035, GS-06-031, GS-06-030 | GS-06-046 |
| S-05 마켓 탭·건전성 띠·파이프라인·KPI | 2942-2999 | GS-06-018, GS-06-036, GS-06-034 | GS-06-046 |
| S-05 상태 세그먼트 × 마켓·주문 표 | 3000-3032 | GS-06-036, GS-06-033, GS-06-032 | GS-06-046 |
| S-06 마켓 탭·KPI·배송 목록·타임라인·운송사 | 3047-3148 | GS-06-037, GS-06-033, GS-06-034 | GS-06-046 |
| S-07 KPI·월별 순이익·비용 구조·마켓별·인사이트·상위 상품 | 3149-3240 | GS-06-038 | GS-06-046 |
| S-10 프로필 | 3314 | GS-06-042 | GS-06-046 |
| S-10 구독 플랜·사용량 | 3426 | GS-06-042, GS-06-043 | GS-06-045 |
| S-10 마켓 연결 | 3510 | GS-06-042, GS-06-023 | GS-06-046 |
| S-10 API 키 관리 | 3617 | GS-06-042, GS-06-023 | GS-06-047 |
| S-10 결제 내역 | 3733 | GS-06-042, GS-06-043 | GS-06-045 |
| S-10 알림 설정 | 3821 | GS-06-042 | GS-06-046 |
| S-10 보안 | 3917 | GS-06-042, GS-06-049(비밀번호·이메일) | GS-06-047 |
| S-10 팀 멤버 관리 | 4045 | GS-06-042 | GS-06-009, GS-06-046 |
| S-11 마법사 1~5단계 | 4163-4330 | GS-06-041, GS-06-040, GS-06-023, GS-06-028(가져오기) | GS-06-046 |
| 마법사 완료 후 운영 화면 탭 생성 | 4163(스크립트 `mkFinish`) | GS-06-041, GS-06-018 | GS-06-046 |
| 프로토타입 스모크 테스트 39항목 | `tests/prototype-smoke.js` | GS-06-046(실제 앱으로 이식) | GS-06-048(CI) |

## 6. 공용 모듈 요청

| ID | 대상 | 요청 | 이유 | 그때까지의 우회 |
|---|---|---|---|---|
| R-1 | `platform-docs/products/_platform-core` 앱 레지스트리 | `globalseller` 앱 등록과 모듈러 번호 2700 배정 | platform-docs 통합 DB로 옮길 때 필요(DS 0장) | 이 저장소는 모놀리스 단독 Supabase로 개발(`05_DATA_MODEL.md`, D-12) |
| R-2 | 공용 ai-service | 번역 기능 키(`globalseller.translate`) 라우팅 행 | D-05에서 (b)를 고르면 필요 | MVP는 워커 직접 호출(D-05 (a)) |

코어 표·함수는 이 저장소에서 고치지 않는다. 코어 lite 마이그레이션은 platform-docs `MONOLITH_CORE_LITE.sql` 복사본이고, 바꿔야 하면 platform-docs에서 먼저 고친 뒤 새 번호 파일로 가져온다.

## 7. 완료 정의

| 조건 | 확인 |
|---|---|
| 빌드·타입·린트 | `pnpm -r build`, `pnpm -r typecheck`, `pnpm -r lint` 0 오류(웹·워커·확장·패키지) |
| SQL | `supabase db reset` 2회 연속 성공, platform-docs `_tools-sqlcheck` mono 검사 OK |
| RLS 스모크 | GS-06-009 전 항목 통과 |
| 결제 E2E | GS-06-045 통과(Toss 테스트 키) |
| 플로우 E2E | GS-06-046 통과(Mock 페르소나 + 가짜 마켓), 375·1024·1440 가로 넘침 0 |
| 보안 | GS-06-047 녹색, security-auditor 전체 감사 🔴 0 |
| 마켓 계약 | eBay·Amazon 어댑터가 GS-06-011 계약 스위트 통과 + 샌드박스 수동 점검 기록 |
| 06장 작업 | W0~W7 완료(P0, Stage B GS-06-049 포함. 공개 베타 전 G1 판정), W8은 Phase 2 |
| 열린 결정 | MVP 범위에 걸린 D-01~D-14 확정 기록 |
| 법률 검토 | 약관·개인정보처리방침·국외 이전 고지 검토 전 유료 출시 금지(`01_PRD.md` 6장) |
| 디자인 | 디자인 시스템 4단계(GS-06-016) 완료, hex 하드코딩·`tailwind.config.js` 0 |

P0 작업과 검증 작업 대응: DB·권한(002, 007, 023) → 009 / 인증 A(007) → 자체 테스트 + 046 / 인증 B(049) → B-1~B-6 + 046 + 047 / 결제(043) → 045 / 수집·등록·운영·화면(010~013, 017~042) → 각 작업 단위 테스트 + 046 / 비밀·토큰·확장 토큰(005, 021, 023) → 047 / 랜딩·법적(044) → 체크리스트 + 법률 검토.

## 8. 인증 단계 작업

정본 `platform-docs/products/_platform-core/AUTH_ROADMAP.md`(9장 작업 반영 규칙). GlobalSeller는 open 앱(가입 즉시 사용)이고 B는 Google + 이메일, C1 카카오·C2 네이버는 Phase 2(P2, 해외 셀러 도구 특성상 우선순위 낮음, 제안)로 둔다. 2장 표에 같은 열로 들어 있다.

| 작업 | 단계 | 진입 게이트(사람 판정, task 파일 완료 보고에 기록) | 웨이브 | 비고 |
|---|---|---|---|---|
| GS-06-007 | Stage A(Mock 로그인) | - | W1 | W0 작업은 시드 스크립트 없이 SQL·단위 테스트로 검증 |
| GS-06-049 | Stage B(Google + 이메일) | G1: MVP P0 기능 작업 완료, 플로우 E2E(046)·RLS(009)·결제 E2E(045)가 Mock 페르소나로 녹색, 인증 모듈 밖 단계 분기 0건(047), Google Cloud·운영 Supabase 준비(`AUTH_ROADMAP.md` 4장) | W7 맨 앞 | 공개 베타 직전 |
| GS-06-055 | Stage C1·C2(카카오·네이버) | G2: Google 공개 베타 2주 안정(제안), 인증 장애 0, `/auth/callback` 오류율 1% 미만(제안), 카카오 앱·네이버 애플리케이션 준비(`AUTH_ROADMAP.md` 6장), D-15·D-16 결정 | W8 | 네이버는 스파이크 0.5일로 경로 결정 |

### 8.1 소유 경로 메모

| 항목 | 내용 |
|---|---|
| 로그인 화면 | 페이지(`app/(auth)/login/`)와 개발용 패널은 GS-06-007, 제공자 버튼·이메일 폼(`components/auth/`)은 GS-06-049, 카카오(`components/auth/kakao/`)·네이버(`app/auth/naver/`, `lib/auth/naver/`)는 GS-06-055. 페이지는 `listLoginOptions('globalseller')` 결과만 렌더하므로 B·C 작업이 페이지 파일을 고치지 않는다 |
| 콜백 | URL `/auth/callback`은 `app/auth/callback/`(라우트 그룹 아님), GS-06-049 소유 |
| 온보딩 | `app/onboarding/terms/`는 GS-06-049 |
| config | `supabase/config.toml`(GS-06-002)의 제공자 블록은 049·055가 1줄 요청으로 바꾼다 |
| 역할 이름 | 코어 `org_members.role`은 `owner`·`admin`·`member`·`viewer`(`MONOLITH_CORE_LITE.sql:172`). 프로토타입 "편집자"는 `member`로 옮긴다 |
