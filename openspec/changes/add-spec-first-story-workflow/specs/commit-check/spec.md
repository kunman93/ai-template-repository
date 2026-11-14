# Spec Delta

## MODIFIED Requirements

### Requirement: Finish-work runs the check before every push of a rewritten history
The Create PR procedure of `finish-work` SHALL run the check after the content check and before the commit review. The
Finalize history procedure SHALL run it after the archive sub-step and before the push, and before the push after a
rebase with conflicts. All SHALL pass the issue
number on `docs/`, `feature/` and `fix/` branches and none on `chore/` branches, and SHALL push only once the check passes.

#### Scenario: Missing trailer on the archive commit
- **WHEN** Finalize history archives the change and the archive commit lacks `Refs: #<n>`
- **THEN** the check fails, the branch is not pushed, the agent rewrites the history, proves the content unchanged and
  runs the check again

#### Scenario: Rebase with conflicts
- **WHEN** Finalize history rebases on the default branch, resolves conflicts and a commit has a non-conventional subject
- **THEN** the check fails before the push that follows the rebase, and the branch is pushed only after the fix

#### Scenario: Chore branch
- **WHEN** Create PR runs on a `chore/` branch whose commits have no `Refs:` trailer and conventional subjects
- **THEN** the check passes and the commit review starts

#### Scenario: Spec branch
- **WHEN** Create PR runs on a `docs/` branch of `write-spec` for Story #45
- **THEN** the check runs with issue `45` and fails for every commit that lacks `Refs: #45`
