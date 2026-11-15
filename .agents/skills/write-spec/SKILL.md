---
name: write-spec
description: 'Write the spec of a Story (a GitHub issue created from the story form) on a docs/ branch: research, OpenSpec change proposal, user approval, review, PR and merge. The change stays unarchived and the PR does not close the Story. Use when the user asks to write the spec of a Story or asks for write-spec, or to work on, start or pick up a Story that has no merged, unarchived spec yet. Implement a merged spec with implement-spec.'
---

# Write a Spec

Runs on a `docs/<change-name>-spec` branch. It ends with the spec, an OpenSpec change, merged into the default branch. It writes no code. To create a Story, use the `write-story` skill (`.agents/skills/write-story`); never create one as a free-form issue.

The main session runs on Sonnet 5.5, except steps 3 and 4, which always run on Opus 5.5 in the main session. The `reviewer` subagent in step 6 is pinned to Opus 5.5 in its agent file. The user names the Story and moves its card on the project board.

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

- Research the issue provided as a prompt with the `openspec-explore` skill (`/opsx-explore`).

## 4. Plan

Runs on Opus 5.5.

- Create the change `<change-name>` with the `openspec-propose` skill (`/opsx-propose`), under the name from step 1.
- Put the line `Story: #<story>` under the title of `proposal.md`.
- Change only the files of the OpenSpec change. Write no code.
- Commit the proposal with the `.agents/skills/git-commit` skill and the trailer `Refs: #<story>`.

## 5. Approve plan

Runs on Sonnet 5.5.

- Ask the user to review the change proposal (the change's artifacts in `openspec/changes/<change-name>/`) and wait for their explicit approval in the conversation.
- If the user requests changes, return to step 4 (Plan) and revise the proposal with the `openspec-update-change` skill (`/opsx-update`). Step 4 runs on Opus 5.5, so the model check applies. Commit the revision with the trailer `Refs: #<story>`. Once the PR exists, make it a `git commit --fixup=<sha>` commit on the commit it belongs to, or a new atomic commit.
- Only after approval, continue with step 6 (Create PR). If the PR already exists, resume at the Review step of step 6, push the fixups normally, update the existing PR and its description, wait for `ci`, and continue the PR review loop of step 6. Do not clean up the history again and do not create a second PR.

## 6. Create PR

Runs on Sonnet 5.5.

- Review step: have the `reviewer` subagent
  ([.github/agents/reviewer.agent.md](../../../.github/agents/reviewer.agent.md)) do a spec review of the docs branch
  against `origin/<default-branch>` and the Story. Run it as the custom `reviewer` subagent, not as a general-purpose or
  code-review agent.
- If there is any CRITICAL or MAJOR finding (verdict REQUEST CHANGES), fix it and repeat the Review step until the verdict is APPROVE. A finding that changes a requirement, scenario, design decision or task goes back to step 4 and then to step 5. Only a fix of wording, consistency or formatting that does not change meaning is a fixup commit (the Implement step as `finish-work` defines it for `write-spec`).
- Clean up the history, have the `reviewer` subagent review the cleaned-up commits, push the docs branch, create the PR, wait for `ci`, and handle CI failures and PR review
  findings with the `finish-work` skill (`.agents/skills/finish-work`, section "Create PR").
- The PR refers to the Story and does not close it.
- Fix CI failures and review findings in the artifacts of the change as the Review step says: a fixup commit only for wording, consistency or formatting that does not change meaning (a consistency fix only brings an artifact in line with what was approved; picking a side in a contradiction is a plan change), and step 4 and then step 5 for the user's approval for anything that changes a requirement, scenario, design decision or task. Run the Review step again. After approval, resume as step 5 says, without a second cleanup or PR.
- Do not finalize until the user approves.

## 7. Finalize

Runs on Sonnet 5.5.

- Wait for the user's explicit approval of the PR in the conversation. GitHub does not allow approving your own PR, so this is the approval.
- Then finalize the history, push, and wait for `ci` with the `finish-work` skill (section "Finalize history"). Never archive the change: it stays in `openspec/changes/`.

## 8. Merge

Runs on Sonnet 5.5.

- Only when `ci` is green and the user has approved, merge the PR with the `finish-work` skill (section "Merge").
- Never merge without the user's approval.
- Then tell the user that the spec is merged and name the change. The Story stays open.
