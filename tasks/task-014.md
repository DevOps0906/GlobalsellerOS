# task-014 디자인 시스템 2단계

- **작업 ID**: GS-06-014 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W1-D 디자인 시스템
- **우선순위 · 규모**: P0 · M
- **선행 작업**: task-001, task-006
- **담당**: `nextjs-expert`
- **착수 전 검증**: —
- **변경 후 검증**: review-expert
- **기능 ID**: GS-F-007
- **착수 전 결정**: 없음

## 목표

디자인 시스템 2단계: `styles/tokens.css`(`@theme`, 라이트·다크) + 기본 컴포넌트(`components/ui/`) + `/dev/components` 미리보기

## 소유 파일 · 디렉토리

`apps/web/styles/tokens.css`, `apps/web/components/ui/`, `apps/web/app/dev/components/`

## 참고 문서

- `docs/기획서/08_DESIGN_SYSTEM.md`
- `docs/디자인/TOKENS_INVENTORY.md`

## 할 것

- [ ] 토큰 파일
- [ ] 기본 컴포넌트(07장 2.1절 이름: `Button`, `Card`, `KpiCard`, `StatusPill`, `MarketTag`, `SegmentTabs`, `SelectCard`, `ChoiceChip`, `Stepper`, `FormField`, `TokenInput`, `FileDropzone`, `Switch`, `SecretField`, `ProgressRow`, `QuotaMeter`, `Callout`, `Dialog`, `DataTable`)
- [ ] 미리보기 페이지

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- 화면 조립(W2 이후)

## 완료 조건

- [ ] 08장 토큰 전부가 `@theme` 변수로 존재, 컴포넌트에 hex·`bg-[#...]` 0건, `/dev/components`에서 08장 컴포넌트 목록 전부 라이트·다크로 렌더, 운영 빌드에서 `/dev/*` 404
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
