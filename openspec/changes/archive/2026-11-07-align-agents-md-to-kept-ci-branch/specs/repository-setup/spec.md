## MODIFIED Requirements

### Requirement: Values already set are kept
The skill SHALL change only values that still hold the template's placeholder: the default branch `main`, a command
reading `_not configured_`, the placeholder step of the `ci` job, and a security advisory link that does not point to
the current repository. It SHALL NOT overwrite any other value; it reports it as already set, and a conflicting value
as a mismatch for the maintainer to resolve. A `main` in `AGENTS.md` SHALL also count as a placeholder when `ci.yml` has
at least one branch filter, every filter names GitHub's default branch and that branch is not `main`; `ci.yml` then
counts as already set and is never rewritten.

#### Scenario: Commands already filled in
- **WHEN** the Test command in `AGENTS.md` is already set
- **THEN** the skill leaves it unchanged and reports it as already set

#### Scenario: Conflicting default branch
- **WHEN** `AGENTS.md` declares `develop` and the default branch on GitHub is `master`
- **THEN** the skill changes neither `AGENTS.md` nor `ci.yml` and reports the mismatch to the maintainer

#### Scenario: Mixed default branch values
- **WHEN** `AGENTS.md` declares `main`, a kept `ci.yml` declares `master` and the default branch on GitHub is `master`
- **THEN** the skill offers to change `AGENTS.md` to `master`, reports `ci.yml` as already set and leaves it unchanged

#### Scenario: Kept ci.yml on another branch than GitHub
- **WHEN** `AGENTS.md` declares `main`, a kept `ci.yml` declares `master` and the default branch on GitHub is `develop`
- **THEN** the skill changes neither file and reports every location as a mismatch

#### Scenario: ci.yml filters disagree
- **WHEN** `AGENTS.md` declares `main`, one `ci.yml` filter declares `master`, the other declares `main`, and the default
  branch on GitHub is `master`
- **THEN** the skill changes neither file and reports every location as a mismatch, so the skill never makes
  `AGENTS.md` and `ci.yml` name different branches

#### Scenario: Own AGENTS.md and ci.yml already on the default branch
- **WHEN** the maintainer kept an `AGENTS.md` without a Repository section and a `ci.yml` on `master`, and the default
  branch on GitHub is `master`
- **THEN** the skill offers to add the Repository section naming `master` and leaves `ci.yml` unchanged
