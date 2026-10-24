# task-001 모노레포·웹 앱 골격

- **작업 ID**: GS-06-001 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W0 기반
- **우선순위 · 규모**: P0 · M
- **선행 작업**: 없음
- **담당**: `nextjs-expert`
- **착수 전 검증**: —
- **변경 후 검증**: review-expert
- **기능 ID**: GS-F-006, 007
- **착수 전 결정**: 없음

## 목표

모노레포·웹 앱 골격: pnpm 워크스페이스, `apps/web` Next.js 16 App Router, TypeScript strict, ESLint, Tailwind CSS v4 설정, 라우트 그룹 `(app)`·`(auth)`·`(marketing)` 빈 페이지

## 소유 파일 · 디렉토리

`package.json`(루트), `pnpm-workspace.yaml`, `tsconfig.base.json`, `apps/web/{package.json,next.config.ts,tsconfig.json,app/layout.tsx,app/globals.css,eslint.config.mjs}`

## 참고 문서

- `docs/설계/DESIGN_STRUCTURE.md` 1장, 7장
- `docs/기획서/02_ARCHITECTURE.md` 1장
- `CLAUDE.md` 4장

## 할 것

- [ ] pnpm 워크스페이스(`apps/*`, `services/*`, `packages/*`) 구성
- [ ] `apps/web` Next.js 16 App Router 생성, React 19, TypeScript strict
- [ ] Tailwind CSS v4 CSS 우선 설정(`@import "tailwindcss"`, `@theme` 자리)
- [ ] docs/설계/DESIGN_STRUCTURE.md 1장 라우트를 빈 페이지로 생성(`(app)` 그룹)
- [ ] ESLint `no-explicit-any`, `no-console` 규칙

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- 디자인 토큰 값 입력(GS-06-014)
- 셸·GNB 구현(GS-06-017)
- 인증(GS-06-007)

## 완료 조건

- [ ] `pnpm -F web build` 통과, `tsc --noEmit` 0 오류, `latest` 태그 의존성 0건, `tailwind.config.js` 0개(`@import "tailwindcss"`만), `/dashboard` 등 S-01~S-10 라우트가 빈 페이지로 200
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
