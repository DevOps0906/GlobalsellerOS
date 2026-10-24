# task-027 등록 API

- **작업 ID**: GS-06-027 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W3 등록·번역·가격
- **우선순위 · 규모**: P0 · M
- **선행 작업**: task-004, task-019, task-023
- **담당**: `nextjs-expert`
- **착수 전 검증**: plan-challenger
- **변경 후 검증**: review-expert, contract-reviewer
- **기능 ID**: GS-F-024~032
- **착수 전 결정**: 없음

## 목표

등록 API: `/api/listings`, `/[id]`, `/[id]/{validate,submit,translate}`, `/api/listings/batches`, `/batches/[id]/run`, `/api/pricing/preview`, `/api/price-rules`, `/api/shipping-templates`

## 소유 파일 · 디렉토리

`apps/web/app/api/listings/`, `apps/web/app/api/pricing/`, `apps/web/app/api/price-rules/`, `apps/web/app/api/shipping-templates/`

## 참고 문서

- `docs/설계/DESIGN_STRUCTURE.md` 5.1절, 11.1절
- `docs/기획서/04_API.md` 2장
- `docs/기획서/03_SCREENS_UX.md` 2.1절, 2.3절

## 할 것

- [ ] 리스팅 CRUD·상태 전이 검사
- [ ] 검증(마켓별 필수 항목 + 리스크)
- [ ] 일괄 등록 생성·실행
- [ ] 템플릿 API
- [ ] 가격 미리보기

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- 마켓 전송 실행(GS-06-028)
- 화면(GS-06-029)

## 완료 조건

- [ ] 검증 실패 시 `submit` 409와 실패 항목 목록, 같은 `request_id` 재전송 시 잡 1건, `translate`는 선차감·실패 환불, 일괄 등록 사전 검증이 5분류(바로·자동 보완·마진 미달·항공 제한·상표권)로 반환, 가격 미리보기가 `pricing.ts` 결과와 같음
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
