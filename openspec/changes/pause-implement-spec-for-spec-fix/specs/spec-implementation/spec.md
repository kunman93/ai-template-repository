# Spec Delta

## MODIFIED Requirements

### Requirement: Every step runs on its model
`implement-spec` SHALL run the model and agent checks of its step 0 before each step: every step runs on Sonnet 5.5 in
the main session. On a mismatch, or when the model or agent cannot be told, it SHALL tell the user what to pick and
stop.

#### Scenario: Wrong main session model
- **WHEN** a step runs on a different main session model than the one the step names
- **THEN** the skill tells the user which model to pick with `/model` and stops

#### Scenario: Custom agent
- **WHEN** the main session runs a custom agent
- **THEN** the skill tells the user to switch with `/agent` and stops

### Requirement: A wrong spec goes to the user
When the implementation shows that an artifact of the change is wrong or incomplete, `implement-spec` SHALL stop and
tell the user. If the Story itself is wrong, the user SHALL decide whether it is incomplete or changed. The skill
SHALL NOT work around a wrong artifact and SHALL NOT change the change's files on the feature branch to fix it.

#### Scenario: Artifact wrong, Story right
- **WHEN** an artifact is wrong but the Story holds
- **THEN** the skill pauses for a spec fix: it recommends amending the change with `write-spec` in amend mode, and
  changes none of the change's files on the feature branch

#### Scenario: Story incomplete
- **WHEN** the user decides that the Story is incomplete (its goal and every acceptance criterion hold, and criteria
  are only added or sharpened)
- **THEN** after the user confirms the corrected Story, the skill pauses for a spec fix as for a wrong artifact

#### Scenario: Story changed
- **WHEN** the user decides that the Story changed
- **THEN** the skill asks the user what to do with the merged change, the branch and the committed work, tells the user
  to write a new spec with `write-spec` under a new change name, and itself deletes no branch and opens no PR

## ADDED Requirements

### Requirement: A pause for a spec fix pushes nothing
When `implement-spec` pauses for a spec fix, it SHALL inspect all uncommitted changes, commit the work that is done,
ask the user about any other uncommitted changes, push nothing, and stop. Work is done when it completes a task and the Commands of `AGENTS.md`
pass.

#### Scenario: Pause with finished work
- **WHEN** the skill pauses and the working tree holds work that completes a task, and the Commands pass
- **THEN** it commits that work with the `git-commit` skill, pushes nothing, and stops

#### Scenario: Pause with a file that mixes finished and unfinished work
- **WHEN** the skill pauses and one file holds both work that completes a task and unfinished edits
- **THEN** it asks the user to separate them before it commits, because `git-commit` stages whole paths

#### Scenario: Pause with unfinished work
- **WHEN** the skill pauses and the working tree holds changes that complete no task, or the Commands fail, for
  example a new failing test without its code
- **THEN** it asks the user what to do with them and does not commit or discard them itself

### Requirement: Resume only after the spec fix is merged
`implement-spec` SHALL resume a paused branch only when the change still exists unarchived on
`origin/<default-branch>`, its files there differ from their version at the merge base of `feature/<change-name>` and
`origin/<default-branch>`, and the user confirms that the commits that changed them contain the spec fix. It SHALL
resume when the user says the spec fix is merged, or re-runs it on the existing branch and says it is paused.

#### Scenario: Spec fix merged
- **WHEN** the user asks to resume, the change's files on `origin/<default-branch>` differ from their merge-base
  version, and the user confirms that the commits shown contain the spec fix
- **THEN** the skill rebases the branch onto the amended spec

#### Scenario: Commits not confirmed
- **WHEN** the skill shows the commits that changed the change's files since the merge base and the user does not
  confirm that they contain the spec fix
- **THEN** the skill does not rebase and waits

#### Scenario: Spec fix not merged
- **WHEN** the user asks to resume and the change's files on `origin/<default-branch>` equal their merge-base version
- **THEN** the skill tells the user that the spec fix is not merged yet, does not rebase, and waits

#### Scenario: Change gone
- **WHEN** the user asks to resume and the change no longer exists unarchived on `origin/<default-branch>`
- **THEN** the skill tells the user, does not rebase, and stops

#### Scenario: Re-run on a paused branch
- **WHEN** the user re-runs `implement-spec` on a change whose `feature/<change-name>` exists and says it is paused for
  a spec fix
- **THEN** the skill resumes with the merge check instead of creating a branch

### Requirement: Resume works on the feature branch
Before the merge check, `implement-spec` SHALL switch to `feature/<change-name>`, and SHALL run the merge check and the
rebase only on that branch. If the branch exists only on origin, the local branch that tracks it continues the same
branch and is not a new branch.

#### Scenario: Resume from another branch
- **WHEN** the user asks to resume while the session is on another branch, such as the local `<default-branch>` after
  merging the spec fix
- **THEN** the skill switches to `feature/<change-name>` first, and neither checks nor rebases the other branch

#### Scenario: Branch only on origin
- **WHEN** the user asks to resume and `feature/<change-name>` exists on origin but not locally, including in a clone
  that never fetched it
- **THEN** the skill fetches it, creates the local branch that tracks it, and resumes on it

#### Scenario: Origin ahead of the local branch
- **WHEN** the local `feature/<change-name>` does not contain the tip of `feature/<change-name>` on origin
- **THEN** the skill stops and asks the user, and does not rebase

#### Scenario: Interrupted resume
- **WHEN** the user resumes again and the backup of an earlier resume is left, because its rebase or re-check did not
  finish
- **THEN** the skill continues the rebase if one of `feature/<change-name>` is in progress, without a new backup, which would
  overwrite the original one, or else, if the branch
  differs from the backup, switches to `feature/<change-name>` and asks the user whether to continue with the re-check
  or undo with the backup, instead of running the merge check

#### Scenario: Other rebase in progress
- **WHEN** the user resumes and a rebase is in progress that is not of `feature/<change-name>`, or no backup of a
  resume exists
- **THEN** the skill stops and asks the user, and does not resolve that rebase's conflicts with the resume's rules

#### Scenario: Resume after an undo
- **WHEN** the user undid an earlier resume, through the skill or with their own `git rebase --abort`, and resumes
  again
- **THEN** no backup is left, or the branch still equals it and the skill deletes it, and the skill runs the merge
  check as on a first resume

#### Scenario: Second spec fix
- **WHEN** a resume has finished its re-check, the skill pauses again, and a second spec fix is merged
- **THEN** no backup is left, and the next resume runs the merge check against the first amendment

### Requirement: The branch is rebased onto the amended spec
On resume, `implement-spec` SHALL rebase `feature/<change-name>` onto `origin/<default-branch>`. Conflicts in the
change's files SHALL take the version of the rebase target, read from `.git/rebase-merge/onto`; all other conflicts SHALL follow the three conflict rules of
Finalize history sub-step 3 of `finish-work`. If the branch was already pushed, its next push SHALL use
`--force-with-lease --force-if-includes`.

#### Scenario: Conflict in the change's files
- **WHEN** the rebase stops on a conflict in a file of `openspec/changes/<change-name>/`
- **THEN** the skill resolves it with the version of that file in the rebase target, even if a later fetch moved
  `origin/<default-branch>` on

#### Scenario: Change file deleted in the rebase target
- **WHEN** the rebase stops on a conflict in a file of the change that the rebase target no longer has
- **THEN** the skill removes the file, as the rebase target's version

#### Scenario: Commit becomes empty
- **WHEN** a commit that only ticked tasks becomes empty after the resolution
- **THEN** the skill skips it and the rebase continues

#### Scenario: Bad resolution
- **WHEN** a resolution turns out wrong, during the rebase or before the re-check is finished and the Commands pass
- **THEN** the skill restores the branch as it was before the rebase, deletes the backup, and asks the user how to
  proceed

#### Scenario: Undo with uncommitted edits of the user
- **WHEN** the skill is about to undo and, outside the change's files, the working tree holds an unstaged or untracked
  change that is not an unmerged path (before `git rebase --abort`), or any staged or unstaged change or untracked file that the
  backup tracks (before `git reset --hard`)
- **THEN** it asks the user to preserve or discard it and keeps the backup until the user decides

#### Scenario: Rebase target unreadable
- **WHEN** a conflict needs the rebase target and `.git/rebase-merge/onto` does not exist
- **THEN** the skill stops and asks the user

#### Scenario: Push rejected
- **WHEN** the next push with `--force-with-lease --force-if-includes` is rejected, for example because someone pushed
  to the branch during the pause
- **THEN** the skill stops and asks the user, and does not push again with other options

#### Scenario: Other conflict
- **WHEN** the rebase stops on a conflict outside the change's files
- **THEN** the skill resolves it with the three conflict rules of Finalize history sub-step 3 of `finish-work`, asks
  the user about a non-trivial one, and pushes nothing

#### Scenario: Branch already pushed
- **WHEN** `feature/<change-name>` existed on origin before the rebase
- **THEN** the next push of the branch uses `git push --force-with-lease --force-if-includes`, and the user is told

#### Scenario: Branch never pushed
- **WHEN** `feature/<change-name>` did not exist on origin before the rebase
- **THEN** the branch is pushed for the first time in the Create PR step, as without a pause

### Requirement: The history rules allow the spec-fix rebase
`AGENTS.md` and `finish-work` SHALL allow the spec-fix rebase of `implement-spec` and the next force push as an
exception to their history rewrite and force push rules, also after the PR exists.

#### Scenario: Rebase during PR review
- **WHEN** a finding during PR review sends `implement-spec` back to its Implement step and it pauses for a spec fix
- **THEN** the rebase and the next push with `--force-with-lease --force-if-includes` are allowed, and every other
  fix during review is still a fixup commit pushed normally

### Requirement: Every task is re-checked against the amended spec
After the rebase, the change's files on the branch SHALL match their version at the rebase target, so every task is unticked.
`implement-spec` SHALL then run the Commands of `AGENTS.md`, check every task against the code and its test assertions
against the amended scenarios, tick only the tasks that are done, and remove code the amended change no longer calls
for in its own commit.

#### Scenario: Ticks reset
- **WHEN** the rebase is done
- **THEN** the change's files equal their version at the merge base of `HEAD` and `origin/<default-branch>` before any
  task is ticked again

#### Scenario: Commands before the re-check
- **WHEN** the rebase brought in other changes of the default branch
- **THEN** the skill runs the Commands before it ticks any task, ticks no task whose checks fail, and if they fail asks
  the user whether to undo the rebase or continue

#### Scenario: Task still done
- **WHEN** the code already meets a task of the amended change, its tests assert the amended scenarios, and the
  Commands pass
- **THEN** the skill ticks that task, and commits the re-checked ticks as one commit

#### Scenario: No task done
- **WHEN** the re-check finds no task done, and ticks that replayed without a conflict are still in `HEAD`
- **THEN** the skill commits the reset, so the change's files in `HEAD` match their version at the rebase target

#### Scenario: Nothing to re-commit
- **WHEN** after the re-check the change's files equal those in `HEAD`
- **THEN** the skill makes no re-check commit

#### Scenario: Task no longer done
- **WHEN** the amendment changed a task so that the code no longer meets it
- **THEN** the task stays unticked and the skill implements it in step 3

#### Scenario: Test asserts the old behavior
- **WHEN** a test asserts behavior that an amended scenario changed
- **THEN** the task of that test stays unticked, and in step 3 the skill changes the test to assert the amended
  scenario and sees it fail before it changes the code

#### Scenario: Obsolete code
- **WHEN** the branch contains code that the amended change no longer calls for
- **THEN** the skill removes it in its own commit and tells the user

### Requirement: A resume with an open PR continues the review loop
When the PR of `feature/<change-name>` is already open on resume, `implement-spec` SHALL NOT clean up the history or
create a second PR. After the Review step it SHALL follow the review loop of `finish-work`.

#### Scenario: Resume during PR review
- **WHEN** the skill resumes after a spec fix and `gh pr list --head feature/<change-name> --state open` finds the PR
- **THEN** it finishes the remaining tasks and the Review step, pushes with the guarded push, updates the PR description
  if it is no longer accurate, waits for `ci`, and waits for the user's approval, without a second PR
