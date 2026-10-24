---
name: supabase-expert
description: >-
  `supabase/` (Postgres 공용 코어 표 + 스키마 `globalseller` · RLS · Auth · Realtime · Storage · RPC · 마이그레이션) 작업 규약.
  수집 상품 · 마켓 계정 · 리스팅 · 일괄 등록 · 동기화 규칙/이벤트 · 환율 · 주문 · 발주 · 배송 · 건전성 스냅샷 · 여건 진단 · 알림 설정 테이블,
  조직별 격리 정책, RPC · 뷰, 시드, 타입 생성, 로컬 Supabase 를 만들거나 고칠 때 반드시 먼저 읽을 것.
  "스키마", "마이그레이션", "RLS", "정책", "RPC", "시드" 요청도 여기서 시작한다.
  웹 화면은 nextjs-expert, 워커 소비 코드는 worker-expert 다. 기존 마이그레이션 파일과 공용 코어 표는 수정하지 않는다.
---

# supabase-expert — `supabase/` 작업 규약

> **버전 주의**: Supabase CLI · 플랫폼 기능은 빠르게 바뀐다. 명령 · 설정 키는 `supabase --help`와 공식 문서로 확인한다.
> 확인하지 못한 항목은 "미확인"으로 보고한다.

## 0. 30초 요약

1. 모든 테이블은 RLS 를 켠다. 격리 단위는 조직(`org_id`), 판정은 코어 헬퍼(`is_org_member` · `has_org_role`). 정책 의도를 주석으로 남긴다.
2. 스키마 변경은 새 번호 마이그레이션 파일로만. 기존 파일과 공용 코어 표(`profiles` · `organizations` · `plans` · `credit_ledger` · `jobs` · `encrypted_credentials` 등)는 수정하지 않는다.
3. 금액: 원화 `bigint` 원 단위(`_krw`), 외화 `bigint` 최소 단위 + `currency`, 환율 `numeric(18,6)`. `float` 금지.
4. 마켓 토큰 · API 키는 `encrypted_credentials`에만. 도메인 테이블은 참조 id 만.
5. 원격 DB 적용 · 삭제는 실행하지 않고 제시만 한다.
6. 테이블 · 정책 정본은 `docs/기획서/05_DATA_MODEL.md`, 이름 · 상태 값은 `docs/설계/DESIGN_STRUCTURE.md` 8장 · 5.1절, RPC 는 11.2절.

## 1. 요청 판별

| 요청 | 시작 위치 |
|---|---|
| 새 테이블 · 컬럼 | `05_DATA_MODEL.md` 테이블 장 → `references/conventions.md` §마이그레이션 |
| 권한 · 정책 | `05_DATA_MODEL.md` RLS 장 → `references/conventions.md` §RLS |
| 주문 · 발주 · 리스팅 외부 id 중복 | `references/conventions.md` §중복 방지와 동시성 |
| 수익 집계 · 탭 배지 | `references/conventions.md` §뷰와 RPC |
| 구매자 개인정보 | `references/conventions.md` §개인정보 |
| 로컬 실행 · 검증 | `references/build-and-run.md` |

## 2. 핵심 규칙

- 정책은 동작별(select/insert/update/delete)로 나누고, 호출 주체(사용자 세션 · 확장 토큰 경유 Route Handler · service role 워커)를 명시한다.
- 상태 컬럼은 `DESIGN_STRUCTURE.md` 5.1절 값으로 check 제약을 건다. 값을 바꾸면 웹 · 워커가 함께 바뀌어야 한다(contract-reviewer 대상).
- 파괴적 변경은 영향 범위(생성 타입 · 웹 쿼리 · 워커 핸들러 · 진행 중 잡 페이로드)와 되돌리기 방법을 적는다.
- 정책 · 스키마 변경 후 nextjs-expert · worker-expert 에게 넘길 항목을 남긴다.

## 3. 제출 전 자가 점검

- [ ] 새 테이블에 RLS 가 켜져 있고 정책 의도가 설명됐는가
- [ ] 같은 조직 / 다른 조직 / 비로그인 / 뷰어 쓰기 성공 · 거부 시나리오를 적었는가
- [ ] `supabase db reset`으로 처음부터 재현되는가 (미실행이면 "미검증")
- [ ] 금액 컬럼이 정수(+ `currency`)인가, 평문 키 컬럼이 없는가
- [ ] 중복 위험 테이블에 고유 제약이 있는가
- [ ] 키 · 시크릿 · 실제 개인정보가 파일 · 시드 · 로그에 없는가

## 4. 참조 파일 지도

| 파일 | 언제 |
|---|---|
| `references/conventions.md` | 마이그레이션 · RLS · 중복 방지 · 뷰 · 개인정보 |
| `references/pitfalls.md` | 이상 동작, 리뷰 전 점검 |
| `references/build-and-run.md` | 로컬 실행 · 검증 명령 |
