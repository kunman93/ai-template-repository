# Spec Delta

## MODIFIED Requirements

### Requirement: Setup refers to the default branch
The setup steps in `README.md` and the `setup-repository` skill SHALL require the `ci` check in a branch ruleset on the
default branch, not on a branch named `main`, and SHALL set the default branch in `AGENTS.md` and in the branch filters
of `ci.yml`.

#### Scenario: Ruleset step
- **WHEN** a reader follows the ruleset step under "Adopting the template", or the skill creates the ruleset
- **THEN** it targets the repository's default branch

#### Scenario: Default branch step
- **WHEN** a reader whose default branch is not `main` follows the manual Setup steps
- **THEN** they tell them to set the branch in the Repository section of `AGENTS.md` and in both branch filters of
  `ci.yml`

### Requirement: Workflow files do not hard-code the default branch
The workflow skills (`implement-story`, `fix-bug`, `do-chore`, `setup-repository`, `finish-work`), the reviewer agent and the Git Workflow
section of `AGENTS.md` SHALL refer to the default branch as `<default-branch>` or "the default branch" and SHALL NOT
name `main` as a branch. Vendored and OpenSpec-generated files are exempt.

#### Scenario: Search for a hard-coded branch
- **WHEN** a maintainer searches the workflow skills, the reviewer agent and `AGENTS.md` for `main` used as a branch
  name (for example `origin/main` or ``"`main`"``)
- **THEN** the only match is the default branch value in the Repository section of `AGENTS.md`, plus the placeholder
  value `main` that `setup-repository` detects
