# Design

## Context

- `implement-story` runs ten steps on one `feature/` branch. Steps 3–5 (research, plan, approve plan) write the
  OpenSpec change.
- `finish-work` is shared by every workflow. Finalize history sub-step 4 archives any unarchived change the branch adds
  (`git diff --diff-filter=A ... -- openspec/changes`). A `write-spec` branch adds its change, so this rule alone would
  archive it.
- The closed PR #46 drafted `write-spec` together with `implement-spec`. This change takes over `write-spec` and leaves
  `implement-spec` to its own Story. See `proposal.md` for the motivation.

## Goals / Non-Goals

**Goals:**

- `write-spec` reads like `implement-story`, `fix-bug` and `do-chore`: numbered steps, a model named per step and the
  approval gates kept in the skill.
- `finish-work` stays the only place that knows how to create, finalize and merge a PR.

**Non-Goals:**

- `implement-spec` and any archive rule for it.
- Changes to `implement-story`, `write-story`, the issue forms, the PR template or `check-commits.sh`.
- A shared extraction of the research, plan and approve plan steps that `write-spec` repeats from `implement-story`.

## Decisions

### 1. The change is named before the branch

`write-spec` derives a kebab-case change name from the Story in step 1, because the branch `docs/<change-name>-spec`
needs it. It passes that name to `openspec-propose`. Before creating the branch, it checks that neither the change on
`origin/<default-branch>` nor the branch (locally or on origin) exists.

- Alternative: branch as `docs/<story-slug>` and rename after planning. Rejected: renaming mid-workflow is error-prone.

### 2. The proposal records the Story

`proposal.md` gets the line `Story: #<n>` under its title, so the later `implement-spec` can read the Story from the
merged change. A field in `.openspec.yaml` was rejected: the CLI generates that file and its schema is not ours.

### 3. Finish-work skips the archive for `write-spec` by workflow

Finalize history sub-step 4 gets one rule in front of the existing check: if the workflow skill in use is `write-spec`,
skip. Otherwise the current diff-based check stays as it is.

- The workflow in use is already explicit in every `finish-work` call, so no detection is needed.
- `finish-work` maps the Implement step of `write-spec` to a fixup commit only for a fix that does not change meaning.
  Anything else goes back to steps 4 and 5 of `write-spec`, because on a spec branch every fix edits the plan.
- Alternative: skip on a `docs/` branch prefix. Rejected: a branch name can be typed wrong and says less than the
  workflow in use.
- The broader per-workflow table of PR #46 is left to the `implement-spec` Story, which needs it.

### 4. `docs/` branches belong to the Story

- `AGENTS.md` lists `docs/<change-name>-spec` with the other prefixes, and its `Refs:` trailer rule names `docs/` next
  to `feature/` and `fix/`.
- The commit check section of `finish-work` passes the Story number on `docs/` branches.
- `check-commits.sh` does not read the branch name, so it stays unchanged.

### 5. A spec PR uses the existing template

The PR marks Story, uses `Refs #<n>` instead of `Closes #<n>`, names the change and ticks the OpenSpec item. One rule
in the Create PR section of `finish-work` says so. A fourth type of change, Spec, was rejected: it would touch the
template, its spec and every adopter for one checkbox.

### 6. Spec review mode lives in the reviewer agent

`reviewer.agent.md` gets a Spec review mode next to Commit review, which the caller asks for. It replaces checks 1 to
10: the reviewer checks the change against the Story and its artifacts against each other, reports changed files
outside the change, treats missing implementation and tests as pending, and runs no Commands. `write-spec` only asks
for a spec review. `finish-work` maps the Review step of `write-spec` to this pass.

- Alternative: describe the mode in the `write-spec` prompt and leave the agent file unchanged. Rejected: the prompt
  would contradict checks 1, 2 and 7 of the agent's own instructions, and a reviewer that follows its file can never
  approve a spec-only branch.

### 7. Opt-in routing

`AGENTS.md` keeps routing a Story to `implement-story` and adds `write-spec` for when the user asks for the spec on its
own. The `write-spec` description triggers on writing or specifying a Story, not on "work on a Story". Until
`implement-spec` exists, a merged spec has no dedicated skill, so making `write-spec` the default would strand Stories.

### 8. Step layout

0 Check workflow setup, 1 Create docs branch, 2 Verify clean state, 3 Research (Opus), 4 Plan (Opus), 5 Approve plan,
6 Create PR (with the spec review first), 7 Finalize, 8 Merge.

## Risks / Trade-offs

- [`write-spec` repeats steps 3–5 of `implement-story`] → Accepted: short prose, and an extraction would couple the two
  skills for little gain.
- [A merged spec waits for `implement-spec`] → Accepted: the Story stays open and `openspec list` shows the change as in
  flight. The `implement-spec` Story follows.
- [The descriptions of `write-spec` and `implement-story` overlap on Stories] → `AGENTS.md` does the routing, and the
  `write-spec` description names only spec requests.

## Migration Plan

- This change runs under `implement-story`, so its own Finalize history archives it under the kept rule.
- Rollback: revert the merge commit.
