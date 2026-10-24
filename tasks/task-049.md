# task-049 인증 Stage B

- **작업 ID**: GS-06-049 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W7 공개 베타
- **우선순위 · 규모**: P0 · M
- **선행 작업**: G1(사람 판정), task-007, task-044
- **담당**: `nextjs-expert`
- **착수 전 검증**: plan-challenger
- **변경 후 검증**: review-expert, security-auditor
- **기능 ID**: GS-F-001
- **착수 전 결정**: D-17 (`docs/기획서/01_PRD.md` 8장, 결정 전 착수 금지)

## 목표

인증 Stage B: Google OAuth + 이메일 가입·인증 메일·비밀번호 재설정, `/auth/callback`(`finishLogin`), 약관 온보딩 `/onboarding/terms`, 배포 env `AUTH_MODE=live`

## 소유 파일 · 디렉토리

`apps/web/components/auth/`, `apps/web/app/auth/callback/`, `apps/web/app/(auth)/{signup,reset-password}/`, `apps/web/app/onboarding/terms/`, `docs/deploy/auth-checklist.md`

## 참고 문서

- `platform-docs/products/_platform-core/AUTH_ROADMAP.md` 4장, 5장
- `docs/기획서/03_SCREENS_UX.md` 7장

## 할 것

- [ ] Google·이메일 로그인
- [ ] 콜백
- [ ] 약관 온보딩
- [ ] 배포 체크리스트

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- 카카오·네이버(GS-06-055)
- `lib/auth/` 경계 변경(GS-06-007 파일에 요청)

## 완료 조건

- [ ] platform-docs/products/_platform-core/AUTH_ROADMAP.md 5.3절 B-1~B-6 그대로, 첫 Google 로그인 사용자가 약관 동의 전 `/dashboard` 진입 불가
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
