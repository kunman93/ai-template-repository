# Spec Delta

## Purpose

Provides the status check named `ci` that the branch ruleset on `main` requires, so pull requests can only merge after
it passes, whatever stack the repository uses.

## ADDED Requirements

### Requirement: A check named ci runs on main
Every pull request to `main` and every push to `main` SHALL run a status check named `ci`.

#### Scenario: Pull request to main
- **WHEN** a pull request targeting `main` is opened or updated
- **THEN** a check named `ci` runs on it

#### Scenario: Push to main
- **WHEN** a commit is pushed to `main`
- **THEN** a check named `ci` runs on it

### Requirement: ci passes before a stack is added
Until a repository adds its own build, test and lint steps, the `ci` check SHALL pass without installing any toolchain
or dependencies.

#### Scenario: Template without a stack
- **WHEN** the `ci` check runs on a repository that has not added a stack
- **THEN** the check succeeds
