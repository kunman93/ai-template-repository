# Spec Delta

## RENAMED Requirements

- FROM: `### Requirement: A check named ci runs on main`
- TO: `### Requirement: A check named ci runs on the default branch`

## MODIFIED Requirements

### Requirement: A check named ci runs on the default branch
Every pull request and every push to the repository's default branch SHALL run a status check named `ci`, whatever the
default branch is named. `ci.yml` SHALL NOT name the default branch.

#### Scenario: Pull request to main
- **WHEN** a pull request targeting the default branch is opened or updated
- **THEN** a check named `ci` runs on it

#### Scenario: Push to main
- **WHEN** a commit is pushed to the default branch
- **THEN** a check named `ci` runs on it

#### Scenario: Default branch is not main
- **WHEN** a repository whose default branch is `master` uses the template's `ci.yml` unchanged
- **THEN** pull requests to `master` and pushes to `master` run the `ci` check, and pushes to other branches do not
  run its steps
