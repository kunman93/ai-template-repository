# Proposal

Story: #47

## Why

`implement-story` puts the spec and the code in one branch and one PR. The spec is approved only in the conversation,
and code is written on top of it before the spec is reviewed as a PR and merged. A `write-spec` skill lets the spec of
a Story be reviewed and merged into the default branch on its own, before any code is written. `implement-spec`, which
implements a merged spec, follows in a separate Story.

## What Changes

- New skill `write-spec` in `.agents/skills/write-spec`:
  - It takes a Story, or asks for one and stops.
  - It runs the workflow check, names the change from the Story, creates `docs/<change-name>-spec` from
    `origin/<default-branch>` and verifies the clean state.
  - It runs research and plan on Opus 5.5 and approve plan on Sonnet 5.5, the same steps as steps 3–5 of
    `implement-story`. The proposal records `Story: #<n>` under its title.
  - Before the PR, the `reviewer` reviews the docs branch in spec-review mode: pending implementation and tests are not
    findings. A plan revision after the PR exists resumes only the review, without a second cleanup or PR.
  - A fix that changes the plan goes back to plan and approval. Only fixes that do not change meaning are plain fixups.
  - It creates the PR with `finish-work`, then finalizes and merges after the user's approval. The change is never
    archived, and the PR uses `Refs #<n>`, never `Closes`.
- The `reviewer` agent gains a spec review mode next to its commit review mode, so `write-spec` asks for it instead of
  overriding the agent's checks in a prompt.
- `finish-work`:
  - Never archives on a `write-spec` branch. Today's rule would archive there, because the branch adds the change.
  - The commit check requires the `Refs: #<n>` trailer on `docs/` branches.
  - A spec PR marks Story, uses `Refs #<n>` and names the change.
- `AGENTS.md` names the `docs/` prefix in branch naming and the `Refs:` trailer rule, and routes a Story to
  `write-spec` only when the user asks for the spec on its own. `implement-story` stays the default and stays
  unchanged.
- `README.md` and `setup-repository` name `write-spec`.
- Live specs that list the workflow skills also name `write-spec`. Archived changes stay untouched.

## Capabilities

### New Capabilities

- `spec-writing`: how the spec of a Story is written, reviewed and merged on its own `docs/` branch and PR, without
  code and without archiving the change.

### Modified Capabilities

- `pull-requests`: `write-spec` opens PRs through `finish-work`. A spec PR refers to its Story without closing it, and
  `docs/` branches map to the Story type of change.
- `default-branch`: the workflow skills that must not hard-code the default branch include `write-spec`.
- `commit-check`: `docs/` branches pass the Story number like `feature/` and `fix/` branches.

## Impact

- New: `.agents/skills/write-spec/SKILL.md`.
- Unchanged: `.agents/skills/implement-story/SKILL.md`, the PR template, `check-commits.sh`.
- `.github/agents/reviewer.agent.md`: the spec review mode.
- `.agents/skills/finish-work/SKILL.md`: the workflow list, the spec PR rule, the archive sub-step and the commit
  check.
- `.agents/skills/setup-repository/SKILL.md`: the list of template skills.
- `AGENTS.md`: branch naming, the `Refs:` trailer rule and the Implementation Workflow.
- `README.md`: the skill list and the workflow overview.
- `openspec/specs/`: `pull-requests`, `default-branch` and `commit-check`, plus the new `spec-writing`.
- No dependencies, scripts or CI changes.
