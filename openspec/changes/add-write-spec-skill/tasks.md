# Tasks

## 1. The write-spec skill

- [ ] 1.1 Create `.agents/skills/write-spec/SKILL.md` with the steps of design decision 8, starting from the PR #46
  draft: Story check, change name and docs branch checks, `Story: #<n>` in the proposal, `Refs: #<n>` on every commit,
  spec-review mode before the PR, review-only resume after a plan revision, `Refs #<n>` PR, no archive, merge after
  approval. Verify each requirement of `specs/spec-writing/spec.md` except the finish-work and routing ones maps to a
  line of the skill, and that it does not name `main` as a branch.
- [ ] 1.2 Make the skill's `description` trigger on writing or specifying a Story only (design decision 7), and verify
  it does not claim "work on, start, pick up a Story".
- [x] 1.3 Add a Spec review mode to `.github/agents/reviewer.agent.md`, following Commit review: name it in the
  description, add the switch under "Your job", and add its section with checks, Commands skipped and its report.
  Verify each scenario of "The reviewer has a spec review mode" in `specs/spec-writing/spec.md` maps to a line.
- [ ] 1.4 Make step 6 of `write-spec` ask for a spec review instead of describing the mode in its prompt, and apply
  "Fixes that change the plan need approval" to every fix in steps 5 and 6. Verify against both requirements.

## 2. finish-work

- [ ] 2.1 Name `write-spec` in the description, title and intro of `.agents/skills/finish-work/SKILL.md`, including
  what its Implement and Review steps mean. Verify by reading the intro.
- [ ] 2.2 Add the spec PR rule (Story, `Refs #<n>`, change named, OpenSpec item ticked) to Create PR. Verify it
  matches the Spec PR scenario of `specs/pull-requests/spec.md`.
- [ ] 2.3 Make Finalize history skip sub-step 4 for `write-spec` and update its intro. Verify both scenarios of the
  "Finish-work never archives on a write-spec branch" requirement against the text.
- [ ] 2.4 Name `docs/` in the commit check section. Verify against `specs/commit-check/spec.md`.

## 3. AGENTS.md, README.md and setup-repository

- [ ] 3.1 In `AGENTS.md`, add `docs/<change-name>-spec` to branch naming, `docs/` to the `Refs:` trailer rule, and an
  opt-in `write-spec` line to the Implementation Workflow next to the unchanged `implement-story` line. Verify against
  the routing requirement of `specs/spec-writing/spec.md`.
- [ ] 3.2 In `README.md`, list `write-spec` with the Story skills, among the users of `finish-work` and in the workflow
  overview. Verify by reading the sections.
- [ ] 3.3 Add `write-spec` to the template skill list of `.agents/skills/setup-repository/SKILL.md`. Verify with
  `grep -n write-spec .agents/skills/setup-repository/SKILL.md`.

## 4. Integration checks

- [ ] 4.1 Run `openspec validate add-write-spec-skill --strict` and verify it passes.
- [ ] 4.2 Verify `.agents/skills/implement-story/SKILL.md` and `openspec/changes/archive/` are unchanged with
  `git diff --stat origin/main -- .agents/skills/implement-story openspec/changes/archive`, which must be empty.
- [ ] 4.3 Search the workflow skills, the reviewer agent and `AGENTS.md` for `main` used as a branch name and verify
  `write-spec` adds no match.

## Workflow follow-up

- Archive the change in the Archive step of `implement-story`, which syncs the delta specs into `openspec/specs/`.
