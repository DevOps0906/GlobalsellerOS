# task-041 S-11 마켓 추가 마법사 화면

- **작업 ID**: GS-06-041 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W5 수익·계정·마법사·결제
- **우선순위 · 규모**: P0 · M
- **선행 작업**: task-018, task-023, task-040
- **담당**: `nextjs-expert`
- **착수 전 검증**: —
- **변경 후 검증**: review-expert, contract-reviewer
- **기능 ID**: GS-F-059~062
- **착수 전 결정**: 없음

## 목표

S-11 마켓 추가 마법사 화면: 인터셉트 라우트 모달 5단계, 진단 칩, 추천 카드, 연결(OAuth·API 키), 초기 설정, 완료 후 운영 화면 탭 생성

## 소유 파일 · 디렉토리

`apps/web/app/(app)/@modal/(.)markets/connect/`, `apps/web/app/(app)/markets/connect/`, `apps/web/components/markets/`(`WizardDialog`, `MarketRecommendCard`)

## 참고 문서

- `docs/기획서/03_SCREENS_UX.md` 2.6절, 3.11절
- `docs/설계/DESIGN_STRUCTURE.md` 4장

## 할 것

- [ ] 모달 라우트
- [ ] 5단계 패널
- [ ] 진입점 연결

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- OAuth 처리(GS-06-023)

## 완료 조건

- [ ] 03장 3.11절 단계별 요소 전부, 권한 승인 전 '다음' 비활성, Esc·배경 클릭 닫기, 직접 URL 진입 시 전체 화면, 완료 후 S-04~S-06에 새 탭(Realtime), 진입점 3곳에서 열림
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
