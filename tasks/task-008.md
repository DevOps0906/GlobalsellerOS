# task-008 환경변수 검증(zod)과 `.env.example`

- **작업 ID**: GS-06-008 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W1 인증·도메인·워커 기반
- **우선순위 · 규모**: P0 · S
- **선행 작업**: task-001
- **담당**: `sub-agent-2`
- **착수 전 검증**: —
- **변경 후 검증**: review-expert, security-auditor
- **기능 ID**: 해당 없음(기반 작업)
- **착수 전 결정**: 없음

## 목표

환경변수 검증(zod)과 `.env.example`: 웹·워커 필수 키, 누락 시 기동 실패, 서버 전용 키 분리

## 소유 파일 · 디렉토리

`apps/web/lib/env.ts`, `services/worker/src/env.ts`, `.env.example`, `services/worker/.env.example`

## 참고 문서

- `docs/기획서/02_ARCHITECTURE.md` 환경변수 절
- `CLAUDE.md` 5장

## 할 것

- [ ] 02장 환경변수 표를 그대로 zod 스키마로 옮김
- [ ] `.env.example` 2개(이름만)
- [ ] 누락 시 기동 실패 테스트

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- 실제 비밀 값 커밋
- 키 이름 새로 만들기(02장에 없으면 팀장 확인)

## 완료 조건

- [ ] 02장 환경변수 표의 키가 `.env.example`에 이름만 있음(값 0), 필수 키 누락 시 기동 실패 테스트, `NEXT_PUBLIC_` 접두사에 비밀 키 0건, LLM·마켓 키는 워커 env에만
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
