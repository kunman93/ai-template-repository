# AI template repository

A stack-agnostic template for AI-assisted development. It contains the workflow, not an application, so you can start any repository from it, in any language or framework.

## What is included

- `AGENTS.md`: instructions for coding agents (working style, default branch, commands, git workflow, engineering principles).
- `.agents/skills/`:
  - `write-story`, `implement-story`: workflow skills for Stories
  - `write-bug-report`, `fix-bug`: workflow skills for bug reports and bug fixes
  - `do-chore`: a workflow skill for maintenance you explicitly ask for (tooling, config, dependencies, docs, refactoring)
  - `onboard-repository`: a workflow skill that onboards an existing repository: it copies the template files the repository lacks, asks keep, take or merge for every file that differs, commits on `chore/adopt-template` and runs `setup-repository`. Run it again to pull later template changes. You install it with `gh skill install`, see [Adopting the template](#adopting-the-template)
  - `setup-repository`: a workflow skill that applies the project-specific [Setup](#manual-setup) after you adopt the template: default branch, Commands, `ci` steps, security link, stack skills and the `ci` ruleset. It asks before every change and keeps values that are already set
  - `finish-work`: has the cleaned-up commits checked mechanically and reviewed, creates the PR, finalizes the history (checking the commits again before each push) and merges. You don't call it directly; `implement-story`, `fix-bug`, `do-chore` and `setup-repository` use it
  - `git-commit`: a skill for making atomic commits
- `.github/agents/reviewer.agent.md`: an independent, read-only code reviewer.
- `.github/ISSUE_TEMPLATE/`: issue forms for Stories, bug reports and feature requests.
- `.github/pull_request_template.md`: the pull request template that the agent fills out when it creates a PR.
- `.github/workflows/ci.yml`: a CI skeleton with the job `ci`.
- `docs/decisions/`: architecture decision records in the [MADR](https://adr.github.io/madr/) format, with the template for new records.
- `openspec/`, `.github/skills/openspec-*` and `.github/prompts/opsx-*`: [OpenSpec](https://github.com/Fission-AI/OpenSpec) setup for spec-driven changes.

---

## Prerequisites

- [GitHub Copilot CLI](https://docs.github.com/en/copilot/concepts/agents/about-copilot-cli)
- [GitHub CLI](https://cli.github.com) (`gh`), signed in
- [Git](https://git-scm.com) 2.56 or later, because the `git-commit` skill stages resolved merge conflicts with `git add --resolved`
- [OpenSpec CLI](https://github.com/Fission-AI/OpenSpec)

---

## Adopting the template

Both a new and an existing repository follow the same list; only getting the files differs.

1. Get the template files.
   - **New repository:** create your repository from this template.
   - **Existing repository:** install the `onboard-repository` skill in your repository, with no uncommitted work:

     ```sh
     gh skill install kunman93/ai-template-repository onboard-repository --allow-hidden-dirs --dir .agents/skills
     ```

     `gh` warns: "Skills in hidden directories (e.g. .claude/, .agents/) may be installed copies from another
     publisher. Verify the skill's origin and check for a canonical source." That is expected,
     because this template keeps its skills in `.agents/skills`; the canonical source is
     `kunman93/ai-template-repository`. Then run the `onboard-repository` skill in Copilot CLI. It copies only the
     template files your repository does not have, asks whether to keep yours, take the template's or merge both for every file that differs, commits
     on `chore/adopt-template` and then runs `setup-repository` (item 2) on the same branch, so both end in one PR.
     Your default branch keeps its name and is never changed.

     To pull later template changes, run `gh skill update onboard-repository --dir .agents/skills` and then the skill
     again. It offers only the files the template changed since your last run.

     <details>
     <summary>Manual onboarding, without the skill</summary>

     Follow the steps below once, in your repository, with no uncommitted work. `<default-branch>` is your default
     branch, for example `master`.

     1. Add the template as a remote, fetch it and start a branch from your up-to-date default branch.

        ```sh
        git remote add template https://github.com/kunman93/ai-template-repository.git
        git fetch template
        git fetch origin
        git switch -c chore/adopt-template origin/<default-branch>
        ```

     2. List the template files your repository already has. Nothing is copied yet.

        ```sh
        git ls-tree -r --name-only template/main -- AGENTS.md .agents .github docs/decisions/adr-template.md docs/decisions/README.md docs/decisions/0000-use-markdown-architectural-decision-records.md openspec/config.yaml .gitignore .editorconfig | while read -r f; do if [ -e "$f" ]; then echo "$f"; fi; done
        ```

     3. Copy only the files that do not exist yet. Files from the previous step stay untouched. The template's
        `README.md`, `openspec/specs/`, `openspec/changes/` and its other decision records describe the template
        itself and are never copied.

        ```sh
        git ls-tree -r --name-only template/main -- AGENTS.md .agents .github docs/decisions/adr-template.md docs/decisions/README.md docs/decisions/0000-use-markdown-architectural-decision-records.md openspec/config.yaml .gitignore .editorconfig | while read -r f; do [ -e "$f" ] || git checkout template/main -- "$f"; done
        ```

        Copy the vendored skills (`.agents/skills/git-commit`) and the OpenSpec skills and prompts this way instead of
        reinstalling them with `gh skill install` or `openspec init`. The copies match the versions this template
        tested, and `gh skill update` and `openspec update` still work on them later.

     4. Decide for each file listed in step 2:
        - **Keep** yours: do nothing.
        - **Take** the template's: `git checkout template/main -- <file>`.
        - **Merge by hand**: compare with `git diff template/main -- <file>` (`-` lines are the template's, `+` lines
          are yours) and edit the file. Do this for `AGENTS.md`, `.github/workflows/ci.yml` and
          `.github/ISSUE_TEMPLATE/config.yml`, because they mix generic content with your project's.

     5. Stage what you merged or took by hand (`git add`), review what came in with `git diff --staged`, then commit on
        `chore/adopt-template`. Do not open the PR yet: the next item sets your default branch on this branch, so that
        `ci` runs on the PR.

     </details>

2. Run the `setup-repository` skill in Copilot CLI. It sets the default branch, Commands, `ci` steps, security link,
   stack skills and the ruleset (the [manual setup](#manual-setup) below lists the same steps), asks before every
   change, keeps values that are already set and can be run again. On `chore/adopt-template` it adds its changes to the
   same PR. The `onboard-repository` skill runs it for you, so on an existing repository you run it yourself only after
   the manual onboarding.
3. Describe your project in this README.

### Manual setup

The steps `setup-repository` applies, for when you do not use it. On an existing repository, do them on
`chore/adopt-template` before you open the PR.

1. If your default branch is not `main`, set it in the Repository section of `AGENTS.md` and in both `branches` filters
   of `.github/workflows/ci.yml` (marked `TODO`). Skills and agents refer to `<default-branch>`, so those two files
   are the only places that name it. Until you do, `ci` does not run on your PR.
2. Fill in the Commands section of `AGENTS.md` with your install, build, test and lint commands. The workflow skills and the reviewer run them.
3. Add your stack's build, test and lint steps to the `ci` job in `.github/workflows/ci.yml`. Keep the job name `ci`.
4. Change the security advisory link in `.github/ISSUE_TEMPLATE/config.yml` to your repository.
5. Add skills for your stack under `.agents/skills/` if you need them, and reference them from `AGENTS.md`.
6. Once the PR is merged, require the `ci` check in a branch ruleset on your default branch.

Create Stories and bug reports with the `write-story` and `write-bug-report` skills, then work on them with `implement-story`, `fix-bug` or `do-chore`.

---

## Maintaining the template

- **OpenSpec:** upgrade the OpenSpec CLI, then run `openspec update`. It regenerates `.github/skills/openspec-*` and `.github/prompts/opsx-*`, so never edit those by hand.
- **Vendored skills:** copied unchanged from upstream, so never edit them locally. Update them with `gh skill update --all --dir .agents/skills`, which reads the source from the `metadata` of each `SKILL.md` (see `.agents/skills/VENDORED.md`). `--dir` keeps it from touching skills installed outside the repository. The warnings about skills without GitHub metadata are expected: the template's own workflow skills are not vendored.
- **Decision record template:** `docs/decisions/adr-template.md` is copied unchanged from MADR; never edit it locally. The source and upgrade steps are in `docs/decisions/README.md`.
