# Spec Delta

## ADDED Requirements

### Requirement: Adopting the template is documented for new repositories only
`README.md` SHALL describe adopting the template only as: create the repository from the template, run
`setup-repository`, then describe the project. It SHALL describe no other way to get the template's files.

#### Scenario: Maintainer reads how to adopt the template
- **WHEN** a maintainer reads "Adopting the template" in `README.md`
- **THEN** it lists creating the repository from the template, running `setup-repository` and describing the project,
  and no other way to get the template's files

### Requirement: The skill requires the template files
The skill SHALL stop and tell the maintainer that the repository was not created from the template when
`AGENTS.md`, `.github/workflows/ci.yml` or `.github/ISSUE_TEMPLATE/config.yml` is missing, or when `AGENTS.md` has no
Repository or no Commands section. It SHALL NOT add a missing file or section.

#### Scenario: AGENTS.md without a Commands section
- **WHEN** a maintainer runs `setup-repository` and `AGENTS.md` has no Commands section
- **THEN** the skill changes nothing and tells the maintainer that the repository was not created from the template

### Requirement: Only placeholder values are changed
The skill SHALL change only values that still hold the template's placeholder: the default branch `main`, a command
reading `_not configured_`, the placeholder step of the `ci` job, and a security advisory link that does not point to
the current repository. It SHALL NOT overwrite any other value; it reports it as already set. The default branch
follows the requirement "The default branch is read, not assumed".

#### Scenario: Commands already filled in
- **WHEN** the Test command in `AGENTS.md` is already set
- **THEN** the skill leaves it unchanged and reports it as already set

#### Scenario: Run again after Setup
- **WHEN** a maintainer runs the skill again after an earlier Setup was merged
- **THEN** the default branch, Commands, `ci` steps and security link that Setup filled in, and the ruleset it created,
  are reported as already set and left unchanged

### Requirement: Stack skills are added only on request
The skill SHALL ask which stack skills to add, SHALL add only the skills the maintainer names, and SHALL reference each
added skill from `AGENTS.md`. It SHALL NOT change or reference skills that are already under `.agents/skills/`.

#### Scenario: Maintainer names a stack skill
- **WHEN** the maintainer names a stack skill with its GitHub source
- **THEN** the skill installs it under `.agents/skills/` and references it from `AGENTS.md`

#### Scenario: Maintainer names no stack skill
- **WHEN** the maintainer names no stack skill
- **THEN** no file under `.agents/skills/` is added and the final report lists stack skills as not done

### Requirement: The skill runs only on the default branch or chore/setup-repository
The skill SHALL fetch GitHub's default branch and run only on `chore/setup-repository` or on GitHub's default branch
at the tip of its `origin` counterpart. Otherwise it SHALL change nothing, stop and say how to get there. When the
fetch fails, it SHALL report the fetch error, change nothing and stop.

#### Scenario: Fetch fails
- **WHEN** the fetch of GitHub's default branch fails
- **THEN** the skill reports the fetch error, changes nothing and stops

#### Scenario: Run from another branch
- **WHEN** a maintainer runs the skill on a feature branch
- **THEN** the skill changes nothing, stops and tells the maintainer to switch to the default branch or to
  `chore/setup-repository`

#### Scenario: Local default branch behind origin
- **WHEN** a maintainer runs the skill on the default branch and it is behind its `origin` counterpart
- **THEN** the skill changes nothing, stops and tells the maintainer to update the branch from `origin`

#### Scenario: Setup branch already exists
- **WHEN** a maintainer runs the skill on the default branch and `chore/setup-repository` exists locally or on `origin`
- **THEN** the skill changes nothing, stops and tells the maintainer to switch to `chore/setup-repository` or delete it

### Requirement: Setup changes go through chore/setup-repository and a reviewed pull request
The skill SHALL commit only on `chore/setup-repository`, created from GitHub's default branch. When that branch has
commits that are not on the default branch, the skill SHALL have the `reviewer` agent review it, open the pull request
and, only after the maintainer's approval, merge it with the `finish-work` skill.

#### Scenario: Repository on master without a setup branch
- **WHEN** the default branch on GitHub is `master`, no `chore/setup-repository` exists and the maintainer confirms a
  change
- **THEN** the skill creates `chore/setup-repository` from `origin/master` and commits there

#### Scenario: Rerun on the setup branch
- **WHEN** a maintainer runs the skill on an existing `chore/setup-repository` and confirms a change
- **THEN** the skill commits on `chore/setup-repository` and opens or updates its pull request

#### Scenario: Nothing to change
- **WHEN** every Setup value is already set and `chore/setup-repository` does not exist or has no commits that are not
  on the default branch
- **THEN** the skill creates no branch, commit or pull request and only reports

### Requirement: An unsettled default branch stops Setup
When the default-branch step ends not done, because the places disagree or the maintainer declines, the skill SHALL
make no other change and stop. Its final report SHALL list every other Setup step as not done because the default
branch is unsettled.

#### Scenario: Places disagree
- **WHEN** `AGENTS.md` names `master`, both `ci.yml` filters name `main` and the default branch on GitHub is `master`
- **THEN** the skill changes neither file, reports the default branch as not done, naming each place and its value,
  so the maintainer makes them agree by hand, and stops

#### Scenario: Maintainer declines the default branch
- **WHEN** the skill proposes `master` for the three places and the maintainer declines
- **THEN** all three still name `main`, the skill reports the default branch as not done and stops; every
  other Setup step is reported as not done because the default branch is unsettled

## MODIFIED Requirements

### Requirement: The default branch is read, not assumed
The skill SHALL read the repository's actual default branch from GitHub and SHALL treat the Repository section of
`AGENTS.md` and both branch filters of `.github/workflows/ci.yml` as one value. It SHALL propose GitHub's branch for
all three only when all three still hold the template value `main` and GitHub's branch differs. When all three name
GitHub's branch, it SHALL report the value as already set. Otherwise it SHALL change none of them and report the step as
not done, naming each place and its value. The three places SHALL be one change, confirmed or declined as a whole.

#### Scenario: Repository on master
- **WHEN** the default branch on GitHub is `master` and `AGENTS.md` and `ci.yml` still name `main`
- **THEN** the skill proposes `master` for the Repository section of `AGENTS.md` and both branch filters of `ci.yml`

#### Scenario: Repository on main
- **WHEN** the default branch on GitHub is `main` and `AGENTS.md` and both `ci.yml` filters name `main`
- **THEN** the skill reports the default branch as already set and changes neither file

### Requirement: The ruleset is created only with permission and rights
The skill SHALL require the `ci` check on the default branch through a branch ruleset only when the maintainer has
admin rights on the repository, `ci.yml` has a job named `ci` that runs on pull requests to the default branch (as
`ci.yml` will be after a confirmed default-branch change), and the maintainer confirms it. It SHALL NOT change
existing rulesets. Otherwise it SHALL report the step as not done, with the reason.

#### Scenario: Maintainer without admin rights
- **WHEN** the maintainer has only write access to the repository
- **THEN** the skill creates no ruleset and its final report lists the ruleset step as not done, with the reason

#### Scenario: Ruleset after a confirmed default-branch change
- **WHEN** the default branch on GitHub is `master`, all three places name `main`, the maintainer has admin rights,
  `ci.yml` has a job named `ci`, GitHub returns the rules, no ruleset requires `ci`, and the maintainer confirms the
  default-branch change
- **THEN** the skill offers the ruleset and does not report that `ci` does not run on pull requests to `master`

#### Scenario: No ci job
- **WHEN** the maintainer renamed the job in `ci.yml` to `build`
- **THEN** the skill creates no ruleset and reports that no job named `ci` exists, so requiring `ci` would block every
  pull request

#### Scenario: Ruleset already requires ci
- **WHEN** a ruleset on the default branch already requires the `ci` check
- **THEN** the skill reports the ruleset step as already set and creates no ruleset

## REMOVED Requirements

### Requirement: A kept ci.yml aligns AGENTS.md to its default branch
**Reason**: A `ci.yml` kept from a repository's own files exists only after onboarding, which the template no longer
supports.
**Migration**: When `AGENTS.md` and `ci.yml` name different branches, the skill reports the default branch as not done
and the maintainer makes them agree by hand.

### Requirement: Missing AGENTS.md sections are offered
**Reason**: A repository created from the template always has the Repository and Commands sections.
**Migration**: The skill stops when a section is missing; restore it from the template by hand.

### Requirement: Existing workflows are combined with ci on purpose
**Reason**: A repository created from the template has no workflows of its own when Setup runs.
**Migration**: Add steps to the `ci` job, or call another workflow from it, by hand.

### Requirement: Values already set are kept
**Reason**: Its scenarios covered conflicting values and an `AGENTS.md` kept from a repository's own files, which only onboarding produced.
**Migration**: Replaced by "Only placeholder values are changed".

### Requirement: Stack skills are referenced and added only on request
**Reason**: Referencing a repository's own unreferenced skills applied only to onboarded repositories.
**Migration**: Replaced by "Stack skills are added only on request".

### Requirement: Setup changes go through a reviewed pull request
**Reason**: Reusing `chore/adopt-template` or another `chore/` branch applied only to onboarding.
**Migration**: Replaced by "Setup changes go through chore/setup-repository and a reviewed pull request".
