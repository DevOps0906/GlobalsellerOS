# task-032 주문 워커 `src/orders/`

- **작업 ID**: GS-06-032 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W4 운영(동기화·주문·배송)
- **우선순위 · 규모**: P0 · M
- **선행 작업**: task-024, task-025, task-010
- **담당**: `worker-expert`
- **착수 전 검증**: plan-challenger
- **변경 후 검증**: review-expert, security-auditor, contract-reviewer
- **기능 ID**: GS-F-040, 043, 044
- **착수 전 결정**: D-11 (`docs/기획서/01_PRD.md` 8장, 결정 전 착수 금지)

## 목표

주문 워커 `src/orders/`: 마켓별 신규 주문 수집(10분), `received`→`purchase_pending`, 발송 확인 일괄 전송, 구매자 개인정보 최소 저장

## 소유 파일 · 디렉토리

`services/worker/src/orders/`

## 참고 문서

- `docs/설계/DESIGN_STRUCTURE.md` 5.1절, 9장
- `docs/기획서/01_PRD.md` 6장
- `docs/기획서/05_DATA_MODEL.md` orders

## 할 것

- [ ] 주문 수집
- [ ] 상태 전이
- [ ] 발송 확인 전송
- [ ] 개인정보 최소화

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- 발주 기록(GS-06-033)

## 완료 조건

- [ ] 같은 마켓 주문 재수집 시 새 행 0, 가짜 마켓 주문 5건 → `purchase_pending` 5건, 발송 확인 실패는 주문별 오류로 남고 나머지는 계속, 구매자 주소는 배송에 필요한 필드만·배송 완료 90일 후 마스킹(제안)
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
