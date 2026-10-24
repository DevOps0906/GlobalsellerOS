# worker-expert — build & run

패키지 매니저는 **pnpm**(워크스페이스)이다. 명령은 각 `package.json`의 `scripts`가 정본이다.

| 목적 | 명령 | 비고 |
|---|---|---|
| 의존성 설치 | `pnpm install` (저장소 루트) | 버전 고정 · 잠금 파일 커밋 |
| 워커 실행(로컬) | `pnpm -F worker dev` | 로컬 Supabase(`supabase start`) 필요. env 는 `services/worker/.env.local` |
| 워커 타입체크 | `pnpm -F worker typecheck` | |
| 워커 테스트 | `pnpm -F worker test` | 모의 어댑터 + 로컬 DB |
| 패키지 테스트 | `pnpm -F @gs/markets test`, `pnpm -F @gs/sources test`, `pnpm -F @gs/net test`, `pnpm -F @gs/compliance test` | 패키지 이름은 각 `package.json` 확인 |
| 확장프로그램 빌드 | `pnpm -F extension build` | 결과물을 크롬 "압축해제된 확장 프로그램 로드"로 확인 |
| 마켓 샌드박스 점검 | 팀장이 지시했을 때만, 샌드박스 키로 | 운영 계정 · 운영 키로 테스트하지 않는다 |

- 마켓 · 쿠팡 · LLM 키는 워커 env 에만 둔다(`.env.example`에 이름만). 웹 env 에 같은 키를 두지 않는다.
- 외부 API 를 부르는 테스트는 기본적으로 녹화 응답(fixture) · 모의 어댑터로 돌린다. 네트워크가 필요한 테스트는 별도 스크립트로 분리한다.
- 실행하지 못한 명령은 "미검증"으로 쓰고 통과로 간주하지 않는다.
