# task-025 Amazon SP-API 어댑터(US)

- **작업 ID**: GS-06-025 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W3 등록·번역·가격
- **우선순위 · 규모**: P0 · L
- **선행 작업**: task-011
- **담당**: `worker-expert`
- **착수 전 검증**: plan-challenger
- **변경 후 검증**: review-expert, contract-reviewer, security-auditor
- **기능 ID**: GS-F-030, 040, 043, 045
- **착수 전 결정**: D-08 (`docs/기획서/01_PRD.md` 8장, 결정 전 착수 금지)

## 목표

Amazon SP-API 어댑터(US): LWA 토큰, Listings Items API 생성·수정, 가격·재고 패치, Orders API, 발송 확인, 계정 건전성 지표

## 소유 파일 · 디렉토리

`packages/markets/amazon-sp/`

## 참고 문서

- `docs/기획서/04_API.md` 6장
- `docs/기획서/01_PRD.md` 2장, 6장

## 할 것

- [ ] LWA 인증
- [ ] 리스팅·가격·재고
- [ ] 주문·발송 확인
- [ ] 지표
- [ ] 녹화 응답 테스트

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- Amazon JP 운영(GS-06-052)
- FBA

## 완료 조건

- [ ] GS-06-011 계약 테스트 통과(SP-API 샌드박스 응답), 엔드포인트별 사용 한도에 맞춘 토큰 버킷, 개인정보(구매자 주소)는 필요한 필드만 저장 대상으로 반환, 마켓플레이스 id를 설정으로 받아 JP 확장 가능(GS-06-052)
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
