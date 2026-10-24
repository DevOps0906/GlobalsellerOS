# task-031 동기화 API

- **작업 ID**: GS-06-031 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W4 운영(동기화·주문·배송)
- **우선순위 · 규모**: P0 · S
- **선행 작업**: task-007, task-030
- **담당**: `nextjs-expert`
- **착수 전 검증**: —
- **변경 후 검증**: review-expert, contract-reviewer
- **기능 ID**: GS-F-036~039
- **착수 전 결정**: 없음

## 목표

동기화 API: `/api/sync/{rules,run,events,events/[id]/approve}`

## 소유 파일 · 디렉토리

`apps/web/app/api/sync/`

## 참고 문서

- `docs/설계/DESIGN_STRUCTURE.md` 11.1절, 11.2절
- `docs/기획서/04_API.md` 2장

## 할 것

- [ ] 규칙 조회·저장
- [ ] 즉시 동기화
- [ ] 로그 조회
- [ ] 승인

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- 규칙 엔진(GS-06-030)

## 완료 조건

- [ ] 규칙 편집은 owner/admin만(member 403), 승인은 RPC `approve_sync_event`로 감사 1행, `run`은 계정당 10분 1회 레이트 리밋(제안), `events`는 `market`·유형 필터
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
