# task-002 DB 적용과 타입 생성

- **작업 ID**: GS-06-002 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W0 기반
- **우선순위 · 규모**: P0 · M
- **선행 작업**: 없음
- **담당**: `supabase-expert`
- **착수 전 검증**: plan-challenger
- **변경 후 검증**: review-expert, security-auditor
- **기능 ID**: GS-F-005
- **착수 전 결정**: D-02, D-12 (`docs/기획서/01_PRD.md` 8장, 결정 전 착수 금지)

## 목표

DB 적용과 타입 생성: 코어 lite + `globalseller` 도메인 마이그레이션 + 시드를 로컬 Supabase에 적용, `config.toml` 스키마 노출, 타입 생성

## 소유 파일 · 디렉토리

`supabase/migrations/`, `supabase/seed.sql`, `supabase/config.toml`, `apps/web/types/supabase.ts`

## 참고 문서

- `docs/기획서/05_DATA_MODEL.md` 1~9장
- `docs/설계/DESIGN_STRUCTURE.md` 5.1절, 8장, 11.2절
- `CLAUDE.md` 5장

## 할 것

- [ ] 코어 lite 마이그레이션과 도메인 마이그레이션 적용
- [ ] `config.toml`에 `globalseller` 스키마 노출
- [ ] 시드(앱 레지스트리 `globalseller`, 플랜 3종) 적용
- [ ] 타입 생성 파일 저장
- [ ] 적용 절차를 `supabase/README.md`에 기록

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- 기존 번호 마이그레이션 수정(항상 새 번호 파일)
- 원격 `db push`
- 코어 표 ALTER

## 완료 조건

- [ ] `supabase db reset` 오류 0건, 2회 연속 적용 성공, DS 8장 테이블 21개·뷰 2개 존재, 상태 check 제약이 DS 5.1절 값과 일치, `supabase gen types --schema public,globalseller` 결과 저장, 모든 `globalseller` 테이블 RLS 활성
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
