# Spec Delta

## Purpose

Lets a maintainer adopt the template's agent workflow in a repository that already exists, without recreating it from
the template and without losing the repository's own files.

## ADDED Requirements

### Requirement: Onboarding an existing repository is documented
`README.md` SHALL document, under "Adopting the template", a path for an existing repository next to the path for a new
repository, followed by the setup steps both paths share. The existing-repository path SHALL consist of git commands a
maintainer or an agent can run in the existing repository.

#### Scenario: Two adoption paths
- **WHEN** a reader opens "Adopting the template" in `README.md`
- **THEN** it describes one path for a new repository, one for an existing repository, and then the shared setup steps
  (Commands, `ci` job, ruleset, security link, stack skills, README)

### Requirement: Onboarding brings the template's workflow files
Onboarding SHALL add the template's agent files (`AGENTS.md`, `.agents/skills/`, `.github/agents/`), issue forms, pull
request template, `ci.yml`, OpenSpec setup (`openspec/config.yaml`, `.github/skills/openspec-*`,
`.github/prompts/opsx-*`), the decision record template, its README and record 0000, `.gitignore` and `.editorconfig`.

#### Scenario: Repository without any template files
- **WHEN** a maintainer onboards a repository that has none of these files
- **THEN** all of them are copied unchanged from `template/main` and staged

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

### Requirement: The default branch is main
The existing-repository path SHALL include renaming the repository's default branch to `main` when it has another name,
locally and on GitHub, because the workflow, `ci.yml` and the ruleset assume `main`.

#### Scenario: Repository on master
- **WHEN** a maintainer onboards a repository whose default branch is `master`
- **THEN** the README gives the commands to rename it to `main` locally and on GitHub before the files are copied

### Requirement: Onboarding prepares later syncs
The existing-repository path SHALL add the template as the git remote named `template`, the same remote that "Syncing a
project with the template" uses, and SHALL end with reviewing the staged changes and committing them on a `chore/`
branch.

#### Scenario: Sync after onboarding
- **WHEN** a maintainer who onboarded a repository later follows "Syncing a project with the template"
- **THEN** the `template` remote already exists and no further setup is needed
