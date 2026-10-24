# task-018 `MarketScope`·`MarketHealthStrip` 공통 컴포넌트

- **작업 ID**: GS-06-018 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W2 수집
- **우선순위 · 규모**: P0 · M
- **선행 작업**: task-014, task-016
- **담당**: `nextjs-expert`
- **착수 전 검증**: —
- **변경 후 검증**: review-expert, contract-reviewer
- **기능 ID**: GS-F-034, 045
- **착수 전 결정**: 없음

## 목표

`MarketScope`·`MarketHealthStrip` 공통 컴포넌트: 마켓 탭 바(전체·계정들·＋마켓 추가), 지표 띠, URL `market` 동기화, 빈 상태, 탭 배지(RPC `market_tab_counts`)

## 소유 파일 · 디렉토리

`apps/web/components/market-scope/`

## 참고 문서

- `docs/설계/DESIGN_STRUCTURE.md` 3장
- `docs/기획서/03_SCREENS_UX.md` 3.4절, 5장
- `prototype/index.html:2820` (탭 바 원본)

## 할 것

- [ ] 탭 바와 지표 띠 슬롯 API
- [ ] URL 동기화 훅
- [ ] 빈 상태
- [ ] Realtime 배지 갱신

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- 화면별 지표 내용(GS-06-035~037)

## 완료 조건

- [ ] 탭 변경 시 URL `market` 갱신·새로고침 후 유지, 계정 0개면 '전체'와 '＋ 마켓 추가'만 보이고 03장 5장 빈 상태 문구, 토큰 만료 계정 탭에 '!' 배지, 지표 띠 슬롯은 화면이 주입
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
