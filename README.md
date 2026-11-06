# AI template repository

A stack-agnostic template for AI-assisted development. It contains the workflow, not an application, so you can start any repository from it, in any language or framework.

## What is included

- `AGENTS.md`: instructions for coding agents (working style, default branch, commands, git workflow, engineering principles).
- `.agents/skills/`:
  - `write-story`, `implement-story`: workflow skills for Stories
  - `write-bug-report`, `fix-bug`: workflow skills for bug reports and bug fixes
  - `do-chore`: a workflow skill for maintenance you explicitly ask for (tooling, config, dependencies, docs, refactoring)
  - `finish-work`: creates the PR, finalizes the history and merges. You don't call it directly; `implement-story`, `fix-bug` and `do-chore` use it
  - `git-commit`: a skill for making atomic commits
- `.github/agents/reviewer.agent.md`: an independent, read-only code reviewer.
- `.github/ISSUE_TEMPLATE/`: issue forms for Stories, bug reports and feature requests.
- `.github/pull_request_template.md`: the pull request template that the agent fills out when it creates a PR.
- `.github/workflows/ci.yml`: a CI skeleton with the job `ci`.
- `docs/decisions/`: architecture decision records in the [MADR](https://adr.github.io/madr/) format, with the template for new records.
- `openspec/`, `.github/skills/openspec-*` and `.github/prompts/opsx-*`: [OpenSpec](https://github.com/Fission-AI/OpenSpec) setup for spec-driven changes.

## Prerequisites

- [GitHub Copilot CLI](https://docs.github.com/en/copilot/concepts/agents/about-copilot-cli)
- [GitHub CLI](https://cli.github.com) (`gh`), signed in
- [Git](https://git-scm.com) 2.56 or later, because the `git-commit` skill stages resolved merge conflicts with `git add --resolved`
- [OpenSpec CLI](https://github.com/Fission-AI/OpenSpec)

## Adopting the template

Both paths end with the same [Setup](#setup).

### New repository

Create your repository from this template. Once created, continue with [Setup](#setup).

### Existing repository

Follow these steps once, in your repository, with no uncommitted work. Your default branch keeps its name; the steps
below never rename it.

1. Add the template as a remote, fetch it and start a branch from your up-to-date default branch. `<url>` is this
   template's URL and `<default-branch>` your default branch, for example `master`.

   ```sh
   git remote add template <url>
   git fetch template
   git fetch origin
   git switch -c chore/adopt-template origin/<default-branch>
   ```

2. List the template files your repository already has. Nothing is copied yet.

   ```sh
   git ls-tree -r --name-only template/main -- AGENTS.md .agents .github docs/decisions/adr-template.md docs/decisions/README.md docs/decisions/0000-use-markdown-architectural-decision-records.md openspec/config.yaml .gitignore .editorconfig | while read -r f; do if [ -e "$f" ]; then echo "$f"; fi; done
   ```

3. Copy only the files that do not exist yet. Files from step 2 stay untouched. The template's `README.md`,
   `openspec/specs/`, `openspec/changes/` and its other decision records describe the template itself and are never
   copied.

   ```sh
   git ls-tree -r --name-only template/main -- AGENTS.md .agents .github docs/decisions/adr-template.md docs/decisions/README.md docs/decisions/0000-use-markdown-architectural-decision-records.md openspec/config.yaml .gitignore .editorconfig | while read -r f; do [ -e "$f" ] || git checkout template/main -- "$f"; done
   ```

   Copy the vendored skills (`.agents/skills/git-commit`) and the OpenSpec skills and prompts this way instead of
   reinstalling them with `gh skill install` or `openspec init`. The copies match the versions this template tested,
   and `gh skill update` and `openspec update` still work on them later.

4. Decide for each file listed in step 2:
   - **Keep** yours: do nothing.
   - **Take** the template's: `git checkout template/main -- <file>`.
   - **Merge by hand**: compare with `git diff template/main -- <file>` (`-` lines are the template's, `+` lines are
     yours) and edit the file. Do this for `AGENTS.md`, `.github/workflows/ci.yml` and
     `.github/ISSUE_TEMPLATE/config.yml`, because they mix generic content with your project's.

5. If your default branch is not `main`, set it in the Repository section of `AGENTS.md` and in both `branches`
   filters of `.github/workflows/ci.yml` (marked `TODO`) now. Until you do, `ci` does not run on your onboarding PR.

6. Review what came in with `git diff --staged`, then commit and open a PR.

Next, continue with [Setup](#setup).

### Setup

1. If your default branch is not `main`, set it in the Repository section of `AGENTS.md` and in both `branches` filters
   of `.github/workflows/ci.yml` (marked `TODO`), unless you did in step 5 of "Existing repository". Skills and agents
   refer to `<default-branch>`, so those two files are the only places that name it.
2. Fill in the Commands section of `AGENTS.md` with your install, build, test and lint commands. The workflow skills and the reviewer run them.
3. Add your stack's build, test and lint steps to the `ci` job in `.github/workflows/ci.yml`. Keep the job name `ci`.
4. Require the `ci` check in a branch ruleset on your default branch.
5. Change the security advisory link in `.github/ISSUE_TEMPLATE/config.yml` to your repository.
6. Add skills for your stack under `.agents/skills/` if you need them, and reference them from `AGENTS.md`.
7. Describe your project in this README.

Create Stories and bug reports with the `write-story` and `write-bug-report` skills, then work on them with `implement-story`, `fix-bug` or `do-chore`.

## Keeping the template up to date

### Maintaining the template

- **OpenSpec:** upgrade the OpenSpec CLI, then run `openspec update`. It regenerates `.github/skills/openspec-*` and `.github/prompts/opsx-*`, so never edit those by hand.
- **Vendored skills:** copied unchanged from upstream, so never edit them locally. Update them with `gh skill update --all --dir .agents/skills`, which reads the source from the `metadata` of each `SKILL.md` (see `.agents/skills/VENDORED.md`). `--dir` keeps it from touching skills installed outside the repository. The warnings about skills without GitHub metadata are expected: the template's own workflow skills are not vendored.
- **Decision record template:** `docs/decisions/adr-template.md` is copied unchanged from MADR; never edit it locally. The source and upgrade steps are in `docs/decisions/README.md`.

### Syncing a project with the template

The template is the source of truth for everything generic (workflow skills, reviewer, issue forms, engineering principles). Keep project-specific content (Repository, Commands, stack skills, `ci.yml`, the security link in `ISSUE_TEMPLATE/config.yml`, this README) separate from it.

- Prefer changing the template first through a `chore/` PR, then copy the paths into your repository. Histories are unrelated, so copy paths instead of merging. A repository onboarded as above already has the `template` remote. If not, add it once: `git remote add template <url>`. Then for each sync:
  1. Commit your work first, because the checkout below overwrites local edits without asking.
  2. `git fetch template`, then `git checkout template/main -- <paths>`.
  3. Review with `git diff --staged`, because the checkout stages what it copies. Files the template removed are not deleted for you.
- If you improved a generic file in a project first, keep that change in its own commit, then port it with `git format-patch -1 <sha>` in the project and `git am -3 <patch-file>` in a clone of the template, through a `chore/` PR. `-3` only helps when the template's file changed; if `am` reports missing history, apply the patch by hand with `git apply --reject <patch-file>`.
- Before starting a Story, run `git fetch template` and check for drift with `git diff template/main -- AGENTS.md .agents .github docs/decisions/adr-template.md docs/decisions/README.md docs/decisions/0000-use-markdown-architectural-decision-records.md openspec/config.yaml .gitignore .editorconfig`. Expect permanent differences in `ci.yml`, `ISSUE_TEMPLATE/config.yml`, `.gitignore`, `.editorconfig`, `openspec/config.yaml` and your stack skills.
- Copy only `adr-template.md`, `README.md` and `0000-use-markdown-architectural-decision-records.md` from `docs/decisions/`. The other records in it are your project's own decisions.
- Never copy `AGENTS.md`, `ci.yml` or `ISSUE_TEMPLATE/config.yml` wholesale: they mix generic content with your project's, so merge them by hand.
