# Design

## Context

Setup in `README.md` is seven manual steps (see proposal.md - Why). The values to set are in `AGENTS.md` (Repository
and Commands sections), `.github/workflows/ci.yml` (two `branches` filters marked `TODO`, one placeholder `echo` step
in the `ci` job) and `.github/ISSUE_TEMPLATE/config.yml` (security advisory link). The ruleset lives in GitHub settings.
The workflow skills (`implement-story`, `fix-bug`, `do-chore`) are prose `SKILL.md` files that the main session follows
on Sonnet 5.5, with a model check in step 0, review by the `reviewer` subagent and PR handling through `finish-work`.
The onboarding change rejected a skill for getting the files, because the skill would first have to be fetched. That
does not apply here: Setup starts after the files, including `.agents/skills/`, are in the repository.

## Goals / Non-Goals

**Goals:**

- One skill that a maintainer can run on a new or an existing repository, and run again safely.
- The skill only fills in template placeholders and leaves every other value as it is.

**Non-Goals:**

- Getting the template files into an existing repository (stays the README git commands).
- Writing stack skills or the project description in `README.md`.
- Changing existing rulesets or branch protection rules.
- Syncing later template changes.

## Decisions

### A prose skill, no script

`setup-repository/SKILL.md` follows the structure of `do-chore`: model and agent check, steps, `reviewer`,
`finish-work`. Every step needs judgment (reading manifests, comparing values, asking), and a script would need its own
tests and runtime in a stack-agnostic template. The skill uses only `git` and `gh`, which are already prerequisites.
Alternative considered: a shell script with prompts (portability and test burden, cannot propose Commands).

### Gather first, then change

The skill first collects everything read-only: the default branch (`gh repo view --json defaultBranchRef`), the
repository name and the viewer's permission (`nameWithOwner`, `viewerPermission`), the current values in the three
files, the manifests in the repository root, the other workflows under `.github/workflows/`, the skills under
`.agents/skills/` that are not template skills, and the effective rules on the default branch
(`gh api repos/{owner}/{repo}/rules/branches/<branch>`). It then shows one overview with every Setup step marked as
"to change", "already set", "mismatch" or "cannot do", and asks about each change. Only when at least one file change
is confirmed does it touch the branch. This keeps the run with nothing to change free of side effects and lets the
maintainer see the whole picture before the first question.

### Placeholder detection

A value is a placeholder only if it is the template's value:

| Setup step     | Placeholder                                                        |
|----------------|--------------------------------------------------------------------|
| Default branch | `main` in `AGENTS.md` and in both `ci.yml` filters                 |
| Commands       | `_not configured_`, per command                                    |
| `ci` steps     | the single `echo "No checks configured yet. ..."` step             |
| Security link  | an advisory URL whose `owner/repo` is not the current repository   |
| Ruleset        | no effective `required_status_checks` rule with context `ci`       |

A missing Repository or Commands section in `AGENTS.md` (a kept, project-specific `AGENTS.md`) also counts as unset;
the skill offers to add the section with the template's wording and leaves the rest of the file unchanged. Anything
else counts as set. The default branch is judged across its locations (the Repository section of `AGENTS.md` and the `ci.yml` filters; a missing one is left out): all
`main` while GitHub differs are placeholders, all equal to GitHub's are set, and any other combination is a mismatch
for which the skill changes nothing and reports every location. Alternative considered: always propose the detected
value and let the maintainer decide (simpler, but makes it easy to overwrite a deliberate value with one keystroke,
which the Story forbids).

### Commands from manifests, verified once

The skill reads common manifests (for example `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `pom.xml`,
`build.gradle`, `Makefile`) and proposes only commands that a manifest defines or that its tool standardizes. When it
finds nothing, or a command is unclear, it asks. Before writing them, it runs each confirmed command once and shows any
failure, so a broken command does not end up in `AGENTS.md` and `ci`. The `ci` steps are derived from the confirmed
Commands (checkout, toolchain setup, then the commands) and keep the job name `ci`.

### Existing workflows: the maintainer picks how they meet `ci`

When other workflows exist, the skill shows each one with its triggers and job names, and asks before proposing any
`ci` step:

- **`ci` runs them:** the `ci` job calls the workflow as a reusable workflow (`uses: ./.github/workflows/<file>`).
  This needs a `workflow_call` trigger in that workflow, which the skill adds only after confirming it, and the
  maintainer decides whether its own triggers stay.
- **Side by side:** `ci` gets steps from the Commands as usual and the existing workflow stays unchanged; the skill
  warns that the same checks then run twice.
- **Leave it:** the `ci` steps stay as they are and the step is reported as not done.

Renaming a job of the existing workflow to `ci` is not offered: the default branch filters and the `TODO` live in
`ci.yml`, and a second place for them would break the Repository section of `AGENTS.md`. A `ci.yml` that the
maintainer kept from their own repository is treated as set and never rewritten; the ruleset step then checks whether
it has a `ci` job (below).

### Branch reuse

If the current branch is `chore/adopt-template`, the skill commits there, so onboarding and
Setup end in one PR, the PR whose `ci` filter must already name the default branch; it asks before reusing any other
`chore/` branch. On any other branch, including the default branch, it fetches the default branch and creates
`chore/setup-repository` from `origin/<default-branch>`, and stops when the template files are not committed on the
resulting branch. It never commits on the default branch, following the Git Workflow of `AGENTS.md`.

### Ruleset last, with `~DEFAULT_BRANCH`

The ruleset is offered only when `viewerPermission` is `ADMIN` and `ci.yml` has a job named `ci` whose
`pull_request` trigger covers the default branch: a ruleset requiring a check that never runs keeps every PR pending.
It is created only after confirmation, through
`gh api -X POST repos/{owner}/{repo}/rulesets` with target `branch`, enforcement `active`, ref condition
`~DEFAULT_BRANCH` and one `required_status_checks` rule for the context `ci`. `~DEFAULT_BRANCH` keeps following the
default branch if it is renamed. It runs after the PR is merged (or right away when there is no PR), so a `ci` that
does not run yet on the default branch cannot block the Setup PR. If GitHub refuses (for example rulesets on a private
repository without a paid plan), the skill reports the step as not done with GitHub's message. Alternative considered:
classic branch protection (older API, and the README already says ruleset).

### Stack skills: reference existing ones, add named ones

The skill first lists skills under `.agents/skills/` that are not template skills (the template's own workflow and
vendored skills, known from `template/main` when that remote exists, otherwise from this skill's list) and whose name
does not appear in `AGENTS.md`, and offers to reference them. It never changes their files. Then it asks which skills
to add. For each one the maintainer names, it installs it with
`gh skill install ... --dir .agents/skills` when the maintainer gives a GitHub source, or copies it from a path they
give, and adds a reference to `AGENTS.md` next to the sentence about stack skills in Engineering Principles. It
suggests none of its own.

### README: one list and a manual Setup section

"Adopting the template" becomes: 1. get the files (new repository: create from the template; existing repository: the
remote, list, copy and decide commands, then commit on `chore/adopt-template`); 2. run `setup-repository`; 3. describe
the project in `README.md`. The existing-repository default branch step moves out, because the skill (or the manual
steps) sets it on the same branch before the PR. "Setup" stays as "Manual setup", the steps the skill applies, for
maintainers who do not use it.

### Verification instead of automated tests

The repository has no test runner and the change is prose, so TDD has no executable target here. The behavior is
verified end to end in `kunman93/git-sandbox` (private, default branch `master`, only `README.md` and `.gitignore`).
Each scenario gets its own branch from `origin/master`: the project state is committed there first to simulate an
existing repository, then the README onboarding steps run against this feature branch, then the skill runs. Each
scenario opens a PR to `master`, so `ci` runs for real, and the PR is closed without merging afterwards, so `master`
stays ready for later experiments.

| # | State before onboarding                                                    | Covers                                              |
|---|----------------------------------------------------------------------------|-----------------------------------------------------|
| 1 | `README.md` and `.gitignore` only                                          | no manifest, default branch `master`                |
| 2 | React (Vite, npm) with ESLint and Vitest, no CI                            | Commands from `package.json`, Node `ci` steps       |
| 3 | Spring Boot (Maven wrapper) with `.github/workflows/build.yml`             | existing workflow question, Java `ci` steps         |
| 4 | Spring Boot (Gradle wrapper) with own `AGENTS.md`, `ci.yml` (job `build`), a skill | colliding files, set values kept, no `ci` job, unreferenced skill |
| 5 | Result of scenario 2                                                       | second run changes nothing                          |

Because this change rewrites the onboarding steps in `README.md`, every scenario also checks onboarding itself, which
had been verified only on a bare repository: the listing step prints exactly the colliding files, the copy step
changes no project file, and no template-only file comes along. A small fix to those README steps belongs to this
change; any other onboarding bug becomes a bug report, so this change does not absorb unrelated fixes.

The Spring Boot projects come from Spring Initializr with their wrappers, because Maven and Gradle are not installed
locally and wrappers are what real projects use. A fresh `general-purpose` subagent runs each scenario: it follows
`SKILL.md` and plays the maintainer with answers fixed in its prompt, so the author of the skill does not grade their
own run. The ruleset step is refused with 403 in every scenario (private repository without Pro), which verifies the
refusal path. A maintainer without admin rights is not verified, because that needs a second account. These scenarios
are checked by review only: "Mixed default branch values", the dirty-tree stop, the question before reusing another
`chore/` branch, the check for committed template files, "Freshly created repository" from the default branch,
"Maintainer declines a change", "Repository on main", "Conflicting default branch", "Ruleset already requires ci",
"Nothing to change" on a branch without commits, and the "`ci` runs it" option for an existing workflow.

Scenarios 1 to 4 run in parallel, each in its own background subagent and its own clone of `git-sandbox` in the
session workspace; scenario 5 runs after scenario 2 on that scenario's clone. Separate clones rather than git
worktrees, because worktrees share `.git/config` and the README step `git remote add template` would fail in the
second worktree, which is exactly the step under test. Each scenario has its own branch and PR, and `ci` concurrency is
per ref, so the runs do not cancel each other; Maven and Gradle use separate local caches.

## Risks / Trade-offs

- [The agent misreads a manifest and proposes a wrong command] → Commands are shown, confirmed and run once before they
  are written.
- [Rulesets on private repositories need a paid plan] → The skill reports GitHub's refusal. `git-sandbox` returns 403
  for rulesets, which verifies the refusal path; the creation request is checked by review only, not live.
- [Prose skills drift from the README] → README Manual setup and the skill list the same steps in the same order, and
  the reviewer checks both.
