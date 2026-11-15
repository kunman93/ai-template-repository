# Tasks

## 1. The implement-spec skill

- [x] 1.1 Create `.agents/skills/implement-spec/SKILL.md` with the steps of design decision 1, starting from the PR #46
  draft: change check and merged-and-unarchived check (decision 2), Story from `Story: #<n>`, existing-branch check
  (decision 3), `Refs: #<n>` on every commit, the reviewer prompt naming the change and the Story, `Closes #<n>` PR,
  archive and merge after approval. Verify each requirement of `specs/spec-implementation/spec.md` except the
  finish-work one maps to a line of the skill, and that it does not name `main` as a branch.
- [x] 1.2 Write the wrong-spec handling of step 3 per design decision 4, including the incomplete and changed paths and
  that the agent deletes no branch and opens no PR. Verify each scenario of "A wrong spec goes to the user" maps to a
  line.
- [x] 1.3 Check the merged-and-unarchived and existing-branch commands in a throwaway clone of this repository (an
  unmerged change, a merged change, an archived change, an existing branch locally and on origin) and verify each
  gives the result its scenario names. Delete the clone afterwards.

## 2. finish-work

- [x] 2.1 Name `implement-spec` in the description, title and intro of `.agents/skills/finish-work/SKILL.md`, with
  Archive for `implement-story` and `implement-spec`. Verify by reading the intro.
- [x] 2.2 Make Finalize history sub-step 4 and its intro per-workflow (design decision 5). Verify both scenarios of
  "Finish-work archives the implemented change" in `specs/spec-implementation/spec.md` and both of "Finish-work never
  archives on a write-spec branch" in `openspec/specs/spec-writing/spec.md` against the text.
- [x] 2.3 Make the Story PR rule of Create PR name the OpenSpec change for `implement-spec` too. Verify against the
  Story PR scenario of `specs/pull-requests/spec.md`.

## 3. Routing and docs

- [x] 3.1 In `AGENTS.md`, route a Story to `write-spec` and its merged spec to `implement-spec` by default, and to
  `implement-story` only on request (design decision 6). Verify against every scenario of "A Story goes spec-first by
  default" in `specs/spec-writing/spec.md`.
- [x] 3.2 Change only the `description` of `.agents/skills/write-spec/SKILL.md` and
  `.agents/skills/implement-story/SKILL.md` to the new routing. Verify with
  `git diff origin/main -- .agents/skills/write-spec .agents/skills/implement-story` that only the `description`
  lines change.
- [x] 3.3 In `README.md`, name `implement-spec` with the Story skills, among the users of `finish-work`, and in the
  workflow overview with the default order. Verify by reading the sections.
- [x] 3.4 Add `implement-spec` to the template skill list of `.agents/skills/setup-repository/SKILL.md`. Verify with
  `grep -n implement-spec .agents/skills/setup-repository/SKILL.md`.

## 4. Integration checks

- [x] 4.1 Run `openspec validate add-implement-spec --strict` and verify it passes.
- [x] 4.2 Verify `openspec/changes/archive/` is unchanged with `git diff --stat origin/main -- openspec/changes/archive`,
  which must be empty.
- [x] 4.3 Search the workflow skills, the reviewer agent and `AGENTS.md` for `main` used as a branch name and verify
  this change adds no match.
- [x] 4.4 Search `AGENTS.md`, `README.md` and `.agents/skills/` for every list of workflow skills that names
  `write-spec` and verify each also names `implement-spec`. For `openspec/specs/`, verify each such list has a delta in
  `specs/` of this change, which the archive syncs.

## 5. Review fixes

- [x] 5.1 In `AGENTS.md`, add the routing lookup of design decision 6 (one match, none, several) for any Story request
  that is not explicit, and route explicit requests for `implement-story` (or the spec and code in one PR), for the
  spec of a Story or for `write-spec` before it. Verify the lookup: `#47` finds nothing in this repository
  (archived), and in a throwaway clone a Story of an unarchived change finds it and two changes for one Story find
  both. Delete the clone afterwards. Verify every scenario of "A Story goes spec-first by default".
- [x] 5.2 Add the change-name check of design decision 2 to step 0 of `implement-spec`. Verify against the scenario
  "Change name is a path".
- [x] 5.3 Make the `implement-spec` skip in Finalize history sub-step 4 of `finish-work` depend on the archive
  (design decision 5). Verify against the three scenarios of "Finish-work archives the implemented change".
- [x] 5.4 Name `feature/<change-name>` for a merged spec in the branch-naming rule of `AGENTS.md`.
- [x] 5.5 Run 4.1, 4.3 and 4.4 again and verify they pass.
- [x] 5.6 Verify `AGENTS.md` against the revised scenarios of "A Story goes spec-first by default" in
  `specs/spec-writing/spec.md`, and run 4.1 again.

## Workflow follow-up

- Archive the change in the Archive step of `implement-story`, which syncs the delta specs into `openspec/specs/`.
