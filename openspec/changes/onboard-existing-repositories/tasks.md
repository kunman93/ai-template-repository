# Tasks

## 1. Default branch setting

- [x] 1.1 Add a Repository section to `AGENTS.md` with `Default branch: main` and the rule that `<default-branch>` in
  any skill or agent file stands for that value, and replace `main` as a branch in its Git Workflow section; verify
  against the "Template value" scenario
- [x] 1.2 Replace `main` as a branch with `<default-branch>` in `.agents/skills/{implement-story,fix-bug,do-chore,finish-work}/SKILL.md`
  and `.github/agents/reviewer.agent.md`, leaving "main session" untouched; verify with
  `git grep -nwE "main" -- AGENTS.md .agents/skills/implement-story .agents/skills/fix-bug .agents/skills/do-chore .agents/skills/finish-work .github/agents`
  that the only branch match left is the value in the Repository section
- [ ] 1.3 Make `.github/workflows/ci.yml` trigger on `pull_request` and `push` without branch filters and add
  `if: github.event_name == 'pull_request' || github.ref_name == github.event.repository.default_branch` to the `ci`
  job; verify `ci.yml` no longer names a branch and that `ci` runs on this Story's PR
- [x] 1.4 Update the Purpose of `openspec/specs/ci-check/spec.md` from "the branch ruleset on `main`" to "the branch
  ruleset on the default branch"; verify `openspec validate --specs --strict` passes
- [x] 1.5 Record the decision as `docs/decisions/0001-declare-the-default-branch-in-agents-md.md` from
  `adr-template.md`, with the options from design.md; verify it follows `docs/decisions/README.md`

## 2. Commands work before they are documented

- [x] 2.1 In a throwaway repository under the session workspace (not in this repository) with branch `master`, a
  `README.md` and a `.gitignore`, add this repository as the `template` remote and run the listing and copy commands from
  design.md in both bash and zsh against this feature branch; verify the listing prints exactly `.gitignore`, the copy
  adds every other onboarding file staged and leaves `README.md` and `.gitignore` unchanged, and no file under
  `openspec/specs/` or `openspec/changes/` appears
- [x] 2.2 In the same throwaway repository, run the keep, take and compare commands for `.gitignore`; verify each has the
  described effect, then delete the throwaway repository

## 3. README

- [x] 3.1 Split "Adopting the template" in `README.md` into "New repository", "Existing repository" and "Setup" (today's
  steps 2 to 7, with the ruleset step targeting the default branch and a step to set the default branch in `AGENTS.md`
  if it is not `main`); verify against the "Two adoption paths" and "Ruleset step" scenarios
- [x] 3.2 Write the "Existing repository" steps: commit or stash, add and fetch the `template` remote, list existing
  files, copy missing files, decide per existing file with the three commands (merge by hand for `AGENTS.md`, `ci.yml`
  and `ISSUE_TEMPLATE/config.yml`), set the default branch in `AGENTS.md`, review `git diff --staged` and commit on a
  `chore/` branch cut from the default branch, and a note to copy vendored and OpenSpec files rather than reinstall them
  with `gh skill install` or `openspec init`; verify every scenario of `template-onboarding` except "Sync after
  onboarding" is covered by the text and the commands match those proven in group 2
- [x] 3.3 Make "Syncing a project with the template" refer to the remote added during onboarding and mention the
  Repository section among the project-specific content of `AGENTS.md`; verify the "Sync after onboarding" scenario
  holds and the remote name is `template` in both sections
- [x] 3.4 Review every changed markdown file against the Markdown Guide basic syntax best practices

## 4. Verification on git-sandbox

- [ ] 4.1 Ask the maintainer for permission to change `kunman93/git-sandbox`, then follow the "Existing repository"
  steps literally from the README in `../git-sandbox`, keeping its default branch `master` and setting it in
  `AGENTS.md`; fix any step that is unclear or wrong in the README and repeat until it runs as written
- [ ] 4.2 Push the onboarding as a `chore/` branch and open a PR against `master` in git-sandbox; verify its `ci` check
  runs and passes, and record the commands, the listed existing files and the decisions taken for the PR of this change
- [ ] 4.3 Run `openspec validate onboard-existing-repositories --strict` and verify it passes

## Workflow follow-up

- Put the git-sandbox evidence from 4.2 into the Testing steps and Screenshots / evidence sections of this Story's PR.
- Archive the change after the user approves the PR, with the `finish-work` skill.
