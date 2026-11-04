# default-branch Specification

## Purpose
Lets a repository keep whatever default branch name it already uses, by declaring it in `AGENTS.md`, so that the
workflow skills and the reviewer work on it without renaming the branch.

## Requirements

### Requirement: AGENTS.md declares the default branch
`AGENTS.md` SHALL contain a Repository section that states the repository's default branch name exactly once, SHALL
state that every `<default-branch>` in a skill or agent file stands for that value, and SHALL state that the branch
filters of `.github/workflows/ci.yml` name it too. The template SHALL declare `main`.

#### Scenario: Template value
- **WHEN** a reader opens the Repository section of the template's `AGENTS.md`
- **THEN** it states the default branch `main`, explains that `<default-branch>` refers to it and points to the branch
  filters of `ci.yml`

#### Scenario: Repository on master
- **WHEN** a maintainer sets the default branch in `AGENTS.md` to `master`
- **THEN** the agent creates branches from, targets PRs at, reviews against and rebases on `master`, and no skill or
  agent file needs editing for the workflow to use `master`

### Requirement: Workflow files do not hard-code the default branch
The workflow skills (`implement-story`, `fix-bug`, `do-chore`, `finish-work`), the reviewer agent and the Git Workflow
section of `AGENTS.md` SHALL refer to the default branch as `<default-branch>` or "the default branch" and SHALL NOT
name `main` as a branch. Vendored and OpenSpec-generated files are exempt.

#### Scenario: Search for a hard-coded branch
- **WHEN** a maintainer searches the workflow skills, the reviewer agent and `AGENTS.md` for `main` used as a branch
  name (for example `origin/main` or ``"`main`"``)
- **THEN** the only match is the default branch value in the Repository section of `AGENTS.md`

### Requirement: Setup refers to the default branch
The setup steps in `README.md` SHALL require the `ci` check in a branch ruleset on the default branch, not on a branch
named `main`, and SHALL tell the maintainer to set the default branch in `AGENTS.md` and in the branch filters of
`ci.yml`.

#### Scenario: Ruleset step
- **WHEN** a reader follows the ruleset step under "Adopting the template"
- **THEN** it targets the repository's default branch

#### Scenario: Default branch step
- **WHEN** a reader whose default branch is not `main` follows Setup
- **THEN** it tells them to set the branch in the Repository section of `AGENTS.md` and in both branch filters of
  `ci.yml`
