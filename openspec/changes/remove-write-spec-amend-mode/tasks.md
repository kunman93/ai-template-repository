# Tasks

## 1. write-spec

- [ ] 1.1 Remove amend mode from `.agents/skills/write-spec/SKILL.md`: the description, the intro (branch and mode
  list), the amend-mode bullets of steps 0, 1, 3, 4 and 6, "(or the amendment)" and the "Wrong Story (amend mode)"
  section. Keep everything else, including the PR #59 triage step. Verify that
  `grep -n -i -E "amend|spec-fix|spec fix" .agents/skills/write-spec/SKILL.md` prints nothing, and that the
  description and step 0 name only a Story as input.

## 2. Reviewer, AGENTS.md and README

- [ ] 2.1 In the Spec review section of `.github/agents/reviewer.agent.md`, drop "(including
  `docs/<change-name>-spec-fix`)" and the "Reported problem" check, and keep the ticked-task check. Verify that
  `grep -n -i -E "spec-fix|spec fix|amended" .github/agents/reviewer.agent.md` prints nothing and that
  `**Ticked tasks.**` is still there.
- [ ] 2.2 In `AGENTS.md`, drop the `docs/<change-name>-spec-fix` part of the branch-naming rule and the Implementation
  Workflow bullet for amending a merged spec. Verify that `grep -n -i -E "spec-fix|amend or fix|amend mode" AGENTS.md`
  prints nothing.
- [ ] 2.3 In `README.md`, drop the amend-mode clause of the `write-spec` entry. Verify that
  `grep -n -i "amend" README.md` prints nothing.

## 3. Integration check

- [ ] 3.1 Verify that
  `git grep -n -i -E "amend mode|amend or fix|spec-fix|spec fix|amendment|amended" -- . ':!openspec/'` prints
  nothing, that `git diff --stat origin/main -- openspec/changes/archive` is empty, and that
  `openspec validate remove-write-spec-amend-mode --strict` passes.

## Workflow follow-up

- Archive the change after the PR is approved. Then `openspec/specs/spec-writing/spec.md` holds no amend-mode
  requirement.
