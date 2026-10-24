# task-052 Amazon JP 확장

- **작업 ID**: GS-06-052 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W8 Phase 2
- **우선순위 · 규모**: P2 · M
- **선행 작업**: task-025, task-026
- **담당**: `worker-expert`
- **착수 전 검증**: —
- **변경 후 검증**: review-expert, contract-reviewer
- **기능 ID**: GS-F-025, 030
- **착수 전 결정**: 없음

## 목표

Amazon JP 확장: 마켓플레이스 id·JPY·10엔 반올림·일본어 번역(JA 프롬프트)

## 소유 파일 · 디렉토리

`packages/markets/amazon-sp/marketplaces/jp.ts`, `services/worker/src/translate/prompts/ja/`

## 참고 문서

- `docs/기획서/01_PRD.md` 2장

## 할 것

- [ ] 마켓플레이스 설정
- [ ] JA 프롬프트

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- US 동작 변경

## 완료 조건

- [ ] JP 리스팅 계약 테스트 통과, 가격이 10엔 단위, JA 평가셋 20건 필수 필드 누락 0
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
