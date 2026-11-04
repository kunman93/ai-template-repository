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
- Renaming an existing repository's default branch.
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

### Copy vendored and OpenSpec files, do not reinstall them

Vendored skills (`git-commit`) and the OpenSpec skills and prompts are copied like every other template file.
`gh skill install` would fetch upstream HEAD instead of the version the template tested, and `openspec init` generates a
skill set that depends on the maintainer's global OpenSpec profile and CLI version, which can leave out skills the
workflow references (`openspec-update-change`, `openspec-sync-specs`). The copies keep their source metadata, so
`gh skill update` and `openspec update` still work later. Copying only `openspec/config.yaml` is enough for OpenSpec:
`openspec list` finds the root and `openspec new change` creates `specs/` and `changes/` (checked with OpenSpec 1.16.0).

### Three options per existing file

For each listed file the README gives the command for each choice: keep (do nothing), take the template's version
(`git checkout template/main -- <file>`), or merge by hand after comparing (`git diff template/main -- <file>`).
`AGENTS.md`, `ci.yml` and `ISSUE_TEMPLATE/config.yml` are called out as merge-by-hand, matching the existing rule in
"Syncing a project with the template".

### Declare the default branch in AGENTS.md

`AGENTS.md` gets a Repository section with `Default branch: main` and the rule that `<default-branch>` in any skill or
agent file stands for that value, plus a note that `ci.yml` names it too (see below). The workflow skills, the reviewer and the Git Workflow section replace `main` with
`<default-branch>` (for example `origin/<default-branch>`, `gh pr create --base <default-branch>`). `AGENTS.md` is
already the file every agent reads first and already holds the project-specific Commands, and it is merged by hand on
sync, so the value survives syncs. Alternatives considered: renaming the default branch to `main` (breaks clones,
pipelines and links outside our control), detecting it at run time with `gh repo view --json defaultBranchRef` or
`origin/HEAD` (implicit, and `origin/HEAD` is often unset in clones), and keeping `main` as a hard requirement (excludes
repositories on `master` or `develop`). OpenSpec's "main spec" and the vendored `git-commit` skill use "main" in another
sense or are not ours to edit, so they stay untouched. Because this is a cross-cutting convention that later skills
must follow, it is recorded as an ADR.

### ci.yml names the default branch

GitHub reads `ci.yml`, not `AGENTS.md`, and `on:` filters cannot use expressions. So `ci.yml` names the default branch
itself: `pull_request` and `push` both have `branches: [main]` with a `TODO` comment telling the maintainer to set their
default branch, and the `ci` job has no condition. Every PR to the default branch shows exactly one `ci` check. The
Repository section of `AGENTS.md` says that `ci.yml` names the branch too, and so do step 5 of "Existing repository"
(before the onboarding PR is opened) and Setup. If a maintainer forgets, `ci` never
runs on their PRs and a ruleset that requires it keeps every PR pending, so the mistake shows on the first PR.

Alternatives considered: triggering without branch filters and skipping the job with
`if: github.event_name == 'pull_request' || github.ref_name == github.event.repository.default_branch` (keeps the name
out of `ci.yml`, but every push to a PR branch adds a second, skipped `ci` check next to the real one, which the
maintainer found confusing; a ruleset test in git-sandbox showed it still blocks a PR whose real `ci` fails), and
naming the skipped job differently with an expression in `name:` (relies on undocumented display behavior for skipped
jobs).

### Structure of "Adopting the template"

Three subsections: "New repository" (create from the template), "Existing repository" (the onboarding steps above) and
"Setup" (today's steps 2 to 7, plus a first step that sets the default branch in `AGENTS.md` and in the branch
filters of `ci.yml`, and the ruleset step now names the default branch instead of `main`). "Syncing a project with the template" keeps its `git remote add template`
line, and the onboarding step uses the same remote name, so a later sync needs no extra setup.

### Verification on git-sandbox

`kunman93/git-sandbox` has default branch `master`, its own `README.md` and `.gitignore`, and nothing else, so it
exercises the default branch setting, the existing-file listing (`.gitignore`), the never-copied `README.md` and the
copy of everything else. It stays on `master`. The steps are followed literally from the README, except that
`template/feature/onboard-existing-repositories` stands in for `template/main` until this change is merged. The
onboarding is pushed as a `chore/` PR in git-sandbox against `master`, and the commands and outcomes go into this
change's PR. The `ci` check is verified separately, with the final `ci.yml` and both filters set to `master`, because
the onboarding itself ran before the filters existed. Any unclear or broken step is fixed in the README before the PR.

## Risks / Trade-offs

- [The listing and the copy run against different states if the maintainer edits files in between] → The README says to
  commit or stash first and to run the steps in order; `git diff --staged` before committing shows exactly what came in.
- [Renaming the default branch would break clones, pipelines and links] → Avoided: the branch keeps its name, and
  `AGENTS.md` and the branch filters of `ci.yml` declare it.
- [The maintainer sets the branch in `AGENTS.md` but not in `ci.yml`] → The Repository section, step 5 of "Existing
  repository" and Setup all point at `ci.yml`, and the `TODO` comment sits next to the value. If it is missed, the required `ci` check never runs and the
  first PR stays pending.
- [An agent uses a literal `main` instead of resolving `<default-branch>`] → The Repository section states the rule
  next to the value, and a grep check in the tasks ensures no workflow file still names `main` as a branch.
- [Files the template later removes or adds] → Out of scope; covered by "Syncing a project with the template" and the
  separate sync Story.
- [Verification touches a repository outside this one] → Done only after the maintainer's explicit permission.
