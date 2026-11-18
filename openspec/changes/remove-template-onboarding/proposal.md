# Proposal

Story: #62

## Why

The template supports two ways in: "Use this template" for a new repository, and onboarding for an existing one (Story
#6, change `onboard-existing-repositories`, and change `add-onboard-repository-skill`). Onboarding is the largest part
to maintain:

- the `onboard-repository` skill;
- a manual fallback in `README.md`;
- the `chore/adopt-template` branch;
- the logic in `setup-repository` that handles a repository's own files.

The template is meant to be adopted only by new repositories, so all of this is cost without a user.

## What Changes

- **BREAKING** `.agents/skills/onboard-repository/` is deleted. An existing repository can no longer be onboarded or
  synced with the template through a skill or documented steps.
- `README.md` describes adopting the template only for a new repository:
  1. Create the repository from the template.
  2. Run `setup-repository`.
  3. Describe the project.

  It drops the `onboard-repository` entry, the existing-repository path, the manual onboarding and every
  `chore/adopt-template` mention.
- `AGENTS.md` routes `setup-repository` to `chore/setup-repository`, and drops the `onboard-repository` routing rule and the `onboard-repository` exception in the OpenSpec CLI
  sync. The exception for a chore that updates OpenSpec stays.
- `setup-repository` handles only a repository created from the template:
  - It drops every mention of `onboard-repository`, the manual onboarding, `chore/adopt-template` and the `template`
    remote.
  - It uses GitHub's default branch for every ref, not the `<default-branch>` placeholder.
  - It runs only on GitHub's default branch, at the tip of `origin` after a fetch, or on `chore/setup-repository`. On any other
    branch, or on the default branch while `chore/setup-repository` exists, it stops and names the branch to switch
    to.
  - It commits only on `chore/setup-repository`, created from GitHub's default branch. Its PR check looks at that
    branch. It no longer reuses `chore/adopt-template` or another `chore/` branch.
  - It no longer offers missing `AGENTS.md` sections. Instead, it stops when one of the template files it fills in, or
    a section it fills in, is missing.
  - The default branch is one value, confirmed or declined as one change. The skill proposes GitHub's default branch only when `AGENTS.md` and both `ci.yml`
    filters all still hold `main`. It reports the value as already set when all three already name GitHub's branch. In
    any other case, and when the maintainer declines, it reports "not done" and stops before any other Setup step,
    because every later step and `finish-work` would use the wrong branch. The maintainer makes the three places agree
    and runs the skill again. The
    kept-`ci.yml` alignment rule and the "mismatch" label are removed. The user chose this rule, so the Story's "no
    default-branch mismatch logic" is read as removing the kept-`ci.yml` alignment and its mismatch handling, not
    any check that the three places agree.
  - It no longer lists other workflows or asks how `ci` relates to them.
  - It no longer offers to reference unreferenced non-template skills. It still asks which stack skills to add.
  - It keeps every value that is already set when it runs again.
- `finish-work` no longer names `onboard-repository`.
- The archived changes `2026-11-04-onboard-existing-repositories` and `2026-11-07-add-onboard-repository-skill` stay
  unchanged as history.
- The Story's "no onboarding requirement or scenario" is read literally: no requirement in `repository-setup` names
  onboarding. So the deletions (the skill directory, the `AGENTS.md` and `finish-work` mentions, and the unchanged
  archives) are not requirements. The tasks verify them with grep checks instead.
- Out of scope: `docs/decisions/0001-declare-the-default-branch-in-agents-md.md`. It mentions existing repositories
  only as background for why the template does not rename a default branch.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `template-onboarding`: all eleven requirements are removed, so the capability goes away.
- `repository-setup`:
  - Removed requirements:
    - the kept-`ci.yml` alignment rule;
    - offering missing `AGENTS.md` sections;
    - combining `ci` with existing workflows.
  - Modified requirements:
    - the default branch becomes one value across `AGENTS.md` and both `ci.yml` filters;
    - the ruleset's "No ci job" scenario no longer assumes a kept `ci.yml`, and a scenario checks the `ci` trigger
      against GitHub's default branch as confirmed.
  - Replaced requirements, under new names. OpenSpec does not let a modified requirement drop scenarios, so each one
    is removed and added again without its onboarding scenarios:
    - "Values already set are kept" becomes "Only placeholder values are changed";
    - "Stack skills are referenced and added only on request" becomes "Stack skills are added only on request";
    - "Setup changes go through a reviewed pull request" becomes "Setup changes go through chore/setup-repository and
      a reviewed pull request".
  - New requirements:
    - "Adopting the template is documented for new repositories only". It replaces the `README.md` requirement of
      `template-onboarding`.
    - "The skill requires the template files". The skill stops when a file or section it fills in is missing.
    - "The skill runs only on the default branch or chore/setup-repository". It is split out of the branch
      requirement so that each states one behavior.
    - "An unsettled default branch stops Setup". It covers places that disagree and a declined default-branch
      change.

## Impact

- `.agents/skills/onboard-repository/`: deleted.
- `.agents/skills/setup-repository/SKILL.md`: description, intro, and steps 1 to 4, 7 and 8.
- `.agents/skills/finish-work/SKILL.md`: the Commit check section.
- `AGENTS.md`: the Implementation Workflow.
- `README.md`: the skill list, "Adopting the template" and "Manual setup".
- `openspec/specs/template-onboarding/` and `openspec/specs/repository-setup/spec.md`, through this change's deltas.
  `openspec archive` leaves the template-onboarding spec in place with no requirements, so the archive commit deletes
  that directory.
- Unchanged:
  - the other workflow skills, the reviewer, CI and `update-skills.yml`;
  - `openspec/changes/archive/2026-11-04-onboard-existing-repositories/`;
  - `openspec/changes/archive/2026-11-07-add-onboard-repository-skill/`.
