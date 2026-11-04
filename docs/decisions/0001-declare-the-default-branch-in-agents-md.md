---
status: accepted
date: 2026-11-04
---

# Declare the default branch in AGENTS.md

## Context and Problem Statement

The workflow skills, the reviewer and `ci.yml` assumed the default branch is called `main`. Repositories that adopt the
template, especially existing ones (Story #6), may use `master` or another name, and renaming a branch breaks clones,
pipelines and links that the maintainers of those repositories control. How does the workflow learn the default branch
name?

## Considered Options

- Declare the name once in `AGENTS.md` and refer to `<default-branch>` everywhere else
- Require every repository to rename its default branch to `main`
- Detect the name at run time with `gh repo view --json defaultBranchRef` or `origin/HEAD`
- Keep `main` hard-coded in each file and edit them all when adopting the template

## Decision Outcome

Chosen option: "Declare the name once in `AGENTS.md`", because it keeps the name in a single explicit place that every
agent reads first, survives syncs (`AGENTS.md` is merged by hand) and forces no rename on anyone.

### Consequences

- Good, because a repository on `master` changes one line, and no other workflow file needs editing.
- Good, because the value is explicit and reviewable in a PR.
- Bad, because `ci.yml` cannot read `AGENTS.md`; it triggers on every pull request and push and skips the job unless the
  ref is the repository's default branch, so pushes to other branches start a run that is skipped.
- Bad, because contributors must write `<default-branch>` and not `main` in new workflow files. The Repository section of
  `AGENTS.md` states the rule.

## Pros and Cons of the Options

### Require a rename to `main`

- Good, because no placeholder is needed.
- Bad, because it breaks other people's clones, pipelines and links, and the maintainers of an existing repository may
  not agree to it.

### Detect the name at run time

- Good, because there is no setting to maintain.
- Bad, because the detection is implicit, and `origin/HEAD` is often unset in clones.

### Keep `main` hard-coded

- Good, because it is the simplest for repositories on `main`.
- Bad, because every other repository edits many files and drifts from the template on each sync.
