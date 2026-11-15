# Proposal

Story: #50

## Why

A spec that `write-spec` merged can turn out wrong while it is implemented. Today the only fix is to revise the change
on the `implement-spec` feature branch, so the fix is reviewed with the code and the default branch shows the wrong spec
until the code merges. `write-spec` should amend a merged change on its own docs branch, reviewed and merged like the
spec itself, so the default branch stays the single source of truth.

## What Changes

- `write-spec` gets an amend mode, chosen when the user names a merged change to amend instead of a Story:
  - It checks that the change name is kebab-case without `/` and that the change exists unarchived on
    `origin/<default-branch>`, as `implement-spec` does. Otherwise it stops and creates no branch.
  - It reads the Story from the proposal's `Story: #<n>` line. When the line is missing, it asks for the number, and
    the amendment adds the line.
  - It asks what is wrong with the spec when the user has not said.
  - It creates `docs/<change-name>-spec-fix` from `origin/<default-branch>`. If that branch exists locally or on
    origin, it asks the user and creates no branch.
  - It researches with `openspec-explore` and amends the change with `openspec-update-change`, both on Opus 5.5, and
    continues only after the user's explicit approval.
  - Review, PR, finalize and merge are the same as for a new spec: spec review mode, `Refs #<n>` without closing the
    Story, never archived. The spec review prompt also names the problem the user reported.
  - If the Story itself turns out wrong, it stops and asks, as `implement-spec` does: an incomplete Story continues the
    amendment once the issue is corrected; a changed Story ends it, with `do-chore` and a new spec recommended. The
    agent deletes no branch and opens or closes no PR on this path.
- The requirements of `write-spec` for the branch name and for `openspec-propose` apply only to a new spec.
- The reviewer's spec review mode reports a ticked task in the change's `tasks.md` as MAJOR, for every `write-spec`
  branch, and a problem named by the caller that the change does not fix as MAJOR.
- Routing: a request to amend or fix a merged change that the user names goes to `write-spec` in amend mode.
  `AGENTS.md` (Implementation Workflow and branch naming), `README.md` and the `write-spec` description name it.
- Out of scope: pausing `implement-spec` for a spec fix and rebasing onto it (Story #51). Until then, `implement-spec`
  keeps revising the change on its feature branch.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `spec-writing`: `write-spec` takes a merged change to amend, besides a Story; the branch and plan requirements apply
  only to a new spec; new requirements define the amend mode and its wrong-Story exit; the spec review mode reports
  ticked tasks and a reported problem the change does not fix; the routing sends amend requests to `write-spec`.

## Impact

- `.agents/skills/write-spec/SKILL.md`: description, intro, steps 0, 1, 3, 4 and 6 for the amend mode.
- `.github/agents/reviewer.agent.md`: the Spec review section.
- `AGENTS.md`: the Implementation Workflow and the branch-naming rule.
- `README.md`: the `write-spec` entry of the skill list.
- `openspec/specs/spec-writing/spec.md`, through this change's delta.
- Unchanged: `finish-work` (it already never archives for `write-spec` and uses `Refs` for a spec PR),
  `implement-spec`, `implement-story`, the PR template and `check-commits.sh`.
