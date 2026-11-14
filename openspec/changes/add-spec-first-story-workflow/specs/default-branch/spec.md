# Spec Delta

## MODIFIED Requirements

### Requirement: Workflow files do not hard-code the default branch
The workflow skills (`implement-story`, `write-spec`, `implement-spec`, `fix-bug`, `do-chore`, `setup-repository`, `finish-work`), the reviewer agent and the Git Workflow
section of `AGENTS.md` SHALL refer to the default branch as `<default-branch>` or "the default branch" and SHALL NOT
name `main` as a branch. Vendored and OpenSpec-generated files are exempt.

#### Scenario: Search for a hard-coded branch
- **WHEN** a maintainer searches the workflow skills, the reviewer agent and `AGENTS.md` for `main` used as a branch
  name (for example `origin/main` or ``"`main`"``)
- **THEN** the only match is the default branch value in the Repository section of `AGENTS.md`, plus the placeholder
  value `main` that `setup-repository` detects
