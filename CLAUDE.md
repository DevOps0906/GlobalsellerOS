# CLAUDE.md — GlobalSeller OS

이 파일은 Claude Code CLI가 이 저장소에서 작업할 때 항상 먼저 읽는 규칙입니다.

## 1. 이 저장소는 무엇인가

쿠팡에서 수집한 국내 상품을 Amazon · eBay · Shopee 등 해외 마켓에 등록하고, 재고 · 가격 동기화부터 주문 · 배송 · 수익 분석까지 운영하는
**역직구 멀티채널 SaaS(GlobalSeller OS)의 단일 저장소**입니다. 프로토타입 · 기획서 · 개발서 · 실제 코드가 모두 여기에 있습니다.

| 위치 | 역할 |
|---|---|
| `prototype/` | 클릭 가능한 HTML 프로토타입. 화면 구조 · 문구 · 상태의 디자인 원본 |
| `docs/` | 설계 구조 · 기획서 · 개발서 · 멀티에이전트 운영 (3장) |
| `tasks/` | 개발 작업 상태와 작업별 지시서 |
| `apps/web` · `apps/extension` · `services/worker` · `packages/*` · `supabase/` | 실제 코드 (구조는 `docs/설계/DESIGN_STRUCTURE.md` 7장) |
| `platform-docs` (별도 저장소) | 공용 코어(인증 · 조직 · 크레딧 · 결제 · 잡) 원본 문서. 코드는 그곳에 쓰지 않습니다 |

권장 로컬 폴더 배치 (두 저장소를 **같은 상위 폴더에 나란히** 클론 — 이 저장소 안에 platform-docs 를 클론하지 않습니다):

```
workspace/
├── GlobalsellerOS/
└── platform-docs/
```

공용 코어 문서를 참고해야 하는 작업(인증 · 크레딧 · 결제 · 잡 런타임)은 platform-docs 를 함께 엽니다.

```bash
cd workspace/GlobalsellerOS
claude --add-dir ../platform-docs
```

## 2. 작업 방식

1. `tasks/README.md`에서 상태가 `대기`인 가장 앞 번호 작업을 고릅니다. (`/next-task` 명령으로도 가능)
2. 해당 `tasks/task-###.md`와 **참고 문서**에서 작업에 필요한 장을 읽고 시작합니다. 작업은 팀(멀티에이전트)으로 나눠 진행합니다 (8장).
3. 작업 범위의 **안 할 것**과 다른 작업의 소유 경로(`docs/기획서/06_AGENT_PLAN.md` 1장)는 절대 건드리지 않습니다. 범위 밖 문제를 발견하면 `tasks/README.md`의 "발견한 문제" 표에 적고 넘어갑니다.
4. **완료 조건**을 모두 확인한 뒤 `tasks/README.md`의 상태를 `완료`로 바꾸고 커밋합니다.
5. 설계와 다르게 구현해야 하면, 코드보다 먼저 관련 문서를 고치고 이유를 커밋 메시지에 남깁니다. 이름 · 경로 · 상태 값이 바뀌면 `docs/설계/DESIGN_STRUCTURE.md`부터 고칩니다.

## 3. 문서 지도

| 문서 | 내용 |
|---|---|
| `docs/설계/DESIGN_STRUCTURE.md` | 디자인 구조 다이어그램과 고정 식별자 — 화면 ID · 라우트 · 셸 · 마켓 탭 패턴 · 마법사 · 데이터 흐름 · 상태 값 · 모듈 경로 · 테이블 · 큐 · API 경로 · 금액 규칙 (모든 문서의 이름 정본) |
| `docs/기획서/README.md` | 제품 한 줄 정의, 근거, 문서 목록, DB 구조 선택 |
| `docs/기획서/01_PRD.md` | 무엇을 만드나 — 페르소나, MVP 범위, 기능 요구사항(`GS-F-###`), 요금 · 크레딧, 비기능, 법 · 개인정보, KPI, 열린 결정 |
| `docs/기획서/02_ARCHITECTURE.md` | 스택, 모듈 경계, 잡 · 워커, 마켓 어댑터, AI 번역, 배포, 환경 변수 |
| `docs/기획서/03_SCREENS_UX.md` | 화면 목록 · 플로우 · 화면별 명세 · 상태 · 반응형 |
| `docs/기획서/04_API.md` | Route Handler · RPC · 잡 페이로드 · 웹훅 · 오류 코드 |
| `docs/기획서/05_DATA_MODEL.md` | 테이블 · 상태 전이 · RLS · 인덱스 · 마이그레이션 |
| `docs/기획서/06_AGENT_PLAN.md` | 작업 목록(`GS-06-###`) · 소유 경로 · 웨이브 · 담당 에이전트 · 수용 기준 |
| `docs/기획서/07_SOURCE_MIGRATION.md` | 프로토타입 · platform-docs 자산 이식과 복사 금지 결함 |
| `docs/기획서/08_DESIGN_SYSTEM.md` | 디자인 토큰 · 서체 · 반응형 스케일 · 컴포넌트 |
| `docs/개발서/globalseller-os_develop.md` | 어떻게 개발하나 — 준비, 로컬 환경, task 진행, 마켓 연동 순서, 검증, 인증 단계 |
| `docs/MULTI_AGENT.md` | 멀티에이전트 팀 구성 · 위임 · 검증 규칙 |
| `docs/planning-update-2026-10-23.md` | 마켓 탭 · 마켓 추가 · 상품 수집 기획과 벤치마킹, 쿠팡 파트너스 API 제약 |
| `prototype/index.html` | 화면 디자인 원본 (`npm test`로 동작 확인) |

## 4. 기술 스택 (작업 시작 시 최신 stable 확인)

| 영역 | 선택 | 비고 |
|---|---|---|
| 웹 | Next.js 16 (App Router) · React 19 · TypeScript 5 · Tailwind CSS v4 · shadcn/ui | 반응형 3구간, 미들웨어는 `proxy.ts` |
| 서버 | Supabase (Postgres · Auth · Realtime · Storage) | 공용 코어 표 + 스키마 `globalseller` |
| 잡 워커 | Node.js 22 · TypeScript | 코어 `jobs`(SKIP LOCKED), 크론 |
| 마켓 연동 | `packages/markets` MarketAdapter | MVP: eBay US · Amazon US (SP-API), P1: Shopee |
| 수집 | `packages/sources` · 크롬 확장 MV3 `apps/extension` | 쿠팡 URL · 목록 업로드 · 확장 · 파트너스 API(P1) |
| AI 번역 · 제목 | 워커에서 LLM HTTP 호출 | 키는 워커 env 에만 |
| 결제 | Toss Payments (공용 코어) | 구독 + 크레딧 |
| 패키지 관리 | pnpm workspace | 버전 고정, `latest` 금지 |

패키지 버전은 작업 시점에 npm 에서 최신 stable 과 유지보수 상태를 확인한 뒤 고정합니다. 스택을 적을 때는 항상 "Tailwind CSS v4"라고 씁니다.

## 5. 반드시 지킬 규칙

- **마켓 API · LLM 은 워커에서만**: 마켓 · 쿠팡 · LLM · 운송사 호출은 `services/worker`(와 그 패키지)에서만 합니다. 웹은 Route Handler 에서 잡을 등록할 뿐입니다. 예외는 OAuth 콜백 토큰 교환과 연결 테스트뿐입니다. (`docs/설계/DESIGN_STRUCTURE.md` 6장)
- **마켓 토큰은 암호화 저장**: 마켓 토큰 · API 키는 공용 코어 `encrypted_credentials`에만 두고, 복호화는 워커에서만 합니다. 응답은 마스킹, 로그 금지.
- **금액은 정수**: 원화는 원 단위 정수(`_krw`), 외화는 최소 단위 정수 + `currency`. 실수(`float` · 소수 `number`) 연산 금지. 가격 공식은 `packages/domain/pricing.ts` 하나만. (`DESIGN_STRUCTURE.md` 11.3절)
- **중복 방지**: 잡 · 리스팅 전송 · 가격 반영 · 발송 확인 · 크레딧 차감에 멱등 키를 붙입니다. 같은 주문 · 같은 리스팅이 두 번 생기면 안 됩니다.
- **손해 가격 자동 반영 금지**: 동기화가 마진 하한 미달 · 급격한 하락을 만들면 반영하지 않고 승인 대기(`held`)로 둡니다.
- **쿠팡 서버 크롤링 금지 · 리스크 검사 우회 금지**: 서버가 쿠팡 페이지를 대량·자동으로 긁지 않습니다. 허용 경로는 확장프로그램이 담은 데이터, 사용자가 준 URL 단건 조회(요청 간격 1초 이상, URL 목록 업로드도 줄마다 단건), 본인 파트너스 키의 공식 API(P1)뿐입니다(`docs/기획서/01_PRD.md` 6장). 리스크 검사(항공 제한 · 브랜드 · 제외어 · 이미지 권한)를 건너뛰는 경로를 만들지 않습니다.
- **DB 변경 규칙**: `supabase/migrations/`의 기존 파일(공용 코어 lite 사본 포함)은 절대 수정하지 않습니다. 변경은 항상 새 파일로 추가합니다. 모든 테이블은 RLS 를 켭니다.
- **비밀 값**: API 키 · 마켓 키 · LLM 키 · Supabase service role 키는 저장소에 넣지 않습니다. `.env.example`에 이름만 적습니다. `NEXT_PUBLIC_`에 비밀을 넣지 않습니다.
- **스타일은 Tailwind CSS v4 토큰만**: `@theme` 토큰(`apps/web/styles/tokens.css`)만 씁니다. `tailwind.config.js` · `@tailwind base` · hex 색 직접 사용 금지.
- **문서 언어**: 문서 · 커밋 메시지 · 화면 문구는 한국어. 코드 식별자는 영어.

## 6. 커밋 규칙

```
[GS-06-012] 주문 통합 관리: 마켓 탭 · 상태 그룹 필터

- 무엇을 했는지
- 확인한 방법 (단위 테스트 / 로컬 Supabase / E2E / 375·1024·1440 화면)
```

## 7. 자주 쓰는 명령 (`.claude/commands/`)

- `/next-task` — 다음 대기 작업을 찾아 계획을 세우고 진행
- `/check` — 정적 분석 · 테스트 · 포맷 확인 후 결과 요약
- `/sync-design` — 프로토타입 화면(`prototype/index.html`)과 현재 구현 차이 점검 (`/sync-design S-05`)
- `/agent-check` — 팀 에이전트 목록 · 모델 · 정합성 점검

## 8. 멀티에이전트 작업 방식

이 세션은 **팀장**입니다 (`.claude/settings.json` → `claude-opus-5-5`). 팀원은 모두 `claude-sonnet-5-5`입니다. 직접 다 하지 말고 나눠 맡기고 검토합니다. 상세는 `docs/MULTI_AGENT.md`.

| 맡길 일 | 에이전트 |
|---|---|
| 웹 화면 · Route Handler / DB · RLS · RPC / 워커 · 마켓 어댑터 · 수집 · 확장프로그램 | `nextjs-expert` / `supabase-expert` / `worker-expert` |
| `packages/domain` · 분야 밖 판단 필요 실무 / 규칙이 정해진 단순 반복 | 대리 `sub-agent-1` / 사원 `sub-agent-2` |
| 착수 전 계획 공격 (마켓 연동 · 가격 · 동기화 · 주문/발주 · 결제/크레딧 · DB · 인증) | `plan-challenger` |
| 변경 후 리뷰 (항상) + 경계 변경 / 보안 변경 | `review-expert` + `contract-reviewer` / `security-auditor` |
| 검증 근거 없음 | `test-writer` |
| 같은 문제로 2회 이상 막힘 | 고문 `advisor` |

- 팀원끼리 서로 부르지 않습니다. 팀장이 중개합니다.
- 지시에는 문서 내용을 붙이지 말고 **경로와 장 번호**만 줍니다.
- 커밋은 팀장만 합니다. 팀원은 commit · push 하지 않습니다.

### 운영 원칙 (팀장)

> 출처: [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) (MIT) — 한국어로 옮기고 이 프로젝트에 맞게 고침. `NOTICE` 참조.

1. **코딩 전에 생각한다** — 가정을 드러내고, 해석이 여럿이면 고르지 말고 제시합니다. 더 단순한 방법이 있으면 말합니다. 모호하면 멈추고 묻습니다.
2. **단순함 우선** — 요청한 것만 만듭니다. 한 번 쓰는 코드에 추상화, 요청하지 않은 설정 · 유연성, 일어날 수 없는 경우의 오류 처리를 넣지 않습니다.
3. **외과수술식 변경** — 필요한 곳만 고칩니다. 옆 코드를 "개선"하지 않고 기존 스타일을 따릅니다. 내 변경이 만든 미사용 코드만 지웁니다. 바뀐 모든 줄은 요청으로 거슬러 올라가야 합니다.
4. **목표 중심 실행** — 완료 조건을 확인 가능한 형태로 바꾸고(예: "중복 방지 추가" → "같은 주문을 두 번 수집하는 테스트를 쓰고 한 행만 남는지 통과시킨다"), 확인될 때까지 반복합니다. 여러 단계면 `단계 → 확인 방법`으로 계획을 적습니다.

팀원(서브에이전트)은 사용자에게 질문할 수 없으므로, 1번은 "가정을 보고에 적고 불확실한 점은 '팀장 확인 필요'로 올린다"로 적용합니다.
