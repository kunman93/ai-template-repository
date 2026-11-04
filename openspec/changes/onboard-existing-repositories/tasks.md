# Tasks

## 1. Commands work before they are documented

- [ ] 1.1 In a throwaway repository under the session workspace (not in this repository) with branch `master`, a
  `README.md` and a `.gitignore`, add this repository as the `template` remote and run the listing and copy commands from
  design.md in both bash and zsh; verify the listing prints exactly `.gitignore`, the copy adds every other onboarding
  file staged and leaves `README.md` and `.gitignore` unchanged, and no file under `openspec/specs/` or
  `openspec/changes/` appears
- [ ] 1.2 In the same throwaway repository, run the keep, take and compare commands for `.gitignore` and the local
  branch rename commands; verify each has the described effect, then delete the throwaway repository

## 2. README

- [ ] 2.1 Split "Adopting the template" in `README.md` into "New repository", "Existing repository" and "Setup" (today's
  steps 2 to 7 unchanged); verify against the "Two adoption paths" scenario
- [ ] 2.2 Write the "Existing repository" steps: commit or stash, add and fetch the `template` remote, rename the default
  branch to `main` (GitHub and local), list existing files, copy missing files, decide per existing file with the three
  commands (merge by hand for `AGENTS.md`, `ci.yml` and `ISSUE_TEMPLATE/config.yml`), review `git diff --staged` and
  commit on a `chore/` branch; verify every scenario of `template-onboarding` except "Sync after onboarding" is covered
  by the text and the commands match those proven in group 1
- [ ] 2.3 Make "Syncing a project with the template" refer to the remote added during onboarding, so the "Sync after
  onboarding" scenario holds; verify the remote name is `template` in both sections
- [ ] 2.4 Review the changed README sections against the Markdown Guide basic syntax best practices

## 3. Verification on git-sandbox

- [ ] 3.1 Ask the maintainer for permission to change `kunman93/git-sandbox`, then follow the "Existing repository"
  steps literally from the README in `../git-sandbox`, including the rename from `master` to `main`; fix any step that
  is unclear or wrong in the README and repeat until it runs as written
- [ ] 3.2 Push the onboarding as a `chore/` branch and open a PR in git-sandbox; verify its `ci` check runs and passes,
  and record the commands, the listed existing files and the decisions taken for the PR of this change
- [ ] 3.3 Run `openspec validate onboard-existing-repositories --strict` and verify it passes

## Workflow follow-up

- Put the git-sandbox evidence from 3.2 into the Testing steps and Screenshots / evidence sections of this Story's PR.
- Archive the change after the user approves the PR, with the `finish-work` skill.
