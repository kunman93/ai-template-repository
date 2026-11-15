# Tasks

## 1. The implement-spec skill

- [ ] 1.1 Create `.agents/skills/implement-spec/SKILL.md` with the steps of design decision 1, starting from the PR #46
  draft: change check and merged-and-unarchived check (decision 2), Story from `Story: #<n>`, existing-branch check
  (decision 3), `Refs: #<n>` on every commit, the reviewer prompt naming the change and the Story, `Closes #<n>` PR,
  archive and merge after approval. Verify each requirement of `specs/spec-implementation/spec.md` except the
  finish-work one maps to a line of the skill, and that it does not name `main` as a branch.
- [ ] 1.2 Write the wrong-spec handling of step 3 per design decision 4, including the incomplete and changed paths and
  that the agent deletes no branch and opens no PR. Verify each scenario of "A wrong spec goes to the user" maps to a
  line.
- [ ] 1.3 Check the merged-and-unarchived and existing-branch commands in a throwaway clone of this repository (an
  unmerged change, a merged change, an archived change, an existing branch locally and on origin) and verify each
  gives the result its scenario names. Delete the clone afterwards.

## 2. finish-work

- [ ] 2.1 Name `implement-spec` in the description, title and intro of `.agents/skills/finish-work/SKILL.md`, with
  Archive for `implement-story` and `implement-spec`. Verify by reading the intro.
- [ ] 2.2 Make Finalize history sub-step 4 and its intro per-workflow (design decision 5). Verify both scenarios of
  "Finish-work archives the implemented change" in `specs/spec-implementation/spec.md` and both of "Finish-work never
  archives on a write-spec branch" in `openspec/specs/spec-writing/spec.md` against the text.
- [ ] 2.3 Make the Story PR rule of Create PR name the OpenSpec change for `implement-spec` too. Verify against the
  Story PR scenario of `specs/pull-requests/spec.md`.

## 3. Routing and docs

- [ ] 3.1 In `AGENTS.md`, route a Story to `write-spec` and its merged spec to `implement-spec` by default, and to
  `implement-story` only on request (design decision 6). Verify against every scenario of "A Story goes spec-first by
  default" in `specs/spec-writing/spec.md`.
- [ ] 3.2 Change only the `description` of `.agents/skills/write-spec/SKILL.md` and
  `.agents/skills/implement-story/SKILL.md` to the new routing. Verify with
  `git diff origin/main -- .agents/skills/write-spec .agents/skills/implement-story` that only the `description`
  lines change.
- [ ] 3.3 In `README.md`, name `implement-spec` with the Story skills, among the users of `finish-work`, and in the
  workflow overview with the default order. Verify by reading the sections.
- [ ] 3.4 Add `implement-spec` to the template skill list of `.agents/skills/setup-repository/SKILL.md`. Verify with
  `grep -n implement-spec .agents/skills/setup-repository/SKILL.md`.

## 4. Integration checks

- [ ] 4.1 Run `openspec validate add-implement-spec --strict` and verify it passes.
- [ ] 4.2 Verify `openspec/changes/archive/` is unchanged with `git diff --stat origin/main -- openspec/changes/archive`,
  which must be empty.
- [ ] 4.3 Search the workflow skills, the reviewer agent and `AGENTS.md` for `main` used as a branch name and verify
  this change adds no match.
- [ ] 4.4 Search `AGENTS.md`, `README.md` and `.agents/skills/` for every list of workflow skills that names
  `write-spec` and verify each also names `implement-spec`. For `openspec/specs/`, verify each such list has a delta in
  `specs/` of this change, which the archive syncs.

## Workflow follow-up

- Archive the change in the Archive step of `implement-story`, which syncs the delta specs into `openspec/specs/`.
