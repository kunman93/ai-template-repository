---
name: write-spec
description: 'Write the spec of a Story (a GitHub issue created from the story form) on a docs/ branch: research, OpenSpec change proposal, user approval, review, PR and merge. The change stays unarchived and the PR does not close the Story. This is the default for a Story: use when the user asks to work on, start, pick up, write, plan or spec a Story, or names a Story issue number, unless they ask for implement-story.'
---

# Write a Spec

Runs on a `docs/<change-name>-spec` branch. It ends with the spec, an OpenSpec change, merged into the default branch. It writes no code. `implement-spec` implements the merged change afterwards. To create a Story, use the `write-story` skill (`.agents/skills/write-story`); never create one as a free-form issue.

The main session runs on Sonnet 5.5, except steps 3 and 4, which always run on Opus 5.5 in the main session. The user names the Story and moves its card on the project board.

## 0. Check workflow setup

- Before step 1, check that the user has provided the Story (an issue number or link). If not, ask the user for one and stop. Do not pick an issue yourself and do not start working. If the user has no Story yet, mention that the `write-story` skill can create one.
- Before starting a step, check the main session model reported in your environment information against the model named in the step.
- If it does not match, or if you cannot tell, tell the user which model to pick with `/model` and stop.
- Also check that the main session runs the default agent, not a custom agent. If it does not, or if you cannot tell, tell the user to switch with `/agent` and stop.
- The check covers the main session only; subagent models are set by their agent file or the `model` argument.

## 1. Create docs branch

Runs on Sonnet 5.5.

- Fetch `<default-branch>` from origin.
- Read the Story and derive a kebab-case change name from its title. Tell the user the name. If `openspec/changes/<change-name>/` already exists on `origin/<default-branch>`, or a branch `docs/<change-name>-spec` already exists locally (`git show-ref --verify refs/heads/docs/<change-name>-spec`) or on origin (`git ls-remote --exit-code --heads origin docs/<change-name>-spec`), ask the user for another name.
- Create a branch `docs/<change-name>-spec` based on `origin/<default-branch>`.

## 2. Verify clean state

Runs on Sonnet 5.5. Run all commands in the Commands section of `AGENTS.md`.

## 3. Research

Runs on Opus 5.5.

- Research the issue provided as a prompt with the `openspec-explore` skill (`/opsx-explore`).

## 4. Plan

Runs on Opus 5.5.

- Create the change `<change-name>` with the `openspec-propose` skill (`/opsx-propose`), under the name from step 1.
- Put the line `Story: #<story>` under the title of `proposal.md`. `implement-spec` reads the Story from it.
- Change only the files of the OpenSpec change. Write no code.
- Commit the proposal with the trailer `Refs: #<story>`.

## 5. Approve plan

Runs on Sonnet 5.5.

- Ask the user to review the change proposal (the change's artifacts in `openspec/changes/<change-name>/`) and wait for their explicit approval in the conversation.
- If the user requests changes, return to step 4 (Plan) and revise the proposal with the `openspec-update-change` skill (`/opsx-update`). Step 4 runs on Opus 5.5, so the model check applies. Commit the revision.
- Only after approval, continue with step 6 (Create PR).

## 6. Create PR

Runs on Sonnet 5.5.

- Review step: have the `reviewer` subagent review the docs branch (the change's artifacts), fix MAJOR findings with fixup commits (the Implement step) and repeat until there are none. A finding that needs a revision of the plan goes back to step 4 and then to step 5.
- Clean up the history, have the `reviewer` subagent review the cleaned-up commits, push the docs branch, create the PR, wait for `ci`, and handle CI failures and PR review
  findings with the `finish-work` skill (`.agents/skills/finish-work`, section "Create PR").
- The PR refers to the Story and does not close it.
- Fix CI failures and review findings in the artifacts of the change with fixup commits. If a finding needs a revision of the plan, return to step 4 and then to step 5 for the user's approval.
- Do not finalize until the user approves.

## 7. Finalize

Runs on Sonnet 5.5.

- Wait for the user's explicit approval of the PR in the conversation. GitHub does not allow approving your own PR, so this is the approval.
- Then finalize the history, push, and wait for `ci` with the `finish-work` skill (section "Finalize history"). Never archive the change: it stays in `openspec/changes/` for `implement-spec`.

## 8. Merge

Runs on Sonnet 5.5.

- Only when `ci` is green and the user has approved, merge the PR with the `finish-work` skill (section "Merge").
- Never merge without the user's approval.
- Then tell the user that the spec is merged and that `implement-spec` implements it, naming the change.
