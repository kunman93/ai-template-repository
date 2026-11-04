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

- Declare the name in `AGENTS.md`, refer to `<default-branch>` in skills and agents, and name it in the branch filters of `ci.yml`
- Require every repository to rename its default branch to `main`
- Detect the name at run time with `gh repo view --json defaultBranchRef` or `origin/HEAD`
- Keep `main` hard-coded in each file and edit them all when adopting the template
- Trigger `ci.yml` without branch filters and skip the job by condition

## Decision Outcome

Chosen option: "Declare the name in `AGENTS.md`", because it keeps the name in one explicit place that every agent
reads first, survives syncs (`AGENTS.md` is merged by hand) and forces no rename on anyone. `ci.yml` is the one
exception: GitHub reads it, not `AGENTS.md`, so its branch filters name the branch too.

### Consequences

- Good, because a repository on `master` changes `AGENTS.md` and the two branch filters of `ci.yml`, and no skill or
  agent file needs editing.
- Good, because the value is explicit and reviewable in a PR.
- Bad, because `ci.yml` cannot read `AGENTS.md`, so the branch is named in a second place, marked with `TODO` comments
  and called out in the Repository section and in Setup. If it is not updated, `ci` never runs and a ruleset that
  requires it keeps every PR pending, so the mistake shows on the first PR.
- Bad, because contributors must write `<default-branch>` and not `main` in new workflow files. The Repository section of
  `AGENTS.md` states the rule.

## Pros and Cons of the Options

### Trigger `ci.yml` without branch filters and skip the job by condition

- Good, because `ci.yml` does not name the branch.
- Bad, because every push to a PR branch adds a second, skipped `ci` check next to the real one, which is confusing.
  It does not weaken the gate: in `kunman93/git-sandbox`, a ruleset requiring `ci` kept blocking a PR whose real `ci`
  failed, even after the skipped run was re-run.

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
