# Proposal

## Why

Adopting the template in an existing repository means five blocks of git commands in `README.md` (remote, list, copy,
decide per file, commit) that a maintainer has to copy, adapt and run in order. That is error-prone, and pulling later
template changes into the repository has no support at all. `gh skill install --allow-hidden-dirs` can now install a
single skill from this template into any repository, so the onboarding steps can become a skill that the maintainer
installs and runs (Story #20).

## What Changes

- New workflow skill `.agents/skills/onboard-repository`. A maintainer installs it with
  `gh skill install <template-repo> onboard-repository --allow-hidden-dirs --dir .agents/skills` and runs it. It:
  - reads the template repository and ref from the `metadata` that `gh skill install` writes into its own frontmatter,
    so it works from forks without editing, and adds that repository as the `template` git remote;
  - stops on uncommitted changes (except its own freshly installed directory) and never renames, commits to or
    rewrites the default branch;
  - works on `chore/adopt-template` from `origin/<default-branch>`, or offers to reuse that branch when it exists;
  - copies only the template files the repository does not have, never the template's `README.md`,
    `openspec/specs/`, `openspec/changes/` or its own decision records;
  - lists every existing file that differs from the template before changing anything and asks keep, take or merge
    for each, proposing merge for `AGENTS.md`, `.github/workflows/ci.yml` and `.github/ISSUE_TEMPLATE/config.yml`;
  - commits with the `git-commit` skill, recording the adopted template commit in a `Template-Commit: <sha>` trailer,
    and hands over to `setup-repository` on the same branch, so onboarding and Setup end in one PR;
  - can be run again: with a recorded `Template-Commit`, it offers only the files the template changed since then, so a
    second run without template changes changes nothing.
- `README.md` "Adopting the template": the existing-repository path becomes the install command, the hidden-directory
  warning `gh` prints and running the skill. The manual git steps stay as a fallback.
- `README.md` skill list, `AGENTS.md` Implementation Workflow and `setup-repository` refer to `onboard-repository` instead
  of the manual onboarding steps; `setup-repository` counts it as a template skill.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `template-onboarding`: onboarding an existing repository is done by the `onboard-repository` skill instead of documented
  git commands (which remain as a fallback); the skill locates the template from its own metadata, guards the working
  tree and default branch, records the adopted template commit and supports later re-runs that offer only template
  changes.

## Impact

- New: `.agents/skills/onboard-repository/SKILL.md`.
- Changed: `README.md`, `AGENTS.md` (Implementation Workflow), `.agents/skills/setup-repository/SKILL.md`.
- Specs: `openspec/specs/template-onboarding/spec.md`.
- No new dependencies: the skill uses `git` and `gh`, which are already prerequisites.
- Verified end to end in `kunman93/git-sandbox` (default branch `master`); its PRs are closed, or merged only into a scenario
  branch, and `master` stays unchanged.
