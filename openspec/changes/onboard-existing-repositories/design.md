# Design

## Context

"Syncing a project with the template" in `README.md` already adds a `template` remote and copies paths with
`git checkout template/main -- <paths>`. That command overwrites existing files without asking and stages the result,
which is fine for a sync of files the project already took from the template, but not for a first adoption where the
repository has its own `AGENTS.md`, `.gitignore` or `ci.yml`. The workflow (`AGENTS.md`, the skills, `ci.yml`, the
ruleset) hard-codes the branch name `main`.

## Goals / Non-Goals

**Goals:**

- Copy-paste commands that work unchanged in bash and zsh (macOS default shell) on macOS and Linux.
- One explicit decision point per existing file, with nothing copied over it before that decision.

**Non-Goals:**

- Automating the merge of `AGENTS.md`, `ci.yml` or other mixed files.
- Making the branch name configurable.
- Windows shells (PowerShell, cmd).

## Decisions

### Documented manual steps, not a script or skill

The deterministic part (list existing files, copy missing ones) is two one-liners; the hard part (merging mixed files)
cannot be automated by a script anyway. A script would need its own test setup (a new dependency in a stack-agnostic
template), and a script or skill would ship into every repository created from the template and would first have to be
fetched from the template to onboard it. Alternatives considered: an `onboard-repository` skill (non-deterministic, same
fetch problem) and a shell script with per-file prompts (tests, portability, dead weight after onboarding).

### Classify by file, copy by file

The onboarding paths are passed to `git ls-tree -r --name-only template/main -- <paths>`, which expands directories to
files. Each file is tested with `[ -e "$f" ]`: existing files are printed, missing ones are copied one by one with
`git checkout template/main -- "$f"`. Copying per file instead of per directory is what keeps an existing
`.github/workflows/ci.yml` or skill untouched while its siblings are added. The paths are written inline in each command
rather than in a shell variable, because zsh does not word-split unquoted variables.

Onboarding paths: `AGENTS.md`, `.agents`, `.github`, `docs/decisions/adr-template.md`, `docs/decisions/README.md`,
`docs/decisions/0000-use-markdown-architectural-decision-records.md`, `openspec/config.yaml`, `.gitignore`,
`.editorconfig`. Record 0000 is included because the onboarded repository adopts MADR too; the template's other
records, `README.md`, `openspec/specs/` and `openspec/changes/` describe the template and are left out.

### Three options per existing file

For each listed file the README gives the command for each choice: keep (do nothing), take the template's version
(`git checkout template/main -- <file>`), or merge by hand after comparing (`git diff HEAD template/main -- <file>`).
`AGENTS.md`, `ci.yml` and `ISSUE_TEMPLATE/config.yml` are called out as merge-by-hand, matching the existing rule in
"Syncing a project with the template".

### Rename the default branch first

Renaming comes before the copy so the onboarding `chore/` branch is cut from `main`. On GitHub the rename uses
`gh api -X POST repos/<owner>/<repo>/branches/<old>/rename -f new_name=main`, which also retargets open PRs and branch
protection; locally `git branch -m <old> main`, `git fetch origin`, `git branch -u origin/main main` and
`git remote set-head origin -a`.

### Structure of "Adopting the template"

Three subsections: "New repository" (create from the template), "Existing repository" (the onboarding steps above) and
"Setup" (today's steps 2 to 7, unchanged). "Syncing a project with the template" keeps its `git remote add template`
line, and the onboarding step uses the same remote name, so a later sync needs no extra setup.

### Verification on git-sandbox

`kunman93/git-sandbox` has default branch `master`, its own `README.md` and `.gitignore`, and nothing else, so it
exercises the rename, the existing-file listing (`.gitignore`), the never-copied `README.md` and the copy of everything
else. The steps are followed literally from the README, the onboarding is pushed as a `chore/` PR in git-sandbox, and
the commands and outcomes go into this change's PR. Any unclear or broken step is fixed in the README before the PR.

## Risks / Trade-offs

- [The listing and the copy run against different states if the maintainer edits files in between] → The README says to
  commit or stash first and to run the steps in order; `git diff --staged` before committing shows exactly what came in.
- [Renaming the default branch breaks other people's clones and CI that hard-code `master`] → The README points to
  GitHub's rename notice and the local commands for other clones; the maintainer decides when to run it.
- [Files the template later removes or adds] → Out of scope; covered by "Syncing a project with the template" and the
  separate sync Story.
- [Verification touches a repository outside this one] → Done only after the maintainer's explicit permission.
