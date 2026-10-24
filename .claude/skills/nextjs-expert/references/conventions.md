# nextjs-expert — conventions

> 작성 시점 기준 일반 규약. 프로젝트의 실제 버전 · 기존 코드가 우선한다. 불일치는 보고한다.

## 라우트

- `apps/web/app/` 아래 폴더 = 경로. 화면 목록 · 라우트 · 쿼리는 `docs/설계/DESIGN_STRUCTURE.md` 1장 표를 따른다
  (`/dashboard`, `/collect?tab=`, `/listings?tab=`, `/sync?market=`, `/orders?market=&status=`, `/shipping?market=`, `/profit`,
  `/settings/integrations`, `/account/[tab]`, `/markets/connect`).
- 로그인 필요 영역은 `app/(app)/`, 공개 영역(로그인 · 랜딩)은 `app/(auth)/` · `app/(marketing)/` 라우트 그룹으로 분리한다.
- 하위 탭 · 마켓 선택은 **쿼리 문자열**로 표현해 새로고침 · 공유 · 뒤로 가기가 동작하게 한다. 클라이언트 상태에만 두지 않는다.
- 로딩 · 에러 경계는 라우트 단위로 둔다.
- GNB 메뉴 순서는 `packages/domain`의 nav 상수를 읽는다(프로토타입 순서와 같음). 화면 코드에 메뉴를 하드코딩하지 않는다.

## 셸

- 상단 탭 · 좌측 GNB · 모바일 가로 메뉴는 **현재 라우트 하나**로 선택 상태를 계산한다 (프로토타입 `data-view` 동작과 같음).
- 사이드바 마켓 칩 → `/account/markets`, 상단 알림 → `/orders`, 아바타 → `/account/profile`.

## MarketScope (S-04 · S-05 · S-06)

- 세 화면은 같은 서버 컴포넌트 `MarketScope`를 쓴다. 탭 = 연결된 `market_accounts` 행(연결 순서) + `전체` + `＋마켓 추가`.
- 선택 값은 `?market=all|<market_account_id>`. 이 값 하나로 지표 띠 · KPI · 목록 · 마켓 전용 규칙을 서버에서 다시 조회한다.
- 탭 배지 숫자는 RPC `market_tab_counts`(supabase-expert) 결과를 쓴다. 화면에서 행을 세지 않는다.
- 마켓 전용 기능(예: Amazon 가격 보호, eBay 품절 리스팅 유지, Shopee 토큰 갱신)은 마켓 코드로 분기하는 대신 `packages/domain`의 마켓 카탈로그 기능 플래그를 읽는다.
- S-05 상태 그룹(발주 대기 · 배대지 · 발송됨 · 취소·반품)은 `DESIGN_STRUCTURE.md` 5.1절 매핑 그대로. `?status=`와 `?market=`은 함께 적용된다.

## 모달 라우트 (S-11 마켓 추가 마법사)

- 인터셉트 라우트 `app/(app)/@modal/(.)markets/connect/`와 전체 페이지 `app/(app)/markets/connect/`를 함께 둔다(새로고침 시 전체 페이지).
- 단계는 `?step=1..5&market=<code>`. 1단계 답변은 `/api/markets/readiness`로 저장, 2단계 점수는 `packages/domain/readiness.ts`로 계산(화면에 공식 하드코딩 금지).
- 3단계 OAuth 는 `/api/markets/connect/start` → 마켓 → `/api/markets/callback/[market]` → `?step=4`로 돌아온다. 권한 승인 전에는 "다음"을 비활성.
- 모달은 `alert` · `confirm`을 쓰지 않는다. ESC · 바깥 클릭 닫기, 포커스 가두기, `aria-modal`.

## 서버/클라이언트 경계

- 기본은 서버 컴포넌트. `"use client"`는 이벤트 · 상태 · 브라우저 API 가 필요한 최소 컴포넌트에만.
- 서버에서 클라이언트로 넘기는 props 는 직렬화 가능한 값만. 금액은 정수 그대로.
- 서버 전용 모듈(비밀 · DB)을 클라이언트 모듈에서 import 하지 않는다 (`server-only`).

## 인증 세션 (Supabase)

- 쿠키 기반 세션 클라이언트를 서버/브라우저용으로 구분해 만든다 (`@supabase/ssr` — 팩토리 이름은 버전 확인).
- 보호 라우트 판단은 서버(`proxy.ts` + 레이아웃)에서 한다. 클라이언트 상태만으로 보호하지 않는다.
- 사용자는 자기 조직(`org_id`)만 본다. 화면 필터가 아니라 RLS 가 막아야 한다.
- 인증 단계(Mock → Google → 카카오·네이버)는 `docs/기획서/01_PRD.md`와 개발서의 인증 장을 따른다. Mock 로그인(`/api/dev/login`)은 로컬 전용.

## Route Handler

- 경로 · 메서드는 `DESIGN_STRUCTURE.md` 11.1절, 요청/응답 · 오류 코드는 `docs/기획서/04_API.md`가 정본이다. 필드를 추정하지 않는다.
- 순서: zod 검증 → 세션 · 조직 · 역할 확인 → (유료 작업이면) 크레딧 선차감 → 잡 등록(`jobs`) → 202 + 잡 id. 실패 시 환불은 코어 규약.
- 마켓 API 호출은 연결 테스트 · OAuth 콜백 토큰 교환만 예외로 서버에서 한다. 그 외는 잡으로 워커에 넘긴다.
- 오류 응답을 한 곳에서 화면 문구로 바꾼다 (SQLSTATE `GS0##` → HTTP · 문구 표는 04 오류 장).

## 반응형

- 구간: 모바일 ≤767px · 태블릿 768–1199px · 데스크탑 ≥1200px.
- 제목 · KPI · 본문 글자 크기와 GNB 폭은 `DESIGN_STRUCTURE.md` 2장 표 값을 토큰(`--fs-*`)으로 둔다.
- 모바일은 GNB · 상단 탭을 숨기고 상단 가로 스크롤 메뉴를 보인다. 표는 카드 안 가로 스크롤.
