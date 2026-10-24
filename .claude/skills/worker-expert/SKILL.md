---
name: worker-expert
description: >-
  `services/worker`(Node 22 잡 워커 · 크론) · `packages/markets`(MarketAdapter) · `packages/sources`(쿠팡 URL 파서 · 파트너스 API ·
  CSV/XLSX) · `packages/net`(안전 fetch) · `packages/compliance`(리스크 규칙) · `apps/extension`(쿠팡 수집 크롬 확장 MV3) 작업 규약.
  잡 런타임(SKIP LOCKED claim · 하트비트 · 재시도 · 실패 시 환불), 수집 · 번역 · 리스팅 전송 · 기존 리스팅 가져오기 · 동기화 ·
  주문 수집 · 송장/추적 핸들러, 크론, eBay OAuth · Amazon LWA/SP-API · Shopee HMAC 서명과 토큰 갱신, 레이트 리밋 · 429 백오프,
  멱등 키를 만들거나 고칠 때 반드시 먼저 읽을 것. "워커", "잡", "마켓 연동", "어댑터", "동기화", "주문 수집", "확장프로그램" 요청도 여기서 시작한다.
  웹 화면은 nextjs-expert, DB 스키마 · RLS 는 supabase-expert 다.
---

# worker-expert — 워커 · 마켓 연동 · 수집 경로 작업 규약

> **외부 API 주의**: 마켓 · 쿠팡 · 운송사 API 의 엔드포인트, 토큰 수명, 호출 한도, 서명 규칙은 자주 바뀐다.
> 이 스킬의 수치는 "작성 시점에 알려진 값"이며, 코드에 쓰기 전 **작업 시점의 공식 문서로 확인**하고 보고에 URL 을 남긴다.
> 확인하지 못한 값은 상수가 아니라 설정으로 두고 "미확인"으로 보고한다.

## 0. 30초 요약

1. 외부 호출(마켓 · 쿠팡 · LLM · 운송사)과 마켓 토큰 복호화는 워커에서만 한다. 웹은 잡을 등록할 뿐이다.
2. 모든 외부 쓰기에 멱등 키. 외부 id 를 먼저 기록하고, 응답 유실 후 재시도해도 같은 리스팅이 두 번 생기지 않게 한다.
3. 401 → 토큰 갱신 1회 후 재시도, 429 · 5xx → 지수 백오프 + 지터, 검증 오류 → 재시도 없이 `error`.
4. 쿠팡 페이지를 서버에서 대량·자동으로 크롤링하지 않는다. 수집 경로는 사용자가 준 URL 단건 조회(간격 1초 이상) · 파트너스 공식 API · 확장프로그램이 담은 데이터 · 업로드 파일(줄마다 단건 조회)뿐(`01_PRD.md` 6장).
5. 마진 하한 미달 · 급격한 가격 하락은 자동 반영하지 않고 `held`. 가격 계산은 `packages/domain/pricing.ts`만.
6. 금액은 정수(원 · 외화 최소 단위). 이름 · 큐 · 상태 값은 `docs/설계/DESIGN_STRUCTURE.md` 9장 · 5.1절이 정본.

## 1. 요청 판별

| 요청 | 시작 위치 |
|---|---|
| 새 잡 핸들러 · 크론 | `references/conventions.md` §잡 런타임 → `DESIGN_STRUCTURE.md` 9장 → `docs/기획서/04_API.md` 잡 페이로드 |
| 새 마켓 · 마켓 기능 | `references/conventions.md` §MarketAdapter · §마켓별 인증 → `docs/기획서/02_ARCHITECTURE.md` |
| 쿠팡 수집 | `references/conventions.md` §수집 경로 |
| 동기화 규칙 | `references/conventions.md` §동기화 → `docs/기획서/01_PRD.md` 동기화 기능 |
| 확장프로그램 | `references/conventions.md` §확장프로그램(MV3) |
| 이상 동작 · 리뷰 전 | `references/pitfalls.md` |
| 실행 · 검증 | `references/build-and-run.md` |

## 2. 핵심 규칙

- 핸들러는 `services/worker/src/<영역>/handler.ts`, 런타임은 `src/runtime/`, 크론은 `src/cron/`. 공용 인덱스 파일을 만들지 않는다(자동 로드).
- 마켓별 차이는 `packages/markets/<market>/`의 `MarketAdapter` 구현 안에만. 핸들러에 `if (market === 'ebay')` 분기를 쓰지 않는다.
- 외부 응답은 zod 로 검증하고, 원문 전체를 DB · 로그에 저장하지 않는다(필요한 필드만).
- 워커는 service role 이라 RLS 를 우회한다 — 모든 쿼리에 `org_id` 조건을 넣는다.
- 구매자 개인정보는 필요한 필드만 받고 로그에 남기지 않는다. 제한 데이터(예: Amazon 구매자 주소)는 마켓이 요구하는 별도 토큰 절차를 따른다.

## 3. 제출 전 자가 점검

- [ ] 외부 호출에 타임아웃(`AbortSignal.timeout`)과 오류 분류(`retryable` · `auth` · `validation` · `fatal`)가 있는가
- [ ] 외부 쓰기에 멱등 키가 있고, 재시도 시 중복이 생기지 않는가
- [ ] 잡 실패 시 상태 기록 · 크레딧 환불(유료 잡) 경로가 있는가
- [ ] 마켓 토큰 · 키가 로그 · 오류 메시지 · 잡 결과에 없는가
- [ ] 금액이 정수로 계산되는가, `pricing.ts`를 썼는가
- [ ] 확인한 공식 문서 URL 과 "미확인" 외부 사실을 보고에 적었는가

## 4. 참조 파일 지도

| 파일 | 언제 |
|---|---|
| `references/conventions.md` | 잡 런타임 · 어댑터 · 마켓별 인증 · 수집 · 동기화 · 확장프로그램 |
| `references/pitfalls.md` | 이상 동작, 리뷰 전 점검 |
| `references/build-and-run.md` | 실행 · 검증 명령 |
