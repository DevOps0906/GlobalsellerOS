# task-055 인증 Stage C

- **작업 ID**: GS-06-055 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W8 Phase 2
- **우선순위 · 규모**: P2 · M
- **선행 작업**: G2(사람 판정), task-049
- **담당**: `nextjs-expert`
- **착수 전 검증**: plan-challenger
- **변경 후 검증**: review-expert, security-auditor
- **기능 ID**: GS-F-001
- **착수 전 결정**: D-15, D-16 (`docs/기획서/01_PRD.md` 8장, 결정 전 착수 금지)

## 목표

인증 Stage C: 카카오(C1)·네이버(C2) 로그인, `/settings/login` 연결·해제

## 소유 파일 · 디렉토리

`apps/web/components/auth/kakao/`, `apps/web/app/auth/naver/`, `apps/web/lib/auth/naver/`, `apps/web/app/(app)/settings/login/`

## 참고 문서

- `platform-docs/products/_platform-core/AUTH_ROADMAP.md` 6장, 7장

## 할 것

- [ ] 카카오
- [ ] 네이버 스파이크 → 경로 결정
- [ ] 로그인 방법 설정

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- B 단계 파일 변경(요청)

## 완료 조건

- [ ] platform-docs/products/_platform-core/AUTH_ROADMAP.md 7.1.3절 C1-1~C1-5, 7.2.4절 C2-1~C2-6 그대로, 로그인 수단 1개 남은 상태에서 해제 거부
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
