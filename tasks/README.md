# 작업 목록

> Claude Code 작업 순서입니다. `/next-task`가 이 표에서 상태가 `대기`이고 선행 작업이 모두 `완료`인 가장 앞 번호를 고릅니다.
> 상태: `대기` → `진행` → `완료` (막히면 `보류` + 사유). 작업 정의의 정본은 `docs/기획서/06_AGENT_PLAN.md` 2장이고, 이 폴더는 그 사본입니다.

## 진행 순서

MVP 목표: **eBay US · Amazon US**에 쿠팡 상품을 URL·목록·확장프로그램으로 수집해 등록하고, 동기화·주문·배송·수익을 운영한다(`docs/기획서/01_PRD.md` 2장).
MVP 출시 조건은 W6까지 완료, 공개 베타는 사람이 G1을 판정한 뒤 W7입니다. W8은 Phase 2입니다.

| 작업 | 웨이브 | 제목 | 담당 | 선행 | 상태 |
|---|---|---|---|---|---|
| [task-001](task-001.md) | W0 | 모노레포·웹 앱 골격 | nextjs-expert | — | 대기 |
| [task-002](task-002.md) | W0 | DB 적용과 타입 생성 | supabase-expert | — | 대기 |
| [task-003](task-003.md) | W0 | 도메인 상수 패키지 | sub-agent-1 | — | 대기 |
| [task-004](task-004.md) | W0 | 가격 공식과 환산 | sub-agent-1 | 003 | 대기 |
| [task-005](task-005.md) | W0 | 안전 fetch 패키지 | worker-expert | — | 대기 |
| [task-006](task-006.md) | W0 | 디자인 시스템 1단계 | sub-agent-2 | — | 대기 |
| [task-007](task-007.md) | W1 | 인증 Stage A | nextjs-expert | 001, 002 | 대기 |
| [task-008](task-008.md) | W1 | 환경변수 검증(zod)과 `.env.example` | sub-agent-2 | 001 | 대기 |
| [task-009](task-009.md) | W1 | RLS·권한 회귀 테스트 | supabase-expert | 002 | 대기 |
| [task-010](task-010.md) | W1 | 워커 런타임 | worker-expert | 002, 003 | 대기 |
| [task-011](task-011.md) | W1 | `MarketAdapter` 인터페이스와 가짜 마켓(fake) 구현 | worker-expert | 003, 005 | 대기 |
| [task-012](task-012.md) | W1 | 쿠팡 소스 파서 | worker-expert | 005 | 대기 |
| [task-013](task-013.md) | W1 | 리스크 규칙 패키지 | worker-expert | 003 | 대기 |
| [task-014](task-014.md) | W1-D | 디자인 시스템 2단계 | nextjs-expert | 001, 006 | 대기 |
| [task-015](task-015.md) | W1-D | 디자인 시스템 3단계 | 사람 | 014 | 대기 |
| [task-016](task-016.md) | W1-D | 디자인 시스템 4단계 | nextjs-expert | 015 | 대기 |
| [task-017](task-017.md) | W2 | 대시보드 셸 | nextjs-expert | 007, 016 | 대기 |
| [task-018](task-018.md) | W2 | `MarketScope`·`MarketHealthStrip` 공통 컴포넌트 | nextjs-expert | 014, 016 | 대기 |
| [task-019](task-019.md) | W2 | 수집 API | nextjs-expert | 007, 012 | 대기 |
| [task-020](task-020.md) | W2 | 수집 워커 핸들러 `src/collect/` | worker-expert | 010, 012, 013, 019 | 대기 |
| [task-021](task-021.md) | W2 | 크롬 확장프로그램(MV3) | worker-expert | 019 | 대기 |
| [task-022](task-022.md) | W2 | S-02 쿠팡 상품 수집 화면 | nextjs-expert | 017, 019 | 대기 |
| [task-023](task-023.md) | W3 | 마켓 연결 API와 토큰 금고 | nextjs-expert | 007, 011 | 대기 |
| [task-024](task-024.md) | W3 | eBay 어댑터 | worker-expert | 011 | 대기 |
| [task-025](task-025.md) | W3 | Amazon SP-API 어댑터(US) | worker-expert | 011 | 대기 |
| [task-026](task-026.md) | W3 | AI 번역 핸들러 `src/translate/` | worker-expert | 010, 013 | 대기 |
| [task-027](task-027.md) | W3 | 등록 API | nextjs-expert | 004, 019, 023 | 대기 |
| [task-028](task-028.md) | W3 | 등록·가져오기 워커 | worker-expert | 010, 011, 027 | 대기 |
| [task-029](task-029.md) | W3 | S-03 해외 마켓 등록 화면 | nextjs-expert | 017, 027 | 대기 |
| [task-030](task-030.md) | W4 | 동기화 워커 `src/sync/` | worker-expert | 020, 028 | 대기 |
| [task-031](task-031.md) | W4 | 동기화 API | nextjs-expert | 007, 030 | 대기 |
| [task-032](task-032.md) | W4 | 주문 워커 `src/orders/` | worker-expert | 024, 025, 010 | 대기 |
| [task-033](task-033.md) | W4 | 주문·송장 API | nextjs-expert | 007, 032 | 대기 |
| [task-034](task-034.md) | W4 | 배송 추적·건강 지표·토큰 갱신 워커 | worker-expert | 024, 025, 033 | 대기 |
| [task-035](task-035.md) | W4 | S-04 재고·가격 동기화 화면 | nextjs-expert | 018, 031 | 대기 |
| [task-036](task-036.md) | W4 | S-05 주문 통합 관리 화면 | nextjs-expert | 018, 033 | 대기 |
| [task-037](task-037.md) | W4 | S-06 배송·물류 추적 화면 | nextjs-expert | 018, 033 | 대기 |
| [task-038](task-038.md) | W5 | 수익 분석 | nextjs-expert | 017, 033 | 대기 |
| [task-039](task-039.md) | W5 | S-01 대시보드 | nextjs-expert | 017, 038 | 대기 |
| [task-040](task-040.md) | W5 | 마켓 추가 마법사 점수 `readiness.ts` | sub-agent-1 | 003 | 대기 |
| [task-041](task-041.md) | W5 | S-11 마켓 추가 마법사 화면 | nextjs-expert | 018, 023, 040 | 대기 |
| [task-042](task-042.md) | W5 | S-10 내 계정 8개 탭 + S-08 연동 설정 화면 | nextjs-expert | 017, 023 | 대기 |
| [task-043](task-043.md) | W5 | 결제 | nextjs-expert | 007, 042 | 대기 |
| [task-044](task-044.md) | W5 | 대기자 등록 랜딩과 법적 문서 | nextjs-expert | 016 | 대기 |
| [task-045](task-045.md) | W6 | 결제 E2E(Toss 테스트 키) | test-writer | 043 | 대기 |
| [task-046](task-046.md) | W6 | 핵심 플로우 E2E(Mock 페르소나 + 가짜 마켓) | test-writer | 022, 029, 035, 036, 037, 041 | 대기 |
| [task-047](task-047.md) | W6 | 보안 회귀 | test-writer | 009, 021, 023 | 대기 |
| [task-048](task-048.md) | W6 | CI(GitHub Actions) | sub-agent-1 | 009, 046 | 대기 |
| [task-049](task-049.md) | W7 | 인증 Stage B | nextjs-expert | G1(사람 판정), 007, 044 | 대기 |
| [task-050](task-050.md) | W7 | 공개 베타 전환 | sub-agent-1 | 049, 045, 046, 047 | 대기 |
| [task-051](task-051.md) | W8 | Shopee 어댑터(SG·TH) | worker-expert | 011, 034 | 대기 |
| [task-052](task-052.md) | W8 | Amazon JP 확장 | worker-expert | 025, 026 | 대기 |
| [task-053](task-053.md) | W8 | Lazada 어댑터 | worker-expert | 011 | 대기 |
| [task-054](task-054.md) | W8 | 키워드 수집(쿠팡 파트너스 API)과 정기 수집 | worker-expert | 020 | 대기 |
| [task-055](task-055.md) | W8 | 인증 Stage C | nextjs-expert | G2(사람 판정), 049 | 대기 |

## 웨이브 설명

| 웨이브 | 이름 | 비고 |
|---|---|---|
| W0 | 기반 | 작업 6개 |
| W1 | 인증·도메인·워커 기반 | 작업 7개 |
| W1-D | 디자인 시스템 | 작업 3개 |
| W2 | 수집 | 작업 6개 |
| W3 | 등록·번역·가격 | 작업 7개 |
| W4 | 운영(동기화·주문·배송) | 작업 8개 |
| W5 | 수익·계정·마법사·결제 | 작업 7개 |
| W6 | E2E·보안 (MVP 출시 조건) | 작업 4개 |
| W7 | 공개 베타 | 작업 2개 |
| W8 | Phase 2 | 작업 5개 |

## 발견한 문제

작업 범위 밖에서 발견한 문제를 적고 넘어갑니다. 팀장이 새 작업으로 만들지 정합니다.

| 날짜 | 발견한 작업 | 내용 | 영향 범위 | 처리 |
|---|---|---|---|---|
| | | | | |
