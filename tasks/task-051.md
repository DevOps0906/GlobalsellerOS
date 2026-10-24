# task-051 Shopee 어댑터(SG·TH)

- **작업 ID**: GS-06-051 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W8 Phase 2
- **우선순위 · 규모**: P1 · L
- **선행 작업**: task-011, task-034
- **담당**: `worker-expert`
- **착수 전 검증**: plan-challenger
- **변경 후 검증**: review-expert, contract-reviewer, security-auditor
- **기능 ID**: GS-F-030, 037
- **착수 전 결정**: 없음

## 목표

Shopee 어댑터(SG·TH): 상점 권한 승인, 접근 토큰 4시간 갱신, 리스팅·가격·재고, 주문, SLS 송장

## 소유 파일 · 디렉토리

`packages/markets/shopee/`

## 참고 문서

- `docs/기획서/04_API.md` 6장
- `docs/기획서/01_PRD.md` 2장

## 할 것

- [ ] 인증·서명
- [ ] 리스팅·주문·송장
- [ ] 녹화 응답 테스트

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- 다른 마켓

## 완료 조건

- [ ] GS-06-011 계약 테스트 통과, 토큰 만료 전 자동 갱신(갱신 실패 시 `token_expired`), 국가별 통화·수수료 분리 계산
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
