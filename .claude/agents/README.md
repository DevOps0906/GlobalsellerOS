# `.claude/agents/` — GlobalSeller OS 개발팀

이 폴더의 에이전트는 **팀장(주 세션)** 이 작업을 나눠 맡기는 팀원입니다. 운영 규칙은 [`docs/MULTI_AGENT.md`](../../docs/MULTI_AGENT.md).
팀장 모델은 `.claude/settings.json`(`claude-opus-5-5`)에서 정합니다. 팀원은 모두 `claude-sonnet-5-5`입니다 (사용자 확정: 주에이전트 Opus 5.5, 부에이전트 Sonnet 5.5).

## 1. 직급 (일반 실무)

| 직급 | 파일 | 모델 | 맡는 일 |
|---|---|---|---|
| 고문 | `advisor.md` | `claude-sonnet-5-5` | 팀장이 2회 이상 막힌 문제를 새 맥락에서 다시 보는 2차 의견 (읽기 전용, 비상용) |
| 팀장 | (주 세션) | `claude-opus-5-5` | task 해석 · 분해 · 위임 · 결과 검토 · 커밋 |
| 대리 | `sub-agent-1.md` | `claude-sonnet-5-5` | `packages/domain`, 분야에 속하지 않는 판단 필요 실무 (문서, 여러 영역에 걸친 작은 수정, 리뷰 지적 반영) |
| 사원 | `sub-agent-2.md` | `claude-sonnet-5-5` | 규칙이 정해진 단순 반복 (탐색, 프로토타입 문구 추출, 시드 정리, task 파일 변환, 형식 점검) |

## 2. 분야 에이전트 (구현)

| 파일 | 영역 | 짝 스킬 | 모델 |
|---|---|---|---|
| `nextjs-expert.md` | `apps/web` | `nextjs-expert` | `claude-sonnet-5-5` |
| `supabase-expert.md` | `supabase/` | `supabase-expert` | `claude-sonnet-5-5` |
| `worker-expert.md` | `services/worker` · `packages/{markets,sources,net,compliance}` · `apps/extension` | `worker-expert` | `claude-sonnet-5-5` |

경로별 담당 정본은 `docs/설계/DESIGN_STRUCTURE.md` 7장, 작업별 담당 정본은 `docs/기획서/06_AGENT_PLAN.md` 2장입니다.

## 3. 검증 에이전트

| 파일 | 언제 | 쓰기 | 모델 |
|---|---|---|---|
| `plan-challenger.md` | 마켓 연동 · 가격 · 동기화 · 주문/발주 · 결제/크레딧 · DB · 인증 task 의 **착수 전** 계획 공격 | 없음 | `claude-sonnet-5-5` |
| `review-expert.md` | 모든 구현 task 의 **변경 후** 리뷰 · 추적성 | 없음 | `claude-sonnet-5-5` |
| `contract-reviewer.md` | 웹 ↔ DB ↔ 워커 ↔ 마켓 어댑터 ↔ 확장프로그램 경계를 넘는 변경 | 없음 | `claude-sonnet-5-5` |
| `security-auditor.md` | 마켓 자격증명 · 결제/크레딧 · 권한 · 개인정보 · 확장프로그램 변경, 공개 베타 · 출시 전 | 없음 | `claude-sonnet-5-5` |
| `test-writer.md` | 리뷰가 "검증 근거 없음"을 냈을 때, 수용 기준 고정 | 테스트 경로만 | `claude-sonnet-5-5` |

## 4. 모델 바꾸기

- 정본은 각 파일 frontmatter 의 `model:`입니다. 바꾸면 이 표와 `docs/MULTI_AGENT.md` 2장도 함께 고칩니다.
- tablet-kiosk-core 에서 옮겨 올 때 바꾼 값: `advisor` Fable 5.1 → Sonnet 5.5, `plan-challenger` Opus 5.5 → Sonnet 5.5, `sub-agent-2` Haiku 5.5 → Sonnet 5.5. 나머지는 원래 Sonnet 5.5 였습니다.
- 고문이 같은 모델이라 역할은 "더 강한 모델"이 아니라 "팀장과 다른 맥락의 2차 의견"입니다. 더 깊은 진단이 필요하면 `advisor.md`만 `claude-opus-5-5`(또는 `claude-fable-5-1`)로 올립니다 (비용 큼 — 같은 문제로 막혔을 때만 부르므로 영향은 작음).
- 마켓 연동 · 결제 계획 검토를 더 깊게 하려면 `plan-challenger.md`를 `claude-opus-5-5`로 올립니다.
- 보안 감사를 더 깊게 보려면 `security-auditor.md`만 `claude-opus-5-5`로 올립니다 (공개 베타 전 1회 권장).
- 사원 작업 비용을 줄이려면 `sub-agent-2.md`를 `claude-haiku-5-5`로 내립니다. 위 사용자 확정 구성과 달라지므로 바꿀 때 사용자에게 확인합니다.

## 5. 에이전트 추가

1. 성격이 가까운 파일을 복사해 `<이름>.md`로 저장하고 `name` · `description` · `tools` · `model`을 고칩니다.
2. 이 표와 `docs/MULTI_AGENT.md` 2장에 한 줄 추가합니다.
3. 대리 · 사원 설명에서 넘겨준 업무를 뺍니다.
4. `/agent-check`로 확인합니다.
