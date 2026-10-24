---
name: nextjs-expert
description: >-
  `apps/web` (GlobalSeller OS 대시보드 — Next.js 16 App Router · React 19 · TypeScript · Tailwind CSS v4 · shadcn/ui) 작업 규약.
  셸(GNB · 상단 탭 · 모바일 가로 메뉴) · 화면 S-01~S-11 · 마켓 탭 공통 컴포넌트 MarketScope · 마켓 추가 마법사 모달 ·
  Route Handler · Supabase SSR 세션(@supabase/ssr) · proxy.ts · 디자인 토큰 · 반응형 3구간을 만들거나 고칠 때 반드시 먼저 읽을 것.
  "화면", "대시보드", "주문 관리 화면", "마켓 탭", "마법사" 요청도 여기서 시작한다.
  DB 스키마 · RLS 는 supabase-expert, 워커 · 마켓 어댑터 · 확장프로그램은 worker-expert 다. Pages Router 로 만들지 않는다.
---

# nextjs-expert — `apps/web` 작업 규약

> **버전 주의**: Next.js · React · @supabase/ssr · Tailwind CSS 는 메이저 변경이 잦다. 새 코드를 쓰기 전 `package.json`의 실제 버전과
> 공식 문서를 확인한다. 확인하지 못한 항목은 "미확인"으로 보고한다.

## 0. 30초 요약

1. 서버 컴포넌트가 기본이다. 상호작용 · 브라우저 API · 상태가 필요한 말단만 `"use client"`.
2. 브라우저는 Route Handler 만 부른다. 마켓 API · LLM · 쿠팡 호출과 마켓 토큰 복호화는 워커 몫이다.
3. 비밀은 서버에만. `NEXT_PUBLIC_*`는 브라우저에 노출된다. service role 키는 Route Handler 서버 코드에서도 꼭 필요한 곳만.
4. 데이터 접근의 최종 방어선은 RLS(supabase-expert)다. 클라이언트 검사는 UX 일 뿐이다.
5. 화면 ID · 라우트 · 상태 값은 `docs/설계/DESIGN_STRUCTURE.md`, 화면 명세는 `docs/기획서/03_SCREENS_UX.md`, 토큰은 `08_DESIGN_SYSTEM.md`가 정본이다.
6. 근거(task 번호 · 기능 ID `GS-F-###` · 기획서 장)를 보고에 인용한다.

## 1. 요청 판별

| 요청 | 시작 위치 |
|---|---|
| 새 화면 | `references/conventions.md` §라우트 → `DESIGN_STRUCTURE.md` 1장 표 → `03_SCREENS_UX.md` 해당 화면 → `prototype/index.html` 해당 요소 |
| 마켓 탭 화면(S-04 · S-05 · S-06) | `references/conventions.md` §MarketScope → `DESIGN_STRUCTURE.md` 3장 |
| 마켓 추가 마법사(S-11) | `references/conventions.md` §모달 라우트 → `DESIGN_STRUCTURE.md` 4장 |
| 인증 · 보호 라우트 | `references/conventions.md` §인증 세션 → supabase-expert 정책 확인 |
| 데이터 로딩 · 캐싱 이상 | `references/pitfalls.md` |
| Route Handler | `references/conventions.md` §Route Handler → `docs/기획서/04_API.md` |
| 실행 · 검증 | `references/build-and-run.md` |

## 2. 핵심 규칙

- 라우트 파일 규약(`page` · `layout` · `loading` · `error` · `route`)을 따른다. 미들웨어는 `proxy.ts`(Next 16).
- `cookies()` · `headers()` · `params` · `searchParams`는 await 한다(Next 16).
- 폼은 서버 측 검증(zod)이 정본, 클라이언트 검증은 보조. 에러 · 로딩 · 빈 상태를 항상 처리한다.
- Route Handler 는 입력을 신뢰하지 않는다 (zod 검증 · 세션 · 조직 · 역할 확인). 요청 바디의 plan · role · price 값은 무시한다.
- 스타일 값은 `styles/tokens.css`의 `@theme` 토큰으로만 (hex · 임의 값 직접 사용 금지). Tailwind CSS v4 문법만.
- 금액은 정수(원 · 외화 최소 단위)로 받고 표시만 포맷한다. 숫자는 JetBrains Mono, 탭 정렬(`tabular-nums`).

## 3. 제출 전 자가 점검

- [ ] lint · typecheck · test · build 결과를 보고했는가 (미실행이면 "미검증")
- [ ] 비밀 값이 클라이언트 번들 · 로그에 없는가, 웹 코드에 마켓 API · LLM 호출이 없는가
- [ ] 375 · 1024 · 1440 너비에서 확인했는가 (모바일 가로 메뉴 포함)
- [ ] 에러 · 로딩 · 빈 상태가 처리됐는가
- [ ] 상단 탭 · GNB · 모바일 메뉴 선택 상태가 라우트 하나로 함께 바뀌는가
- [ ] 근거를 인용했는가

## 4. 참조 파일 지도

| 파일 | 언제 |
|---|---|
| `references/conventions.md` | 새 화면 · 마켓 탭 · 모달 · 인증 · Route Handler |
| `references/pitfalls.md` | 이상 동작, 리뷰 전 점검 |
| `references/build-and-run.md` | 실행 · 검증 명령 |
