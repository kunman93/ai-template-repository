# Spec Delta

## MODIFIED Requirements

### Requirement: All workflows open PRs the same way
The `implement-story`, `fix-bug`, `do-chore` and `setup-repository` workflows SHALL create pull requests only through
the Create PR procedure of the `finish-work` skill, so they get the template without instructions of their own.

#### Scenario: Any workflow reaches PR creation
- **WHEN** a Story, bug fix, chore or repository setup reaches its Create PR step
- **THEN** the PR is created by the `finish-work` Create PR procedure and follows the template
