# task-003 도메인 상수 패키지

- **작업 ID**: GS-06-003 (정본 `docs/기획서/06_AGENT_PLAN.md` 2장)
- **웨이브**: W0 기반
- **우선순위 · 규모**: P0 · M
- **선행 작업**: 없음
- **담당**: `sub-agent-1`
- **착수 전 검증**: —
- **변경 후 검증**: review-expert, contract-reviewer
- **기능 ID**: GS-F-006, 034, 045
- **착수 전 결정**: 없음

## 목표

도메인 상수 패키지: `markets.ts`(마켓 카탈로그: 코드·지역·통화와 최소 단위·인증 방식·수수료·월 고정비), `status.ts`(DS 5.1절 상태·S-05 그룹·`StatusPill` 배리언트), `nav.ts`(GNB·상단 탭·모바일 메뉴), `health.ts`(마켓 건전성 지표 정의와 목표값)

## 소유 파일 · 디렉토리

`packages/domain/{markets,status,nav,health}.ts`와 테스트, `packages/domain/package.json`

## 참고 문서

- `docs/설계/DESIGN_STRUCTURE.md` 5.1절, 10장
- `docs/기획서/01_PRD.md` 2장
- `docs/기획서/03_SCREENS_UX.md` 8장

## 할 것

- [ ] `markets.ts` 마켓 카탈로그(MVP eBay US·Amazon US, P1 Shopee SG·TH, P2 Amazon JP·Lazada·Qoo10·Etsy·TikTok Shop)와 통화 최소 단위
- [ ] `status.ts` 상태 상수, S-05 그룹, `StatusPill` 배리언트 매핑
- [ ] `nav.ts` GNB·상단 탭·모바일 메뉴 정의
- [ ] `health.ts` 지표 정의(Amazon ODR 1% 미만 등, 01장 GS-F-045)
- [ ] 단위 테스트

## 안 할 것 (범위 밖)

- 소유 파일 · 디렉토리 밖 수정(필요하면 소유 작업에 요청하고 보고에 적는다)
- 가격 공식(GS-06-004)
- 마법사 점수(GS-06-040)
- DB 스키마 변경

## 완료 조건

- [ ] 단위 테스트: 상태 값 목록이 DS 5.1절과 1:1(스냅샷), S-05 상태 그룹 4개가 DS 5.1절 매핑과 일치, 통화 소수 자리(USD 2, JPY 0, SGD 2), GNB 항목 순서가 03장 8.2절과 일치
- [ ] `/check`의 해당 영역 명령 통과
- [ ] 변경 후 검증 에이전트 판정 ACCEPT(🔴 0)

## 완료 보고

| 완료 조건 | 결과 | 확인 방법 |
|---|---|---|
| | | |
