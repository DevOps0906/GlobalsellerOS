# task-007 인증 Stage A

- **작업 ID**: GS-06-007 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W1 인증·도메인·워커 기반
- **우선순위 · 규모**: P0 · M
- **선행 작업**: task-001, task-002
- **담당**: `nextjs-expert`
- **착수 전 검증**: plan-challenger
- **변경 후 검증**: review-expert, security-auditor
- **기능 ID**: GS-F-001
- **착수 전 결정**: 없음

## 목표

인증 Stage A: `lib/auth/`(`getAuthConfig`, `isMockAuthAllowed`, `listLoginOptions`, `finishLogin`), Mock 로그인 `POST /api/dev/login`, 개발용 페르소나 패널, `MOCK AUTH · 로컬 전용` 배지, `requireSession`, `proxy.ts`, 시드 사용자 스크립트

## 소유 파일 · 디렉토리

`apps/web/app/(auth)/login/`, `apps/web/app/api/dev/login/`, `apps/web/lib/auth/`, `apps/web/lib/session/`, `apps/web/proxy.ts`, `scripts/dev/`

## 참고 문서

- `platform-docs/products/_platform-core/AUTH_ROADMAP.md` 2장, 3장, 9장
- `docs/기획서/03_SCREENS_UX.md` 7장
- `docs/기획서/05_DATA_MODEL.md` 개발용 시드 절

## 할 것

- [ ] 인증 모듈 경계 `lib/auth/`
- [ ] Mock 로그인 라우트와 개발용 패널(페르소나 `pro`, `empty` 포함)
- [ ] `requireSession('globalseller', { roles })`
- [ ] `proxy.ts` 보호 경로와 `next` 화이트리스트
- [ ] 시드 사용자 스크립트(로컬 전용 가드)

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- Google·이메일 로그인(GS-06-049)
- 카카오·네이버(GS-06-055)
- 쿠키에 역할 저장

## 완료 조건

- [ ] `owner` 로그인 → `session_context('globalseller').entitled=true`, `outsider`로 다른 조직 `globalseller` 행 0, `viewer` 쓰기 403, `next=//evil.com` → `/dashboard`, `AUTH_MODE=mock`+운영 빌드 실패, `AUTH_MODE=live`에서 `/api/dev/login` 404, 시드 스크립트는 원격 URL이면 exit 1, 두 번 실행해도 가입 크레딧 1회
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
