# repository-setup Specification

## Purpose

Lets a maintainer apply the project-specific Setup of a repository that adopted the template through a skill that asks
before every change, keeps what is already set and reports what it left to the maintainer.

## Requirements

### Requirement: A skill applies the Setup steps

The repository SHALL provide a workflow skill `setup-repository` under `.agents/skills/` that covers the Setup steps of
`README.md`: the default branch in `AGENTS.md` and `ci.yml`, the Commands of `AGENTS.md`, the `ci` job steps, the branch
ruleset requiring `ci`, the security advisory link and stack skills.

#### Scenario: Freshly created repository

- **WHEN** a maintainer runs `setup-repository` in a repository just created from the template
- **THEN** the skill goes through each of these Setup steps and, for each, proposes a change, reports it as already set,
  or reports that it left the step to the maintainer

### Requirement: The default branch is read, not assumed

The skill SHALL read the repository's actual default branch from GitHub and SHALL propose that value for the Repository
section of `AGENTS.md` and both branch filters of `.github/workflows/ci.yml` when they still hold the template value
`main` and it differs.

#### Scenario: Repository on master

- **WHEN** the default branch on GitHub is `master` and `AGENTS.md` and `ci.yml` still name `main`
- **THEN** the skill proposes `master` for the Repository section of `AGENTS.md` and both branch filters of `ci.yml`

#### Scenario: Repository on main

- **WHEN** the default branch on GitHub is `main`
- **THEN** the skill reports the default branch as already set and changes neither file

### Requirement: Every change is confirmed

The skill SHALL show each change it proposes, with the current and the proposed value, and SHALL apply it only after the
maintainer confirms it. A declined change SHALL be left unchanged and reported as left to the maintainer.

#### Scenario: Maintainer declines a change

- **WHEN** the skill proposes Commands and the maintainer declines
- **THEN** the Commands section of `AGENTS.md` is unchanged and the final report lists the Commands as not done

### Requirement: Values already set are kept

The skill SHALL change only values that still hold the template's placeholder: the default branch `main`, a command
reading `_not configured_`, the placeholder step of the `ci` job, and a security advisory link that does not point to
the current repository. It SHALL NOT overwrite any other value; it reports it as already set, and a conflicting value as
a mismatch for the maintainer to resolve.

#### Scenario: Commands already filled in

- **WHEN** the Test command in `AGENTS.md` is already set
- **THEN** the skill leaves it unchanged and reports it as already set

#### Scenario: Conflicting default branch

- **WHEN** `AGENTS.md` declares `develop` and the default branch on GitHub is `master`
- **THEN** the skill changes neither `AGENTS.md` nor `ci.yml` and reports the mismatch to the maintainer

#### Scenario: Own AGENTS.md and ci.yml already on the default branch

- **WHEN** the maintainer kept an `AGENTS.md` without a Repository section and a `ci.yml` on `master`, and the default
  branch on GitHub is `master`
- **THEN** the skill offers to add the Repository section naming `master` and leaves `ci.yml` unchanged

### Requirement: A kept ci.yml aligns AGENTS.md to its default branch

A `main` in `AGENTS.md` SHALL count as a placeholder when `ci.yml` has at least one branch filter, every filter names
GitHub's default branch and that branch is not `main`. `ci.yml` then counts as already set and SHALL never be rewritten.

#### Scenario: Mixed default branch values

- **WHEN** `AGENTS.md` declares `main`, a kept `ci.yml` declares `master` and the default branch on GitHub is `master`
- **THEN** the skill offers to change `AGENTS.md` to `master`, reports `ci.yml` as already set and leaves it unchanged

#### Scenario: Kept ci.yml on another branch than GitHub

- **WHEN** `AGENTS.md` declares `main`, a kept `ci.yml` declares `master` and the default branch on GitHub is `develop`
- **THEN** the skill changes neither file and reports every location as a mismatch

#### Scenario: ci.yml filters disagree

- **WHEN** `AGENTS.md` declares `main`, one `ci.yml` filter declares `master`, the other declares `main`, and the
  default branch on GitHub is `master`
- **THEN** the skill changes neither file and reports every location as a mismatch, so the skill never makes `AGENTS.md`
  and `ci.yml` name different branches

### Requirement: Missing AGENTS.md sections are offered

A missing Repository or Commands section in `AGENTS.md` SHALL count as unset. The skill SHALL offer to add it with the
template's wording and SHALL leave the rest of `AGENTS.md` unchanged.

#### Scenario: Own AGENTS.md without template sections

- **WHEN** the maintainer kept their own `AGENTS.md`, which has no Repository and no Commands section
- **THEN** the skill offers to add both sections and leaves the rest of the file unchanged

### Requirement: Commands and ci steps are proposed from the repository

The skill SHALL propose each unset command from the build and package manifests it finds in the repository, or ask the
maintainer when it finds none, and SHALL propose `ci` job steps that run the confirmed Commands. The `ci` job SHALL keep
its name `ci`.

#### Scenario: Node project

- **WHEN** the repository has a `package.json` with `test` and `lint` scripts and the Commands are not configured
- **THEN** the skill proposes the matching install, test and lint commands and `ci` steps that run them

#### Scenario: No manifest

- **WHEN** the repository has no manifest the skill recognizes
- **THEN** the skill asks the maintainer for the commands instead of inventing them

### Requirement: Existing workflows are combined with ci on purpose

Before proposing `ci` job steps, the skill SHALL list the workflows under `.github/workflows/` other than `ci.yml` and
ask the maintainer how the `ci` check relates to them. It SHALL NOT propose `ci` steps that duplicate an existing
workflow without the maintainer choosing that, and SHALL NOT change an existing workflow without confirmation.

#### Scenario: Pipeline in another file

- **WHEN** the repository has `.github/workflows/build.yml` that runs its tests and `ci.yml` still has the placeholder
  step
- **THEN** the skill shows `build.yml` and asks whether the `ci` job should run it, whether both should run side by
  side, or whether to leave the `ci` steps to the maintainer, before proposing any `ci` step

### Requirement: The ruleset is created only with permission and rights

The skill SHALL require the `ci` check on the default branch through a branch ruleset only when the maintainer has admin
rights on the repository, `ci.yml` has a job named `ci` that runs on pull requests to the default branch, and the
maintainer confirms it. It SHALL NOT change existing rulesets. Otherwise it SHALL report the step as not done, with the
reason.

#### Scenario: Maintainer without admin rights

- **WHEN** the maintainer has only write access to the repository
- **THEN** the skill creates no ruleset and its final report lists the ruleset step as not done, with the reason

#### Scenario: No ci job

- **WHEN** the repository kept its own `ci.yml` whose job is named `build`
- **THEN** the skill creates no ruleset and reports that no job named `ci` exists, so requiring `ci` would block every
  pull request

#### Scenario: Ruleset already requires ci

- **WHEN** a ruleset on the default branch already requires the `ci` check
- **THEN** the skill reports the ruleset step as already set and creates no ruleset

### Requirement: Stack skills are referenced and added only on request

The skill SHALL list the skills under `.agents/skills/` that are neither template skills nor referenced from `AGENTS.md`
and offer to reference them. It SHALL ask which stack skills to add, SHALL add only the skills the maintainer names, and
SHALL reference each added skill from `AGENTS.md`.

#### Scenario: Existing unreferenced skill

- **WHEN** the repository has its own `.agents/skills/kotlin-style` and `AGENTS.md` does not mention it
- **THEN** the skill offers to reference `kotlin-style` from `AGENTS.md` and leaves the skill's files unchanged

#### Scenario: Maintainer names no stack skill

- **WHEN** the maintainer names no stack skill and no unreferenced skill exists
- **THEN** no file under `.agents/skills/` is added and the final report lists stack skills as not done

### Requirement: Steps not done are reported

The skill SHALL end with a report that lists each Setup step as done, already set, or not done with the reason, and
SHALL list the remaining manual step to describe the project in `README.md`.

#### Scenario: Final report

- **WHEN** the skill has gone through all Setup steps
- **THEN** it reports every Setup step with its outcome and reminds the maintainer to describe the project in
  `README.md`

### Requirement: Setup changes go through a reviewed pull request

The skill SHALL commit its changes on a `chore/` branch, reusing `chore/adopt-template` (or another `chore/` branch
after asking) or creating one from the default branch. When that branch has commits that are not on the default branch,
the skill SHALL have the `reviewer` agent review it and SHALL open the pull request and, only after the maintainer's
approval, merge it with the `finish-work` skill.

#### Scenario: Onboarding branch

- **WHEN** a maintainer runs the skill on `chore/adopt-template` after committing the onboarding files
- **THEN** the skill commits its changes on `chore/adopt-template`, so the onboarding files and the Setup changes go
  into one pull request

#### Scenario: Nothing to change

- **WHEN** every Setup value is already set and the current branch has no commits that are not on the default branch
- **THEN** the skill creates no branch, commit or pull request and only reports
