# Proposal

Story: #51

## Why

When `implement-spec` finds that a merged change is wrong or incomplete, it revises the change on its feature branch
today. The fix is then reviewed together with the code. Until the code merges, the default branch shows the wrong spec.
Since #50, `write-spec` can amend a merged change on its own branch. `implement-spec` should pause for that amendment and
then continue on top of it. That keeps the default branch the single source of truth for the spec, and keeps the
progress of unmerged work (ticked tasks) off it.

## What Changes

- When `implement-spec` finds a wrong or incomplete artifact, it stops and tells the user. It recommends a spec fix with
  `write-spec` in amend mode. It no longer revises the change on the feature branch.
  - This replaces both in-branch revision paths: "artifact wrong, Story right" and "Story incomplete" (the latter after
    the user has corrected the Story).
  - The "Story changed" path stays as #48 defined it.
- Pausing:
  - The skill commits the work that is done: it completes a task and the Commands pass.
  - It asks the user about any other uncommitted changes.
  - It pushes nothing.
- Resuming:
  - The skill switches to `feature/<change-name>` first, fetched from origin when it was pushed, so it never checks or
    rebases another branch. An interrupted resume continues where it stopped.
  - It resumes only after the spec fix is merged. It checks this with git: the change is still unarchived on
    `origin/<default-branch>`, and its files there differ from their version at the branch's merge base. The user then
    confirms that the commits that changed them contain the spec fix.
  - It resumes when the user says the spec fix is merged, or when the user re-runs it on the existing
    `feature/<change-name>` and says the branch is paused.
- Rebase onto the amended spec:
  - The skill rebases `feature/<change-name>` onto `origin/<default-branch>`.
  - Conflicts in the change's files take the rebase target's version. A commit that becomes empty is skipped.
  - All other conflicts follow the Finalize history rules of `finish-work`.
  - If the branch was already pushed, its next push uses `--force-with-lease --force-if-includes`. If that push is
    rejected, the skill stops and asks the user.
- Re-check of the tasks:
  - After the rebase, the skill restores the change's files from the default branch, so every task is unticked.
  - It runs the Commands and checks every task against the code and its tests against the amended scenarios. It ticks
    only the tasks that are done and commits the result as one commit, if it differs from `HEAD`.
  - It removes code that the amended change no longer calls for in its own commit, and tells the user.
- `implement-spec` no longer has an Opus 5.5 step. The whole workflow runs on Sonnet 5.5 in the main session; the
  `reviewer` subagent stays on Opus 5.5.
- `AGENTS.md` and `finish-work` allow this rebase and the next force push as an exception to the history rewrite rules.
- `README.md` says that `implement-spec` pauses for a spec fix.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `spec-implementation`:
  - Every step runs on Sonnet 5.5.
  - A wrong or incomplete artifact pauses the workflow for a spec fix instead of revising the change on the branch.
  - New requirements cover:
    - resuming only after the spec fix is merged;
    - the rebase and its push rules;
    - the re-check of every task.

## Impact

- `.agents/skills/implement-spec/SKILL.md`: the intro, steps 1 and 3, and a new "Pause for a spec fix" section.
- `.agents/skills/finish-work/SKILL.md`: the rule against rewriting the history after the first push, and the push of
  fixes.
- `AGENTS.md`: the history rewrite and force push rules of Git Workflow.
- `README.md`: the `implement-spec` entry of the skill list.
- `openspec/specs/spec-implementation/spec.md`, through this change's delta.
- Unchanged: `write-spec` (its amend mode already exists), `implement-story` (it keeps revising its own unmerged
  change), the reviewer agent, the PR template and `check-commits.sh`.
