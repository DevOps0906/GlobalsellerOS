# task-019 수집 API

- **작업 ID**: GS-06-019 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W2 수집
- **우선순위 · 규모**: P0 · M
- **선행 작업**: task-007, task-012
- **담당**: `nextjs-expert`
- **착수 전 검증**: plan-challenger
- **변경 후 검증**: review-expert, contract-reviewer, security-auditor
- **기능 ID**: GS-F-012, 013, 017, 018, 021
- **착수 전 결정**: 없음

## 목표

수집 API: `/api/collect/{single,jobs,jobs/[id]/cancel,upload,presets}`, `/api/source-products`, `/api/source-products/[id]`, `/api/extension/{token,items}`

## 소유 파일 · 디렉토리

`apps/web/app/api/collect/`, `apps/web/app/api/source-products/`, `apps/web/app/api/extension/`

## 참고 문서

- `docs/설계/DESIGN_STRUCTURE.md` 11.1절
- `docs/기획서/04_API.md` 2장

## 할 것

- [ ] zod 입력 검증
- [ ] RPC `enqueue_collect_job` 호출
- [ ] 업로드 서명 URL
- [ ] 확장 토큰 발급·검증

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- 수집 실행(GS-06-020)
- 화면(GS-06-022)

## 완료 조건

- [ ] 상품 수 한도 초과 403(`GS003`), 같은 `request_id` 2회 → 잡 1건, 업로드는 서명 URL만(서버 파일 경유 0), 확장 토큰은 `extension:collect` 범위만·만료 30일(제안), `/api/extension/items` 요청당 50건 초과 400, 다른 조직 `source_products` 접근 404
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
