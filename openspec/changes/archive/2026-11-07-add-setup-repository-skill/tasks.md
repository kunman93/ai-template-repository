# Tasks

## 1. Skill

- [x] 1.1 Create `.agents/skills/setup-repository/SKILL.md` with frontmatter (`name`, a `description` that says when
  to use it) and step 0 (model and default agent check, Sonnet 5.5, `reviewer` pinned to Opus 5.5), matching the
  structure of `do-chore`; verify the skill is listed by Copilot CLI in a new session
- [x] 1.2 Write the gather step: read the default branch, `nameWithOwner` and `viewerPermission` with `gh repo view`,
  the values in `AGENTS.md`, `ci.yml` and `ISSUE_TEMPLATE/config.yml`, the manifests, the other workflows, the
  non-template skills and the effective rules on the default branch; classify each Setup step with the placeholder table in design.md and show one overview; verify
  against the "Freshly created repository", "Repository on main", "Conflicting default branch" and "Commands already
  filled in" and "Own AGENTS.md without template sections" scenarios
- [x] 1.3 Write the change steps: ask per change with current and proposed value; default branch in `AGENTS.md` and
  both `ci.yml` filters; Commands from manifests, asked when unclear, run once before they are written; `ci` steps from
  the confirmed Commands, after asking how they relate to existing workflows; security link; referencing existing
  unreferenced skills and adding named stack skills in `AGENTS.md`; verify against the "Repository on master",
  "Maintainer declines a change", "Node project", "No manifest", "Pipeline in another file", "Existing unreferenced
  skill" and "Maintainer names no stack skill" scenarios
- [x] 1.4 Write the branch, commit, review, PR, finalize and merge steps (reuse a `chore/` branch or create
  `chore/setup-repository`, refuse the default branch, `git-commit`, `reviewer`, `finish-work`) and skip them when
  nothing changed; verify against the "Onboarding branch" and "Nothing to change" scenarios
- [x] 1.5 Write the ruleset step (after the merge, or right away without a PR; `ADMIN` only; only with a `ci` job
  running on pull requests to the default branch; `~DEFAULT_BRANCH`; report GitHub's refusal) and the final report (every step with its outcome, plus describing the project in
  `README.md`); verify against the ruleset and "Final report" scenarios
- [x] 1.6 Check that `SKILL.md` names the default branch only as `<default-branch>`; verify
  `git grep -nwE "main" -- .agents/skills/setup-repository` shows no branch use of `main` apart from the placeholder value
  it detects

## 2. Documentation

- [x] 2.1 Restructure "Adopting the template" in `README.md` into one list (get the files, run `setup-repository`,
  describe the project), move the existing-repository commands into the first item ending with a commit on
  `chore/adopt-template`, drop the separate default branch step, and turn "Setup" into "Manual setup" with the same
  steps in the same order as the skill; verify against the "Two adoption paths", "Manual Setup", "No more work than a
  new repository", "Ruleset step" and "Default branch step" scenarios
- [x] 2.2 Add `setup-repository` to "What is included" in `README.md` and to the Implementation Workflow section of
  `AGENTS.md`; verify both mention it and match the skill's `description`
- [x] 2.3 Run `openspec validate add-setup-repository-skill --strict`; verify it passes

## 3. Verification in git-sandbox

Each scenario runs in a fresh `general-purpose` subagent that follows `SKILL.md` with scripted maintainer answers, on
its own branch of `kunman93/git-sandbox` cut from `origin/master`, onboarded from this feature branch with the README
commands, with a PR to `master` that is closed without merging. Scenarios 1 to 4 run in parallel, each in its own clone of
`git-sandbox` in the session workspace (not a worktree, because the README adds the `template` remote); scenario 5
runs after scenario 2 on its clone.

In every scenario, before the skill runs, also verify onboarding: the listing step prints exactly the colliding files,
`git diff <scenario base commit> --stat -- . ':!AGENTS.md' ':!.agents' ':!.github' ':!docs/decisions' ':!openspec'
':!.editorconfig'` plus a check of every colliding file shows no project file changed, and no `README.md`,
`openspec/specs/` or `openspec/changes/` file came from the template. A small fix to the README onboarding steps this
change rewrites goes into this change; any other onboarding bug is filed with `write-bug-report` and linked in the PR.

- [x] 3.1 Scenario 1, bare repository (`README.md` and `.gitignore` only); verify the skill asks for Commands instead of
  proposing any, `AGENTS.md` and both `ci.yml` filters name `master`, the security link points to `git-sandbox`, `ci`
  runs on the PR, and the ruleset step reports GitHub's 403
- [x] 3.2 Scenario 2, React (Vite, npm) with ESLint and Vitest and no CI; verify the Commands and `ci` steps match
  `package.json`, the commands ran once locally, and `ci` passes on the PR
- [x] 3.3 Scenario 3, Spring Boot with the Maven wrapper and its own `.github/workflows/build.yml`; verify the skill asks
  how `ci` relates to `build.yml` before proposing `ci` steps, applies the chosen option, and `ci` passes on the PR
- [x] 3.4 Scenario 4, Spring Boot with the Gradle wrapper and its own `AGENTS.md`, `ci.yml` (job `build`) and
  `.agents/skills/sandbox-style`, keeping its own `AGENTS.md` and `ci.yml`; verify onboarding lists the colliding
  files, choosing "keep yours" leaves `AGENTS.md` and `ci.yml` byte-identical to the scenario base, the skill offers the Repository and Commands sections and keeps the rest of `AGENTS.md`, keeps `ci.yml`, refuses
  the ruleset because no `ci` job exists, and offers to reference `sandbox-style`
- [x] 3.5 Scenario 5, run the skill again on the branch of scenario 2; verify it reports every step as already set (or
  not done for the reported reasons) and creates no new commit
- [x] 3.6 Rerun scenarios 1 and 4 with the skill as of commit 4db9dd4 (scenario 4 again on the final skill) and close the sandbox PRs and delete their branches; verify `master` of `git-sandbox` is unchanged
- [x] 3.7 Record the results of all scenarios, and which scenarios were checked by review only (design.md), in this
  PR's description

## Workflow follow-up

- Archive the change after the maintainer approves the PR (`implement-story` step 9).
