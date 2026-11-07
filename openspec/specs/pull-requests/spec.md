# pull-requests Specification

## Purpose
Gives every pull request the same structure, filled out completely by the agent that opens it, so that a reviewer knows
what a PR is about, how it was verified and what it closes before starting the review.

## Requirements

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
- **THEN** it offers Story, Bug fix and Chore, matching the `feature/`, `fix/` and `chore/` branches, and a separate
  Breaking change option

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
- **WHEN** the agent creates the PR for a Story
- **THEN** every section has content derived from the branch, Type of change marks Story, and Related issues closes the
  Story's issue

#### Scenario: Section that does not apply
- **WHEN** the agent creates a PR for a change without visible output, such as a documentation change
- **THEN** the Screenshots / evidence section says `n/a`

#### Scenario: Chore without an issue
- **WHEN** the agent creates the PR for a chore that has no issue
- **THEN** the Related issues section says `n/a`

#### Scenario: No leftovers from the template
- **WHEN** the agent has created a PR
- **THEN** its body contains no HTML comments and no placeholder such as `#[issue-number]`

### Requirement: Checkboxes state only the truth
The agent SHALL tick a checkbox in the PR body only when the statement is true for the branch, and SHALL leave a
checklist item that does not apply unticked with `n/a` next to it.

#### Scenario: Unconfigured commands
- **WHEN** the Commands in `AGENTS.md` are not configured
- **THEN** the checklist item about the Commands is unticked with `n/a` instead of claiming they pass

#### Scenario: Chore without an OpenSpec change
- **WHEN** the agent creates the PR for a bug fix or chore
- **THEN** the checklist item about the OpenSpec change is unticked and marked `n/a`

### Requirement: The description stays current
After creating a PR, the agent SHALL update its description whenever pushed changes make any section inaccurate.

#### Scenario: Fix after review
- **WHEN** the agent pushes a fix for a CI failure or review finding that changes what the description states
- **THEN** it updates the affected sections of the PR description

#### Scenario: Archived OpenSpec change
- **WHEN** the agent archives the OpenSpec change of a Story and pushes
- **THEN** any path to the change in the PR description points to its location under `openspec/changes/archive/`

### Requirement: All workflows open PRs the same way
The `implement-story`, `fix-bug`, `do-chore` and `setup-repository` workflows SHALL create pull requests only through
the Create PR procedure of the `finish-work` skill, so they get the template without instructions of their own.

#### Scenario: Any workflow reaches PR creation
- **WHEN** a Story, bug fix, chore or repository setup reaches its Create PR step
- **THEN** the PR is created by the `finish-work` Create PR procedure and follows the template
