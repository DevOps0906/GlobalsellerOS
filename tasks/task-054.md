# task-054 키워드 수집(쿠팡 파트너스 API)과 정기 수집

- **작업 ID**: GS-06-054 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W8 Phase 2
- **우선순위 · 규모**: P1 · M
- **선행 작업**: task-020
- **담당**: `worker-expert`
- **착수 전 검증**: plan-challenger
- **변경 후 검증**: review-expert, security-auditor
- **기능 ID**: GS-F-019, 020
- **착수 전 결정**: 없음

## 목표

키워드 수집(쿠팡 파트너스 API)과 정기 수집: 키 등록, 호출 한도 게이지, 한도 대기·재개, 매일 새 상품만 수집

## 소유 파일 · 디렉토리

`packages/sources/coupang-partners/`, `services/worker/src/collect/keyword.ts`, `services/worker/src/collect/schedule.ts`

## 참고 문서

- `docs/planning-update-2026-10-23.md` 5장
- `prototype/index.html:1895-2027`

## 할 것

- [ ] 파트너스 클라이언트
- [ ] 한도 관리
- [ ] 정기 스케줄

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- 가격 필터를 API에 기대기(API가 무시함, 수집 후 적용)

## 완료 조건

- [ ] 한도 초과 응답이 3회 이상 연속으로 나지 않음(사전 차단), 정기 수집은 이전 수집 상품 제외, 키는 `encrypted_credentials`에만
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
