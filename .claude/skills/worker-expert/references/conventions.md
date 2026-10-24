# worker-expert — conventions

> 프로젝트의 실제 코드 · 기획서가 우선한다. 외부 API 수치는 작업 시점 공식 문서로 확인한다. 불일치는 보고한다.

## 잡 런타임 (`services/worker/src/runtime/`)

- 큐는 공용 코어 `jobs` 테이블 하나(SKIP LOCKED claim). 도메인에 별도 큐 테이블을 만들지 않는다. 큐 이름은 `globalseller.<영역>`(`DESIGN_STRUCTURE.md` 9장).
- claim → 하트비트(진행 중 주기적으로 갱신) → 완료/실패 기록. 하트비트가 끊긴 잡은 다시 claim 가능해야 한다(워커 재시작 대비).
- 재시도: `retryable` 오류만, 최대 횟수와 지수 백오프(+ 지터). 최종 실패 시 코어 `fail_job`이 크레딧을 자동 환불(유료 잡만).
- 조직별 동시성 상한을 둔다(한 조직의 대량 등록이 다른 조직을 막지 않게). 상한 값은 플랜 한도 · 마켓 한도에서 온다.
- 핸들러는 `export default { queue, handle(job, ctx) }` 형태로 `src/<영역>/handler.ts`에 두면 런타임이 자동 로드한다.
- 크론(`src/cron/`)은 잡을 **등록**만 하고 일은 핸들러가 한다. 주기 값은 `DESIGN_STRUCTURE.md` 9장 표.

## 멱등 키

| 대상 | 키 형식 (제안) | 저장 위치 |
|---|---|---|
| 잡 등록 | `job:globalseller:<request_id>` | `jobs` 고유 키 |
| 리스팅 전송 | `listing:<listing_id>:v<content_version>` | `listings` 전송 키 컬럼 |
| 가격 · 재고 반영 | `sync:<sync_event_id>` | `sync_events` |
| 발송 확인 | `ship:<order_id>:<tracking_no>` | `shipments` |
| 크레딧 차감 | `consume:globalseller:<request_id>` | 코어 `credit_ledger` |

- 외부 쓰기 전에 키를 기록하고, 외부 응답의 id 를 받으면 즉시 저장한다. 응답이 유실되면 재시도 전에 **외부 조회로 이미 생성됐는지 확인**한다(SKU 기준 조회 등).
- SKU 는 조직 · 원본 상품 · 옵션에서 결정적으로 만든다(같은 상품을 다시 보내도 같은 SKU).

## MarketAdapter (`packages/markets/`)

- 인터페이스 1개, 마켓별 구현 폴더 1개: `ebay/`, `amazon-sp/`, `shopee/`(P1), `lazada/` · `qoo10/`(P2), 테스트용 `mock/`.
- 메서드 묶음(이름은 `02_ARCHITECTURE.md`가 정본): 인증(인증 URL · 코드 교환 · 토큰 갱신 · 연결 테스트), 리스팅(생성 · 수정 · 가격/재고 갱신 · 종료 · 기존 목록 가져오기 · 카테고리/필수 속성 조회), 주문(신규 주문 조회 · 발송 확인 · 취소/반품 조회), 건전성 지표 조회.
- 결과는 판별 유니온: `{ ok: true, data }` 또는 `{ ok: false, kind: 'retryable' | 'auth' | 'validation' | 'fatal', code, message }`. 예외를 그대로 던지지 않는다.
- 마켓이 지원하지 않는 기능은 카탈로그 기능 플래그(`packages/domain`)로 표시하고 어댑터는 `fatal: unsupported`를 돌려준다.
- 호출 한도는 어댑터 안의 토큰 버킷(마켓 · 계정 · 오퍼레이션 단위)으로 지킨다. 응답 헤더에 한도 정보가 오면 그것을 우선한다.

## 마켓별 인증 (작성 시점에 알려진 내용 — 작업 시점에 공식 문서 확인)

| 마켓 | 방식 | 토큰 · 서명 | 주의 |
|---|---|---|---|
| eBay | OAuth 2.0 authorization code | 사용자 access token 은 짧고(약 2시간) refresh token 은 길다(약 18개월) — 수치 확인 필요 | 판매자 계정 삭제 알림 엔드포인트(`/api/webhooks/ebay/account-deletion`, 챌린지 응답) 등록이 개발자 계정 요건. 샌드박스와 운영 키가 다르다 |
| Amazon SP-API | Login with Amazon(LWA) authorization code → refresh token → access token | access token 은 약 1시간. 예전 문서의 AWS IAM · SigV4 요구는 2023년에 없어졌다고 알려져 있음 — 확인 필요 | 오퍼레이션별 호출 한도(usage plan). 구매자 주소 같은 제한 데이터는 Restricted Data Token 절차가 필요. 리스팅은 Listings Items API, 상품 유형별 필수 속성은 Product Type Definitions |
| Shopee Open Platform | 상점 권한 승인(파트너 앱) → access/refresh token | 요청마다 HMAC-SHA256 서명(파트너 id · 경로 · 타임스탬프 · 토큰 · 상점 id). access token 수명이 짧다(약 4시간) — 확인 필요 | 국가(상점)별 토큰. 크론 `token_refresh`가 만료 전에 갱신 |
| Lazada (P2) | 판매자 OAuth | 요청 서명(HMAC) | 국가별 엔드포인트 |

- 토큰 · 키는 `encrypted_credentials`에만 저장하고, 복호화는 어댑터 호출 직전 워커 메모리에서만. 로그 · 잡 결과 · 오류 메시지에 넣지 않는다.
- OAuth state 는 코어 `oauth_states`(1회용 · 만료) 규약을 따른다. 콜백은 웹 Route Handler 가 받고 토큰 교환 후 바로 암호화 저장한다.

## 수집 경로 (`packages/sources/`, `services/worker/src/collect/`)

- 허용 경로: ① 사용자가 입력한 쿠팡 URL · 상품번호(형식 검증 후 파트너스 API 또는 확장프로그램 데이터로 채움) ② 쿠팡 파트너스 API ③ 확장프로그램이 사용자 브라우저에서 담아 보낸 데이터 ④ 업로드한 CSV · XLSX.
- **서버에서 쿠팡 페이지를 대량·자동으로 크롤링하지 않는다.** 약관 · 차단 위험이 있고 기획서가 금지한다(`01_PRD.md` 6장). 허용: 사용자가 준 URL 단건 조회(요청 간격 1초 이상, URL 목록도 줄마다 단건), 확장프로그램이 담은 데이터, 파트너스 공식 API(P1).
- 쿠팡 파트너스 API 제약(`docs/planning-update-2026-10-23.md` 5장): 최종 승인(누적 판매 15만 원 이상) 후에만 키 발급, 키워드 검색만 지원(가격 · 정렬 조건은 무시된다는 보고), 호출 한도 있음(공식 문서 분당 50회 · 실사용 보고 시간당 10회로 자료가 엇갈림 — 화면은 보수적으로 10회 표시). 초과가 반복되면 계정 제한 사례가 있으므로 한도는 설정값 + 조직별 카운터로 지킨다.
- 그래서 조건 필터(가격 · 리뷰 · 평점 · 마진 · 무게 · 제외어 · 브랜드)는 **수집 후** 워커가 적용한다.
- 외부 이미지 · 사용자 URL 은 `packages/net` 안전 fetch 로만(허용 도메인, DNS 확인 후 사설 IP 차단, 리다이렉트 상한, 크기 · 시간 상한).
- 리스크 검사(`packages/compliance`): 항공 제한 품목(배터리 · 인화성), 브랜드 판매 제한, 제외 키워드, 이미지 사용 권한. 검사 결과를 건너뛰는 경로를 만들지 않는다.

## 동기화 (`src/sync/`)

- 크론이 원본 재확인 잡을 등록 → 변동이면 `sync_events`(`detected`) → 규칙 평가 → `applied` · `held` · `skipped` · `failed`.
- 규칙은 조직 기본 + 마켓 계정별 덮어쓰기(`sync_rules`). 마켓 전용 규칙(Amazon 최저·최고가 보호, eBay 품절 시 리스팅 유지, Shopee 국가별 가격)은 카탈로그 기능 플래그로 켠다.
- 원가 상승 → 목표 마진 유지 재계산. 마진 하한 미달 · 직전 대비 급락(임계값은 기획서) · 원가 0 · 환율 이상값은 자동 반영 금지(`held`).
- 품절 → 마켓 재고 0. 재입고 → 재고 버퍼를 뺀 수량으로 복원.

## 주문 · 배송 (`src/orders/`, `src/shipping/`)

- 주문 수집은 `(market_account_id, external_order_id)`로 upsert. 같은 주문이 두 번 들어와도 한 행.
- 발주는 사용자가 기록한다(MVP). 워커가 쿠팡에 자동 주문하지 않는다.
- 발송 확인은 송장 등록 후 잡으로 마켓에 전송, 멱등 키 `ship:<order_id>:<tracking_no>`.

## 확장프로그램 (`apps/extension/`, Chrome MV3)

- 원격 코드 실행 금지(MV3). 모든 스크립트는 패키지에 포함.
- `host_permissions`는 쿠팡 상품 · 검색 페이지와 GlobalSeller API 도메인만. 다른 사이트 권한을 요청하지 않는다.
- 웹에서 발급한 단기 확장 토큰(`/api/extension/token`)만 저장한다. 마켓 토큰 · Supabase 키를 확장에 두지 않는다.
- 사용자가 보고 있는 페이지에서 사용자가 누른 상품만 `/api/extension/items`로 보낸다(요청당 상한은 `DESIGN_STRUCTURE.md` 11.1절). 백그라운드 자동 순회 수집을 하지 않는다.
- 쿠팡 페이지 구조가 바뀌면 파서만 깨지게 셀렉터를 한 파일에 모은다.
