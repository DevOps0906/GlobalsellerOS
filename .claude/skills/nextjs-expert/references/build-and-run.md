# nextjs-expert — build & run

패키지 매니저는 **pnpm**(워크스페이스)이다. 명령은 `apps/web/package.json`의 `scripts`가 정본이다.

| 목적 | 명령 | 비고 |
|---|---|---|
| 의존성 설치 | `pnpm install` (저장소 루트) | 잠금 파일이 정본, `latest` 태그 금지 |
| 개발 서버 | `pnpm -F web dev` | 환경 변수는 `apps/web/.env.local` (커밋 금지) |
| 타입체크 | `pnpm -F web typecheck` 또는 `pnpm -F web exec tsc --noEmit` | 스크립트 없으면 보고 |
| 린트 | `pnpm -F web lint` | |
| 테스트 | `pnpm -F web test` | 없으면 "테스트 없음"으로 보고 |
| 빌드 | `pnpm -F web build` | 산출물(`.next/`) 커밋 금지 |
| DB 타입 재생성 | `supabase gen types typescript --local > apps/web/types/supabase.ts` | supabase-expert 변경 후. 생성 파일 직접 수정 금지 |
| 프로토타입 비교 | `/sync-design <화면 ID>` | `prototype/index.html` 기준 |
| E2E | `pnpm test:e2e` | 로컬 스택 + 개발 서버 필요 |

- 환경 변수 목록은 루트 `.env.example`이 정본이다. 값은 저장소에 두지 않는다.
- 로컬 Supabase 연결과 Mock 로그인 시드는 `docs/개발서/globalseller-os_develop.md`의 로컬 환경 · 인증 장을 따른다.
- 실행하지 못한 명령은 "미검증"으로 쓰고 통과로 간주하지 않는다.
