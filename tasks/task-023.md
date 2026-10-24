# task-023 마켓 연결 API와 토큰 금고

- **작업 ID**: GS-06-023 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W3 등록·번역·가격
- **우선순위 · 규모**: P0 · M
- **선행 작업**: task-007, task-011
- **담당**: `nextjs-expert`
- **착수 전 검증**: plan-challenger
- **변경 후 검증**: review-expert, security-auditor, contract-reviewer
- **기능 ID**: GS-F-056, 061
- **착수 전 결정**: D-08 (`docs/기획서/01_PRD.md` 8장, 결정 전 착수 금지)

## 목표

마켓 연결 API와 토큰 금고: `/api/markets/{catalog,readiness,connect/start,callback/[market],accounts,accounts/[id],accounts/[id]/test}`, OAuth state, 토큰 암호화 저장, eBay 계정 삭제 알림 웹훅

## 소유 파일 · 디렉토리

`apps/web/app/api/markets/`, `apps/web/app/api/webhooks/ebay/`, `apps/web/lib/credentials/`

## 참고 문서

- `docs/설계/DESIGN_STRUCTURE.md` 4장, 11.1절
- `docs/기획서/04_API.md` 2장, 5장
- `docs/기획서/05_DATA_MODEL.md` market_accounts

## 할 것

- [ ] 카탈로그·진단 답변 API
- [ ] OAuth 시작·콜백
- [ ] API 키 방식 계정 추가·테스트
- [ ] 토큰 금고 래퍼(코어 `encrypted_credentials`)
- [ ] eBay 계정 삭제 알림 엔드포인트

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- 마켓 API 실제 호출 로직(어댑터 소유, 연결 테스트는 어댑터 함수 호출만)
- 마법사 화면(GS-06-041)

## 완료 조건

- [ ] 응답·로그·DB 평문 토큰 0건(grep 테스트), state 재사용·만료 거부, 마켓 수 한도 초과 403, 연결 해제 시 `revoke_credential`와 감사 1행, eBay 계정 삭제 알림 챌린지 응답 통과(SHA-256 응답 해시)
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
