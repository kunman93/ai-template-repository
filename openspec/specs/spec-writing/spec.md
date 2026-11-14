# spec-writing Specification

## Purpose
Lets the spec of a Story be written, reviewed and merged into the default branch on its own branch and PR, before any
code is written, so that the code can be built on an approved spec.

## Requirements

### Requirement: A skill writes the spec of a Story
The repository SHALL provide a workflow skill `write-spec` in `.agents/skills/write-spec`. It SHALL take a Story (an
issue number or link). Without one, it SHALL ask the user for it and stop, without picking an issue itself.

#### Scenario: Story given
- **WHEN** a maintainer runs `write-spec` with Story #47
- **THEN** the skill works on Story #47

#### Scenario: No Story given
- **WHEN** a maintainer runs `write-spec` without naming a Story
- **THEN** the skill asks for one, mentions that `write-story` can create one, and stops without creating a branch

### Requirement: The spec gets its own docs branch
`write-spec` SHALL run the workflow check of `implement-story`, derive a kebab-case change name from the Story, and
create the branch `docs/<change-name>-spec` from `origin/<default-branch>`. It SHALL ask for another name when that
change or branch already exists. It SHALL then verify the clean state with the Commands of `AGENTS.md`.

#### Scenario: New Story
- **WHEN** `write-spec` starts on a Story whose derived change name is unused
- **THEN** it creates `docs/<change-name>-spec` from `origin/<default-branch>` and tells the user the name

#### Scenario: Name already taken
- **WHEN** `openspec/changes/<change-name>/` exists on `origin/<default-branch>`, or `docs/<change-name>-spec` exists
  locally or on origin
- **THEN** the skill asks the user for another name and creates no branch until it has one

#### Scenario: Wrong main session model
- **WHEN** a step runs on a different main session model than the one the step names
- **THEN** the skill tells the user which model to pick with `/model` and stops

### Requirement: Research, plan and approval match implement-story
`write-spec` SHALL research with `openspec-explore` and plan with `openspec-propose` on Opus 5.5, and get the plan
approved on Sonnet 5.5, as steps 3–5 of `implement-story` do. It SHALL change only the files of the OpenSpec change,
write `Story: #<n>` under the proposal's title, and continue only after the user's explicit approval.

#### Scenario: Proposal records the Story
- **WHEN** `write-spec` creates the change for Story #47
- **THEN** the line `Story: #47` stands under the title of its `proposal.md`

#### Scenario: User requests changes
- **WHEN** the user asks for changes to the plan
- **THEN** the skill revises the change with `openspec-update-change` on Opus 5.5 and asks for approval again

#### Scenario: No code on the branch
- **WHEN** the docs branch is compared with the default branch
- **THEN** every changed file is under `openspec/changes/<change-name>/`

### Requirement: The reviewer has a spec review mode
The reviewer agent SHALL offer a spec review mode that the caller asks for. In it, the reviewer SHALL check the
OpenSpec change of the branch against its Story and its artifacts against each other, SHALL report any changed file
outside the change, SHALL NOT report missing implementation or tests, SHALL NOT run the Commands, and SHALL end with an
explicit APPROVE or REQUEST CHANGES verdict.

#### Scenario: Missing tests are pending
- **WHEN** the reviewer reviews a docs branch in spec review mode and finds no implementation or tests for the
  specified behavior
- **THEN** it does not report them as findings

#### Scenario: Artifact contradicts the Story
- **WHEN** a requirement of the change contradicts an acceptance criterion of the Story
- **THEN** the reviewer reports it as a MAJOR finding and the verdict is REQUEST CHANGES

#### Scenario: File outside the change
- **WHEN** the branch changes a file outside `openspec/changes/<change-name>/`
- **THEN** the reviewer reports it as a MAJOR finding

### Requirement: write-spec reviews the spec before the PR
Before the PR, `write-spec` SHALL have the `reviewer` subagent review the docs branch in spec review mode, and SHALL
fix CRITICAL and MAJOR findings and repeat the review until the verdict is APPROVE.

#### Scenario: CRITICAL or MAJOR finding
- **WHEN** the reviewer reports a CRITICAL or MAJOR finding in the artifacts
- **THEN** the skill fixes it and runs the review again in spec review mode before going on

### Requirement: Fixes that change the plan need approval
`write-spec` SHALL revise the change on Opus 5.5 and get the user's approval again for any fix of a review, CI or PR
finding that changes a requirement, scenario, design decision or task. Only a fix of wording, consistency or
formatting that does not change meaning SHALL be committed as a plain fixup.

#### Scenario: Contradiction between design and spec
- **WHEN** a finding reports that a design decision contradicts a requirement
- **THEN** the skill revises the change with `openspec-update-change` on Opus 5.5 and asks the user for approval before
  reviewing again

#### Scenario: Typo
- **WHEN** a finding reports a typo in a scenario
- **THEN** the skill fixes it with a fixup commit without asking for approval again

### Requirement: A plan revision after the PR resumes only the review
When the plan is revised after the PR exists, `write-spec` SHALL commit the revision as fixups or new atomic commits,
get the user's approval, and resume at the review. It SHALL NOT clean up the history again or create a second PR.

#### Scenario: PR review asks for a plan change
- **WHEN** a PR finding needs a revision of the plan and the user approves the revised plan
- **THEN** the skill runs the spec review, pushes normally, updates the existing PR and its description, and opens no
  new PR

### Requirement: The spec is merged without archiving
`write-spec` SHALL create the PR, finalize the history and merge through `finish-work`, finalizing and merging only
after the user's explicit approval. It SHALL never archive the change, and every commit SHALL carry `Refs: #<n>`.

#### Scenario: Spec merged
- **WHEN** the user approves the spec PR and `ci` is green
- **THEN** the PR is merged, `openspec/changes/<change-name>/` is on the default branch unarchived, and the Story stays
  open

#### Scenario: No approval
- **WHEN** the user has not approved the spec PR
- **THEN** the skill neither finalizes nor merges

### Requirement: Finish-work never archives on a write-spec branch
The Finalize history procedure of `finish-work` SHALL skip archiving when the workflow in use is `write-spec`, although
the branch adds an unarchived change. For `implement-story`, it SHALL keep archiving the change the branch adds.

#### Scenario: Finalizing a spec branch
- **WHEN** Finalize history runs for `write-spec` on a branch that adds `openspec/changes/<change-name>/`
- **THEN** the change is not archived and no archive commit is created

#### Scenario: Finalizing a Story branch
- **WHEN** Finalize history runs for `implement-story` on a branch that adds an unarchived change
- **THEN** the change is archived as before

### Requirement: Spec-only is opt-in
`AGENTS.md` SHALL route a Story to `write-spec` only when the user asks for the spec on its own, and to
`implement-story` otherwise. `implement-story` SHALL stay unchanged.

#### Scenario: User asks to implement a Story
- **WHEN** the user asks to work on a Story without asking for the spec on its own
- **THEN** the agent uses `implement-story`

#### Scenario: User asks for the spec of a Story
- **WHEN** the user asks to write the spec of a Story
- **THEN** the agent uses `write-spec`
