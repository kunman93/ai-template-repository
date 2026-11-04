# ci-check Specification

## Purpose
Provides the status check named `ci` that the branch ruleset on the default branch requires, so pull requests can only merge after
it passes, whatever stack the repository uses.

## Requirements

### Requirement: ci passes before a stack is added
Until a repository adds its own build, test and lint steps, the `ci` check SHALL pass without installing any toolchain
or dependencies.

#### Scenario: Template without a stack
- **WHEN** the `ci` check runs on a repository that has not added a stack
- **THEN** the check succeeds

### Requirement: A check named ci runs on the default branch
Every pull request to the repository's default branch and every push to it SHALL run a status check named `ci`.
`ci.yml` SHALL name the default branch in the branch filters of `pull_request` and `push`, with a `TODO` comment that
tells the maintainer to set their default branch, and SHALL NOT skip the `ci` job by condition.

#### Scenario: Pull request to the default branch
- **WHEN** a pull request targeting the default branch is opened or updated
- **THEN** a check named `ci` runs on it

#### Scenario: Push to the default branch
- **WHEN** a commit is pushed to the default branch
- **THEN** a check named `ci` runs on it

#### Scenario: Default branch is not main
- **WHEN** a repository whose default branch is `master` sets `master` in both branch filters of `ci.yml`
- **THEN** pull requests to `master` and pushes to `master` run the `ci` check

#### Scenario: One ci check per pull request
- **WHEN** commits are pushed to the branch of a pull request that targets the default branch
- **THEN** the pull request shows exactly one check named `ci` per commit
