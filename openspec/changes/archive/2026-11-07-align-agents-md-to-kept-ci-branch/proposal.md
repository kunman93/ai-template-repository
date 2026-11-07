# Proposal

## Why

A maintainer who onboards an existing repository and keeps their own `ci.yml` has `ci.yml` filters that already name
the real default branch, while `AGENTS.md` still holds the template's `main`. Today `setup-repository` reports this as
a mismatch and changes nothing, so the maintainer must edit `AGENTS.md` by hand, even though only one value is right
(#24, originally #23).

## What Changes

- When `AGENTS.md` holds `main`, every existing `ci.yml` branch filter names GitHub's default branch and that branch is
  not `main`, Setup treats the `AGENTS.md` value as a placeholder and offers to change it to GitHub's default branch.
  `ci.yml` is reported as already set and never rewritten.
- When the branch the kept `ci.yml` names differs from GitHub's default branch, Setup keeps reporting a mismatch and
  changes neither file.
- The "Mixed default branch values" scenario and the matching Default branch rule in
  `.agents/skills/setup-repository/SKILL.md` describe the new behavior.
- Out of scope: the reverse case (`AGENTS.md` already set, `ci.yml` still on the template's `main`) stays a mismatch.

## Capabilities

### New Capabilities

_None._

### Modified Capabilities

- `repository-setup`: the "Values already set are kept" requirement treats a `main` in `AGENTS.md` as a placeholder
  when the `ci.yml` filters already name GitHub's default branch.

## Impact

- `openspec/specs/repository-setup/spec.md`
- `.agents/skills/setup-repository/SKILL.md` (steps 1 and 2, Default branch)
- No code, dependencies or CI changes.
