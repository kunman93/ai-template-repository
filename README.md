# AI template repository

A stack-agnostic template for AI-assisted development. It contains the workflow, not an application, so you can start any repository from it, in any language or framework.

## What is included

- `AGENTS.md`: instructions for coding agents (working style, commands, git workflow, engineering principles).
- `.agents/skills/`: workflow skills for Stories (`implement-story`, `write-story`), bug fixes (`fix-bug`, `write-bug-report`), chores (`do-chore`), finishing work (`finish-work`) and commits (`git-commit`).
- `.github/agents/reviewer.agent.md`: an independent, read-only code reviewer.
- `.github/ISSUE_TEMPLATE/`: issue forms for Stories, bug reports and feature requests.
- `.github/workflows/ci.yml`: a CI skeleton with the job `ci`.
- `docs/decisions/`: architecture decision records in the [MADR](https://adr.github.io/madr/) format, with the template for new records.
- `openspec/`, `.github/skills/openspec-*` and `.github/prompts/opsx-*`: [OpenSpec](https://github.com/Fission-AI/OpenSpec) setup for spec-driven changes.

## Prerequisites

- [GitHub Copilot CLI](https://docs.github.com/en/copilot/concepts/agents/about-copilot-cli)
- [GitHub CLI](https://cli.github.com) (`gh`), signed in
- [OpenSpec CLI](https://github.com/Fission-AI/OpenSpec)

## Adopting the template

1. Create your repository from this template.
2. Fill in the Commands section of `AGENTS.md` with your install, build, test and lint commands. The workflow skills and the reviewer run them.
3. Add your stack's build, test and lint steps to the `ci` job in `.github/workflows/ci.yml`. Keep the job name `ci`.
4. Require the `ci` check in a branch ruleset on `main`.
5. Change the security advisory link in `.github/ISSUE_TEMPLATE/config.yml` to your repository.
6. Add skills for your stack under `.agents/skills/` if you need them, and reference them from `AGENTS.md`.
7. Describe your project in this README.

Create Stories and bug reports with the `write-story` and `write-bug-report` skills, then work on them with `implement-story`, `fix-bug` or `do-chore`.

## Keeping the template up to date

### Maintaining the template

- **OpenSpec:** upgrade the OpenSpec CLI, then run `openspec update`. It regenerates `.github/skills/openspec-*` and `.github/prompts/opsx-*`, so never edit those by hand.
- **Vendored skills:** copied unchanged from upstream, so never edit them locally. Each records its source in the `metadata` of its own `SKILL.md`; re-copy it from there (see `.agents/skills/VENDORED.md`).

### Syncing a project with the template

The template is the source of truth for everything generic (workflow skills, reviewer, issue forms, engineering principles). Keep project-specific content (Commands, stack skills, `ci.yml`, the security link in `ISSUE_TEMPLATE/config.yml`, this README) apart from it.

- Prefer changing the template first through a `chore/` PR, then copy the paths into your repository. Histories are unrelated, so copy paths instead of merging. Once: `git remote add template <url>`. Then for each sync:
  1. Commit your work first, because the checkout below overwrites local edits without asking.
  2. `git fetch template`, then `git checkout template/main -- <paths>`.
  3. Review with `git diff --staged`, because the checkout stages what it copies. Files the template removed are not deleted for you.
- If you improved a generic file in a project first, keep that change in its own commit, then port it with `git format-patch -1 <sha>` in the project and `git am -3 <patch-file>` in a clone of the template, through a `chore/` PR. `-3` only helps when the template's file changed; if `am` reports missing history, apply the patch by hand with `git apply --reject <patch-file>`.
- Before starting a Story, run `git fetch template` and check for drift with `git diff template/main -- AGENTS.md .agents .github`. Expect permanent differences in `ci.yml`, `ISSUE_TEMPLATE/config.yml` and your stack skills.
- Never copy `AGENTS.md`, `ci.yml` or `ISSUE_TEMPLATE/config.yml` wholesale: they mix generic content with your project's, so merge them by hand.
