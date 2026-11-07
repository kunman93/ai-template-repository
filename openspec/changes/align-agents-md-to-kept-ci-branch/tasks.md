# Tasks

## 1. Skill

- [x] 1.1 In step 1 of `.agents/skills/setup-repository/SKILL.md`, add the Default branch case from design.md
  (`AGENTS.md` holds `main`, every existing `ci.yml` filter names GitHub's default branch and it is not `main`:
  `AGENTS.md` is a placeholder, `ci.yml` is already set) before the "Otherwise" mismatch case; verify by walking the
  "Mixed default branch values", "Kept ci.yml on another branch than GitHub", "ci.yml filters disagree", "Repository
  on master", "Repository on main", "Conflicting default branch" and "Own AGENTS.md and ci.yml already on the default
  branch" scenarios through the rule and confirming each gets its expected outcome
- [x] 1.2 In step 2 (Default branch) of the same file, make the proposal apply to each location that holds `main`, so
  only `AGENTS.md` is proposed in the new case and `ci.yml` and its `TODO` comments stay unchanged; verify against
  the "Mixed default branch values" scenario
- [x] 1.3 Check the skill still names the default branch only as `<default-branch>` outside the placeholder value;
  verify `git grep -nwE "main" -- .agents/skills/setup-repository` shows only placeholder uses of `main`

## 2. Verification in git-sandbox

Each case runs in a fresh `general-purpose` subagent that follows `SKILL.md` of this feature branch with scripted
maintainer answers, in its own clone of `kunman93/git-sandbox` (default branch `master`) in the session workspace, on a
local `chore/` branch cut from `origin/master`. The case first commits the template's `AGENTS.md` (Repository section
naming `main`) and its own `.github/workflows/ci.yml`. Nothing is pushed; the skill stops after step 2 (Decide the
changes), and the clone is deleted afterwards.

- [x] 2.1 Case 1, kept `ci.yml` with both filters on `master`; verify the overview marks the default branch of
  `AGENTS.md` "to change" and `ci.yml` "already set", the skill proposes `main` -> `master` for `AGENTS.md` only, and
  after confirming, `git diff` shows only the Repository line of `AGENTS.md` changed and `ci.yml` byte-identical
- [x] 2.2 Case 2, kept `ci.yml` with both filters on `develop`; verify the overview marks every default branch location
  "mismatch", the skill proposes no default branch change, and `git diff` shows `AGENTS.md` and `ci.yml` unchanged
- [x] 2.3 Record both results in this PR's description; verify `master` of `git-sandbox` is unchanged
  (`git ls-remote` shows the same commit before and after)

## 3. Validation

- [x] 3.1 Run `openspec validate align-agents-md-to-kept-ci-branch --strict`; verify it passes

## Workflow follow-up

- Archive the change after the user approves the PR, which syncs the delta into
  `openspec/specs/repository-setup/spec.md`.
