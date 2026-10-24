# task-010 워커 런타임

- **작업 ID**: GS-06-010 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W1 인증·도메인·워커 기반
- **우선순위 · 규모**: P0 · M
- **선행 작업**: task-002, task-003
- **담당**: `worker-expert`
- **착수 전 검증**: plan-challenger
- **변경 후 검증**: review-expert, contract-reviewer
- **기능 ID**: GS-F-033
- **착수 전 결정**: D-10 (`docs/기획서/01_PRD.md` 8장, 결정 전 착수 금지)

## 목표

워커 런타임: 잡 claim 루프(SKIP LOCKED), 핸들러 자동 로드(`src/<영역>/handler.ts`), 조직별 동시성, 하트비트·취소, 크론 스케줄러와 환율 크론(`src/cron/fx.ts`)

## 소유 파일 · 디렉토리

`services/worker/{package.json,tsconfig.json}`, `services/worker/src/runtime/`, `services/worker/src/cron/{index,scheduler,fx}.ts`

## 참고 문서

- `docs/설계/DESIGN_STRUCTURE.md` 9장
- `docs/기획서/02_ARCHITECTURE.md` 잡과 워커 절
- `docs/기획서/04_API.md` 잡 페이로드 계약

## 할 것

- [ ] claim·heartbeat·complete·fail 루프
- [ ] 핸들러 자동 로드 규약
- [ ] 크론 스케줄러(fx, sync, orders, tracking, token_refresh, health)
- [ ] 환율 크론 구현(나머지 크론은 각 작업이 핸들러 제공)

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- 영역 핸들러 구현(각 작업 소유)
- 코어 `jobs` 표 변경

## 완료 조건

- [ ] 같은 잡을 워커 2개가 동시에 잡지 않음(동시성 테스트), 워커 재시작 후 진행 중 잡 재개, 조직당 동시 실행 상한 지킴, 크론 6종(DS 9장) 등록, 환율 실패 시 직전 값 유지·`fx_rates` 새 행 0
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
