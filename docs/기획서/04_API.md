# 04 API: GlobalSeller OS

작성일 2026-10-25. 경로 이름은 `docs/설계/DESIGN_STRUCTURE.md` 11.1절, RPC 이름은 11.2절, 금액 규칙은 11.3절이 정본이다. DB 객체는 `supabase/migrations/20261025000002_globalseller_domain.sql`(이하 `domain.sql`)에 있다.

## 1. 원칙

| 항목 | 규칙 |
|---|---|
| 인증 | 모든 `/api/*`(웹훅, `/api/dev/login`, `/api/extension/items` 제외) 첫 줄에서 `requireSession('globalseller', { roles })`. 미로그인 401, pending·suspended 403, `entitled=false` 402. 세션은 인증 단계(A Mock·B Google·C 카카오·네이버)와 무관하게 실제 Supabase JWT다(8장, platform-docs `AUTH_ROADMAP.md` 0장) |
| 확장프로그램 | `/api/extension/items`는 `Authorization: Bearer <확장 토큰>`. 토큰은 `/api/extension/token`이 발급(HMAC, 24시간, `org_id`·`user_id`·`scope=collect` 포함). 서버가 서명·만료·조직 엔타이틀먼트를 다시 확인 |
| 역할 | 읽기 owner/admin/member/viewer. 운영 쓰기(수집·등록·동기화 승인·발주·송장) owner/admin/member. 마켓 연결·해제, 결제, 팀 관리 owner/admin. 역할이 없으면 거부 |
| 플랜 | `entitled_plan_code` + `plans.features`(01_PRD 4.4절 `gs_*` 키)만. 요청 바디의 plan·model·org 값은 무시 |
| 멱등 | 클라이언트가 쓰기 요청마다 UUID `request_id`를 보낸다. 서버 키 `job:globalseller:<영역>:<request_id>`, `consume:globalseller:<영역>:<request_id>`(platform-docs `CORE_SPEC.md` 4.4절) |
| 크레딧 | AI 번역만 차감한다(01_PRD 4.2). Route Handler에서 `consume_credits` 선차감 후 잡 등록. 클라이언트가 부르는 별도 차감 API는 없다 |
| DB 쓰기 | 사용자 클라이언트는 SELECT만(05_DATA_MODEL 4장). 쓰기는 Route Handler의 `createAdminClient()`(service_role)와 `globalseller` RPC만. service_role 쓰기 전에 세션의 조직·역할을 다시 확인한다 |
| 응답 봉투 | 성공 `{ data }`(목록은 `{ data, nextCursor }`), 실패 `{ error: { code, message, details? } }`. code는 7장 |
| 페이지 | 커서 기반 `?cursor=&limit=`(기본 50, 최대 200) |
| 레이트 리밋 | `rate_limit_hit('globalseller:<route>:<org_id>', 60, 60)`(분당 60, 제안). 수집·일괄 등록 생성은 분당 10(제안). 초과 429 |
| 입력 | zod. 문자열 길이 상한, 쿠팡 URL은 `packages/sources/coupang-url`의 허용 형식만(`^https://(www\.|m\.)?coupang\.com/vp/products/\d+`) |
| 금액 | 요청·응답 모두 정수. 원화 `*_krw`, 외화 `*_minor` + `currency`. 소수 금액을 받지 않는다 |
| 외부 호출 | Route Handler는 마켓·쿠팡·LLM을 부르지 않는다. 예외: OAuth 코드 교환(`/api/markets/callback/[market]`, 타임아웃 15초). 연결 테스트는 잡으로 워커가 실행 |

## 2. Route Handler

표기: 역할 R = 읽기 전 역할, W = owner/admin/member, A = owner/admin. 크레딧 열의 0은 차감 없음.

### 2.1 수집 (S-02)

| 메서드 경로 | 역할 | 입력(zod 요약) | 출력 | 크레딧 | 호출 RPC·코어 | 오류 |
|---|---|---|---|---|---|---|
| POST `/api/collect/single` | W | `{ request_id: uuid, url: CoupangUrl \| productId: string, group_id?: uuid, options?: { images: bool, notice: bool, ocr: bool, review_summary: bool } }` | `{ collect_job_id, job_id }` 202 | 0 | `enqueue_collect_job(method 'url')` | 22023(URL 형식), GS002, GS003 |
| GET `/api/collect/jobs` | R | `?status&cursor` | `collect_jobs[]` | 0 | - | - |
| POST `/api/collect/jobs` | W | `{ request_id, method: 'url_list'\|'keyword'\|'schedule', keywords?: string[1..20], file_path?: string, preset_id?: uuid, group_id?: uuid }` | `{ collect_job_id }` 202 | 0 | `enqueue_collect_job` | GS003, GS004(`schedule`이 플랜 밖), 22023 |
| POST `/api/collect/jobs/[id]/cancel` | W | `{}` | `{ status }` | 0 | 코어 `cancel_job` | JB002 → 409 |
| POST `/api/collect/upload` | W | `{ request_id, filename: /\.(csv\|xlsx)$/, size_bytes ≤ 5MB }` | `{ upload_url, file_path }`(서명 URL 10분) | 0 | Storage `org-files/<org>/globalseller/collect/<uuid>` | 413 |
| GET·POST·PATCH `/api/collect/presets` | R / W | `{ name, filters: CollectFilters, post_actions: { translate: bool, auto_queue: bool }, schedule_cron?, schedule_enabled? }` | `collect_presets` 행 | 0 | - | GS004(정기 수집이 플랜 밖) |
| POST `/api/extension/token` | W | `{}` | `{ token, expires_at }` | 0 | `write_audit('globalseller.extension.token')` | - |
| POST `/api/extension/items` | 확장 토큰 | `{ request_id, items: ExtensionItem[1..50] }`(상품번호, URL, 제목, 가격, 이미지 URL, 배송 유형, 평점, 리뷰 수 — 확장프로그램이 화면에서 읽은 값) | `{ collect_job_id, accepted, rejected }` | 0 | `enqueue_collect_job(method 'extension')` | 401(토큰), GS003 |
| GET `/api/source-products` | R | `?status&group_id&risk&q&cursor` | `source_products[]` + 옵션 수 | 0 | - | - |
| GET·PATCH·DELETE `/api/source-products/[id]` | R / W | PATCH `{ group_id?, memo?, status?: 'reviewing'\|'ready'\|'excluded', option_ids_selected?: uuid[] }` | 행 | 0 | 상태 전이 트리거 | GS001(409) |

### 2.2 등록 (S-03)

| 메서드 경로 | 역할 | 입력(zod 요약) | 출력 | 크레딧 | 호출 RPC·코어 | 오류 |
|---|---|---|---|---|---|---|
| GET `/api/listings` | R | `?market_account_id&status&q&cursor` | `listings[]` | 0 | - | - |
| POST `/api/listings` | W | `{ request_id, source_product_id, market_account_ids: uuid[1..10], price_rule_id?, shipping_template_id? }` | 마켓별 `draft` 행 | 0 | `pricing.ts`로 초기 가격 | 409(계정 무효) |
| GET·PATCH `/api/listings/[id]` | R / W | PATCH `{ title ≤200, bullets ≤5×500, description ≤4000, keywords ≤20, category_id, attributes, price_minor, quantity }`(draft·ready·error만) | 행 | 0 | 상태 전이 | GS001 |
| POST `/api/listings/[id]/validate` | W | `{}` | `{ status, checks: Check[] }` | 0 | `packages/compliance` | 422 `RISK_BLOCKED` |
| POST `/api/listings/[id]/submit` | W | `{ request_id }` | `{ job_id }` 202 | 0 | `enqueue_job(globalseller.listing, listing.submit)` | GS001(ready 아님), 422 |
| POST `/api/listings/[id]/translate` | W | `{ request_id, language: 'en'\|'ja'\|'th', fields?: ('title'\|'bullets'\|'description'\|'keywords')[] }` | `{ job_id }` 202 | 1 | `consume_credits` → `enqueue_job(globalseller.translate)` | CR001(402) |
| GET `/api/listings/batches` | R | `?cursor` | `listing_batches[]` | 0 | - | - |
| POST `/api/listings/batches` | W | `{ request_id, source_product_ids: uuid[1..gs_bulk_listing_max], market_account_ids: uuid[1..10], price_rule_id, shipping_template_id, options: { translate_tone, stock_buffer } }` | `{ batch_id, preview: { pass, warn, block } }`(사전 검증) | 0 | 항목 생성 + 검증 | GS003(항목 수 초과) |
| POST `/api/listings/batches/[id]/run` | W | `{ request_id, include_warn: bool }` | `{ queued }` 202 | 통과 항목 × 번역 언어 수 | `consume_credits`(`consume:globalseller:batch:<batch_id>`) → 항목별 잡 | CR001, GS001 |
| GET·POST·PATCH `/api/price-rules` | R / W | `{ name, target_margin_pct, min_margin_pct, rounding, fx_buffer_pct, is_default }` | 행 | 0 | - | 23514(min > target) |
| GET·POST·PATCH `/api/shipping-templates` | R / W | `{ name, carrier, min_days, max_days, handling_days, cost_krw, weight_limit_g, is_default }` | 행 | 0 | - | 23514 |
| POST `/api/pricing/preview` | R | `{ cost_krw, shipping_krw, fee_pct, target_margin_pct, rounding, markets: market_code[] }` | 마켓별 `{ currency, price_minor, fee_minor, profit_minor, margin_pct, fx_rate }` | 0 | `fx_rates` 최신 | 422(환율 없음) |

### 2.3 운영 (S-04 · S-05 · S-06 · S-07)

| 메서드 경로 | 역할 | 입력(zod 요약) | 출력 | 크레딧 | 호출 RPC·코어 | 오류 |
|---|---|---|---|---|---|---|
| GET `/api/sync/rules` | R | `?market_account_id` | 기본 규칙 + 계정 덮어쓰기 병합 | 0 | - | - |
| PUT `/api/sync/rules` | A | `{ market_account_id?: uuid, rules: { rule_key, enabled, params }[] }` | 저장 행 | 0 | `write_audit` | 22023(마켓 전용 규칙을 다른 마켓에) |
| POST `/api/sync/run` | W | `{ request_id, market_account_id?: uuid }` | `{ job_id }` 202 | 0 | `enqueue_job(globalseller.sync, sync.check_sources)` | 429(5분 1회, 제안) |
| GET `/api/sync/events` | R | `?market_account_id&change_type&status&cursor` | `sync_events[]` | 0 | - | - |
| POST `/api/sync/events/[id]/approve` | W | `{}` | 행 | 0 | `approve_sync_event` | GS005(held 아님) |
| GET `/api/orders` | R | `?market_account_id&status_group: all\|purchase_pending\|warehouse\|shipped\|claims&q&cursor` | `orders[]`(배송지는 마스킹: 이름 첫 글자, 국가·도시만) + 그룹별 수 | 0 | `market_tab_counts('orders')` | - |
| POST `/api/orders/[id]/purchase` | W | `{ coupang_order_no?, cost_krw: int ≥ 0, domestic_ship_krw?: int ≥ 0, memo? }` | `purchases` 행 | 0 | `record_purchase` | GS006, 22023 |
| POST `/api/orders/[id]/claim` | W | `{ action: 'accept_cancel'\|'reject_cancel'\|'accept_return'\|'reject_return', reason? }` | 주문 행 | 0 | 상태 전이 + 마켓 반영 잡 | GS001 |
| POST `/api/orders/confirm-shipment` | W | `{ request_id, order_ids: uuid[1..100] }` | `{ job_id }` 202 | 0 | `enqueue_job(globalseller.orders_import, orders.confirm_shipment)` | 409(송장 없음) |
| GET `/api/shipments` | R | `?market_account_id&status&cursor` | `shipments[]` | 0 | `market_tab_counts('shipping')` | - |
| POST `/api/shipments` | W | `{ request_id, items: { order_id, carrier, tracking_no, cost_krw?, weight_g? }[1..200] }` | 생성 행 | 0 | `enqueue_job(globalseller.tracking, shipping.upload_tracking)` | 23505(같은 송장) → 409 |
| GET `/api/shipments/[id]` | R | - | 행 + `shipment_events[]` | 0 | - | 404 |
| GET `/api/profit` | R | `?period=month\|last_month\|90d&group=market\|product\|month` | `v_profit_monthly` 집계, 상품 상위 10 | 0 | - | 상품별·인사이트는 `gs_profit_insights` 없으면 숨김 |

### 2.4 마켓 연결과 계정 (S-10 · S-11)

| 메서드 경로 | 역할 | 입력(zod 요약) | 출력 | 크레딧 | 호출 RPC·코어 | 오류 |
|---|---|---|---|---|---|---|
| GET `/api/markets/catalog` | R | - | `packages/domain/markets.ts` 카탈로그(코드, 이름, 지역, 인증 방식, 고정비 문구, 수수료 문구, 지원사업 배지) | 0 | - | - |
| GET·PUT `/api/markets/readiness` | R / A | PUT `{ answers: { biz, tel, pay, card, region[], cat[], budget } }` | 최신 답변 + 추천 목록(`readiness.ts` 계산) | 0 | `readiness_answers` insert | 22023 |
| POST `/api/markets/connect/start` | A | `{ request_id, market_code, site, nickname ≤60 }` | `{ authorize_url, market_account_id }` | 0 | `create_oauth_state` 발급, `market_accounts` insert(connecting) | GS003(계정 한도), 409(같은 계정 연결 중) |
| GET `/api/markets/callback/[market]` | 세션 쿠키 | `?code&state`(Shopee는 `code&shop_id`) | 302 → `/markets/connect?step=4` 또는 `?error=` | 0 | `consume_oauth_state`, `encrypted_credentials` 저장, `write_audit('globalseller.market_account.connected')` | OA001 → `?error=state`, 교환 실패 → `?error=exchange` |
| GET `/api/markets/accounts` | R | - | 계정 목록(토큰 없음, `expires_at`·상태만) | 0 | - | - |
| POST `/api/markets/accounts` | A | `{ request_id, market_code, site, nickname, api_key, seller_id }`(API 키 방식 마켓) | 계정 행(connecting) + 연결 테스트 잡 | 0 | `encrypted_credentials` 저장 | GS003 |
| PATCH `/api/markets/accounts/[id]` | A | `{ nickname?, sort_order?, settings?: { order_import_interval_min: 10\|30, price_rule_id, shipping_template_id, stock_buffer: 0..10, currency } }` | 행 | 0 | - | 22023 |
| DELETE `/api/markets/accounts/[id]` | A | `{ confirm: 'disconnect' }` | `{ status: 'disconnected' }` | 0 | 코어 `revoke_credential`, `write_audit` | - |
| POST `/api/markets/accounts/[id]/test` | A | `{}` | `{ job_id }` 202 | 0 | `enqueue_job(... 'market.test')` | - |
| `/api/billing/*` | A | 코어 Toss 흐름 그대로(platform-docs `CORE_SPEC.md` 5장) | - | - | `confirm_payment_order` 등 | PM* |
| GET `/api/account/usage` | R | - | `plan_usage(org)` | 0 | `plan_usage` | - |

## 3. RPC (SECURITY DEFINER, 스키마 `globalseller`)

| 시그니처 | 호출자 | 검사 | 반환 | SQLSTATE | 위치 |
|---|---|---|---|---|---|
| `enqueue_collect_job(p_org_id uuid, p_method text, p_params jsonb, p_request_id text, p_preset_id uuid = null, p_group_id uuid = null, p_actor_id uuid = null)` | service_role | 엔타이틀먼트, `request_id` 8~80자, `schedule`이면 `gs_scheduled_collect`, 상품 수 한도, 같은 `request_id`면 기존 행 반환 | `collect_jobs` 행(+ 코어 잡) | GS002, GS003, GS004, 22023 | `domain.sql:877-932` |
| `approve_sync_event(p_event_id uuid)` | authenticated(W), service_role | 역할, 엔타이틀먼트, `status = 'held'` | `sync_events` 행(잡 id 포함) | 42501, GS002, GS005, P0002 | `domain.sql:935-971` |
| `record_purchase(p_order_id uuid, p_coupang_order_no text, p_cost_krw bigint, p_domestic_ship_krw bigint = 0, p_memo text = null)` | authenticated(W), service_role | 역할, 엔타이틀먼트, 주문이 `received`·`purchase_pending`, 금액 ≥ 0 | `purchases` 행, 주문 `purchased` | 42501, GS002, GS006, 22023, P0002 | `domain.sql:974-1019` |
| `market_tab_counts(p_org_id uuid, p_screen text)` | authenticated(R), service_role | 조직 멤버, `p_screen in (sync, orders, shipping)` | `(market_account_id, market_code, nickname, sort_order, badge, alert)` | 42501, 22023 | `domain.sql:1022-1044` |
| `plan_usage(p_org_id uuid)` | authenticated(R), service_role | 조직 멤버 | `{ products, markets, ai_translations, members }` 각 `{ used, limit }` | 42501 | `domain.sql:1047-1080` |

코어 RPC(`consume_credits`, `refund_credits`, `enqueue_job`, `claim_jobs`, `complete_job`, `fail_job`, `cancel_job`, `create_oauth_state`/`consume_oauth_state`, `revoke_credential`, `write_audit`, `session_context`, 결제 함수)는 platform-docs `CORE_SPEC.md`를 인용만 하고 재정의하지 않는다.

## 4. 잡 페이로드 계약

모든 페이로드에 `org_id`는 넣지 않는다(잡 행의 `org_id`를 쓴다). 스키마는 `packages/domain/schema/jobs.ts`(zod)가 정본이고 웹과 워커가 같은 파일을 import한다.

| `job_type` | payload | result | progress 메시지 |
|---|---|---|---|
| `collect.url` / `collect.url_list` / `collect.extension` / `collect.keyword` / `collect.schedule` | `{ collect_job_id: uuid, method }`(원본 입력은 `collect_jobs.params`) | `{ collected: int, passed: int, excluded: int, reasons: Record<reason, int> }` | `"n / total 수집"`, `"필터 적용 중"` |
| `translate.listing` | `{ listing_id: uuid, language, fields: string[], content_version: int, credit_ledger_id: int }` | `{ title, bullets_count, provider, model, tokens_in, tokens_out }` | `"번역 중"`, `"금지 문형 검사"` |
| `listing.submit` | `{ listing_id: uuid, attempt: int, batch_item_id?: uuid }` | `{ external_id, status: 'live' \| 'error', errors?: { field, message }[] }` | `"마켓 전송"`, `"마켓 응답 대기"` |
| `listing.import` | `{ market_account_id: uuid, cursor?: string }` | `{ imported: int, matched_sources: int, next_cursor?: string }` | `"기존 리스팅 가져오는 중 n건"` |
| `sync.check_sources` | `{ market_account_id?: uuid }` | `{ checked: int, events: int, held: int }` | `"원본 n / total 확인"` |
| `sync.apply_event` | `{ sync_event_id: uuid }` | `{ applied: bool, error? }` | - |
| `orders.import` | `{ market_account_id: uuid, since?: string }` | `{ new: int, updated: int, next_since: string }` | - |
| `orders.confirm_shipment` | `{ order_ids: uuid[] }` | `{ confirmed: int, failed: { order_id, message }[] }` | `"발송 확인 n / total"` |
| `shipping.track` | `{ shipment_ids?: uuid[] }`(없으면 미완료 전부, 조직당 200건) | `{ updated: int, delayed: int }` | - |
| `shipping.upload_tracking` | `{ shipment_ids: uuid[] }` | `{ uploaded: int, failed: { shipment_id, message }[] }` | - |
| `market.test` / `market.refresh_token` / `market.health` | `{ market_account_id: uuid }` | `{ ok: bool, expires_at?, metrics? }` | - |

공통 필터 타입(`CollectFilters`): `{ price_krw: [min, max], min_reviews, min_rating, min_margin_pct, max_weight_g, delivery: 'rocket_only' \| 'all', exclude_keywords: string[≤100], exclude_brands: string[≤100], exclude_duplicates: bool, exclude_air_restricted: bool }`.

## 5. 웹훅

### 5.1 수신

| 경로 | 제공자 | 서명·검증 | event_id 출처 | 처리 |
|---|---|---|---|---|
| POST `/api/webhooks/toss` | Toss Payments | 코어 규약(platform-docs `CORE_SPEC.md` 6장) | `eventId`/`paymentKey` | 코어 `webhook_events` 멱등 → 결제 이행 |
| GET `/api/webhooks/ebay/account-deletion` | eBay Marketplace Account Deletion | 챌린지: `challenge_code` + `EBAY_DELETION_VERIFICATION_TOKEN` + 엔드포인트 URL을 SHA-256 → `{ challengeResponse }` 200 | - | 등록 확인용 |
| POST `/api/webhooks/ebay/account-deletion` | 같음 | 요청 서명 헤더 검증(eBay 공개키, 미확인 세부) | `notificationId` | 해당 eBay 사용자 id의 `orders.ship_to` 즉시 삭제(`pii_purged_at`), 연결 계정 `disconnected`, 감사 기록. 200을 3초 안에 반환(처리는 잡) |

eBay는 계정 삭제 알림을 처리하지 않으면 키셋이 비활성화될 수 있고, 알림에는 24시간 안에 2xx로 응답해야 한다([Hookdeck 가이드](https://hookdeck.com/webhooks/platforms/guide-to-ebay-webhooks-features-and-best-practices), 개발서 9.1절). 위 3초 응답은 이 제품의 목표값(제안)이다. POST 서명 헤더 검증 세부는 GS-06-024 착수 시 eBay 공식 문서로 확인한다. Amazon SP-API 알림(SQS/EventBridge)과 Shopee 푸시는 Phase 2이며 MVP는 주기 조회(크론)로 대신한다.

### 5.2 발신

| 이벤트 | 채널 | 내용 |
|---|---|---|
| `order_received` | 이메일(MVP), Slack(P1, D-13) | 마켓, 주문번호, 금액, 발송 기한 |
| `api_error` | 같음 | 계정 토큰 만료·연속 실패 |
| `daily_sales` / `weekly_report` | 이메일 | 전일·주간 매출·순이익 요약 |
| `price_anomaly` | 같음 | `held` 변동 발생 |
| `renewal_notice` | 이메일 | 결제 7일 전 |

설정은 `notification_prefs`(05_DATA_MODEL 2장). 발신은 워커 크론이 하며 외부 웹훅 수신자에게 서명된 POST를 보내는 기능은 Phase 2(`gs` 공개 API와 함께)다.

## 6. 외부 API 어댑터

| 외부 | 호출 위치 | 실패 처리 | 쿼터 |
|---|---|---|---|
| eBay Sell APIs(Inventory, Fulfillment, Account) | 워커 `packages/markets/ebay` | 401 → `refresh` 1회 후 재시도, 실패하면 계정 `token_expired`. 4xx 검증 오류는 재시도 없이 리스팅 `error` | API별 일일 한도(미확인) → 계정 버킷 |
| Amazon SP-API(Listings Items, Orders, Feeds, Sellers) | 워커 `packages/markets/amazon-sp` | 403 토큰 → LWA 재발급. 429 → `x-amzn-RateLimit-Limit` 기준 대기 후 재시도 | 작업별 rate·burst(미확인 값은 스파이크) |
| Shopee Open Platform v2 | 워커 `packages/markets/shopee`(P1) | `error_auth` → 토큰 재발급, 실패 시 `token_expired` | 미확인 |
| 쿠팡 파트너스 검색 API | 워커 `packages/sources/coupang-partners`(P1) | 403 3회 연속 → 해당 조직 키 24시간 중지 + 알림 | 조직 키당 시간당 10회(보수값) |
| 쿠팡 상품 페이지 | 워커 `packages/sources/coupang-url`(사용자가 준 URL 단건만) | `packages/net` 경유(쿠팡 도메인 허용 목록, 15초). 실패·차단 응답이면 재시도 1회 후 해당 행만 실패로 남기고 확장프로그램 담기를 안내. 검색·카테고리 페이지 순회 같은 대량·자동 크롤링은 하지 않는다(01_PRD 6장, 루트 `CLAUDE.md` 5장) | 조직 단위 요청 간격 1초 이상(목록 업로드도 줄마다 단건) |
| LLM 제공자 | 워커 `src/translate` | 체인 다음 제공자로 대체, 전부 실패 → `fail_job` → 코어 자동 환불 | 조직당 동시 2(제안) |
| 환율 API | 워커 `src/cron/fx` | 실패 시 직전 값 유지, 24시간 넘게 갱신 없으면 가격 계산 화면에 경고 | 시간당 1 |
| 운송사 추적 | 워커 `src/shipping` | 실패 시 다음 주기, 7일 갱신 없으면 `exception` 표시 | 미정 |
| Toss Payments | 웹 `app/api/billing` | 코어 규약 | - |

## 7. 오류 코드

| 코드 | 의미 | HTTP | 발생 |
|---|---|---|---|
| GS001 | 상태 전이 위반 | 409 | `globalseller.status_guard`(`domain.sql:107-128`) |
| GS002 | `globalseller` 엔타이틀먼트 없음 | 402 | RPC 3종 |
| GS003 | 플랜 한도 초과(상품 수, 마켓 계정 수, 일괄 등록 항목 수, 멤버 수) | 403 + 업그레이드 안내 | 한도 트리거 2종(`domain.sql:757-816`), `enqueue_collect_job`, Route Handler(일괄 항목·멤버) |
| GS004 | 플랜에 없는 기능(정기 수집 등) | 403 | `enqueue_collect_job`, Route Handler |
| GS005 | 승인 대기(`held`)가 아닌 변동 승인 | 409 | `approve_sync_event` |
| GS006 | 발주를 기록할 수 없는 주문 상태 | 409 | `record_purchase` |
| 23514 | CHECK 위반(마진 순서, 위험 리스팅 전송, 가격 없는 전송 등) | 422 | DB |
| 23503 | 다른 조직 행 참조(복합 FK) | 404 | DB |
| 23505 | 중복(같은 상품·SKU·주문·송장) | 409 | DB |
| 코어 | 42501→403, CR001→402, P0002/PM404→404, 22023/SB001/JB002/PM410→409, PM001/PM409→409 + 운영 알림, OA001→400 | 표 기준 | platform-docs `CORE_SPEC.md` 15장 |
| 앱 `RISK_BLOCKED` | 리스크 검사 차단(항공 제한, 상표권, 제외어) | 422 | `/validate`, 일괄 사전 검증 |
| 앱 `VALIDATION_FAILED` | 마켓 필수 항목 누락 | 422 + `details: { field, market }[]` | `/validate` |
| 앱 `MARKET_ACCOUNT_INVALID` | 다른 조직·연결 해제·토큰 만료 계정 | 409 | 등록·동기화·송장 |
| 앱 `MARKET_EXCHANGE_FAILED` | OAuth 코드 교환 실패 | 302 `?error=exchange` | 콜백 |
| 앱 `EXTENSION_TOKEN_INVALID` | 확장 토큰 서명·만료 오류 | 401 | `/api/extension/items` |
| 앱 `FX_STALE` | 환율이 24시간 넘게 갱신되지 않음 | 200 + 경고(차단하지 않음) | `/api/pricing/preview` |
| 앱 `RATE_LIMITED` | 레이트 리밋 초과 | 429 + `Retry-After` | 전체 |

## 8. 인증 단계 경로

정본 platform-docs `AUTH_ROADMAP.md`. 02_ARCHITECTURE 9장과 같은 규칙이다.

| 경로 | 단계 | 동작 | 가드 |
|---|---|---|---|
| POST `/api/dev/login` | A(로컬 전용) | `{ persona: 'owner'\|'admin'\|'member'\|'viewer'\|'outsider'\|'no_app'\|'suspended' }` → 시드 계정으로 `signInWithPassword` → `finishLogin('globalseller', '/dashboard')` | `AUTH_MODE=mock`이고 Mock 허용 판정이 참일 때만 존재. 그 밖에는 404. `VERCEL_ENV=production`에서 `mock`이면 빌드 실패 |
| GET `/auth/callback` | B·C1 | 코드 교환 → `finishLogin('globalseller', next)` → `next` 화이트리스트(`/dashboard`, `/collect`, `/listings`, `/orders`, `/account/*`) 밖이면 `/dashboard` | `error=callback`·`state` 오류 화면 |
| GET `/auth/naver/start`, `/auth/naver/callback` | C2 브리지 경로만 | `AUTH_ROADMAP.md` 7.2.3절 | `NAVER_AUTH_PATH=bridge`일 때만 |

마켓 OAuth 콜백(`/api/markets/callback/[market]`)은 로그인이 아니라 이미 로그인한 사용자의 마켓 권한 승인이다. 세션이 없으면 `/login?next=/markets/connect`로 보낸다.
