# Tasks

## 1. Remove the onboarding skill

- [x] 1.1 Delete `.agents/skills/onboard-repository/` with `git rm -r`. Verify that
  `test ! -e .agents/skills/onboard-repository` succeeds.

## 2. setup-repository

- [x] 2.1 In the front-matter description and the intro of `.agents/skills/setup-repository/SKILL.md`, state that
  the skill fills in the placeholders of a repository created from the template. Drop "adopted this template",
  "finish adopting the template" and the `onboard-repository` and manual-onboarding sentence.
- [x] 2.2 In step 1 (Gather):
  - Start with `git fetch origin` plus GitHub's default branch, then the branch check of design.md ("Only
    `chore/setup-repository`"). When the fetch fails, change nothing and stop.
  - Use GitHub's default branch from `gh repo view` for every ref in the skill, including the rules API call, the
    ruleset precondition and step 7.
  - After it, add the check for `AGENTS.md` (with its Repository and Commands sections), `.github/workflows/ci.yml` and
    `.github/ISSUE_TEMPLATE/config.yml`. When one is missing, the skill stops and says the repository was not created
    from the template.
  - Drop the gathering of other workflows and of non-template skills, the `template` remote and the template-skill
    list.
  - Drop "A missing Repository or Commands section counts as unset".
  - Replace the default-branch classification with the three-row rule of design.md.
  - Drop the kept-`ci.yml` sentence.

  Verify that `grep -n -i -E "template\` remote|kept|counts as unset|other than \`ci.yml\`|mismatch" .agents/skills/setup-repository/SKILL.md`
  prints nothing. Also verify that the overview labels are "to change", "already set", "not done" (which replaces
  "mismatch") and "cannot do" (kept for a ruleset GitHub refuses to read).
- [x] 2.3 In step 2 (Decide):
  - Default branch: propose GitHub's branch for all three places as one change, confirmed or declined as a whole.
    When the step ends not done, stop before any other Setup step and give the final report (step 8), with every
    other step not done because the default branch is unsettled. The ruleset precondition checks `ci.yml`
    as it will be after a confirmed default-branch change. Remove their `TODO` comments. Drop the
    "only `AGENTS.md`" case and the missing-section offer.
  - Drop the missing-Commands-section offer.
  - Remove the "Existing workflows" bullet.
  - Stack skills: drop the offer to reference unreferenced skills.

  Verify that `grep -n -i -E "Existing workflows|workflow_call|unreferenced|template's wording" .agents/skills/setup-repository/SKILL.md`
  prints nothing.
- [x] 2.4 In step 3 (Branch and commit), keep only this branch rule: on `chore/setup-repository`, commit there;
  on the default branch, create `chore/setup-repository` from `origin/` plus GitHub's default branch. Drop the
  template-file check, which now runs in step 1. In step 4 (Check for a PR), check whether `chore/setup-repository`
  has commits that are not on `origin/` plus GitHub's default branch. When it does not exist or has none, skip steps 5
  and 6. Verify that
  `grep -n -E "adopt-template|another \`chore/\`|current branch" .agents/skills/setup-repository/SKILL.md` prints
  nothing.
- [x] 2.5 Read the whole skill and check it against every requirement in
  `specs/repository-setup/spec.md` of this change: the default-branch rule, the template-file check, only placeholder
  values changed, stack skills only added, the branch check and committing only on `chore/setup-repository`, step
  4's check of that branch, the stop on a not-done default branch, and the ruleset precondition against GitHub's
  default branch. List any mismatch and fix it. Verify that
  `grep -n -i -E "onboard|adopt|<default-branch>" .agents/skills/setup-repository/SKILL.md` prints nothing.

## 3. AGENTS.md, finish-work and README

- [x] 3.1 In `AGENTS.md`, remove the `onboard-repository` routing bullet, and make the `setup-repository` bullet name
  `chore/setup-repository` instead of "`chore/` branch". In the OpenSpec CLI sync, change the exception to "Do not do this for a chore that updates OpenSpec." Verify that
  `grep -n -i "onboard" AGENTS.md` prints nothing.
- [x] 3.2 In the Commit check section of `.agents/skills/finish-work/SKILL.md`, change "(including `setup-repository`
  and `onboard-repository`)" to "(including `setup-repository`)". Verify that
  `grep -n "onboard" .agents/skills/finish-work/SKILL.md` prints nothing.
- [x] 3.3 In `README.md`:
  - Remove the `onboard-repository` entry from the skill list.
  - Rewrite "Adopting the template" as: 1. create your repository from this template; 2. run `setup-repository`;
    3. describe your project.
  - Remove the existing-repository path, the `gh skill install` block and its warning text, the
    `gh skill update onboard-repository` paragraph and the manual onboarding `<details>`.
  - Remove the `chore/adopt-template` and existing-repository sentences from item 2 and from "Manual setup".

  Verify that `grep -n -i -E "onboard|adopt-template|existing repo" README.md` prints nothing.

## 4. Integration check

- [x] 4.1 Verify that
  `git grep -n -i -E "onboard-repository|adopt-template|onboarding" -- .agents .github AGENTS.md README.md` prints
  nothing. Verify that
  `git diff --stat origin/main...HEAD -- openspec/changes/archive/2026-11-04-onboard-existing-repositories openspec/changes/archive/2026-11-07-add-onboard-repository-skill`
  is empty, and that `test ! -e .agents/skills/onboard-repository` succeeds. Verify that `openspec validate remove-template-onboarding --strict` passes.

## Workflow follow-up

- Archive the change after the PR is approved. The `retire_capabilities: true` marker in `.openspec.yaml` makes
  archive delete `openspec/specs/template-onboarding/`. Then verify that `test ! -e openspec/specs/template-onboarding`
  succeeds and that `openspec validate repository-setup --type spec --strict` passes. Only the specs this change
  touches are checked: `openspec validate --specs --strict` also fails on `spec-writing`, which #67 fixes.
