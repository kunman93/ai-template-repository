# template-onboarding Specification

## Purpose
Lets a maintainer adopt the template's agent workflow in a repository that already exists, without recreating it from
the template and without losing the repository's own files.

## Requirements

### Requirement: Onboarding an existing repository is documented
`README.md` SHALL document, under "Adopting the template", one short list for both a new and an existing repository:
get the template files, run the `setup-repository` skill, describe the project in `README.md`. For an existing
repository, getting the files SHALL be the `onboard-repository` install command and running the skill, with the git
commands kept as a manual fallback.

#### Scenario: Two adoption paths
- **WHEN** a reader opens "Adopting the template" in `README.md`
- **THEN** it describes one list in which only getting the files differs between a new and an existing repository,
  followed by running `setup-repository` and describing the project

#### Scenario: Existing repository with the skill
- **WHEN** a maintainer follows the existing-repository path
- **THEN** `README.md` gives the install command, explains the hidden-directory warning `gh` prints and tells them to
  run `onboard-repository`, which runs `setup-repository` itself; the manual git steps are presented only as a fallback

#### Scenario: Manual Setup
- **WHEN** a maintainer does not want to use the skill
- **THEN** `README.md` documents the Setup steps manually (default branch, Commands, `ci` job, ruleset, security link,
  stack skills)

#### Scenario: No more work than a new repository
- **WHEN** a maintainer adopts the template in an existing repository
- **THEN** the only steps that a new repository does not need are installing and running `onboard-repository`, or the
  manual fallback

### Requirement: Onboarding brings the template's workflow files
Onboarding SHALL add the template's agent files (`AGENTS.md`, `.agents/skills/`, `.github/agents/`), issue forms, pull
request template, `ci.yml`, OpenSpec setup (`openspec/config.yaml`, `.github/skills/openspec-*`,
`.github/prompts/opsx-*`), the decision record template, its README and record 0000, `.gitignore` and `.editorconfig`.

#### Scenario: Repository without any template files
- **WHEN** a maintainer onboards a repository that has none of these files
- **THEN** all of them are copied unchanged from the template version being adopted and committed

#### Scenario: Vendored and OpenSpec files match the template
- **WHEN** a maintainer onboards a repository
- **THEN** the vendored skills and the OpenSpec skills and prompts are copied from the template rather than
  reinstalled with `gh skill install` or `openspec init`, so their versions and set match the template

### Requirement: Existing files are never overwritten without a decision
Before changing anything, onboarding SHALL list every template file that already exists in the repository and differs
from the template. It SHALL copy only the files that do not exist yet, and SHALL leave each listed file unchanged until
the maintainer decides to keep it, take the template's version or merge both by hand. The skill's own installed
directory SHALL be left out of this comparison.

#### Scenario: A file already exists
- **WHEN** a maintainer onboards a repository that already has its own `.gitignore`
- **THEN** `.gitignore` is listed before anything changes, the skill asks keep, take or merge, and a kept `.gitignore`
  stays byte-identical

#### Scenario: Files that mix generic and project content
- **WHEN** `AGENTS.md`, `.github/workflows/ci.yml` or `.github/ISSUE_TEMPLATE/config.yml` already exists and differs
- **THEN** the skill proposes to merge it rather than take the template's version

#### Scenario: Other files are untouched
- **WHEN** the repository has files outside the template's file set, such as `.github/workflows/build.yml`
- **THEN** onboarding leaves them unchanged

### Requirement: Template-only content is not copied
Onboarding SHALL NOT copy the template's `README.md`, `openspec/specs/`, `openspec/changes/` or decision records other
than record 0000, because they describe the template itself.

#### Scenario: Copy step scope
- **WHEN** a maintainer runs `onboard-repository`
- **THEN** the repository's `README.md` is unchanged and no file under `openspec/specs/` or `openspec/changes/` is added

### Requirement: The default branch is declared, not renamed
The existing-repository path SHALL keep the repository's default branch name and SHALL NOT commit to, rename or
rewrite the default branch. The default branch SHALL be set in the Repository section of `AGENTS.md` and in the branch
filters of `.github/workflows/ci.yml` on the onboarding branch, by `setup-repository` or by the manual Setup steps,
before the onboarding PR is opened.

#### Scenario: Repository on master
- **WHEN** a maintainer onboards a repository whose default branch is `master`
- **THEN** `master` keeps its name and commits, the onboarding branch `chore/adopt-template` is cut from
  `origin/master`, and `master` is set in `AGENTS.md` and in both branch filters of `ci.yml` on that branch before the
  PR is opened

### Requirement: Onboarding prepares later syncs
Onboarding SHALL add the template as the git remote named `template` and SHALL record the adopted template commit in a
`Template-Commit: <sha>` trailer of its commit. A later run SHALL offer keep, take or merge only for files the template
changed since the recorded commit, and SHALL add files the template added since then. Without a recorded commit, a run
SHALL behave like the first run.

#### Scenario: Sync after onboarding
- **WHEN** a maintainer who onboarded a repository later runs `onboard-repository` again
- **THEN** the `template` remote already exists and no further setup is needed

#### Scenario: Second run without template changes
- **WHEN** the template has not changed since the recorded `Template-Commit`, even though Setup filled in `AGENTS.md`
  and `ci.yml`
- **THEN** the skill offers no file and creates no branch, commit or pull request

#### Scenario: Run after a template change
- **WHEN** the template changed one file since the recorded `Template-Commit`
- **THEN** the skill offers keep, take or merge only for that file, and its new commit records the new template commit

### Requirement: Onboarding is a skill installed with one command
The template SHALL provide a workflow skill `onboard-repository` under `.agents/skills/` that a maintainer installs into an
existing repository with `gh skill install <template-repo> onboard-repository --allow-hidden-dirs --dir .agents/skills` and
then runs to onboard that repository.

#### Scenario: Install into an existing repository
- **WHEN** a maintainer runs the install command in a repository that has none of the template files
- **THEN** only `.agents/skills/onboard-repository/` is added, and running the skill onboards the repository

### Requirement: The skill finds the template from its own metadata
The skill SHALL read the template repository and ref from the source `metadata` in its own frontmatter, which
`gh skill install` writes, and SHALL use them for the `template` remote and as the template version to adopt. Without
that metadata, the skill SHALL tell the maintainer to install it with `gh skill install` and stop.

#### Scenario: Installed from a fork
- **WHEN** a maintainer installs `onboard-repository` from a fork of the template
- **THEN** the skill adopts the fork's files, without anyone editing the skill

#### Scenario: Copy without metadata
- **WHEN** the skill's frontmatter has no source metadata, for example in a repository created from the template
- **THEN** the skill tells the maintainer to install it with `gh skill install` and changes nothing

### Requirement: The skill starts only from a clean working tree
The skill SHALL stop before changing anything when the working tree has uncommitted changes other than its own
directory `.agents/skills/onboard-repository/`, which the install adds or updates.

#### Scenario: Dirty working tree
- **WHEN** the maintainer has an uncommitted change to a project file and runs the skill
- **THEN** the skill tells them to commit or stash it and stops; no branch, remote, file or commit is created

#### Scenario: Freshly installed skill
- **WHEN** the only uncommitted change is the newly installed `.agents/skills/onboard-repository/`
- **THEN** the skill continues and commits that directory with the onboarding

### Requirement: The skill works on chore/adopt-template
The skill SHALL make its changes on the branch `chore/adopt-template` created from `origin/<default-branch>`. When that
branch already exists, locally or on `origin`, the skill SHALL ask whether to reuse it and SHALL stop if the maintainer
declines. The skill SHALL NOT delete a branch.

#### Scenario: Branch already exists
- **WHEN** `chore/adopt-template` exists from an earlier, unfinished run
- **THEN** the skill asks whether to reuse it, and continues on it only after the maintainer agrees

#### Scenario: Branch left over from a merged onboarding
- **WHEN** `chore/adopt-template` exists and its tip is already in the default branch
- **THEN** the skill says so, and when the maintainer declines it tells them how to delete the branch, stops and
  deletes nothing itself

### Requirement: Onboarding hands over to Setup
After committing, the skill SHALL run the `setup-repository` skill on the same branch, so the onboarding and the Setup
changes go into one pull request. When the skill has nothing to change, it SHALL create no branch, commit or pull
request and SHALL only report.

#### Scenario: Onboarding committed
- **WHEN** the skill has committed the onboarding on `chore/adopt-template`
- **THEN** `setup-repository` runs on `chore/adopt-template`, and the onboarding and Setup changes end in one pull
  request

#### Scenario: Nothing to change
- **WHEN** a run finds no template file to add and no template change to offer
- **THEN** the skill creates no branch, commit or pull request and reports that the repository is up to date
