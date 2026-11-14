# Spec Delta

## Purpose

Takes a Story from issue to merged code, either spec-first in two workflows, `write-spec` and `implement-spec`, each with
its own branch and pull request, or in one pull request with `implement-story`, and defines when the change is archived.

## ADDED Requirements

### Requirement: A Story goes spec-first by default
`AGENTS.md` SHALL route a Story to `write-spec` and then `implement-spec` by default, and to `implement-story` only when
the user asks for it. `implement-story` SHALL keep running spec and implementation on one `feature/` branch with one PR.

#### Scenario: Story without a named skill
- **WHEN** the user asks to work on a Story without naming a skill
- **THEN** the agent loads `write-spec`

#### Scenario: User asks for one PR
- **WHEN** the user asks to implement a Story with `implement-story`
- **THEN** the agent loads `implement-story`, which plans, implements, archives and merges on one `feature/` branch

### Requirement: write-spec needs a Story
The `write-spec` skill SHALL start only with a Story named by the user (an issue number or link). Without one, it SHALL
ask the user for it and stop, without picking an issue itself.

#### Scenario: No Story given
- **WHEN** the user runs `write-spec` without naming a Story
- **THEN** it asks for the Story, mentions that `write-story` can create one, and stops without creating a branch

### Requirement: write-spec works on a docs branch named after the change
The `write-spec` skill SHALL name the OpenSpec change from the Story before branching, SHALL create the branch
`docs/<change-name>-spec` from `origin/<default-branch>`, and SHALL create the change under that same name.

#### Scenario: Branch and change share the name
- **WHEN** `write-spec` runs for a Story whose change is named `add-spec-first-story-workflow`
- **THEN** it works on `docs/add-spec-first-story-workflow-spec`, cut from `origin/<default-branch>`, and creates the
  change `openspec/changes/add-spec-first-story-workflow/`

### Requirement: write-spec plans without writing code
The `write-spec` skill SHALL verify the clean state, run research and plan on Opus 5.5 and approve plan on Sonnet 5.5,
and SHALL change only the files of its OpenSpec change. Its proposal SHALL record the Story as a line `Story: #<n>`.
Before the PR, it SHALL have the `reviewer` subagent review the docs branch.

#### Scenario: Proposal names the Story
- **WHEN** `write-spec` creates the proposal for Story #45
- **THEN** `proposal.md` contains the line `Story: #45`

#### Scenario: Plan not approved
- **WHEN** the user requests changes to the proposal
- **THEN** `write-spec` revises the change with `openspec-update-change` on Opus 5.5 and asks for approval again before
  creating the PR

#### Scenario: Spec reviewed before the PR
- **WHEN** the plan is approved
- **THEN** `write-spec` has the `reviewer` subagent review the docs branch and fixes MAJOR findings before it creates the PR

### Requirement: write-spec merges the spec without archiving it
After the plan is approved, `write-spec` SHALL create the PR with the `finish-work` skill, and SHALL finalize and merge
it only after the user's approval. The OpenSpec change SHALL stay unarchived, and the PR SHALL NOT close the Story.

#### Scenario: Spec PR merged
- **WHEN** the user approves the spec PR and `write-spec` merges it
- **THEN** `openspec/changes/<change-name>/` is on the default branch, nothing was moved to
  `openspec/changes/archive/`, and the Story is still open

### Requirement: implement-spec needs a merged spec
The `implement-spec` skill SHALL start only with the name of an OpenSpec change given by the user. Without one, it SHALL
ask the user for it and stop. It SHALL stop when the change does not exist unarchived in `openspec/changes/` on
`origin/<default-branch>`.

#### Scenario: No change named
- **WHEN** the user runs `implement-spec` without naming a change
- **THEN** it asks for the change, mentions that `write-spec` writes one, and stops without creating a branch

#### Scenario: Change not merged
- **WHEN** the named change exists only on an unmerged `docs/` branch, or only under `openspec/changes/archive/`
- **THEN** `implement-spec` tells the user that the change is not on the default branch and stops without creating a
  branch

### Requirement: implement-spec implements the change and closes the Story
The `implement-spec` skill SHALL create `feature/<change-name>` from `origin/<default-branch>` and run implement,
review, PR, archive and merge, without research, plan or approve plan. Its PR SHALL close the Story named by the
`Story: #<n>` line of the change's proposal.

#### Scenario: Implementation PR
- **WHEN** `implement-spec` creates the PR for the change `add-spec-first-story-workflow` whose proposal says
  `Story: #45`
- **THEN** the PR comes from `feature/add-spec-first-story-workflow` and its Related issues section says `Closes #45`

#### Scenario: Proposal without a Story line
- **WHEN** the change's proposal has no `Story: #<n>` line
- **THEN** `implement-spec` asks the user for the Story number and waits before creating the branch

### Requirement: Spec corrections during implementation
When implementing shows that an artifact of the change is wrong or incomplete, `implement-spec` SHALL stop and tell the
user. It SHALL revise the artifacts on the `feature/` branch after the user's approval, or, when the Story's intent is
wrong, have the Story corrected and a new change written with `write-spec`.

#### Scenario: Wrong task
- **WHEN** a task of the change turns out to be wrong and the Story's intent still holds
- **THEN** `implement-spec` revises the artifacts with `openspec-update-change` on Opus 5.5, commits them on the
  `feature/` branch, and resumes only after the user approves the revision

#### Scenario: Wrong Story
- **WHEN** the Story's acceptance criteria turn out to be wrong
- **THEN** `implement-spec` asks the user to correct the Story and to decide what happens to the merged change and the
  committed work, and the new spec is written with `write-spec`

### Requirement: Archiving depends on the workflow
The `finish-work` skill SHALL always archive the change of `implement-spec`, even though the change was added on the
default branch, and SHALL archive the change an `implement-story` branch adds. For `write-spec`, `fix-bug`, `do-chore`
and `setup-repository` it SHALL never archive.

#### Scenario: Finalize for implement-spec
- **WHEN** Finalize history runs for `implement-spec` and its change is still in `openspec/changes/`
- **THEN** the change is archived on the branch and the archive is committed

#### Scenario: Repeat finalize
- **WHEN** Finalize history runs again for `implement-spec` and the change is already archived on the branch
- **THEN** nothing is archived again

#### Scenario: Finalize for implement-story
- **WHEN** Finalize history runs for `implement-story`, whose branch adds an unarchived change
- **THEN** that change is archived on the branch, as before

#### Scenario: Finalize for write-spec
- **WHEN** Finalize history runs for `write-spec`, whose branch adds the change
- **THEN** nothing is archived
