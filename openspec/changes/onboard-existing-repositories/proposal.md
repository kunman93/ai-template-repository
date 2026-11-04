# Proposal

## Why

The README only describes adopting the template by creating a new repository from it. A maintainer of an existing
repository has no documented way to get the same agent workflow, and the copy command from "Syncing a project with the
template" (`git checkout template/main -- <paths>`) silently overwrites files the repository already has (Story #6).

## What Changes

- Split "Adopting the template" in `README.md` into a path for a new repository and a path for an existing repository,
  followed by the shared setup steps that exist today (Commands, `ci` job, ruleset, security link, stack skills,
  README).
- The existing-repository path is a sequence of documented git commands, run once in the existing repository:
  - commit or stash local work, add the `template` remote and fetch it;
  - rename the default branch to `main` if it is not `main` yet, because the workflow, `ci.yml` and the ruleset assume
    `main`;
  - list the template files the repository already has, before anything is copied;
  - copy only the template files the repository does not have yet;
  - for each file it already has, decide explicitly: keep it, take the template's version or merge by hand;
  - if the files that mix generic and project content (`AGENTS.md`, `.github/workflows/ci.yml`,
    `.github/ISSUE_TEMPLATE/config.yml`) already exist, merge them by hand instead of taking the template's version;
  - never copy the template's `README.md`, `openspec/specs/` or `openspec/changes/`, which describe the template itself;
  - review the staged result and commit it on a `chore/` branch.
- The `template` remote is the same one "Syncing a project with the template" uses, so later syncs work unchanged.
- Verify the steps by onboarding `kunman93/git-sandbox` (default branch `master`, with its own `README.md` and
  `.gitignore`) and record the result in the PR.

## Capabilities

### New Capabilities

- `template-onboarding`: how a maintainer adopts the template's workflow in a repository that already exists, without
  overwriting the repository's files without an explicit decision.

### Modified Capabilities

None.

## Impact

- Changed file: `README.md` ("Adopting the template").
- No new scripts, skills, CI steps or dependencies. Repositories created from the template inherit only the extra
  README section.
- Verification changes `kunman93/git-sandbox` (a branch rename and an onboarding PR), outside this repository; it is
  done only with the maintainer's permission.
- Keeping onboarded repositories in sync with later template changes stays out of scope (separate Story).
