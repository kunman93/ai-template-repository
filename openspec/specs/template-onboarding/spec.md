# template-onboarding Specification

## Purpose
Lets a maintainer adopt the template's agent workflow in a repository that already exists, without recreating it from
the template and without losing the repository's own files.

## Requirements

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

### Requirement: Onboarding brings the template's workflow files
Onboarding SHALL add the template's agent files (`AGENTS.md`, `.agents/skills/`, `.github/agents/`), issue forms, pull
request template, `ci.yml`, OpenSpec setup (`openspec/config.yaml`, `.github/skills/openspec-*`,
`.github/prompts/opsx-*`), the decision record template, its README and record 0000, `.gitignore` and `.editorconfig`.

#### Scenario: Repository without any template files
- **WHEN** a maintainer onboards a repository that has none of these files
- **THEN** all of them are copied unchanged from `template/main` and staged

#### Scenario: Vendored and OpenSpec files match the template
- **WHEN** a maintainer onboards a repository
- **THEN** the README tells them to copy the vendored skills and the OpenSpec skills and prompts from the template
  rather than reinstall them with `gh skill install` or `openspec init`, so their versions and set match the template

### Requirement: Existing files are never overwritten without a decision
Before copying, onboarding SHALL list every template file that already exists in the repository. Onboarding SHALL copy
only the files that do not exist yet, and SHALL leave each existing file unchanged until the maintainer decides to keep
it, take the template's version or merge both by hand.

#### Scenario: A file already exists
- **WHEN** a maintainer onboards a repository that already has `.gitignore`
- **THEN** `.gitignore` is listed as existing, the copy step leaves it unchanged, and the README tells the maintainer
  the commands to keep it, take the template's version or compare both to merge by hand

#### Scenario: Files that mix generic and project content
- **WHEN** `AGENTS.md`, `.github/workflows/ci.yml` or `.github/ISSUE_TEMPLATE/config.yml` already exists
- **THEN** the README tells the maintainer to merge it by hand rather than take the template's version

### Requirement: Template-only content is not copied
Onboarding SHALL NOT copy the template's `README.md`, `openspec/specs/`, `openspec/changes/` or decision records other
than record 0000, because they describe the template itself.

#### Scenario: Copy step scope
- **WHEN** a maintainer runs the copy step
- **THEN** the repository's `README.md` is unchanged and no file under `openspec/specs/` or `openspec/changes/` is added

### Requirement: The default branch is declared, not renamed
The existing-repository path SHALL keep the repository's default branch name. The default branch SHALL be set in the
Repository section of `AGENTS.md` and in the branch filters of `.github/workflows/ci.yml` on the onboarding branch,
by `setup-repository` or by the manual Setup steps, before the onboarding PR is opened. Onboarding SHALL NOT rename the
default branch.

#### Scenario: Repository on master
- **WHEN** a maintainer onboards a repository whose default branch is `master`
- **THEN** the branch stays `master`, the onboarding `chore/` branch is cut from `master`, and `master` is set in
  `AGENTS.md` and in both branch filters of `ci.yml` on that branch before the PR is opened

### Requirement: Onboarding prepares later syncs
The existing-repository path SHALL add the template as the git remote named `template`, so that later syncs need no further
setup, and SHALL end with reviewing the staged changes and committing them on a `chore/`
branch.

#### Scenario: Sync after onboarding
- **WHEN** a maintainer who onboarded a repository later wants to fetch template changes
- **THEN** the `template` remote already exists and no further setup is needed
