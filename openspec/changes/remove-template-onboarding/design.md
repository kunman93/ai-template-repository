# Design

## Context

See proposal.md (Why). Onboarding reaches into five places: the `onboard-repository` skill, `README.md`, `AGENTS.md`,
`finish-work` and `setup-repository`. Most of the onboarding logic in `setup-repository` sits in step 1 (Gather and
classify), step 2 (Decide) and step 3 (Branch and commit).

## Goals / Non-Goals

**Goals:**

- `setup-repository` assumes a repository created from the template and stays safe to run again.
- No file under `.agents/` or `.github/`, and neither `AGENTS.md` nor `README.md`, mentions `onboard-repository` or
  `chore/adopt-template`. The specs and the change archive may still name them as history.

**Non-Goals:**

- No replacement path for existing repositories.
- No new behavior in the other Setup steps beyond dropping onboarding handling and using GitHub's default branch for
  every ref.

## Decisions

### Default branch is one value

The skill reads three places:

- the Repository section of `AGENTS.md`;
- both `branches` filters of `ci.yml`.

| The three places                         | Outcome                              |
|------------------------------------------|--------------------------------------|
| all `main`, and GitHub's branch differs  | to change: propose GitHub's branch   |
| all name GitHub's branch                 | already set                          |
| anything else                            | not done: list each place and value  |

- The three places are one change, confirmed or declined as a whole, so declining cannot split them.
- A "not done" default branch, whether the places disagree or the maintainer declined, stops the skill before any
  other step. The final report lists every other step as not done because the default branch is unsettled. Every
  later step, the reviewer and `finish-work` read `<default-branch>` from `AGENTS.md`. With a wrong
  value they would require a `ci` check that never runs, or open the PR against a branch that does not exist. A
  repository created from the template normally gets `main` on GitHub, so this only triggers after a rename on GitHub.
- The "not done" row is a check that the three places agree, not the removed mismatch handling. It keeps the rule in `AGENTS.md` that `AGENTS.md` and `ci.yml` name the same branch.
- It drops the kept-`ci.yml` partial-alignment case.
- Alternative: replace each `main` on its own. Rejected by the user, because it can leave `AGENTS.md` and `ci.yml`
  naming different branches.

### Missing template files or sections stop the skill

- A repository created from the template always has `AGENTS.md` with its Repository and Commands sections, `ci.yml`
  and `ISSUE_TEMPLATE/config.yml`.
- So the skill checks for them in step 1 (Gather) and stops when one is missing, instead of offering to add it.
- The check moves from step 3 to step 1. It runs after the branch check, so the skill stops before it asks
  anything.
- Alternative: keep offering the missing sections. Rejected, because the Story removes that handling.

### Only `chore/setup-repository`

- `<default-branch>` in `AGENTS.md` still holds the placeholder `main` before Setup, so the skill uses GitHub's
  default branch from `gh repo view` (called `<gh-default>` here) for every ref: the branch check, the rules API call,
  steps 3 and 4, the ruleset precondition and step 7. The ruleset precondition checks `ci.yml` as it will be after a
  confirmed default-branch change.
- The branch check runs after `git fetch origin <gh-default>`, so a stale `origin` ref cannot pass it. When the fetch
  fails, the skill changes nothing and stops.
- Step 1 starts with a branch check, so the working tree is always the tree the skill commits from:
  - On `chore/setup-repository`: continue. Running the skill there means reusing the branch.
  - On `<gh-default>`, with `HEAD` equal to `origin/<gh-default>`: continue, unless `chore/setup-repository` exists
    locally or on `origin` (`git ls-remote --heads origin chore/setup-repository`). Then stop and tell the maintainer
    to switch to it or delete it.
  - On `<gh-default>` behind `origin`: stop and tell the maintainer to fast-forward it from `origin`.
  - On `<gh-default>` ahead of or diverged from `origin`: stop and tell the maintainer to move the local commits to
    another branch and reset the default branch to `origin/<gh-default>`. Never suggest pushing to the default
    branch.
  - On any other branch: stop and name the branch to switch to.
- Step 3 creates `chore/setup-repository` from `origin/<gh-default>` when the skill runs on the default branch.
- Step 4 checks `chore/setup-repository` against `origin/<gh-default>`.
- Alternative: read the values from another branch's tree without switching to it (round 1 of the review). Rejected,
  because manifests and the Commands it runs would still come from the working tree, and it breaks when
  `origin/main` no longer exists.
- It no longer special-cases `chore/adopt-template` or another `chore/` branch.

### Ruleset precondition stays

- The check that `ci.yml` has a job named `ci` triggered on pull requests to the default branch stays. A maintainer can
  still rename the job, and requiring a check that never runs blocks every PR.
- The "No ci job" scenario changes from "kept `ci.yml`" to "renamed job".
- The precondition checks `ci.yml` as it will be after a confirmed default-branch change. A new scenario covers a
  repository on `master`.

### Stack skills: only add

- The skill drops the list of non-template skills and the fallback list of template skill names, which included
  `onboard-repository`. It also drops the `template` remote lookup.
- It only asks which stack skills to add, as today.

### Spec mechanics

- `template-onboarding`: every requirement is REMOVED. `.openspec.yaml` declares `retire_capabilities: true`, so
  archiving deletes `openspec/specs/template-onboarding/` instead of stopping on a spec with no requirements.
- `repository-setup`: OpenSpec 2.0 rejects a MODIFIED block that drops a scenario. It also rejects REMOVED and ADDED
  under the same name. So the three requirements that lose scenarios are REMOVED and ADDED again under new names.

### OpenSpec CLI sync

- `AGENTS.md` drops the `onboard-repository` exception, including "the `setup-repository` it hands over to".
- `setup-repository` then syncs the CLI like the other workflows. The stamps exist in every repository created from the
  template, so the sync is safe there.

## Risks / Trade-offs

- [An existing repository that already onboarded can no longer pull template changes with the skill] → Accepted
  (Story). Its copy of `onboard-repository` keeps working until the maintainer deletes it. `gh skill update` has nothing to
  update it from once the template no longer has the skill.
- [The empty `template-onboarding` spec could be left behind after archive] → The `retire_capabilities` marker makes
  archive delete it, and the workflow follow-up in tasks.md verifies that it is gone.
