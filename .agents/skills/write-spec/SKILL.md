---
name: write-spec
description: 'Write the spec of a Story (a GitHub issue created from the story form) on a docs/ branch: research, OpenSpec change proposal, plan review, user approval, PR and merge. The change stays unarchived and the PR does not close the Story. Use when the user asks to write the spec of a Story or asks for write-spec, or to work on, start or pick up a Story that has no merged, unarchived spec yet. Implement a merged spec with implement-spec.'
---

# Write a Spec

Runs on a `docs/<change-name>-spec` branch. It ends with the spec, an OpenSpec change, merged into the default branch. It writes no code. To create a Story, use the `write-story` skill (`.agents/skills/write-story`); never create one as a free-form issue.

The main session runs on Sonnet 5.5, except steps 3, 4 and 5, which always run on Opus 5.5 in the main session. The `reviewer` subagent in steps 5 and 7 is pinned to Opus 5.5 in its agent file. The user names the Story and moves the Story's card on the project board.

## 0. Check workflow setup

- Before step 1, check that the user has provided the Story (an issue number or link). If not, ask the user for one and stop. Do not pick an issue yourself and do not start working. If the user has no Story yet, mention that the `write-story` skill can create one.
- Before starting a step, check the main session model reported in your environment information against the model named in the step.
- If it does not match, or if you cannot tell, tell the user which model to pick with `/model` and stop.
- Also check that the main session runs the default agent, not a custom agent. If it does not, or if you cannot tell, tell the user to switch with `/agent` and stop.
- The check covers the main session only; subagent models are set by their agent file or the `model` argument.

## 1. Create docs branch

Runs on Sonnet 5.5.

- Fetch `<default-branch>` from origin.
- Read the Story and derive a kebab-case change name from its title. Tell the user the name.
- If any of these exists, ask the user for another name and create no branch until you have one:
  - `openspec/changes/<change-name>/` on `origin/<default-branch>`.
  - The branch `docs/<change-name>-spec` locally (`git show-ref --verify refs/heads/docs/<change-name>-spec`).
  - The branch `docs/<change-name>-spec` on origin (`git ls-remote --exit-code --heads origin docs/<change-name>-spec`).
- Create a branch `docs/<change-name>-spec` based on `origin/<default-branch>`.

## 2. Verify clean state

Runs on Sonnet 5.5. Run all commands in the Commands section of `AGENTS.md`.

## 3. Research

Runs on Opus 5.5.

- Research the issue provided as a prompt with the `openspec-explore` skill.

## 4. Plan

Runs on Opus 5.5.

- Create the change `<change-name>` with the `openspec-propose` skill, under the name from step 1, and put the line `Story: #<story>` under the title of `proposal.md`.
- Change only the files of the OpenSpec change. Write no code.
- Commit the proposal with the `.agents/skills/git-commit` skill and the trailer `Refs: #<story>`.

## 5. Review plan

Runs on Opus 5.5.

- Have the custom `reviewer` subagent ([.github/agents/reviewer.agent.md](../../../.github/agents/reviewer.agent.md)) do a spec review of the docs branch against `origin/<default-branch>` and the Story. Name the Story number in its prompt. Run it as the custom `reviewer` subagent, not as a general-purpose or code-review agent.
- If there is any CRITICAL or MAJOR finding (verdict REQUEST CHANGES), return to step 4 (Plan), fix the findings by revising the proposal with the `openspec-update-change` skill, commit the revision with the trailer `Refs: #<story>` (once the PR exists, as a fixup or new atomic commit as step 6 says), and run the review again. Repeat until the verdict is APPROVE.
- Once the reviewer approves, continue with step 6 (Approve plan).

## 6. Approve plan

Runs on Sonnet 5.5.

- Ask the user to review the change proposal (the change's artifacts in `openspec/changes/<change-name>/`) and tell them which MINOR findings remain. Wait for their explicit approval in the conversation.
- If the user requests changes, return to step 4 (Plan) and revise the proposal with the `openspec-update-change` skill. Step 4 runs on Opus 5.5, so the model check applies. Commit the revision with the trailer `Refs: #<story>`, and go through step 5 again. Once the PR exists, make it a `git commit --fixup=<sha>` commit on the commit it belongs to, or a new atomic commit.
- Only after approval, continue with step 7 (Create PR). If the PR already exists, resume at the push of step 7, without a second cleanup or PR.

## 7. Create PR

Runs on Sonnet 5.5.

- Clean up the history, have the `reviewer` subagent review the cleaned-up commits, push the docs branch, create the PR, wait for `ci`, and handle CI failures and PR review
  findings with the `finish-work` skill (`.agents/skills/finish-work`, section "Create PR").
- The PR refers to the Story and does not close it.
- Triage PR review findings with `finish-work` (section "Read review findings"), then fix CI failures and the valid findings. A consistency fix only brings an artifact in line with what was approved; picking a side in a contradiction is a plan change.
  - A fix of wording, consistency or formatting that does not change meaning is a plain fixup commit that needs no new approval (the Implement step as `finish-work` defines it for `write-spec`). After it, run only the reviewer pass of step 5 with the `reviewer` subagent, with no `/model` switch and no step 6, and repeat until the verdict is APPROVE before pushing, treating a finding that changes meaning as the next bullet says.
  - Any other fix, one that changes a requirement, scenario, design decision or task, goes back to step 4, then through steps 5 and 6. After approval, resume as step 6 says.
- Do not finalize until the user approves.

## 8. Finalize

Runs on Sonnet 5.5.

- Wait for the user's explicit approval of the PR in the conversation. GitHub does not allow approving your own PR, so this is the approval.
- Then finalize the history, push, and wait for `ci` with the `finish-work` skill (section "Finalize history"). Never archive the change: it stays in `openspec/changes/`.

## 9. Merge

Runs on Sonnet 5.5.

- Only when `ci` is green and the user has approved, merge the PR with the `finish-work` skill (section "Merge").
- Never merge without the user's approval.
- Then tell the user that the spec is merged and name the change. The Story stays open.
