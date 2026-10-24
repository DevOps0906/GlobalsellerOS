---
description: 다음 대기 작업을 찾아 계획을 세우고 팀(멀티에이전트)으로 진행
---
팀장(이 세션)으로 진행한다. 팀 구성과 위임 기준은 `docs/MULTI_AGENT.md`.

1. `tasks/README.md`의 작업 표에서 상태가 `대기`이고 선행 작업이 모두 `완료`인 가장 앞 번호 작업을 고른다. 웨이브 순서(`docs/기획서/06_AGENT_PLAN.md` 3장)를 넘지 않는다. $ARGUMENTS 에 작업 번호(`GS-06-###` 또는 `###`)가 있으면 그 작업을 고른다.
2. 해당 `tasks/task-###.md`를 읽고, "참고 문서"는 **작업에 필요한 장만** 읽는다. 이름 · 경로 · 상태 값은 `docs/설계/DESIGN_STRUCTURE.md`가 정본이다. 프로토타입에서 값만 뽑는 일(화면 문구 · 표 열 · 상태 이름)과 파일 탐색은 사원(sub-agent-2)에게 맡긴다.
3. 구현 계획을 짧게 정리한다: 바꿀 파일, 순서, 맡길 에이전트, 확인 방법.
   - task 가 마켓 연동 · 가격 공식 · 동기화 규칙 · 주문/발주 · 결제/크레딧 · DB 스키마 · 인증을 건드리면 **plan-challenger**로 계획을 먼저 검증하고 결과(판정)를 함께 보여 준다.
4. 계획을 사용자에게 보여 주고 승인을 받는다.
5. 승인 후 위임한다. 영역별로 nextjs-expert(`apps/web`) · supabase-expert(`supabase/`) · worker-expert(`services/worker` · `packages/{markets,sources,net,compliance}` · `apps/extension`), `packages/domain`과 그 밖의 실무는 대리(sub-agent-1). 한 줄 수정처럼 위임 비용이 더 큰 일은 팀장이 직접 한다. "안 할 것"과 다른 작업의 소유 경로는 누구도 건드리지 않는다.
6. 변경 후 **review-expert**로 리뷰한다. 경계를 넘는 변경(웹 ↔ DB ↔ 워커 ↔ 어댑터 ↔ 확장)이면 contract-reviewer, 마켓 자격증명 · 결제/크레딧 · 권한 · 개인정보 · 확장프로그램 변경이면 security-auditor 를 형제로 함께 부른다. "검증 근거 없음"이 나오면 test-writer 로 테스트를 만들고 다시 리뷰한다.
7. 🔴 지적은 해당 에이전트에게 돌려 고친다. 같은 문제로 2회 이상 막히면 고문(advisor)에게 자문한다.
8. 완료 조건(task 의 완료 조건 + `06_AGENT_PLAN.md` 해당 행의 수용 기준)을 하나씩 확인하고 결과를 표로 보고한다 (누가 무엇을 했는지 포함).
9. `tasks/README.md` 상태를 `완료`로 바꾸고, 루트 CLAUDE.md 6장 형식으로 커밋한다.
