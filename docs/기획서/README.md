# GlobalSeller OS (globalseller-os)

작성일 2026-10-25. 장 구조는 `platform-docs/products/_platform-core/DOC_TEMPLATE.md` 2.1절을 따른다. 이름·화면 ID·라우트·테이블·상태 값은 `docs/설계/DESIGN_STRUCTURE.md`가 정본이고, 이 폴더의 문서는 그 이름을 그대로 쓴다.

표기: 근거는 `경로:줄`. 이 저장소 안의 경로는 저장소 루트 기준(`prototype/index.html:1392`), platform-docs의 경로는 `platform-docs/` 접두사를 붙인다. 근거 없는 수치·정책은 "제안", 확인하지 않은 외부 사실은 "미확인".

## 1. 한 줄 정의

쿠팡에서 고른 국내 상품을 수집함에 담아 마진·리스크를 검토하고, AI 번역과 가격 규칙으로 eBay·Amazon 등 해외 마켓에 등록한 뒤, 재고·가격 동기화부터 주문·쿠팡 발주·배송·수익 분석까지 한 화면에서 운영하는 **역직구 멀티채널 SaaS**다.

| 항목 | 내용 |
|---|---|
| 대상 사용자 | 부업 역직구 셀러, K-뷰티·식품 전문 1인 셀러, 2~10명 규모 역직구 팀(01장 1절) |
| 화면 | S-01 대시보드 ~ S-11 마켓 추가 마법사(`docs/설계/DESIGN_STRUCTURE.md` 1장). S-09 구조도는 제품에서 제외 |
| MVP 마켓 | eBay US, Amazon US(P0). Shopee SG·TH P1, Amazon JP·Lazada P2(`docs/설계/DESIGN_STRUCTURE.md` 10장) |
| MVP 수집 경로 | URL 개별, URL 목록 업로드, 크롬 확장프로그램(P0). 쿠팡 파트너스 API 키워드 수집·정기 수집은 P1 |
| 앱 id / 스키마 / 약어 | `globalseller` / `globalseller` / `GS`(작업 `GS-06-###`, 기능 `GS-F-###`, SQLSTATE `GS001~GS099`) |
| 디자인 원본 | `prototype/index.html`(클릭 가능한 단일 파일 프로토타입). 토큰 값의 정본은 08장 |
| 저장소 | `DevOps0906/GlobalsellerOS`. 이 저장소가 곧 개발 폴더다(개발서 `docs/개발서/`) |

## 2. 통합 근거

GlobalSeller OS는 platform-docs의 기존 제품을 합친 것이 아니라 **신설 제품**이다. 다만 같은 도메인(마켓 등록)과 같은 공용 코어를 쓰는 nomad-commerce의 설계를 이식하고, 화면 구조는 이미 검증용으로 만든 프로토타입을 정본으로 삼는다.

| 근거 | 내용 |
|---|---|
| 방향이 반대인 커머스 제품 | nomad-commerce는 해외(아마존)·도매 → 국내(쿠팡·스마트스토어) 방향이다(`platform-docs/products/nomad-commerce/README.md:7`). GlobalSeller는 국내(쿠팡) → 해외(eBay·Amazon·Shopee) 방향이라 소싱·업로드 대상이 바뀌지만 "마켓 계정 자격증명, 마켓 어댑터, 안전 fetch, 금지어 검사, 잡 워커" 구조는 같다 |
| 설계 이식 대상 | nomad-commerce의 마켓 어댑터 패키지 경계(`platform-docs/products/nomad-commerce/CLAUDE.md:44-46`), 자격증명 vault·마스킹 응답(`platform-docs/products/nomad-commerce/06_AGENT_PLAN.md` CM-06-009 행), 안전 fetch(같은 문서 CM-06-008 행), 금지어 매처 패키지(`platform-docs/products/nomad-commerce/CLAUDE.md:43`). 코드는 07장 2절 표대로 "패턴 이식"만 하고 nomad-commerce 코드를 그대로 복사하지 않는다 |
| 공용 코어 | 인증·조직·플랜·크레딧·Toss·암호화 자격증명·잡은 `platform-docs/products/_platform-core/CORE_SPEC.md`를 그대로 소비한다(1.3절 계약 요약표). Toss 단일 PG(`CORE_SPEC.md:203`), 크레딧 선차감 순서(`CORE_SPEC.md:177`), 인증 단계 A→B→C(`AUTH_ROADMAP.md:7`) |
| 화면 정본 | 프로토타입의 GNB·하위 탭·마켓별 탭·마법사를 `docs/설계/DESIGN_STRUCTURE.md`가 구조로 옮겼다. 2026-10-23 기획 업데이트에서 경쟁사(Sellbrite, 카페24 마켓플러스, 윈들리) 구조를 반영했다(`docs/planning-update-2026-10-23.md:58-65`) |
| 검증 우선 | 쿠팡 파트너스 API는 최종 승인 후에만 키가 나오고 키워드 검색만 되므로(`docs/planning-update-2026-10-23.md:69-73`) MVP 수집은 URL·목록·확장프로그램으로 시작한다. 마켓은 무료 OAuth인 eBay와 시장이 가장 큰 Amazon US를 먼저 붙인다 |

## 3. 원본 매핑

| 원본 | 리뷰 파일 | 완성도 | 가져오는 것 | 버리는 것 |
|---|---|---|---|---|
| `prototype/index.html` (2026-10-23판) | `tests/prototype-smoke.js`(39개 항목 통과, `README.md:57-62`) | 화면 목업 100%, 데이터·서버 0% | GNB 구조, 화면 11종, 하위 탭, 마켓 탭 패턴, 마법사 5단계와 점수 규칙(`prototype/index.html:4535`), 디자인 토큰(`prototype/index.html:12-96`), 문구, 반응형 3구간 글자 크기(`prototype/index.html:610-612`) | 인라인 JS 상태, `data-v` JSON 하드코딩 수치, 구조도 화면, 이모지 아이콘, 데모 데이터(07장 3절) |
| `docs/planning-update-2026-10-23.md` | 같은 파일 4장 벤치마킹 표 | 기획 확정 | 전체 탭 + 마켓별 탭, 마법사 단계, 개별·대량 수집 단계, 쿠팡 파트너스 API 제약과 대응 | 화면 수치(예시 데이터) |
| nomad-commerce 기획서 (`platform-docs/products/nomad-commerce/`) | `platform-docs/products/nomad-commerce/07_SOURCE_MIGRATION.md` 4절 | 기획만(코드 미착수) | 마켓 어댑터 인터페이스 패턴, 자격증명 vault·마스킹, 안전 fetch 규칙, 금지어 매처 원칙, 워커 핸들러 자동 로드 규약, 복사 금지 결함 목록 | 쿠팡·스마트스토어 업로드 어댑터, 상세페이지 슬롯·이미지 생성, 아마존 소싱, 플레이오토 엑셀 |
| `platform-docs/products/_platform-core/` | `CORE_SPEC.md`, `SECURITY_BASELINE.md`, `AUTH_ROADMAP.md` | 코어 명세·SQL 확정 | `MONOLITH_CORE_LITE.sql` 코어 표, `session_context`, `consume_credits`/`refund_credits`, Toss 흐름, `encrypted_credentials`, `jobs`, 인증 단계 | affiliate(SECTION 9). AI 계층 표는 쓰지만 FastAPI·Dify·음성은 MVP에서 쓰지 않는다(02장) |

세부 이식·폐기 목록은 `07_SOURCE_MIGRATION.md`.

## 4. 문서 목록

| 파일 | 내용 |
|---|---|
| `README.md` | 이 문서. 한 줄 정의, 통합 근거, 원본 매핑, 문서 목록, DB 구조 선택 |
| `01_PRD.md` | 페르소나 3명, MVP·Phase 범위(인증 단계 포함), 기능 요구사항 `GS-F-001~062`(화면 S-01~S-11 전부), 요금·크레딧(제안), 비기능 수치, 법·개인정보·금지 문구, KPI, 열린 결정 D-01~D-14와 인증 단계 결정 D-15~D-17 |
| `02_ARCHITECTURE.md` | 스택, 모듈 경계, 공용 모듈 사용, 잡과 워커, AI 라우팅, 결함 차단 설계, 배포, 환경변수, 인증 단계 |
| `03_SCREENS_UX.md` | 화면 목록, 사용자 플로우, 화면별 명세, 메인페이지 방향, 상태·오류·빈 화면, 접근성·반응형 |
| `04_API.md` | Route Handler, RPC, 잡 페이로드, 웹훅, 외부 API 어댑터, 오류 코드 |
| `05_DATA_MODEL.md` | 스키마 `globalseller` 테이블, 상태 전이, RLS, 인덱스, 코어 참조, 모놀리스와 모듈러 차이 |
| `06_AGENT_PLAN.md` | 작업 `GS-06-###`, 웨이브 W0~W8, 담당 에이전트(주 Opus 5.5, 부 Sonnet 5.5), 완료 정의 |
| `07_SOURCE_MIGRATION.md` | 원본별 자산 분류, 프로토타입 클래스 → 컴포넌트 매핑, 폐기 목록, 복사 금지 결함, 아카이브 절차 |
| `08_DESIGN_SYSTEM.md` | 정답 소스(Tailwind CSS v4 `@theme`), 프로토타입에서 뽑은 토큰 값, 반응형 글자 크기, 다크 모드, 컴포넌트 목록 |
| `../../CLAUDE.md` | 개발 에이전트 지침(저장소 루트). 절대 규칙, 문서 지도, 멀티에이전트 작업 방식 |
| `../../supabase/` | 마이그레이션(코어 lite 복사본 + `globalseller` 도메인), 시드, RLS 테스트 |
| `../설계/DESIGN_STRUCTURE.md` | 디자인 구조 다이어그램과 고정 식별자(이 폴더 문서의 이름 정본) |
| `../개발서/` | 개발 방법 안내서(시작부터 출시까지) |

## 5. DB 구조 선택

| 구조 | 선택 | 이유 |
|---|---|---|
| 모놀리스(단독 Supabase) | 1차 개발·출시 기본값 | 이 저장소가 단독 개발 폴더이고, 셀러 마켓 토큰을 다른 제품과 물리적으로 분리하는 편이 위험이 적다(제안). 코어 표는 `MONOLITH_CORE_LITE.sql`을 `supabase/migrations/`에 복사해 쓰고, 도메인 표는 스키마 `globalseller`에 둔다 |
| 모듈러(통합 DB) | 대안. platform-docs에 제품으로 등록할 때 | 번호 2700(제안, `docs/설계/DESIGN_STRUCTURE.md` 0장). nomad-commerce(1400)와 같은 계정·크레딧 지갑을 쓰면 국내 판매와 역직구를 함께 하는 셀러에게 교차 판매가 쉽다. 전환 시 도메인 SQL의 `globalseller.` 접두사는 그대로 두고 코어 참조만 모듈러 `core.`로 바꾼다(05장 8절) |

결정 대기: 모놀리스에서 코어 표의 스키마를 `public`으로 둘지는 01장 D-12.
