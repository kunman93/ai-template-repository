---
name: implement-spec
description: 'Implement a spec (an OpenSpec change already merged into the default branch by write-spec) on a feature/ branch: implement, review, PR, archive and merge. The PR closes the Story. Use when the user asks to implement a spec or an OpenSpec change, or names a change merged by write-spec.'
---

# Implement a Spec

Runs on a `feature/<change-name>` branch. It implements an OpenSpec change that `write-spec` merged into the default branch, and its PR closes the Story. To write the spec first, use the `write-spec` skill (`.agents/skills/write-spec`).

The whole workflow runs on Sonnet 5.5 in the main session, except a spec correction in step 3, which runs on Opus 5.5. Step 4 runs the `reviewer` subagent, which is pinned to Opus 5.5 in its agent file. The user names the change and moves the Story's card on the project board.

## 0. Check workflow setup

- Before step 1, check that the user has named the OpenSpec change (its name in `openspec/changes/`). If not, ask the user for it and stop. Do not pick a change yourself and do not start working. If the user has no spec yet, mention that the `write-spec` skill can write one.
- Fetch `<default-branch>` from origin and check that the change exists unarchived there: `git cat-file -e origin/<default-branch>:openspec/changes/<change-name>/proposal.md`. If it does not, tell the user that the change is not merged into the default branch, or is already archived, and stop. Do not create a branch.
- Read the Story from the line `Story: #<story>` of that proposal: `git show origin/<default-branch>:openspec/changes/<change-name>/proposal.md`. If the line is missing, ask the user for the Story number and wait.
- Before starting a step, check the main session model reported in your environment information against the model named in the step.
- If it does not match, or if you cannot tell, tell the user which model to pick with `/model` and stop.
- Also check that the main session runs the default agent, not a custom agent. If it does not, or if you cannot tell, tell the user to switch with `/agent` and stop.
- The check covers the main session only; subagent models are set by their agent file or the `model` argument.

## 1. Create feature branch

Runs on Sonnet 5.5.

- Create a branch `feature/<change-name>` based on `origin/<default-branch>`.

## 2. Verify clean state

Runs on Sonnet 5.5. Run all commands in the Commands section of `AGENTS.md`.

## 3. Implement

Runs on Sonnet 5.5 in the main session.

- Implement the tasks from the change with the `openspec-apply-change` skill (`/opsx-apply`), applying TDD, and make atomic commits with the `.agents/skills/git-commit` skill, following the Engineering Principles in `AGENTS.md`. End every commit with the trailer `Refs: #<story>`.
- If the implementation shows that an artifact of the change (proposal, specs, design or tasks) is wrong or incomplete, stop and tell the user. Do not work around it.
  - If the Story's intent or acceptance criteria are wrong, `openspec-update-change` cannot fix it because it does not change a change's intent. Instead:
    1. Ask the user to correct the Story issue and wait until they confirm.
    2. Ask the user what to do with the merged change and the work already committed, and wait for their decision.
    3. Tell the user to write the new spec with `write-spec`. Resume this workflow only for a change merged by it.
  - Otherwise:
    1. Revise the artifacts with the `openspec-update-change` skill (`/opsx-update`). It runs on Opus 5.5, so the model check applies.
    2. Commit the revised artifacts.
    3. Ask the user to review the revision and wait for their explicit approval in the conversation.
    4. Switch back to Sonnet 5.5 (the model check applies) and resume with the updated tasks.
- When done, verify the work with all commands in the Commands section of `AGENTS.md`.
- Then continue directly with step 4 (Review) without asking the user.

## 4. Review

Runs on Sonnet 5.5. The review itself runs in the `reviewer` subagent, which is pinned to Opus 5.5. No `/model` switch is needed, so start it automatically.

Once the implementation is complete, have the reviewer agent
([.github/agents/reviewer.agent.md](../../../.github/agents/reviewer.agent.md)) review the feature branch.
Run it as the custom `reviewer` subagent, not as a general-purpose or code-review agent.

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
- Then finalize the history, archive the change with the `openspec-archive-change` skill (`/opsx-archive`), push, and
  wait for `ci` with the `finish-work` skill (sections "Archive" and "Finalize history").

## 7. Merge

Runs on Sonnet 5.5.

- Only when `ci` is green and the user has approved, merge the PR with the `finish-work` skill (section "Merge").
- Never merge without the user's approval.
