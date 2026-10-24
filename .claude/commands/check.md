---
description: 정적 분석 · 테스트 · 포맷 확인 후 결과 요약
---
존재하는 프로젝트만 실행하고, 결과를 표(항목 / 결과 / 실패 내용)로 요약한다. 실패는 원인과 고칠 방법을 제안하되 사용자가 요청하기 전에는 고치지 않는다.
$ARGUMENTS 에 영역(`web` · `worker` · `packages` · `extension` · `db` · `prototype`)이 있으면 그 영역만 실행한다.

- apps/web: `pnpm -F web lint`, `pnpm -F web typecheck`, `pnpm -F web test`, `pnpm -F web build`
- services/worker: `pnpm -F worker typecheck`, `pnpm -F worker test`
- packages/*: `pnpm -r --filter "./packages/*" test` (패키지별 `typecheck` 스크립트가 있으면 함께)
- apps/extension: `pnpm -F extension typecheck`, `pnpm -F extension build`
- supabase: `supabase db reset` 후 `supabase test db` (로컬 Supabase가 켜져 있을 때만. 원격 명령 금지)
- E2E: `pnpm test:e2e` (로컬 스택과 웹 개발 서버가 떠 있을 때)
- prototype: `npm test` (Playwright 프로토타입 스모크, `tests/prototype-smoke.js`. 설치된 Chromium 은 `CHROMIUM_PATH=...`)
- 금지 패턴 검사: `rg -n "NEXT_PUBLIC_.*(KEY|SECRET|TOKEN)|service_role|tailwind\.config|@tailwind base" apps/web` 결과가 0건인지
