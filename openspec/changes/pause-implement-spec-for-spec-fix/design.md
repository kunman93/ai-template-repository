# Design

## Context

- `implement-spec` step 3 has three exits for a wrong spec: "Otherwise" and "Incomplete" revise the change on the
  feature branch with `openspec-update-change` on Opus 5.5; "Changed" hands over to `do-chore` and `write-spec`.
- `write-spec` amend mode (#50) amends a merged change on `docs/<change-name>-spec-fix` and merges it into the default
  branch with no task ticked. The reviewer reports any ticked task on such a branch as MAJOR.
- On a feature branch, `openspec-apply-change` ticks tasks in the change's `tasks.md`, and the ticks are committed with
  the code. Those hunks are what conflict with an amendment.
- `AGENTS.md` allows history rewrites and force pushes only in the Create PR, Finalize history and Merge procedures of
  `finish-work`. `finish-work` forbids rewriting after the first push and pushes review fixes normally.
- See `proposal.md` for the motivation.

## Goals / Non-Goals

**Goals:**

- One place, the default branch, where a merged spec is amended.
- Resuming is mechanical: a git check, a rebase with one fixed rule for the change's files, and a re-check.

**Non-Goals:**

- Changes to `write-spec`, the reviewer agent, the PR template or `check-commits.sh`.
- `implement-story`, which revises its own change before it is merged and so never needs a spec fix.
- Detecting a wrong spec automatically. The agent still decides that while it implements.

## Decisions

### 1. A pause replaces both in-branch revisions

"Otherwise" and "Incomplete" both become "Pause for a spec fix", a new section of `implement-spec`. "Changed" stays as
it is.

- An incomplete Story only adds or sharpens criteria, which `write-spec` amend mode handles, so it pauses after the user
  has corrected the Story, like a wrong artifact.
- With no revision on the branch, `implement-spec` has no Opus 5.5 step left. The intro and the model requirement say
  Sonnet 5.5 throughout.
- Alternative: keep the in-branch revision as a fallback. Rejected: two ways to amend a merged spec are what #50 and
  this Story remove.

### 2. Pause

1. Commit the work that is done with `git-commit`. Work is done when it completes a task and the Commands of
   `AGENTS.md` pass. Ask the user about any other uncommitted change, such as a failing test written before its code
   (TDD), since the rebase needs a clean tree.
2. Tell the user what is wrong, and recommend `write-spec` in amend mode with the change name and the problem.
3. Push nothing and stop.

- Alternative: `git stash` the rest. Rejected: a stash is easy to lose across sessions and branch switches; the user
  decides.

### 3. Resume and the merge check

The skill resumes when the user says the spec fix is merged, or when a re-run of `implement-spec` finds
`feature/<change-name>` (step 1 asks what to do) and the user says the branch is paused.

After merging a spec fix, the session is usually on the local `<default-branch>`, so the check never relies on `HEAD`.
It fetches both branches, switches first and names the feature branch explicitly:

```text
git fetch origin <default-branch>
git ls-remote --exit-code --heads origin feature/<change-name>   # exit 0 = pushed; run again before any later push
git fetch origin +refs/heads/feature/<change-name>:refs/remotes/origin/feature/<change-name>   # only if pushed
git switch feature/<change-name>        # if only on origin: git switch -c feature/<change-name> origin/feature/<change-name>
git merge-base --is-ancestor origin/feature/<change-name> feature/<change-name>   # only if pushed
git cat-file -e origin/<default-branch>:openspec/changes/<change-name>/proposal.md   # still unarchived
base=$(git merge-base feature/<change-name> origin/<default-branch>)
git diff --quiet "$base" origin/<default-branch> -- openspec/changes/<change-name>/  # exit 1 = amended
git log --oneline "$base"..origin/<default-branch> -- openspec/changes/<change-name>/
```

- Fetching the feature branch makes `git switch` work in a clone that never fetched it, and keeps the remote-tracking
  ref current.
- A tracking branch created from origin by `git switch` continues the paused branch. It is not the new branch that
  step 1 refuses to create.
- The local branch does not contain the tip on origin (someone pushed to it, or another machine has newer work): stop
  and ask the user.
- An interrupted resume is checked before anything else, because git refuses to switch during a rebase:
  - A rebase is in progress (`git status`): continue it with decision 4 only if it rebases `feature/<change-name>` and
    `backup/spec-fix/<change-name>` exists. Only a resume creates that backup, so without it the rebase is another one,
    for example from Finalize history. Otherwise ask the user.
  - No rebase is in progress, but `backup/spec-fix/<change-name>` exists: switch to `feature/<change-name>`.
    - If the branch equals the backup (`git rev-parse` of both), the rebase never ran or was aborted outside the skill:
      delete the backup and go on with the merge check.
    - Otherwise ask the user whether to continue with the re-check of decision 5 or to undo with that backup.
  - The backup exists only from the start of decision 4 until the end of decision 5 or an undo, so it always means an
    unfinished resume.
  - After a finished rebase the merge check would see no difference, so it cannot detect either state.
- The change is gone: tell the user and stop. Most likely the Story changed and `do-chore` removed it.
- No difference: the spec fix is not merged yet, so tell the user and wait.
- A difference: show the user the `git log` output and ask them to confirm that it contains the spec fix. Any edit to
  the change's files passes the diff, for example a link fix by `do-chore`, so the diff alone does not prove that this
  spec fix is merged. Without the confirmation, wait.
- Alternative: look up a merged `docs/<change-name>-spec-fix` PR with `gh`. Rejected: it depends on the branch name and
  the API. The git diff checks the very thing the rebase needs.
- A second spec fix works the same way: after the first rebase the merge base moves up, so the check compares against
  the first amendment.

### 4. Rebase

1. Run `git branch -f backup/spec-fix/<change-name>`. It has its own name, so it is never mistaken for the
   `backup/<branch>` of `finish-work`, which can outlive a pause during Finalize history.
2. Run `git rebase origin/<default-branch>`.
3. A conflict in a file of `openspec/changes/<change-name>/` takes the default branch's version, as the Story asks:
   - The file exists on the default branch: `git checkout origin/<default-branch> -- <file>`.
   - The amendment deleted it: `git rm <file>`.

   The ticks this drops come back in decision 5. A commit that only ticked tasks can become empty: skip it with
   `git rebase --skip`.
4. Every other conflict follows only the three conflict rules of Finalize history sub-step 3 of `finish-work`: trivial
   conflicts are resolved, non-trivial ones go to the user, and unsure ones go to an Opus subagent. The rest of that
   sub-step (Commands, review, commit check, push and re-approval) does not apply here; decision 5 runs the Commands.
5. Undo a bad resolution with `git rebase --abort` during the rebase, or `git reset --hard backup/spec-fix/<change-name>`
   after it. Then delete the backup, so that the next resume runs the merge check again, and ask the user how to
   proceed.
6. The backup is deleted only after an undo (sub-step 5) or at the end of decision 5.

- Push: nothing during the pause. Before any later push, the skill does not rely on memory: if the branch is on origin and
  `git merge-base --is-ancestor origin/feature/<change-name> HEAD` fails after a fetch, the branch was rewritten and the
  next push uses
  `--force-with-lease --force-if-includes`, and the user is told that the PR history was rewritten. If that push is
  rejected (someone pushed to the branch during the pause), stop and ask the user; never retry with other options.
- Alternative: merge `origin/<default-branch>` into the branch. Rejected: Finalize history rebases anyway, and a merge
  commit breaks the commit check and the atomic history.

### 5. Reset and re-check the ticks

1. After the rebase, restore the change's files and check that they match the default branch. Every task is now
   unticked, including ticks that the rebase replayed without a conflict:

   ```text
   base=$(git merge-base HEAD origin/<default-branch>)   # the commit rebased onto, even if origin moved on
   git restore --source="$base" --staged --worktree -- openspec/changes/<change-name>/
   git diff --quiet "$base" -- openspec/changes/<change-name>/
   ```

2. Run the Commands of `AGENTS.md`: the rebase brought in the default branch's other changes. A task whose checks fail
   is not done. If they fail, tell the user and ask whether to undo with the backup (decision 4, sub-step 5) or to
   continue and fix them in step 3.
3. Check every task against the code and its tests against the amended scenarios. A task is done only if the code
   meets it, its tests assert the amended scenarios, and the Commands pass. A task whose test asserts behavior that an
   amended scenario changed stays unticked.
4. Tick the tasks that are done. The restore changed only the working tree and the index, so `HEAD` can still hold
   ticks that replayed without a conflict. Compare with `HEAD`: if
   `git diff --quiet HEAD -- openspec/changes/<change-name>/` exits 1, commit the change's files as one commit with
   `git-commit`, for example `docs(openspec): re-check tasks of <change-name> after spec fix`. This also commits a
   reset of stale ticks when no task is done. If it exits 0, there is nothing to commit.
5. Delete the backup: `git branch -D backup/spec-fix/<change-name>`.
6. Remove code that the amended change no longer calls for in its own commit, and tell the user.
7. Continue step 3 with the unticked tasks. For a task whose test asserts the old behavior, change the test first and
   see it fail before changing the code (TDD).

- Alternative: rely on conflict resolution alone. Rejected: ticks on lines the amendment did not touch replay without a
  conflict, so a task whose meaning changed elsewhere (in the specs or design) would stay ticked.

### 6. History rules

- `AGENTS.md` names the "Pause for a spec fix" section of `implement-spec` next to the `finish-work` procedures, both in
  the rewrite rule and in the force push rule of the Never list.
- In `finish-work`, the rule "After the first push, do not rewrite the history during review" gets the exception: the
  spec-fix rebase of `implement-spec`, whose next push is a force push. All other review fixes stay fixup commits pushed
  normally.
- After that force push, the existing rule to check the PR description against the branch applies.

## Risks / Trade-offs

- [The rebase rewrites a pushed branch during review, so the user loses the incremental view of the fixups] → The skill
  tells the user. The fixup commits survive the rebase and are still squashed in Finalize history.
- [`git checkout origin/<default-branch> -- <file>` during the rebase can leave an intermediate commit whose `tasks.md`
  hunk unticks lines] → Decision 5 normalizes the final state, which is what the archive keeps. Before the first push,
  the Create PR history cleanup can fold such hunks; after it, they stay as small `tasks.md` hunks in their commits.
- [The agent misjudges a task as done in the re-check] → The `reviewer` subagent checks the branch against the change in
  step 4 as before.
