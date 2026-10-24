# supabase — GlobalSeller OS 데이터베이스

GlobalSeller OS는 단독 Supabase 프로젝트 1개(모놀리스)로 시작한다. 공용 코어 표는 `public` 스키마, 제품 도메인 표는 `globalseller` 스키마에 둔다. 설계 설명은 [`docs/기획서/05_DATA_MODEL.md`](../docs/기획서/05_DATA_MODEL.md), 이름 기준은 [`docs/설계/DESIGN_STRUCTURE.md`](../docs/설계/DESIGN_STRUCTURE.md) 8장.

## 1. 파일과 적용 순서

| 순서 | 파일 | 내용 |
|---|---|---|
| 1 | `migrations/20261025000001_core_lite.sql` | 공용 코어 사본(platform-docs `_platform-core/MONOLITH_CORE_LITE.sql`, affiliate 절만 제거). 신원·조직, 플랜·구독, Toss 결제, 크레딧, OAuth state, 암호화 자격증명, 레이트 리밋, 잡, Storage, AI 계층, 음성 |
| 2 | `migrations/20261025000002_globalseller_domain.sql` | 스키마 `globalseller`: 표 22개, 뷰 2개, RPC 5개, 상태 전이 트리거, RLS, Realtime |
| 3 | `seed.sql` | 앱 행 `globalseller`, 플랜 3종, 크레딧팩 2종, AI 라우팅 기본값, 개발용 환율 |

`supabase db reset`이 1 → 2 → seed 순서로 적용한다(파일 이름 순서 + `seed.sql`).

## 2. 로컬에서 쓰기

```bash
supabase start                       # 로컬 Supabase (Docker)
supabase db reset                    # 마이그레이션 전부 + seed.sql 적용
node scripts/dev/seed-users.mjs --app globalseller   # 개발용 페르소나(인증 Stage A, 05_DATA_MODEL 10장)
```

`supabase/config.toml`의 API 노출 스키마에 `globalseller`를 넣어야 PostgREST로 읽을 수 있다.

```toml
[api]
schemas = ["public", "graphql_public", "globalseller"]
extra_search_path = ["public", "extensions"]
```

## 3. 타입 생성

```bash
supabase gen types typescript --local --schema public,globalseller > apps/web/types/supabase.ts
```

워커(`services/worker`)는 같은 파일을 `packages/domain`을 거쳐 쓴다. 스키마를 바꾸면 타입을 다시 만들고 커밋한다.

## 4. SQL 검사 (Supabase 없이)

platform-docs의 PGlite 검사 도구를 쓴다. pgvector가 필요한 AI 절이 있어 `--vector`를 붙인다.

```bash
cd ../platform-docs/products/_tools-sqlcheck && npm ci
node check.mjs --vector mono \
  ../../../GlobalsellerOS/supabase/migrations/20261025000001_core_lite.sql \
  ../../../GlobalsellerOS/supabase/migrations/20261025000002_globalseller_domain.sql \
  ../../../GlobalsellerOS/supabase/seed.sql
```

세 파일 모두 `OK`여야 한다. 2026-10-25 기준 통과(도메인·seed 두 번 연속 적용도 통과).

## 5. 변경 규칙

| 규칙 | 내용 |
|---|---|
| 기존 파일 수정 금지 | `migrations/`의 이미 있는 번호 파일은 고치지 않는다. 변경은 항상 새 번호 파일(`YYYYMMDDHHMMSS_<설명>.sql`)로 추가한다 |
| 코어 불변 | `20261025000001_core_lite.sql`과 `public` 코어 객체를 ALTER하지 않는다. 코어 변경이 필요하면 platform-docs `_platform-core`에 요청하고 새 번호로 사본을 받는다 |
| 쓰기 권한 | 사용자(authenticated)에게는 SELECT만 준다. 쓰기는 Route Handler·워커(service_role)와 `globalseller` RPC만 |
| 금액 | 원화 `*_krw bigint`, 외화 `*_minor bigint` + `currency`. `numeric`은 환율·비율에만 |
| 상태 | 새 상태 값은 `globalseller.transition_allowed` 표와 check 제약을 같은 마이그레이션에서 함께 바꾼다 |
| 원격 | `supabase db push`는 사람이 승인한 뒤에만. 에이전트는 원격 DB에 쓰지 않는다 |
