# task-009 RLS·권한 회귀 테스트

- **작업 ID**: GS-06-009 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W1 인증·도메인·워커 기반
- **우선순위 · 규모**: P0 · M
- **선행 작업**: task-002
- **담당**: `supabase-expert`
- **착수 전 검증**: —
- **변경 후 검증**: review-expert, security-auditor
- **기능 ID**: GS-F-002, 005
- **착수 전 결정**: 없음

## 목표

RLS·권한 회귀 테스트: 조직 격리, 역할별 쓰기, service_role 전용 RPC, 마켓 토큰 비노출

## 소유 파일 · 디렉토리

`supabase/tests/`

## 참고 문서

- `docs/기획서/05_DATA_MODEL.md` RLS 절
- `docs/설계/DESIGN_STRUCTURE.md` 11.2절

## 할 것

- [ ] pgTAP 또는 SQL 스모크 테스트
- [ ] 페르소나별 시나리오(owner, member, viewer, outsider)
- [ ] RPC 권한(`approve_sync_event`, `record_purchase`) 검사

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- 정책 자체 수정(문제 발견 시 GS-06-002에 보고)

## 완료 조건

- [ ] 05장 RLS 표의 모든 정책 항목 통과, 다른 조직 `market_accounts`·`orders`·`source_products` 조회 0행, `viewer`의 INSERT·UPDATE 거부, `encrypted_credentials` 암호문 컬럼을 authenticated가 읽지 못함, CI에서 실패 시 머지 차단
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
