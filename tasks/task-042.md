# task-042 S-10 내 계정 8개 탭 + S-08 연동 설정 화면

- **작업 ID**: GS-06-042 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W5 수익·계정·마법사·결제
- **우선순위 · 규모**: P0 · L
- **선행 작업**: task-017, task-023
- **담당**: `nextjs-expert`
- **착수 전 검증**: —
- **변경 후 검증**: review-expert, security-auditor
- **기능 ID**: GS-F-002, 003, 053~058
- **착수 전 결정**: D-13 (`docs/기획서/01_PRD.md` 8장, 결정 전 착수 금지)

## 목표

S-10 내 계정 8개 탭 + S-08 연동 설정 화면: 프로필, 플랜·사용량, 마켓 연결, API 키, 결제 내역, 알림, 보안, 팀 / 쿠팡 파트너스 키·확장 토큰·운송사

## 소유 파일 · 디렉토리

`apps/web/app/(app)/account/`, `apps/web/components/account/`, `apps/web/app/(app)/settings/integrations/`, `apps/web/app/api/notification-prefs/`

## 참고 문서

- `docs/기획서/03_SCREENS_UX.md` 3.9절, 3.10절
- `prototype/index.html:3241-4162`

## 할 것

- [ ] 8개 탭
- [ ] 연동 설정
- [ ] 알림 설정 API

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- 결제 처리(GS-06-043)
- 2FA 실제 활성화(P1)

## 완료 조건

- [ ] 03장 3.9·3.10절 요소 전부, 키 필드는 마스킹 값만 받음(평문 응답 0), 팀 초대·역할 변경은 코어 RPC 사용·감사 행, 계정 삭제는 화면 안 확인 단계(`confirm()` 0), 사용량 막대가 `plan_usage`와 같음
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
