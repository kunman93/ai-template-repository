# spec-implementation Specification

## Purpose
Lets a spec that `write-spec` merged into the default branch be implemented, reviewed, archived and merged on its own
branch and PR, which closes the Story.

## Requirements

### Requirement: A skill implements a merged spec
The repository SHALL provide a workflow skill `implement-spec` in `.agents/skills/implement-spec`. It SHALL take the
name of an OpenSpec change. Without one, it SHALL ask the user for it explicitly and stop, without picking a change
itself.

#### Scenario: Change given
- **WHEN** a maintainer runs `implement-spec` with the change `add-foo`
- **THEN** the skill works on `openspec/changes/add-foo/`

#### Scenario: No change given
- **WHEN** a maintainer runs `implement-spec` without naming a change
- **THEN** the skill asks for one, mentions that `write-spec` can write one, and stops without creating a branch

#### Scenario: Change name is a path
- **WHEN** the change name is not kebab-case or contains `/`, such as `archive/2026-01-01-add-foo`
- **THEN** the skill asks for a plain change name and stops without creating a branch

### Requirement: Only a merged, unarchived change is implemented
`implement-spec` SHALL fetch the default branch and stop, without creating a branch, if the change does not exist
unarchived on `origin/<default-branch>`.

#### Scenario: Change merged and unarchived
- **WHEN** `openspec/changes/<change-name>/proposal.md` exists on `origin/<default-branch>`
- **THEN** the skill goes on

#### Scenario: Change not merged
- **WHEN** the change exists only on an unmerged `docs/` branch or locally
- **THEN** the skill tells the user that the change is not on the default branch and stops

#### Scenario: Change already archived
- **WHEN** the change exists only under `openspec/changes/archive/` on `origin/<default-branch>`
- **THEN** the skill tells the user that the change is not unarchived on the default branch and stops

### Requirement: The proposal names the Story
`implement-spec` SHALL read the Story from the `Story: #<n>` line of the change's `proposal.md` on
`origin/<default-branch>`. If the line is missing, it SHALL ask the user for the Story number and wait.

#### Scenario: Story line present
- **WHEN** the proposal of the change contains `Story: #48`
- **THEN** the skill works for Story #48

#### Scenario: Story line missing
- **WHEN** the proposal has no `Story: #<n>` line
- **THEN** the skill asks the user for the Story number and does not go on until it has one

### Requirement: The code gets its own feature branch
`implement-spec` SHALL create `feature/<change-name>` from `origin/<default-branch>` and verify the clean state with
the Commands of `AGENTS.md`. If that branch already exists locally or on origin, it SHALL tell the user, ask what to
do, and create no branch.

#### Scenario: New branch
- **WHEN** `feature/<change-name>` exists neither locally nor on origin
- **THEN** the skill creates it from `origin/<default-branch>`

#### Scenario: Branch already exists
- **WHEN** `feature/<change-name>` exists locally or on origin
- **THEN** the skill tells the user, asks what to do, and creates no branch

### Requirement: Every step runs on its model
`implement-spec` SHALL run the model and agent checks of its step 0 before each step: Sonnet 5.5 in the main session,
except a revision of the change, which runs on Opus 5.5. On a mismatch, or when the model or agent cannot be told, it
SHALL tell the user what to pick and stop.

#### Scenario: Wrong main session model
- **WHEN** a step runs on a different main session model than the one the step names
- **THEN** the skill tells the user which model to pick with `/model` and stops

#### Scenario: Custom agent
- **WHEN** the main session runs a custom agent
- **THEN** the skill tells the user to switch with `/agent` and stops

### Requirement: Implement, review, PR, archive and merge
`implement-spec` SHALL implement the change's tasks with `openspec-apply-change`, have the `reviewer` subagent review
the branch until no MAJOR finding remains, and create the PR, archive the change and merge through `finish-work`.
Every commit SHALL carry `Refs: #<n>`. It SHALL archive and merge only after the user's explicit approval.

#### Scenario: PR closes the Story
- **WHEN** the skill creates the PR for the change of Story #48
- **THEN** the PR closes #48 and names the change

#### Scenario: Merged
- **WHEN** the user approves the PR and `ci` is green
- **THEN** the change is archived under `openspec/changes/archive/` on the branch and the PR is merged

#### Scenario: No approval
- **WHEN** the user has not approved the PR
- **THEN** the skill neither archives nor merges

### Requirement: A wrong spec goes to the user
When the implementation shows that an artifact of the change is wrong or incomplete, `implement-spec` SHALL stop and
tell the user. If the Story itself is wrong, the user SHALL decide whether it is incomplete or changed. The skill
SHALL NOT work around a wrong artifact.

#### Scenario: Artifact wrong, Story right
- **WHEN** an artifact is wrong but the Story holds
- **THEN** the skill revises the change with `openspec-update-change` on Opus 5.5, commits the revision, and resumes
  only after the user approves it

#### Scenario: Story incomplete
- **WHEN** the user decides that the Story is incomplete (its goal and every acceptance criterion hold, and criteria
  are only added or sharpened)
- **THEN** after the user confirms the corrected Story, the skill amends the change with `openspec-update-change` and
  resumes only after the user approves the revision

#### Scenario: Story changed
- **WHEN** the user decides that the Story changed
- **THEN** the skill asks the user what to do with the merged change, the branch and the committed work, tells the user
  to write a new spec with `write-spec` under a new change name, and itself deletes no branch and opens no PR

### Requirement: Finish-work archives the implemented change
On an `implement-spec` branch, the Finalize history procedure of `finish-work` SHALL archive the change the workflow
names, although the change was added on the default branch. If an earlier run already archived it, it SHALL skip. If
the change is neither unarchived nor archived on the branch, it SHALL tell the user and archive nothing.

#### Scenario: Finalizing an implement-spec branch
- **WHEN** Finalize history runs for `implement-spec` and `openspec/changes/<change-name>/` exists on the branch
- **THEN** the change is archived and the archive is committed on the branch

#### Scenario: Repeat run
- **WHEN** Finalize history runs again for `implement-spec` and `openspec/changes/archive/<date>-<change-name>/`
  exists on the branch
- **THEN** no second archive is attempted

#### Scenario: Change missing and not archived
- **WHEN** Finalize history runs for `implement-spec` and the change exists neither under `openspec/changes/` nor
  under `openspec/changes/archive/` on the branch
- **THEN** the skill tells the user and archives nothing
