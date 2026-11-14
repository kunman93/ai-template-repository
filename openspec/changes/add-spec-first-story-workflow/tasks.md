# Tasks

## 1. write-spec

- [x] 1.1 Create `.agents/skills/write-spec/SKILL.md` with the steps of design.md decision 8:
  - frontmatter `name` and `description` in the style of `fix-bug`
  - the Story check and the workflow check of step 0
  - the change name from the Story (decision 1) and the `docs/<change-name>-spec` branch
  - research and plan on Opus 5.5, with the `Story: #<n>` proposal line (decision 2)
  - approve plan on Sonnet 5.5
  - a reviewer pass on the docs branch before the PR (decision 10)
  - a check that neither the change nor the `docs/` branch exists yet, and the `Refs` trailer on its commits
  - Create PR, Finalize and Merge through `finish-work`, with no archive

  Verify by walking every write-spec scenario of `specs/story-workflow/spec.md` through the text.

## 2. implement-spec

- [ ] 2.1 Create `.agents/skills/implement-spec/SKILL.md`, starting from steps 6–10 of `implement-story`, per design.md
  decisions 6–8:
  - step 0 (Check workflow setup), as in `fix-bug`:
    - a model check before every step: Sonnet 5.5 for all steps, and Opus 5.5 for a spec correction with
      `openspec-update-change`
    - the default-agent check
  - the change-name check and the merged-spec check
  - the Story read from the proposal line, or asked for when the line is missing
  - the `feature/<change-name>` branch
  - the adapted spec-correction rule
  - `Closes #<n>` through `finish-work`

  Verify by walking every implement-spec scenario of `specs/story-workflow/spec.md` through the text. Then confirm that
  `git diff origin/main -- .agents/skills/implement-story` is empty.

## 3. finish-work

- [ ] 3.1 In `.agents/skills/finish-work/SKILL.md`, add `write-spec` and `implement-spec` to the frontmatter and the
  intro list of workflows, next to `implement-story`. Verify by reading both.
- [ ] 3.2 In Create PR, add the spec PR rule (decision 5): Type Story, `Refs #<n>` instead of `Closes`, and the change
  named. Verify against the "Spec PR" scenario of `specs/pull-requests/spec.md`.
- [ ] 3.3 Replace Finalize history sub-step 4 and its intro with the rule of decision 3. Verify against the four
  scenarios of "Archiving depends on the workflow".
- [ ] 3.4 In Commit check, pass the Story number on `docs/` branches. Verify against the "Spec branch" scenario of
  `specs/commit-check/spec.md`.

## 4. Documentation and other skills

- [ ] 4.1 In `AGENTS.md`:
  - add `docs/<change-name>-spec` to branch naming
  - add `docs/` to the `Refs:` trailer rule
  - in Implementation Workflow, route a Story per decision 9

  Verify against the "Reader looks up the rule" scenario and the two scenarios of "A Story goes spec-first by default".
- [ ] 4.2 In `README.md`, add the new skills to the skill list and the `finish-work` entry. Describe the default flow
  `write-story` → `write-spec` → `implement-spec`, with `implement-story` as the one-PR alternative. Verify by reading
  the changed places.
- [ ] 4.3 In `.agents/skills/setup-repository/SKILL.md`, add `write-spec` and `implement-spec` to the list of template
  skills. Verify by reading the list.

## 5. Integration checks

- [ ] 5.1 Run `openspec validate add-spec-first-story-workflow --strict`. Confirm that every file listing the workflow
  skills names `write-spec` and `implement-spec`. Find these files by searching the repository for `fix-bug`, outside
  `openspec/changes/archive/`.
- [ ] 5.2 In `kunman93/git-sandbox`, on a throwaway branch, run the merged-spec check of decision 6 against three
  states of a sample change: added on an unmerged `docs/` branch, merged into the default branch, and archived. Confirm
  that only the merged state passes. Leave the default branch of the sandbox unchanged and delete the branch.
