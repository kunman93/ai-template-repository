# Spec Delta

## MODIFIED Requirements

### Requirement: One generic pull request template
The repository SHALL have a single pull request template, `.github/pull_request_template.md`, with the sections
Description, Type of change, Related issues, Testing steps, Screenshots / evidence and Checklist. Its options and
checklist items SHALL NOT assume a language, framework or stack. `README.md` SHALL list it among the included files.

#### Scenario: Template sections
- **WHEN** a reader opens `.github/pull_request_template.md`
- **THEN** it contains exactly the sections Description, Type of change, Related issues, Testing steps,
  Screenshots / evidence and Checklist, in that order

#### Scenario: Type of change matches the workflows
- **WHEN** a reader looks at the Type of change section
- **THEN** it offers Story, Bug fix and Chore, matching the `docs/` and `feature/` branches of a Story, the `fix/`
  branches and the `chore/` branches, and a separate Breaking change option

#### Scenario: Stack-agnostic checklist
- **WHEN** a reader looks at the Checklist section
- **THEN** its items refer to the workflow (reviewer approval, the Commands in `AGENTS.md`, documentation, the OpenSpec
  change) and none names a specific language, framework or tool chain

#### Scenario: Template is listed in the README
- **WHEN** a reader looks at "What is included" in `README.md`
- **THEN** it lists `.github/pull_request_template.md`

### Requirement: The agent fills out every section
When the agent creates a pull request, it SHALL use the template as the PR body and fill every section from the
branch's commits, diff and linked issue. The body SHALL contain no empty sections, placeholders or template comments. A
section that does not apply SHALL say `n/a`.

#### Scenario: Story PR
- **WHEN** the agent creates the PR for a Story with `implement-story`, or the implementation PR with `implement-spec`
- **THEN** every section has content derived from the branch, Type of change marks Story, and Related issues closes the
  Story's issue

#### Scenario: Spec PR
- **WHEN** the agent creates the spec PR for a Story with `write-spec`
- **THEN** Type of change marks Story, Related issues refers to the Story with `Refs #<n>` and does not close it, and
  the Description names the OpenSpec change

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
The `implement-story`, `write-spec`, `implement-spec`, `fix-bug`, `do-chore` and `setup-repository` workflows SHALL create pull requests
only through the Create PR procedure of the `finish-work` skill, so they get the template without instructions of their
own.

#### Scenario: Any workflow reaches PR creation
- **WHEN** a Story, a spec, an implementation of a spec, a bug fix, a chore or a repository setup reaches its Create PR step
- **THEN** the PR is created by the `finish-work` Create PR procedure and follows the template
