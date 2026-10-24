# task-020 수집 워커 핸들러 `src/collect/`

- **작업 ID**: GS-06-020 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W2 수집
- **우선순위 · 규모**: P0 · L
- **선행 작업**: task-010, task-012, task-013, task-019
- **담당**: `worker-expert`
- **착수 전 검증**: plan-challenger
- **변경 후 검증**: review-expert, contract-reviewer
- **기능 ID**: GS-F-012, 016, 018, 021, 022
- **착수 전 결정**: 없음

## 목표

수집 워커 핸들러 `src/collect/`: 항목별 가져오기(`packages/net`·`packages/sources`), 조건 필터, 리스크 검사, 중복 제외, `source_products`·옵션 upsert, 작업 집계·제외 사유

## 소유 파일 · 디렉토리

`services/worker/src/collect/`

## 참고 문서

- `docs/설계/DESIGN_STRUCTURE.md` 5장, 9장
- `docs/기획서/04_API.md` 잡 페이로드 계약
- `docs/기획서/03_SCREENS_UX.md` 2.2절

## 할 것

- [ ] 잡 payload 처리(URL 단건·URL 목록·확장프로그램 데이터)
- [ ] 쿠팡 요청 간격 1초 이상·조직당 동시 1건(01장 6장)
- [ ] 필터·리스크·중복
- [ ] 옵션 저장
- [ ] 집계와 실패 처리

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- 키워드 수집(GS-06-054)
- AI 번역(GS-06-026)

## 완료 조건

- [ ] URL 목록 100건 작업이 진행률을 Realtime으로 갱신하고 완료 시 `counts`(수집·통과·제외 사유 5종) 합이 입력 수와 같음, 같은 상품 재수집 시 새 행 0(갱신만), 리스크 `block` 상품은 `excluded`, 쿠팡 요청 간격 1초 이상·조직당 동시 1건(01장 6장)을 테스트로 확인
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
