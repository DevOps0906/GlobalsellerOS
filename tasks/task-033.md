# task-033 주문·송장 API

- **작업 ID**: GS-06-033 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W4 운영(동기화·주문·배송)
- **우선순위 · 규모**: P0 · M
- **선행 작업**: task-007, task-032
- **담당**: `nextjs-expert`
- **착수 전 검증**: plan-challenger
- **변경 후 검증**: review-expert, security-auditor
- **기능 ID**: GS-F-042~044, 046
- **착수 전 결정**: D-03 (`docs/기획서/01_PRD.md` 8장, 결정 전 착수 금지)

## 목표

주문·송장 API: `/api/orders`, `/[id]/purchase`, `/[id]/claim`, `/confirm-shipment`, `/api/shipments`, `/api/shipments/[id]`

## 소유 파일 · 디렉토리

`apps/web/app/api/orders/`, `apps/web/app/api/shipments/`

## 참고 문서

- `docs/설계/DESIGN_STRUCTURE.md` 11.1절
- `docs/기획서/03_SCREENS_UX.md` 2.5절
- `docs/기획서/04_API.md` 2장

## 할 것

- [ ] 주문 조회(market × status)
- [ ] 발주 기록
- [ ] 클레임
- [ ] 발송 확인 잡
- [ ] 송장 등록·조회

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- 주문 수집(GS-06-032)
- 추적(GS-06-034)

## 완료 조건

- [ ] 발주 기록은 RPC `record_purchase`로 `purchased` 전이 1회(중복 요청 멱등), 원가는 원 정수만 허용, 송장 일괄 업로드 200행에서 형식 오류 행만 거부, viewer 쓰기 403
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
