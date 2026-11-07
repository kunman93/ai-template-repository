# Spec Delta

## MODIFIED Requirements

### Requirement: Onboarding an existing repository is documented
`README.md` SHALL document, under "Adopting the template", one short list for both a new and an existing repository:
get the template files, run the `setup-repository` skill, describe the project in `README.md`. Getting the files SHALL
consist of creating the repository from the template for a new repository, and of git commands a maintainer or an agent
can run in the existing repository for an existing one. `README.md` SHALL keep the Setup steps the skill applies
documented as manual steps.

#### Scenario: Two adoption paths
- **WHEN** a reader opens "Adopting the template" in `README.md`
- **THEN** it describes one list in which only getting the files differs between a new and an existing repository,
  followed by running `setup-repository` and describing the project

#### Scenario: Manual Setup
- **WHEN** a maintainer does not want to use the skill
- **THEN** `README.md` documents the Setup steps manually (default branch, Commands, `ci` job, ruleset, security link,
  stack skills)

#### Scenario: No more work than a new repository
- **WHEN** a maintainer adopts the template in an existing repository
- **THEN** the only steps that a new repository does not need are getting the template files and committing them

### Requirement: The default branch is declared, not renamed
The existing-repository path SHALL keep the repository's default branch name. The default branch SHALL be set in the
Repository section of `AGENTS.md` and in the branch filters of `.github/workflows/ci.yml` on the onboarding branch,
by `setup-repository` or by the manual Setup steps, before the onboarding PR is opened. Onboarding SHALL NOT rename the
default branch.

#### Scenario: Repository on master
- **WHEN** a maintainer onboards a repository whose default branch is `master`
- **THEN** the branch stays `master`, the onboarding `chore/` branch is cut from `master`, and `master` is set in
  `AGENTS.md` and in both branch filters of `ci.yml` on that branch before the PR is opened
