---
name: implement-spec
description: 'Implement a spec (an OpenSpec change already merged into the default branch by write-spec) on a feature/ branch: implement, review, PR, archive and merge. The PR closes the Story. Use when the user asks to implement a spec or an OpenSpec change, names a change merged by write-spec, or asks to work on a Story whose spec is already merged.'
---

# Implement a Spec

Runs on a `feature/<change-name>` branch. It implements an OpenSpec change that `write-spec` merged into the default branch, and its PR closes the Story. To write the spec first, use the `write-spec` skill (`.agents/skills/write-spec`).

The whole workflow runs on Sonnet 5.5 in the main session. Step 4 runs the `reviewer` subagent, which is pinned to Opus 5.5 in its agent file. The user names the change and moves the Story's card on the project board.

## 0. Check workflow setup

- Before step 1, check that the user has named the OpenSpec change (its name in `openspec/changes/`). If not, ask the user for it and stop. Do not pick a change yourself and do not start working. If the user has no spec yet, mention that the `write-spec` skill can write one.
- Check that the name is kebab-case and contains no `/`. If not, ask the user for a plain change name and stop: a path such as `archive/<date>-<change-name>` would pass the next check.
- Fetch `<default-branch>` from origin and check that the change exists unarchived there: `git cat-file -e origin/<default-branch>:openspec/changes/<change-name>/proposal.md`. If it does not, tell the user that the change is not merged into the default branch, or is already archived, and stop. Do not create a branch.
- Read the Story from the line `Story: #<story>` of that proposal: `git show origin/<default-branch>:openspec/changes/<change-name>/proposal.md`. If the line is missing, ask the user for the Story number and wait.
- Before starting a step, check the main session model reported in your environment information against the model named in the step.
- If it does not match, or if you cannot tell, tell the user which model to pick with `/model` and stop.
- Also check that the main session runs the default agent, not a custom agent. If it does not, or if you cannot tell, tell the user to switch with `/agent` and stop.
- The check covers the main session only; subagent models are set by their agent file or the `model` argument.

## 1. Create feature branch

Runs on Sonnet 5.5.

- If any of these exists, tell the user, ask what to do and create no branch:
  - The branch `feature/<change-name>` locally (`git show-ref --verify refs/heads/feature/<change-name>`).
  - The branch `feature/<change-name>` on origin (`git ls-remote --exit-code --heads origin feature/<change-name>`).
  If the user says that an existing `feature/<change-name>` is paused for a spec fix, resume it with "Pause for a spec fix" below instead.
- Otherwise create a branch `feature/<change-name>` based on `origin/<default-branch>`.

## 2. Verify clean state

Runs on Sonnet 5.5. Run all commands in the Commands section of `AGENTS.md`.

## 3. Implement

Runs on Sonnet 5.5 in the main session.

- Implement the tasks from the change with the `openspec-apply-change` skill, applying TDD, and make atomic commits with the `.agents/skills/git-commit` skill, following the Engineering Principles in `AGENTS.md`. End every commit with the trailer `Refs: #<story>`.
- If the implementation shows that an artifact of the change (proposal, specs, design or tasks) is wrong or incomplete, stop and tell the user. Do not work around it.
  - If the Story itself is wrong, tell the user whether you think it is incomplete (its goal and every existing acceptance criterion hold, and criteria are only added or sharpened) or changed (anything else), with a one-sentence reason. If you are unsure, propose changed. Wait for the user's decision. Ask the user to correct the Story issue and wait until they confirm. Then:
    - Incomplete: after the user confirms the corrected Story, pause for a spec fix (see "Pause for a spec fix"); never change the change's files on the feature branch to fix it.
    - Changed: `openspec-update-change` cannot fix it because it does not change a change's intent. Instead:
      1. Ask the user what to do with the merged change, this branch and the work already committed, and wait for their decision. Recommend removing the obsolete change from the default branch with `do-chore`, so it cannot be implemented later. Do not delete branches or open PRs yourself.
      2. Tell the user to write the new spec with `write-spec` under a new, unused change name. Resume this workflow only for a change merged by it.
  - Otherwise: pause for a spec fix (see "Pause for a spec fix"). Never change the change's files on the feature branch to fix it.
- When done, verify the work with all commands in the Commands section of `AGENTS.md`.
- Then continue directly with step 4 (Review) without asking the user.

## 4. Review

Runs on Sonnet 5.5. The review itself runs in the `reviewer` subagent, which is pinned to Opus 5.5. No `/model` switch is needed, so start it automatically.

Once the implementation is complete, have the reviewer agent
([.github/agents/reviewer.agent.md](../../../.github/agents/reviewer.agent.md)) review the feature branch.
Run it as the custom `reviewer` subagent, not as a general-purpose or code-review agent.
Name the change and the Story in its prompt: the change's artifacts are on `origin/<default-branch>`, so they are not in the branch diff.

If there are any MAJOR findings, return to step 3 (Implement) and fix them,
then run the review again. Repeat until the reviewer approves without any MAJOR findings.

## 5. Create PR

Runs on Sonnet 5.5.

- Clean up the history, have the `reviewer` subagent review the cleaned-up commits, push the feature branch, create the PR, wait for `ci`, and handle CI failures and PR review
  findings with the `finish-work` skill (`.agents/skills/finish-work`, section "Create PR").
- The PR closes the Story with `Closes #<story>` and names the change.
- Do not archive until the user approves.

## 6. Archive

Runs on Sonnet 5.5.

- Wait for the user's explicit approval of the PR in the conversation. GitHub does not allow approving your own PR, so this is the approval.
- Then finalize the history, archive the change with the `openspec-archive-change` skill, push, and
  wait for `ci` with the `finish-work` skill (sections "Archive" and "Finalize history").

## 7. Merge

Runs on Sonnet 5.5.

- Only when `ci` is green and the user has approved, merge the PR with the `finish-work` skill (section "Merge").
- Never merge without the user's approval.

## Pause for a spec fix

Runs on Sonnet 5.5. A merged spec is amended only on the default branch, with `write-spec` in amend mode.

### Pause

1. Commit the work that is done with the `.agents/skills/git-commit` skill. Work is done when it completes a task and the Commands of `AGENTS.md` pass.
2. Ask the user what to do with any other uncommitted change, such as a failing test written before its code. Do not commit, stash or discard it yourself; the rebase needs a clean tree.
3. Tell the user what is wrong and recommend `write-spec` in amend mode with the change name and the problem.
4. Push nothing and stop.

### Resume

Resume when the user says the spec fix is merged, or re-runs this skill on the existing `feature/<change-name>` and says it is paused. Do not rely on `HEAD`: the session is usually on the local `<default-branch>`.

1. Check for an interrupted resume first, because git refuses to switch during a rebase:
   - A rebase is in progress (`git status`): continue it with "Rebase" only if it rebases `feature/<change-name>` and `backup/spec-fix/<change-name>` exists. Otherwise it is another rebase: stop and ask the user.
   - No rebase, but `backup/spec-fix/<change-name>` exists: switch to `feature/<change-name>`.
     - If the branch equals the backup (`git rev-parse` of both), delete the backup and go on with step 2.
     - Otherwise ask the user whether to continue with "Re-check" or to undo with the backup.
2. Fetch and switch:
   1. `git fetch origin <default-branch>`.
   2. `git ls-remote --exit-code --heads origin feature/<change-name>`. Exit 0 means the branch was pushed.
   3. If it was pushed, `git fetch origin +refs/heads/feature/<change-name>:refs/remotes/origin/feature/<change-name>`. If it fails, stop and ask the user.
   4. `git switch feature/<change-name>`. If the branch is only on origin, run `git switch -c feature/<change-name> origin/feature/<change-name>` instead; it continues the paused branch.
   5. If it was pushed, run `git merge-base --is-ancestor origin/feature/<change-name> feature/<change-name>`. If it fails, origin is ahead: stop and ask the user.
3. Merge check, only on `feature/<change-name>`:
   1. `git cat-file -e origin/<default-branch>:openspec/changes/<change-name>/proposal.md`. If it fails, the change is gone (most likely removed with `do-chore`): tell the user and stop.
   2. `base=$(git merge-base feature/<change-name> origin/<default-branch>)`, then `git diff --quiet "$base" origin/<default-branch> -- openspec/changes/<change-name>/`. Exit 0 means the spec fix is not merged yet: tell the user and wait.
   3. Exit 1: show `git log --oneline "$base"..origin/<default-branch> -- openspec/changes/<change-name>/` and ask the user to confirm that it contains the spec fix. Without the confirmation, wait and do not rebase.

### Rebase

1. `git branch -f backup/spec-fix/<change-name>`. It is never the `backup/<branch>` of `finish-work`.
2. `git rebase origin/<default-branch>`. Never rebase the default branch itself.
3. A conflict in a file of `openspec/changes/<change-name>/` takes the default branch's version:
   - The file exists there: `git checkout origin/<default-branch> -- <file>`.
   - The amendment deleted it: `git rm <file>`.
   - A commit that becomes empty: `git rebase --skip`.
4. Every other conflict follows only the three conflict rules of Finalize history sub-step 3 of `finish-work` (trivial: resolve; non-trivial: ask the user; unsure: ask an Opus subagent). Its Commands, review, commit check, push and re-approval do not apply here.
5. Undo a bad resolution with `git rebase --abort` during the rebase, or `git reset --hard backup/spec-fix/<change-name>` after it. Then delete the backup (`git branch -D backup/spec-fix/<change-name>`) and ask the user how to proceed.
6. Push nothing. Do not rely on memory for whether the branch was rewritten: before any later push, run `git fetch origin +refs/heads/feature/<change-name>:refs/remotes/origin/feature/<change-name>` if the branch exists on origin (`git ls-remote --exit-code --heads origin feature/<change-name>`). If `git merge-base --is-ancestor origin/feature/<change-name> HEAD` fails, the rewritten branch has diverged from origin, so the next push uses `git push --force-with-lease --force-if-includes` and the user is told that the PR history was rewritten. If it is rejected, stop and ask the user; never retry with other options. A branch never pushed is pushed in step 5 as usual.

### Re-check

1. Restore the change's files from the commit the branch is based on, not from a newer `origin/<default-branch>`, and verify the diff is empty (every task is now unticked):
   - `base=$(git merge-base HEAD origin/<default-branch>)`
   - `git restore --source="$base" --staged --worktree -- openspec/changes/<change-name>/`
   - `git diff --quiet "$base" -- openspec/changes/<change-name>/`
2. Run the Commands of `AGENTS.md`. If they fail, tell the user and ask whether to undo with the backup (Rebase sub-step 5) or to continue and fix them in step 3.
3. Check every task against the code and its tests against the amended scenarios. A task is done only if the code meets it, its tests assert the amended scenarios and the Commands pass.
4. Tick only the tasks that are done. If `git diff --quiet HEAD -- openspec/changes/<change-name>/` exits 1, commit the change's files as one commit with `git-commit`, for example `docs(openspec): re-check tasks of <change-name> after spec fix`, ending with the `Refs: #<story>` trailer. If it exits 0, commit nothing.
5. Delete the backup: `git branch -D backup/spec-fix/<change-name>`.
6. Remove code the amended change no longer calls for in its own commit and tell the user.
7. Continue step 3 with the unticked tasks. For a task whose test asserts the old behavior, change the test first and see it fail before changing the code.
