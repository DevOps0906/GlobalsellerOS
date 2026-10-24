# supabase-expert — conventions

> 프로젝트의 실제 설정 · 기존 마이그레이션이 우선한다. 불일치는 보고한다.

## 마이그레이션

- 위치 `supabase/migrations/`. 파일명은 CLI 가 만드는 타임스탬프 접두(`YYYYMMDDHHMMSS_<이름>.sql`)를 따른다.
  첫 두 파일은 공용 코어 lite(`..._core_lite.sql`, platform-docs `_platform-core/MONOLITH_CORE_LITE.sql` 사본)와 도메인(`..._globalseller_domain.sql`)이다.
- 한 마이그레이션 = 하나의 의도 (테이블 생성 / 정책 추가 / 인덱스 추가). 섞지 않는다.
- 이미 있는 파일은 수정하지 않는다. 고칠 때는 새 마이그레이션으로. 코어 lite 사본도 고치지 않는다(코어 변경은 platform-docs 에 요청).
- 도메인 스키마는 `globalseller`. 테이블 · 컬럼 이름은 `05_DATA_MODEL.md`와 `DESIGN_STRUCTURE.md` 8장 표와 같게 쓴다.
- 앱 레지스트리 행 id 는 `globalseller`, 플랜 코드 · 한도 키는 `01_PRD.md` 요금 장과 같게 시드한다.

## RLS

- 테이블 생성과 같은 마이그레이션에서 RLS 를 켠다.
- 기본 정책: `is_org_member(org_id)`로 읽기, 쓰기는 `has_org_role(org_id, <역할>)`. 정책 조건 컬럼(`org_id`)에는 인덱스.
- 역할: 소유자 · 관리자 · 편집자 · 뷰어(코어 `org_members.role` 값 확인). 뷰어는 쓰기 정책에 포함하지 않는다.
- update 정책은 using 과 with check 를 모두 쓴다 (다른 조직으로 옮기기 방지).
- 사용자가 고칠 수 있는 메타데이터를 권한 근거로 쓰지 않는다.
- service role 은 RLS 를 우회한다 — 워커 · 서버 코드에서만, 그래서 워커 쿼리는 항상 `org_id`를 조건에 넣는다.
- 워커만 쓰는 테이블 · 컬럼(예: `sync_events` 반영 결과, `market_health_snapshots`)은 사용자 세션 쓰기 정책을 두지 않는다.

## 중복 방지와 동시성

- `orders`: `(market_account_id, external_order_id)` 고유. 같은 주문을 다시 수집하면 갱신만 한다.
- `purchases`: 주문당 활성 발주 1건(부분 고유 인덱스). `record_purchase`는 조건부 갱신(`update orders ... where status = 'purchase_pending' returning`)으로 한 번만 성공.
- `listings`: `(market_account_id, external_id)` 고유(외부 id 가 있을 때), 전송 멱등 키 컬럼 고유.
- `sync_events`: `(listing_id, source_snapshot_hash)` 같은 변동을 두 번 만들지 않게.
- 잡은 코어 `jobs`(SKIP LOCKED) 규약을 따르고, 도메인에 별도 큐 테이블을 만들지 않는다.

## 금액

- 원화: `bigint` 원 단위, 이름 끝 `_krw` (`cost_krw`, `shipping_krw`).
- 외화: `bigint` 최소 단위(`price_minor`, `fee_minor`) + `currency char(3)` check.
- 환율: `numeric(18,6)` (1 외화 단위당 원). 마진율: `numeric(5,2)`.

## 뷰와 RPC

- `v_profit_monthly`: 월 · 마켓 계정별 매출 · 원가 · 수수료 · 배송비 · 순이익. `security_invoker = true`로 RLS 를 따르게 한다.
- `market_tab_counts(screen text)`: 화면(`sync` · `orders` · `shipping`)별 마켓 계정 탭 배지 숫자.
- RPC 이름 · 인자는 `DESIGN_STRUCTURE.md` 11.2절과 `04_API.md`가 정본. `security definer` 함수는 `search_path`를 고정하고 시작부에서 조직 권한을 확인한다.

## 개인정보

- 구매자 이름 · 주소 · 전화는 `orders` 본문과 분리된 컬럼(또는 테이블)에 두고, 보존 기간(`01_PRD.md` 6장)이 지나면 파기하는 함수 · 크론 대상이 되게 한다.
- 로그 · 감사 행에 구매자 정보 원문을 넣지 않는다.

## 타입 · 시드

- DB 변경 후 웹 타입을 재생성한다(`apps/web/types/supabase.ts`). 생성 파일은 직접 수정하지 않는다.
- 시드는 개발용 페르소나 · 플랜 · 가짜 마켓 계정만. 실제 개인정보 · 키 · 주문번호를 넣지 않는다.
