# task-028 등록·가져오기 워커

- **작업 ID**: GS-06-028 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W3 등록·번역·가격
- **우선순위 · 규모**: P0 · M
- **선행 작업**: task-010, task-011, task-027
- **담당**: `worker-expert`
- **착수 전 검증**: plan-challenger
- **변경 후 검증**: review-expert, contract-reviewer
- **기능 ID**: GS-F-030, 033, 062
- **착수 전 결정**: 없음

## 목표

등록·가져오기 워커: `src/listing/`(어댑터로 전송, `queued`→`submitting`→`live`/`error`, 마켓 한도 대기열), `src/listing-import/`(마법사 4단계 기존 리스팅 읽기 전용 가져오기)

## 소유 파일 · 디렉토리

`services/worker/src/listing/`, `services/worker/src/listing-import/`

## 참고 문서

- `docs/설계/DESIGN_STRUCTURE.md` 4장, 5.1절, 9장
- `docs/기획서/04_API.md` 잡 페이로드 계약

## 할 것

- [ ] 전송 핸들러
- [ ] 가져오기 핸들러(쓰기 0)
- [ ] 배치 집계

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- 어댑터 내부 수정(소유 작업에 요청)

## 완료 조건

- [ ] 가짜 마켓으로 일괄 44건 전송 시 상태 전이가 DS 5.1절대로만 일어남, 마켓 `rate_limit`이면 대기 후 재개(실패로 세지 않음), 가져오기는 마켓에 쓰기 호출 0건, 실패 항목 원문 메시지 저장
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
