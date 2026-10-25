# task-040 마켓 추가 마법사 점수 `readiness.ts`

- **작업 ID**: GS-06-040 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W5 수익·계정·마법사·결제
- **우선순위 · 규모**: P0 · S
- **선행 작업**: task-003
- **담당**: `sub-agent-1`
- **착수 전 검증**: —
- **변경 후 검증**: review-expert, test-writer
- **기능 ID**: GS-F-059, 060
- **착수 전 결정**: 없음

## 목표

마켓 추가 마법사 점수 `readiness.ts`: 진단 7문항 × 마켓 카탈로그 → 적합도(3~97)·상태 5종·준비 필요 항목·팁

## 소유 파일 · 디렉토리

`packages/domain/readiness.ts`, `packages/domain/readiness.test.ts`

## 참고 문서

- `docs/설계/DESIGN_STRUCTURE.md` 4장
- `prototype/index.html:4163-4330` (마법사 원본 스크립트 mkEval)
- `docs/설계/DESIGN_STRUCTURE.md` 4.1절 (7문항 답변 값·기본 선택 — DB 제약 `readiness_answers_values_check`와 같게)

## 할 것

- [ ] 점수 함수
- [ ] 상태 판정
- [ ] 스냅샷 테스트

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- 카탈로그 값 변경(GS-06-003)
- 화면

## 완료 조건

- [ ] 프로토타입 동작과 같은 결과(기본 답변에서 바로 연결 가능 마켓·순서 스냅샷), 사업자 없음 → 사업자 필요 마켓이 '준비 후 연결', 연결된 계정은 '연결됨'으로 아래 정렬
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
