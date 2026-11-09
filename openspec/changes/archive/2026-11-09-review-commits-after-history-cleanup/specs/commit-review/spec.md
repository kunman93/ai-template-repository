# Spec Delta

## Purpose

Reviews the commits of a branch after its history is cleaned up and before it is pushed, so that the commits that
reach the default branch are accurate, atomic and conventional.

## ADDED Requirements

### Requirement: Commits are reviewed after the history cleanup
The Create PR procedure of `finish-work` SHALL run the `reviewer` subagent in commit review mode on the cleaned-up
history, after the content check against the backup and before the push. It SHALL push only once the commit review
reports no CRITICAL or MAJOR finding.

#### Scenario: Clean history
- **WHEN** the history has been cleaned up and the commit review returns APPROVE
- **THEN** the procedure pushes the branch and creates the PR

#### Scenario: Commit review requests changes
- **WHEN** the commit review returns REQUEST CHANGES
- **THEN** the branch is not pushed, the history is rewritten again, the content check against the same backup runs
  again, and the commit review runs again

### Requirement: Commit review checks only the commits
In commit review mode the reviewer SHALL review every commit between `origin/<default-branch>` and `HEAD`, each by its
message and its own diff, and SHALL NOT repeat the review of the branch diff. It SHALL use only `git fetch`, `git log`
and `git show` and SHALL NOT modify any file, the index or any local branch.

#### Scenario: Read-only inspection
- **WHEN** the reviewer runs in commit review mode
- **THEN** it inspects the commits with `git fetch`, `git log` and `git show` only, and the working tree, the index
  and every local branch are unchanged afterwards

### Requirement: Non-conventional subjects are reported
The reviewer SHALL report a commit whose subject is not a Conventional Commits subject as a MAJOR finding.

#### Scenario: Subject without a type
- **WHEN** a commit on the branch has the subject `update reviewer`
- **THEN** the reviewer reports that commit, by short SHA and subject, as a MAJOR finding

### Requirement: Messages that do not match their diffs are reported
The reviewer SHALL report a commit whose message describes changes its diff does not contain, or whose diff has
substantial changes the message does not mention, as a MAJOR finding.

#### Scenario: Message claims a change the diff lacks
- **WHEN** a commit message says it updates the README and the commit's diff does not touch the README
- **THEN** the reviewer reports that commit as a MAJOR finding and names the claimed change that is missing

#### Scenario: Squashed fixup the message omits
- **WHEN** a commit's diff also tightens a spec requirement that its message does not mention
- **THEN** the reviewer reports that commit as a MAJOR finding and names the unmentioned change

### Requirement: Commits that mix unrelated changes are reported
The reviewer SHALL report a commit that mixes unrelated changes as a MAJOR finding.

#### Scenario: Two logical changes in one commit
- **WHEN** a commit both adds a reviewer check and changes an unrelated CI step
- **THEN** the reviewer reports that commit as a MAJOR finding and names the changes to split

### Requirement: Commit findings use the existing severities and verdict
Each commit finding SHALL use the reviewer's severity levels CRITICAL, MAJOR and MINOR, and the commit review SHALL end
with an explicit APPROVE or REQUEST CHANGES verdict. Any CRITICAL or MAJOR finding SHALL force REQUEST CHANGES.

#### Scenario: Only minor findings
- **WHEN** the commit review finds only MINOR findings
- **THEN** its verdict is APPROVE and it lists the MINOR findings

#### Scenario: A major finding
- **WHEN** the commit review finds at least one MAJOR finding
- **THEN** its verdict is REQUEST CHANGES
