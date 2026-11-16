# Tasks

## 1. implement-spec pause and resume

- [x] 1.1 In `.agents/skills/implement-spec/SKILL.md`, replace the "Otherwise" and "Incomplete" paths of step 3 with a
  pointer to a new section "Pause for a spec fix" (design decision 1), and keep "Changed" as it is. Make the intro
  say that every step runs on Sonnet 5.5 and drop the Opus 5.5 revision. Verify each scenario of "Every step runs on
  its model" and "A wrong spec goes to the user" in `specs/spec-implementation/spec.md` maps to a line, and that no
  line still runs `openspec-update-change`.
- [x] 1.2 Write the pause part of the new section (design decision 2): commit the work that is done (it completes a
  task and the Commands pass), ask about other uncommitted changes, recommend `write-spec` amend mode with the change
  name and the problem, push nothing and stop. Verify against the scenarios of "A pause for a spec fix pushes
  nothing".
- [x] 1.3 Write the resume part (design decision 3): the two triggers, the interrupted-resume check (a rebase in
  progress is continued only if it is of `feature/<change-name>` and `backup/spec-fix/<change-name>` exists, otherwise
  ask; a leftover backup without a rebase, deleted if the branch still equals it), fetching the default branch and, if
  it is on origin, the feature branch, the switch
  to `feature/<change-name>`, the stop when origin is ahead of the local branch, the unarchived check, the merge-base
  diff on the feature branch, and the user's confirmation of the `git log` output, with the "change gone", "not merged
  yet" and "not confirmed" exits. In step 1, let the user say that an existing `feature/<change-name>` is paused, and
  send that case to the resume part. Verify against every scenario of "Resume only after the spec fix is merged" and
  "Resume works on the feature branch".
- [x] 1.4 Write the rebase part (design decision 4): the backup `backup/spec-fix/<change-name>`, the rebase, the
  change-file conflict rule (checkout, or `git rm` for a file the default branch deleted), skipping an empty commit, a
  pointer to only the three conflict rules of Finalize history sub-step 3 of `finish-work` (not its push or
  re-approval), the undo path with the deletion of the backup, and the push rule with its stop on a rejected push.
  Verify against every scenario of "The branch is rebased onto the amended spec".
- [x] 1.5 Write the re-check part (design decision 5): restore the change's files and verify the empty diff, run the
  Commands and ask the user whether to undo or continue if they fail, check every task against the code and its tests
  against the amended scenarios, tick only the tasks that are done, commit if the change's files differ from `HEAD`,
  delete the backup, remove obsolete code in its own commit and tell the user, then continue
  step 3. Verify against every scenario of "Every task is re-checked against the amended spec".
- [x] 1.6 Check the commands of tasks 1.3 to 1.5 in a throwaway clone of this repository with a fake change. Cover:
  - an amendment merged and not merged, and a change removed;
  - resuming from the local default branch, from a clone made before the feature branch was pushed, and with origin
    ahead of the local branch;
  - an interrupted resume (rebase in progress, and a leftover `backup/spec-fix/<change-name>`), another rebase in
    progress without that backup, a resume after each undo path (abort, reset, undo after failing Commands, and the
    user's own `git rebase --abort`), and a second spec fix after a finished resume;
  - a conflict in `tasks.md` resolved to the default branch's version, and a change file the amendment deleted;
  - a tick-only commit that becomes empty, and a tick that replays without a conflict;
  - the empty diff after the restore, a re-check with no task done while `HEAD` has stale ticks, and a re-check whose
    files equal `HEAD`.

  Verify each gives the result its scenario names, and that the default branch is never rebased. Delete the clone
  afterwards.

## 2. History rules

- [x] 2.1 In the Git Workflow section of `AGENTS.md`, name the "Pause for a spec fix" section of `implement-spec` as
  allowed in the rewrite and force push rule and in the Never list (design decision 6). Verify that the rule still
  requires `--force-with-lease --force-if-includes`, and that nothing else is allowed.
- [x] 2.2 In the Create PR section of `.agents/skills/finish-work/SKILL.md`, add the spec-fix rebase of
  `implement-spec` as the one exception to "do not rewrite the history during review", whose next push is a force push.
  Verify against the "Rebase during PR review" scenario.

## 3. Docs

- [x] 3.1 In `README.md`, say in the `implement-spec` part of the skill list that it pauses for a spec fix with
  `write-spec` when the merged spec is wrong. Verify by reading the entry.

## 4. Integration checks

- [x] 4.1 Run `openspec validate pause-implement-spec-for-spec-fix --strict` and verify it passes.
- [x] 4.2 Verify that
  `git diff --stat origin/<default-branch> -- .agents/skills/write-spec .agents/skills/implement-story .github .agents/skills/finish-work/scripts`
  is empty.
- [x] 4.3 Search the changed skill and `AGENTS.md` lines for `main` used as a branch name, and verify this change adds
  no match.

## Workflow follow-up

- Archive the change in the Archive step of `implement-story`, which syncs the delta specs into `openspec/specs/`.
