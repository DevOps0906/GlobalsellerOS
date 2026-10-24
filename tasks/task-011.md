# task-011 `MarketAdapter` 인터페이스와 가짜 마켓(fake) 구현

- **작업 ID**: GS-06-011 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W1 인증·도메인·워커 기반
- **우선순위 · 규모**: P0 · M
- **선행 작업**: task-003, task-005
- **담당**: `worker-expert`
- **착수 전 검증**: plan-challenger
- **변경 후 검증**: review-expert, contract-reviewer
- **기능 ID**: GS-F-030
- **착수 전 결정**: 없음

## 목표

`MarketAdapter` 인터페이스와 가짜 마켓(fake) 구현: 토큰 갱신, 리스팅 생성·수정·종료, 가격·재고 변경, 주문 조회, 발송 확인, 건강 지표, 오류 분류

## 소유 파일 · 디렉토리

`packages/markets/types.ts`, `packages/markets/testing/`(계약 테스트 스위트), `packages/markets/fake/`

## 참고 문서

- `docs/기획서/04_API.md` 외부 API 어댑터 절
- `docs/기획서/02_ARCHITECTURE.md` 모듈 경계 절

## 할 것

- [ ] 인터페이스 정의와 오류 타입
- [ ] 레이트 리밋 토큰 버킷 공용 유틸
- [ ] 가짜 마켓(개발·E2E용, 설정으로 교체)
- [ ] 계약 테스트 스위트(실제 어댑터도 같은 스위트 통과)

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- eBay·Amazon 실제 구현(GS-06-024, 025)

## 완료 조건

- [ ] 인터페이스가 04장 외부 어댑터 절과 1:1, 가짜 마켓으로 리스팅 생성 → 가격 변경 → 주문 조회 → 발송 확인 시나리오 통과, 오류를 `retryable`·`auth`·`validation`·`rate_limit` 4종으로 분류
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
