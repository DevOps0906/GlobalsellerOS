# task-017 대시보드 셸

- **작업 ID**: GS-06-017 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W2 수집
- **우선순위 · 규모**: P0 · M
- **선행 작업**: task-007, task-016
- **담당**: `nextjs-expert`
- **착수 전 검증**: —
- **변경 후 검증**: review-expert
- **기능 ID**: GS-F-006, 007
- **착수 전 결정**: 없음

## 목표

대시보드 셸: `(app)/layout.tsx`, 헤더(로고·브레드크럼·상단 탭 5개·알림·테마·아바타), 좌측 GNB(메뉴·마켓 칩·사용자 카드), 모바일 가로 메뉴, 라우트 기반 선택 동기화, 배지 숫자

## 소유 파일 · 디렉토리

`apps/web/app/(app)/layout.tsx`, `apps/web/components/shell/`(`AppTopbar`, `TopTabs`, `AppSidebar`, `NavItem`, `MarketChip`, `SidebarUserCard`, `MobileNav`), `apps/web/components/layout/`

## 참고 문서

- `docs/기획서/03_SCREENS_UX.md` 8장
- `docs/설계/DESIGN_STRUCTURE.md` 2장
- `prototype/index.html:1298-1390`

## 할 것

- [ ] 셸 레이아웃
- [ ] `packages/domain/nav.ts` 정의 사용
- [ ] 배지 숫자 서버 조회
- [ ] 모바일 메뉴 선택 항목 가운데 스크롤

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- 화면 본문
- nav 정의 변경(GS-06-003)

## 완료 조건

- [ ] 상단 탭·GNB·모바일 메뉴가 같은 라우트에서 함께 선택됨(E2E), 375·1024·1440 폭에서 본문 가로 넘침 0, GNB 순서가 03장 8.2절과 같음, 마켓 칩 → `/account/markets`
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
