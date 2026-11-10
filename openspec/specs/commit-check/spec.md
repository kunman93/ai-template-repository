# commit-check Specification

## Purpose

Verifies a branch's commits mechanically, using only git and no model, so that no leftover fixup, malformed subject or
missing issue reference reaches the default branch.

## Requirements

### Requirement: Leftover fixup commits fail the check

The check SHALL fail for every commit between the base and `HEAD` whose subject starts with `fixup!`, `squash!` or
`amend!`.

#### Scenario: Fixup left after the autosquash

- **WHEN** a commit with the subject `fixup! feat(skills): add the check` is on the branch
- **THEN** the check fails and reports that commit as a leftover fixup

### Requirement: Non-conventional subjects fail the check

The check SHALL fail for every commit whose subject does not match `<type>[(<scope>)][!]: <summary>`, where `<type>` is
one of the types of the `git-commit` skill, or whose subject is longer than 72 characters.

#### Scenario: Subject without a type

- **WHEN** a commit with the subject `update readme` is on the branch
- **THEN** the check fails and reports that commit as not conventional

#### Scenario: Unknown type

- **WHEN** a commit with the subject `feature: add the check` is on the branch
- **THEN** the check fails and reports that commit as not conventional

#### Scenario: Subject too long

- **WHEN** a commit has a conventional subject of 73 characters
- **THEN** the check fails and reports that commit as too long

#### Scenario: Valid subjects

- **WHEN** the commits have the subjects `docs: fix a typo`, `feat(skills): add the check` and
  `feat(api)!: remove the v1 endpoints`
- **THEN** none of them is reported for its subject

### Requirement: Missing issue references fail the check

When the check is given an issue number `<n>`, it SHALL fail for every commit whose git trailers do not include
`Refs: #<n>`. A `Refs:` line that git does not read as a trailer SHALL NOT count. Without an issue number it SHALL NOT
check `Refs:`.

#### Scenario: Missing trailer

- **WHEN** the check runs with issue `27` and a commit has no `Refs:` trailer
- **THEN** the check fails and reports that commit as missing `Refs: #27`

#### Scenario: Wrong issue

- **WHEN** the check runs with issue `27` and a commit has only the trailer `Refs: #26`
- **THEN** the check fails and reports that commit as missing `Refs: #27`

#### Scenario: Refs line outside the trailer block

- **WHEN** the check runs with issue `27` and a commit has `Refs: #27` in its own paragraph, separated by a blank line
  from a final `Co-authored-by:` trailer
- **THEN** the check fails and reports that commit as missing `Refs: #27`

#### Scenario: Branch without an issue

- **WHEN** the check runs without an issue number on commits that have no `Refs:` trailer
- **THEN** no commit is reported for `Refs:`

### Requirement: The check reports every offending commit

The check SHALL report every offending commit by short SHA and subject together with the rule it breaks, SHALL exit
non-zero when it reports any commit, and SHALL exit zero with no report when every commit passes.

#### Scenario: Several offending commits

- **WHEN** two commits on the branch break rules
- **THEN** the check reports both, each by short SHA and subject, and exits non-zero

#### Scenario: Clean history

- **WHEN** every commit on the branch passes
- **THEN** the check exits zero

### Requirement: The check runs without a model

The check SHALL use only git inspection commands and SHALL NOT modify any file, the index or any branch. It SHALL fail
with a usage error when the base ref does not resolve or the issue number is not a positive integer.

#### Scenario: Unknown base

- **WHEN** the check runs with a base ref that does not exist
- **THEN** it exits non-zero with a usage error and reports no commit

### Requirement: Finish-work runs the check before every push of a rewritten history

The Create PR procedure of `finish-work` SHALL run the check after the content check and before the commit review. The
Finalize history procedure SHALL run it after the archive sub-step and before the push, and before the push after a
rebase with conflicts. All SHALL pass the issue number on `feature/` and `fix/` branches and none on `chore/` branches,
and SHALL push only once the check passes.

#### Scenario: Missing trailer on the archive commit

- **WHEN** Finalize history archives the change and the archive commit lacks `Refs: #<n>`
- **THEN** the check fails, the branch is not pushed, the agent rewrites the history, proves the content unchanged and
  runs the check again

#### Scenario: Rebase with conflicts

- **WHEN** Finalize history rebases on the default branch, resolves conflicts and a commit has a non-conventional
  subject
- **THEN** the check fails before the push that follows the rebase, and the branch is pushed only after the fix

#### Scenario: Chore branch

- **WHEN** Create PR runs on a `chore/` branch whose commits have no `Refs:` trailer and conventional subjects
- **THEN** the check passes and the commit review starts

### Requirement: The Refs trailer rule is documented

`AGENTS.md` SHALL state that on a branch that belongs to an issue, every commit ends with the trailer `Refs: #<n>` in
the same trailer block as any `Co-authored-by` trailer.

#### Scenario: Reader looks up the rule

- **WHEN** a reader opens the Git Workflow section of `AGENTS.md`
- **THEN** it states the `Refs: #<n>` trailer rule and that no blank line may separate it from `Co-authored-by`
