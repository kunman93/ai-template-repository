# Proposal

Story: #45

## Why

`implement-story` puts the spec and the code in one branch and one PR. The spec is approved only in the conversation,
and code is written on top of it before the spec is reviewed as a PR and merged. A spec-first workflow lets the spec be
reviewed and merged into the default branch on its own, before any code is written. `implement-story` stays as the
one-PR alternative.

## What Changes

- New skill `write-spec` in `.agents/skills/write-spec`:
  - It takes a Story, or asks for one and stops.
  - It runs the workflow check and names the change from the Story.
  - It creates `docs/<change-name>-spec` from `origin/<default-branch>` and verifies the clean state.
  - It runs research and plan on Opus 5.5, and approve plan on Sonnet 5.5 (the same steps as steps 3–5 of
    `implement-story`).
  - It then creates the PR, finalizes and merges with `finish-work`.
  - The OpenSpec change stays unarchived, and the PR refers to the Story without closing it.
- The proposal of every change written by `write-spec` records its Story as `Story: #<n>`.
- New skill `implement-spec` in `.agents/skills/implement-spec`:
  - It takes the name of an OpenSpec change merged into the default branch, or asks for it and stops.
  - It stops if that change does not exist unarchived in `openspec/changes/` on `origin/<default-branch>`.
  - It creates `feature/<change-name>` and runs implement, review, PR, archive and merge.
  - Its PR closes the Story named in the proposal.
- `implement-story` stays unchanged.
- `finish-work` decides whether to archive by the workflow in use:
  - `implement-spec` always archives its change, although the change was added on the default branch.
  - `implement-story` keeps archiving the change its branch adds.
  - `write-spec`, `fix-bug`, `do-chore` and `setup-repository` never archive.
- `docs/` branches belong to the Story, so every commit on them carries `Refs: #<story>`, and the commit check passes
  the Story number.
- A spec PR marks Story as its type of change and refers to the Story with `Refs #<n>` instead of `Closes #<n>`.
- `AGENTS.md` routes a Story to `write-spec` and then `implement-spec` by default, and to `implement-story` only when the
  user asks for it. `AGENTS.md`, `README.md`, `finish-work` and `setup-repository` name the new skills and the `docs/`
  branch prefix.
- Live specs that list the workflow skills also name `write-spec` and `implement-spec`. Archived changes stay untouched.

## Capabilities

### New Capabilities

- `story-workflow`: how a Story goes from issue to merged code, either spec-first with `write-spec` and
  `implement-spec`, each with its own branch and PR, or in one PR with `implement-story`, and when the OpenSpec change
  is archived.

### Modified Capabilities

- `pull-requests`: `write-spec` and `implement-spec` also open PRs through `finish-work`. A spec PR refers to its Story
  without closing it, and `docs/` branches map to the Story type of change.
- `default-branch`: the workflow skills that must not hard-code the default branch include `write-spec` and
  `implement-spec`.
- `commit-check`: `docs/` branches pass the Story number like `feature/` and `fix/` branches.

## Impact

- New: `.agents/skills/write-spec/SKILL.md` and `.agents/skills/implement-spec/SKILL.md`.
- Unchanged: `.agents/skills/implement-story/SKILL.md`.
- `.agents/skills/finish-work/SKILL.md`: the workflow list, the PR body rule for a spec PR, the archive sub-step of
  Finalize history and the commit check.
- `.agents/skills/setup-repository/SKILL.md`: the list of template skills.
- `AGENTS.md`: branch naming, the `Refs:` trailer rule and the Implementation Workflow.
- `README.md`: the skill list and the workflow overview.
- `openspec/specs/`: `pull-requests`, `default-branch` and `commit-check`, plus the new `story-workflow`.
- No dependencies, scripts or CI changes.
