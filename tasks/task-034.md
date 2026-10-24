# task-034 배송 추적·건강 지표·토큰 갱신 워커

- **작업 ID**: GS-06-034 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W4 운영(동기화·주문·배송)
- **우선순위 · 규모**: P0 · M
- **선행 작업**: task-024, task-025, task-033
- **담당**: `worker-expert`
- **착수 전 검증**: —
- **변경 후 검증**: review-expert, contract-reviewer
- **기능 ID**: GS-F-045, 047, 048
- **착수 전 결정**: 없음

## 목표

배송 추적·건강 지표·토큰 갱신 워커: `src/shipping/`(운송사 추적 이벤트), 크론 `src/cron/health.ts`(마켓 지표 일별 스냅샷), `src/cron/token-refresh.ts`

## 소유 파일 · 디렉토리

`services/worker/src/shipping/`, `services/worker/src/cron/{health,token-refresh}.ts`

## 참고 문서

- `docs/설계/DESIGN_STRUCTURE.md` 9장
- `docs/기획서/05_DATA_MODEL.md` shipments, market_health_snapshots

## 할 것

- [ ] 추적 핸들러(운송사 2종 MVP: 우체국 EMS·K-Packet, 제안)
- [ ] 지표 스냅샷
- [ ] 토큰 갱신

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- 화면

## 완료 조건

- [ ] 송장 등록 직후 1회 + 1시간 주기 추적, 예상일 초과 시 `delayed`, 지표 스냅샷이 계정당 하루 1행, 토큰 만료 전 갱신 실패 시 계정 `token_expired`와 알림 1건
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
