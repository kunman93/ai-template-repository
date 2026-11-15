# Spec Delta

## MODIFIED Requirements

### Requirement: The agent fills out every section
When the agent creates a pull request, it SHALL use the template as the PR body and fill every section from the
branch's commits, diff and linked issue. The body SHALL contain no empty sections, placeholders or template comments. A
section that does not apply SHALL say `n/a`.

#### Scenario: Story PR
- **WHEN** the agent creates the PR for a Story with `implement-story` or `implement-spec`
- **THEN** every section has content derived from the branch, Type of change marks Story, Related issues closes the
  Story's issue, and the Description names the OpenSpec change

#### Scenario: Spec PR
- **WHEN** the agent creates the spec PR for a Story with `write-spec`
- **THEN** Type of change marks Story, Related issues refers to the Story with `Refs #<n>` and does not close it, the
  Description names the OpenSpec change, and the OpenSpec item of the Checklist is ticked

#### Scenario: Section that does not apply
- **WHEN** the agent creates a PR for a change without visible output, such as a documentation change
- **THEN** the Screenshots / evidence section says `n/a`

#### Scenario: Chore without an issue
- **WHEN** the agent creates the PR for a chore that has no issue
- **THEN** the Related issues section says `n/a`

#### Scenario: No leftovers from the template
- **WHEN** the agent has created a PR
- **THEN** its body contains no HTML comments and no placeholder such as `#[issue-number]`

### Requirement: All workflows open PRs the same way
The `implement-story`, `write-spec`, `implement-spec`, `fix-bug`, `do-chore` and `setup-repository` workflows SHALL
create pull requests only through the Create PR procedure of the `finish-work` skill, so they get the template without
instructions of their own.

#### Scenario: Any workflow reaches PR creation
- **WHEN** a Story, a spec, the implementation of a spec, a bug fix, a chore or a repository setup reaches its Create
  PR step
- **THEN** the PR is created by the `finish-work` Create PR procedure and follows the template
