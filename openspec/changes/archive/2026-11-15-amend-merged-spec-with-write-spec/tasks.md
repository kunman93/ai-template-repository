# Tasks

## 1. write-spec amend mode

- [x] 1.1 In `.agents/skills/write-spec/SKILL.md`, add the amend mode to the description and intro (design decision
  1), and to step 0: the change-name, merged-and-unarchived and `Story: #<n>` checks of `implement-spec`, and asking
  what is wrong when the user has not said (design decision 2). Verify each scenario of "A skill writes the spec of a
  Story" and "The amend mode starts from a merged change" in `specs/spec-writing/spec.md` maps to a line, except the
  branch ones (1.2), and that the narrowed "The spec gets its own docs branch" and "Research, plan and approval match
  implement-story" still map to the new-spec lines of steps 1, 3 and 4.
- [x] 1.2 Add the amend-mode branch `docs/<change-name>-spec-fix` and its existence checks to step 1 (design decision
  3). Verify the "Merged change" and "Spec-fix branch exists" scenarios against the text.
- [x] 1.3 Add the amend-mode lines to steps 3 and 4: research the problem against the merged change and the Story,
  amend with `openspec-update-change`, keep the `Story:` line (or add it with the number confirmed in step 0 when it
  was missing) and tick no task. Verify each scenario of "An amendment is revised on Opus and approved" maps to a line
  of steps 3–5, and that step 4 adds the line of "Story line missing" under the proposal title with the confirmed
  number.
- [x] 1.4 Add the wrong-Story exit to amend mode (design decision 6), reachable from steps 3–6. Verify each scenario
  of "A wrong Story is handled as in implement-spec" maps to a line, including that the agent deletes no branch and
  closes no PR.
- [x] 1.5 Make steps 6 and 8 name the amended change in the reviewer prompt, the PR and the final message, and in amend
  mode give the reviewer the problem the user reported, so it checks that the amendment fixes it. Verify each
  scenario of "A spec fix is merged like a spec" maps to a line of steps 6–8 or to the existing `finish-work` spec PR
  rule, and that the step 6 reviewer prompt names the reported problem.
- [x] 1.6 Check the step 0 and step 1 commands in a throwaway clone of this repository: a merged change, an archived
  change, a change only on an unmerged branch, a path as the name, and an existing spec-fix branch locally and on
  origin. Verify each gives the result its scenario names. Delete the clone afterwards.

## 2. Reviewer

- [x] 2.1 In the Spec review section of `.github/agents/reviewer.agent.md`, report any ticked task in the change's
  `tasks.md` as MAJOR, and a problem named by the caller that the change does not fix as MAJOR (design decision 4),
  and say that the mode also covers an amendment on `docs/<change-name>-spec-fix`. Verify against the "Ticked task"
  and "Reported problem not fixed" scenarios.

## 3. Routing and docs

- [x] 3.1 In `AGENTS.md`, route a request to amend or fix a merged change that the user names to `write-spec` in amend
  mode, above the `implement-spec` entry for a named merged spec, and name `docs/<change-name>-spec-fix` in the
  branch-naming rule (design decision 5). Verify against every scenario of "A Story goes spec-first by default".
- [x] 3.2 In `README.md`, say in the `write-spec` entry that it also amends a merged spec. Verify by reading the entry.

## 4. Integration checks

- [x] 4.1 Run `openspec validate amend-merged-spec-with-write-spec --strict` and verify it passes.
- [x] 4.2 Verify
  `git diff --stat origin/<default-branch> -- openspec/changes/archive .agents/skills/implement-spec .agents/skills/finish-work`
  is empty.
- [x] 4.3 Search the changed skill, agent and `AGENTS.md` lines for `main` used as a branch name and verify this
  change adds no match.

## Workflow follow-up

- Archive the change in the Archive step of `implement-story`, which syncs the delta specs into `openspec/specs/`.
