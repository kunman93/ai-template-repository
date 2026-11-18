# AI template repository

A stack-agnostic template for AI-assisted development. It contains the workflow, not an application, so you can start any repository from it, in any language or framework.

## What is included

- `AGENTS.md`: instructions for coding agents (working style, default branch, commands, git workflow, engineering principles).
- `.agents/skills/`:
  - `write-story`, `write-spec`, `implement-spec`, `implement-story`: workflow skills for Stories. By default a Story goes through `write-spec` (writes only the spec, reviewed and merged on its own) and then `implement-spec` (implements the merged spec, and its PR closes the Story); `implement-story` writes the spec and the code in one PR when you ask for it
  - `write-bug-report`, `fix-bug`: workflow skills for bug reports and bug fixes
  - `do-chore`: a workflow skill for maintenance you explicitly ask for (tooling, config, dependencies, docs, refactoring)
  - `setup-repository`: a workflow skill that applies the project-specific [Setup](#manual-setup) to a repository created from the template: default branch, Commands, `ci` steps, security link, stack skills and the `ci` ruleset. It asks before every change and keeps values that are already set
  - `finish-work`: has the cleaned-up commits checked mechanically and reviewed, creates the PR, finalizes the history (checking the commits again before each push) and merges. You don't call it directly; `implement-story`, `write-spec`, `implement-spec`, `fix-bug`, `do-chore` and `setup-repository` use it
  - `git-commit`: a skill for making atomic commits
- `.github/agents/reviewer.agent.md`: an independent, read-only code reviewer.
- `.github/ISSUE_TEMPLATE/`: issue forms for Stories, bug reports and feature requests.
- `.github/pull_request_template.md`: the pull request template that the agent fills out when it creates a PR.
- `.github/workflows/ci.yml`: a CI skeleton with the job `ci`.
- `.github/dependabot.yml`: a monthly Dependabot update of the GitHub Actions the workflows use, grouped into one PR. The workflows pin third-party actions to a commit SHA, which Dependabot keeps current.
- `.github/workflows/update-skills.yml`: the template's own weekly skill updates; it runs only in the template repository.
- `docs/decisions/`: architecture decision records in the [MADR](https://adr.github.io/madr/) format, with the template for new records.
- `openspec/` and `.agents/skills/openspec-*`: [OpenSpec](https://github.com/Fission-AI/OpenSpec) setup for spec-driven changes.

---

## Prerequisites

- [GitHub Copilot CLI](https://docs.github.com/en/copilot/concepts/agents/about-copilot-cli)
- [GitHub CLI](https://cli.github.com) (`gh`), signed in
- [Git](https://git-scm.com) 2.56 or later, because the `git-commit` skill stages resolved merge conflicts with `git add --resolved`
- [OpenSpec CLI](https://github.com/Fission-AI/OpenSpec). Before a workflow, the agent reinstalls it globally at the version stamped in `.agents/skills/openspec-*/SKILL.md` on the default branch if yours differs (see `AGENTS.md`). Repositories stamped with different versions therefore swap the global install back and forth.

---

## Adopting the template

1. Create your repository from this template.
2. Run the `setup-repository` skill in Copilot CLI. It sets the default branch, Commands, `ci` steps, security link,
   stack skills and the ruleset (the [manual setup](#manual-setup) below lists the same steps), asks before every
   change, keeps values that are already set and can be run again.
3. Describe your project in this README.

### Manual setup

The steps `setup-repository` applies, for when you do not use it.

1. If your default branch is not `main`, set it in the Repository section of `AGENTS.md` and in both `branches` filters
   of `.github/workflows/ci.yml` (marked `TODO`). Skills and agents refer to `<default-branch>`, so those two files
   are the only places that name it. Until you do, `ci` does not run on your PR.
2. Fill in the Commands section of `AGENTS.md` with your install, build, test and lint commands. The workflow skills and the reviewer run them (not in a spec review).
3. Add your stack's build, test and lint steps to the `ci` job in `.github/workflows/ci.yml`. Keep the job name `ci`.
4. Change the security advisory link in `.github/ISSUE_TEMPLATE/config.yml` to your repository.
5. Add skills for your stack under `.agents/skills/` if you need them, and reference them from `AGENTS.md`.
6. Once the PR is merged, require the `ci` check in a branch ruleset on your default branch.

Create Stories and bug reports with the `write-story` and `write-bug-report` skills, then work on a Story with `write-spec` and, once its spec is merged, `implement-spec` (or `implement-story` for the spec and the code in one PR), and on the rest with `fix-bug` or `do-chore`.

---

## Maintaining the template

- **OpenSpec:** upgrade the OpenSpec CLI, set the profile and workflows as in the `openspec` job of `.github/workflows/update-skills.yml` (both are global settings), then run `openspec update`. It regenerates `.agents/skills/openspec-*`, so never edit those by hand.
- **Vendored skills:** copied unchanged from upstream, so never edit them locally. Update them with `gh skill update --all --dir .agents/skills`, which reads the source from the `metadata` of each `SKILL.md` (see `.agents/skills/VENDORED.md`). `--dir` keeps it from touching skills installed outside the repository. The warnings about skills without GitHub metadata are expected: the template's own workflow skills and the generated `openspec-*` skills are not vendored.
- **Automatic updates:** `.github/workflows/update-skills.yml` runs both updates weekly (Sunday 23:59 UTC) and opens one PR per update (`chore/update-vendored-skills`, `chore/update-openspec`). It only runs in this template repository: its jobs are guarded by `github.repository`, so it stays inert in repositories that adopt the template. PRs opened with the default token do not trigger `ci`, so the jobs open them with a GitHub App token. Create a GitHub App with Contents and Pull requests write access, install it on this repository, and store its Client ID as the variable `UPDATE_APP_CLIENT_ID` and its private key as the secret `UPDATE_APP_PRIVATE_KEY`.
- **Decision record template:** `docs/decisions/adr-template.md` is copied unchanged from MADR; never edit it locally. The source and upgrade steps are in `docs/decisions/README.md`.
