# Design

## Context

Step 1 of `.agents/skills/setup-repository/SKILL.md` classifies the default branch by comparing the values that
exist in the Repository section of `AGENTS.md` and the two `ci.yml` branch filters with each other and with GitHub. It
has three cases: all `main` and GitHub differs (placeholders), all equal to GitHub (already set), otherwise mismatch.
Step 2 proposes GitHub's branch for every location that holds `main`.

## Goals / Non-Goals

**Goals:**
- Add one classification case without changing the outcome of any case that exists today, except the one in #24.

**Non-Goals:**
- Telling a template `ci.yml` from a kept one.
- The reverse case: `AGENTS.md` already set while `ci.yml` still holds the template's `main`.

## Decisions

- **Decide on values, not on where `ci.yml` came from.** The new case applies when `AGENTS.md` holds `main`, at
  least one `ci.yml` filter exists, every existing filter names GitHub's default branch, and that branch is not `main`.
  A template `ci.yml` cannot reach this state without the maintainer having edited it, so "kept" needs no detection.
  Alternative: detect a kept `ci.yml` through the template's `# TODO` comments or the `template` remote. Rejected: more
  rules for the same outcome.
- **Only `AGENTS.md` moves.** In the new case, `ci.yml` is "already set", and step 2 proposes GitHub's branch for
  `AGENTS.md` only, leaving the `TODO` comment handling of step 2 untouched because it applies only to filters that hold
  `main`.
- **GitHub stays the source of truth.** If the `ci.yml` filters name another branch than GitHub's, the case does not
  apply and the old "mismatch" outcome stays, so Setup never writes a branch GitHub does not report.

## Risks / Trade-offs

- [A maintainer really wants `AGENTS.md` to stay `main` while `ci.yml` and GitHub use `master`] → Every change is
  confirmed; declining leaves `AGENTS.md` unchanged and reports it as not done.
