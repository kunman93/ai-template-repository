# Proposal

## Why

After adopting the template, a maintainer has to work through seven manual Setup steps in `README.md`. Some must match
the repository exactly, such as the branch filters of `ci.yml`, and are easy to miss. The existing-repository path also
has its own six steps, which partly repeat Setup (the default branch step appears twice). That makes adopting the
template in an existing repository more work than in a new one (Story #15).

## What Changes

- Add a workflow skill `.agents/skills/setup-repository` that walks the maintainer through the project-specific Setup on
  a `chore/` branch, end to end like `do-chore`:
  - reuses `chore/adopt-template` (after the onboarding copy steps, and any other `chore/` branch only on request) or creates
    `chore/setup-repository` from `origin/<default-branch>`;
  - reads the actual default branch with `gh repo view` and proposes it for the Repository section of `AGENTS.md` and
    both branch filters of `ci.yml`, instead of assuming `main`;
  - proposes the Commands of `AGENTS.md` from the manifests it finds, and the `ci` job steps from the confirmed
    Commands, after asking how `ci` relates to workflows the repository already has;
  - proposes the security advisory link for the current repository;
  - offers to create a branch ruleset on the default branch that requires `ci`, only with admin rights and only when
    a job named `ci` runs on pull requests to the default branch;
  - offers to reference existing skills that `AGENTS.md` does not mention, asks which stack skills to add, and
    references them from `AGENTS.md`;
  - asks before every change, never overwrites a value the maintainer has already set, and reports every step it did
    not do itself, with the reason;
  - commits with `git-commit`, has the `reviewer` review the branch and finishes with `finish-work`.
- Restructure "Adopting the template" in `README.md` into one short list for both paths: get the files (new repository:
  create from the template; existing repository: the remote, list, copy and decide commands), run `setup-repository`,
  describe the project in the README. The manual Setup steps stay documented in their own section for maintainers who
  do not use the skill.
- List the skill in `README.md` ("What is included") and in the Implementation Workflow section of `AGENTS.md`.
- Verify five scenarios in `kunman93/git-sandbox` (private, default branch `master`): a bare repository, a React
  project, a Spring Boot project with its own workflow, a Spring Boot project with its own agent files, and a second
  run. The sandbox PRs are closed without merging, so its `master` stays untouched.

## Capabilities

### New Capabilities

- `repository-setup`: the `setup-repository` skill that applies the project-specific Setup of an adopted repository,
  with a confirmation for every change and a report of the steps it left to the maintainer.

### Modified Capabilities

- `template-onboarding`: "Adopting the template" becomes one list for both paths that hands Setup to the skill and
  keeps the manual steps documented; the existing-repository path no longer has its own default branch step, because
  the skill sets it before the onboarding PR is opened.
- `default-branch`: the Setup requirements now hold for both the skill and the manual Setup steps.

## Impact

- New file: `.agents/skills/setup-repository/SKILL.md`.
- Changed files: `README.md` ("What is included", "Adopting the template"), `AGENTS.md` (Implementation Workflow).
- No scripts and no new dependencies. Uses `gh` and `git`, which are already prerequisites.
- Creating the ruleset changes GitHub settings outside the repository. The skill asks first and needs admin rights.
- Verification pushes branches and opens PRs in `kunman93/git-sandbox`, outside this repository, with the maintainer's
  permission. The PRs are closed and the branches deleted afterwards.
- Repositories created from the template get the skill from the start. Existing repositories get it with the
  onboarding copy step, because `.agents` is already in the copied paths.
