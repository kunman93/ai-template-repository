---
name: implement-story
description: 'Implement a Story (a GitHub issue created from the story form) on a feature/ branch: research, OpenSpec change proposal, user approval, implementation, review, PR, archive and merge. Use when the user asks to work on, start, implement or pick up a Story or names a Story issue number.'
---

# Implement a Story

Runs on a `feature/<...>` branch. To create a Story, use the `write-story` skill (`.agents/skills/write-story`); never create one as a free-form issue.

The main session runs on Sonnet 5.5, except steps 3 and 4, which always run on Opus 5.5 in the main session. Step 7 runs the `reviewer` subagent, which is pinned to Opus 5.5 in its agent file. The user names the Story and moves its card on the project board.

## 0. Check workflow setup

- Before step 1, check that the user has provided the Story (an issue number or link). If not, ask the user for one and stop. Do not pick an issue yourself and do not start working. If the user has no Story yet, mention that the `write-story` skill can create one.
- Before starting a step, check the main session model reported in your environment information against the model named in the step.
- If it does not match, or if you cannot tell, tell the user which model to pick with `/model` and stop.
- Also check that the main session runs the default agent, not a custom agent. If it does not, or if you cannot tell, tell the user to switch with `/agent` and stop.
- The check covers the main session only; subagent models are set by their agent file or the `model` argument.

## 1. Create feature branch

Runs on Sonnet 5.5.

- Fetch `<default-branch>` from origin.
- Create a branch `feature/<branch-name-based-on-issue>` based on `origin/<default-branch>`.

## 2. Verify clean state

Runs on Sonnet 5.5. Run all commands in the Commands section of `AGENTS.md`.

## 3. Research

Runs on Opus 5.5.

- Research the issue provided as a prompt with the `openspec-explore` skill (`/opsx-explore`).

## 4. Plan

Runs on Opus 5.5.

- Create a change proposal with the `openspec-propose` skill (`/opsx-propose`).
- Commit the proposal.

## 5. Approve plan

Runs on Sonnet 5.5.

- Ask the user to review the change proposal (the change's artifacts in `openspec/changes/<change>/`) and wait for their explicit approval in the conversation.
- If the user requests changes, return to step 4 (Plan) and revise the proposal with the `openspec-update-change` skill (`/opsx-update`). Step 4 runs on Opus 5.5, so the model check applies.
- Only after approval, continue with step 6 (Implement).

## 6. Implement

Runs on Sonnet 5.5 in the main session.

- Implement the tasks from the change with the `openspec-apply-change` skill (`/opsx-apply`), applying TDD, and make atomic commits with the `.agents/skills/git-commit` skill, following the Engineering Principles in `AGENTS.md`.
- If the implementation shows that an artifact of the change (proposal, specs, design or tasks) is wrong or incomplete, stop and tell the user. Do not work around it.
  - If the Story's intent or acceptance criteria are wrong, `openspec-update-change` cannot fix it because it does not change a change's intent. Instead:
    1. Ask the user to correct the Story issue and wait until they confirm.
    2. Ask the user what to do with the old change and the work already committed, and wait for their decision.
    3. Restart at step 3 (Research), then go through step 4 (Plan) with a new change and step 5 (Approve plan) again. Steps 3 and 4 run on Opus 5.5, so the model check applies.
    4. Resume step 6 only after the user approves the new plan.
  - Otherwise:
    1. Return to step 4 (Plan) and revise the artifacts with the `openspec-update-change` skill (`/opsx-update`). Step 4 runs on Opus 5.5, so the model check applies.
    2. Commit the revised artifacts.
    3. Go through step 5 (Approve plan) again and wait for the user's explicit approval.
    4. Resume step 6 with the updated tasks.
- When done, verify the work with all commands in the Commands section of `AGENTS.md`.
- Then continue directly with step 7 (Review) without asking the user.

## 7. Review

Runs on Sonnet 5.5. The review itself runs in the `reviewer` subagent, which is pinned to Opus 5.5. No `/model` switch is needed, so start it automatically.

Once the implementation is complete, have the reviewer agent
([.github/agents/reviewer.agent.md](../../../.github/agents/reviewer.agent.md)) review the feature branch.
Run it as the custom `reviewer` subagent, not as a general-purpose or code-review agent.

If there are any MAJOR findings, return to step 6 (Implement) and fix them,
then run the review again. Repeat until the reviewer approves without any MAJOR findings.

## 8. Create PR

Runs on Sonnet 5.5.

- Clean up the history, have the `reviewer` subagent review the cleaned-up commits, push the feature branch, create the PR, wait for `ci`, and handle CI failures and PR review
  findings with the `finish-work` skill (`.agents/skills/finish-work`, section "Create PR").
- Do not archive until the user approves.

## 9. Archive

Runs on Sonnet 5.5.

- Wait for the user's explicit approval of the PR in the conversation. GitHub does not allow approving your own PR, so this is the approval.
- Then finalize the history, archive the change with the `openspec-archive-change` skill (`/opsx-archive`), push, and
  wait for `ci` with the `finish-work` skill (sections "Archive" and "Finalize history").

## 10. Merge

Runs on Sonnet 5.5.

- Only when `ci` is green and the user has approved, merge the PR with the `finish-work` skill (section "Merge").
- Never merge without the user's approval.
