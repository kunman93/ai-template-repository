# Proposal

Story: #61

## Why

The amend mode of `write-spec` (#50, PR #53) was built for one user: the spec-fix pause of `implement-spec` (#51,
PR #58), which was closed as overkill. `implement-spec` keeps revising a wrong spec on its feature branch, so the amend
mode is an unused path that every reader of `write-spec`, `AGENTS.md` and the reviewer has to skip.

## What Changes

- `write-spec` loses its amend mode. It only writes the spec of a Story on `docs/<change-name>-spec`.
  - Its description, intro, steps 0, 1, 3, 4 and 6 drop the amend-mode text.
  - The "Wrong Story (amend mode)" section is removed.
- `AGENTS.md` drops the `docs/<change-name>-spec-fix` branch name and the routing rule for amending a merged spec.
- The reviewer's spec review mode drops its spec-fix branch rules:
  - the mention of `docs/<change-name>-spec-fix`;
  - the "Reported problem" check, which only a spec fix triggers.
- The ticked-task check of the spec review mode stays: it applies to every spec branch.
- `README.md` no longer mentions amend mode in the `write-spec` entry.
- The archived change `2026-11-15-amend-merged-spec-with-write-spec` stays as history.
- Out of scope: any new wrong-Story handling for a new spec. `write-spec` had none before amend mode.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `spec-writing`: the four amend-mode requirements are removed. The requirements on the skill's input, the docs
  branch, research and plan, the reviewer's spec review mode and the routing lose their amend-mode text. Their other
  behavior is unchanged.

## Impact

- `.agents/skills/write-spec/SKILL.md`: description, intro, steps 0, 1, 3, 4 and 6, and the "Wrong Story (amend mode)"
  section.
- `.github/agents/reviewer.agent.md`: the Spec review section.
- `AGENTS.md`: the branch-naming rule and the Implementation Workflow.
- `README.md`: the `write-spec` entry of the skill list.
- `openspec/specs/spec-writing/spec.md`, through this change's delta.
- Unchanged: `implement-spec`, `implement-story`, `finish-work`, the PR template, CI and
  `openspec/changes/archive/2026-11-15-amend-merged-spec-with-write-spec/`.
