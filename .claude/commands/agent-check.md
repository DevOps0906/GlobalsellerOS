---
description: 팀 에이전트 목록 · 모델 · 짝 스킬 정합성 점검 (읽기 전용)
allowed-tools: Read, Glob, Grep, Bash(ls:*), Bash(cat:*), Bash(grep:*), Bash(sed:*)
---

# Agent Check

이 저장소에서 실제로 부를 수 있는 에이전트를 **파일에서 읽어** 보고한다. 파일을 고치지 않는다. 입력: `$ARGUMENTS`

1. `.claude/settings.json`의 `model`(팀장)을 읽는다. `claude-opus-5-5`가 아니면 어긋남으로 보고한다.
2. `.claude/agents/*.md`(README 제외)의 frontmatter 에서 `name` · `model` · `tools` · `disallowedTools`를 읽는다.
3. 각 분야 에이전트(nextjs-expert · supabase-expert · worker-expert)의 짝 스킬(`.claude/skills/<name>/SKILL.md`)과 `references/{conventions,pitfalls,build-and-run}.md`가 있는지 확인한다.
4. 아래를 점검해 어긋난 것을 보고한다.
   - 파일명과 `name`이 같은가
   - 모든 팀원 `model`이 `claude-sonnet-5-5`인가 (사용자 확정 구성: 주 Opus 5.5, 부 Sonnet 5.5. 다르면 의도한 변경인지 `.claude/agents/README.md` 4장에 기록이 있는지 본다)
   - `.claude/agents/README.md` 표 · `docs/MULTI_AGENT.md` 2장 표의 이름 · 모델이 frontmatter 와 같은가
   - 읽기 전용이어야 하는 에이전트(advisor · plan-challenger · review-expert · contract-reviewer · security-auditor)에 `Write` · `Edit`가 없는가
   - 에이전트 · 스킬이 가리키는 문서 경로(`docs/설계/DESIGN_STRUCTURE.md`, `docs/기획서/*`, `docs/개발서/*`, `.claude/commands/check.md`, `tasks/README.md`)가 실제로 있는가
   - 분야 에이전트의 담당 경로가 `docs/설계/DESIGN_STRUCTURE.md` 7장 표와 같은가
5. 결과를 표로 보고한다.

```
| 직급/분류 | 에이전트 | 모델 | 쓰기 | 짝 스킬 | 상태 |
```

어긋난 항목은 "정본(frontmatter) 값 / 문서 값 / 고칠 파일" 형식으로 아래에 나열한다.
