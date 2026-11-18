## MODIFIED Requirements

### Requirement: A skill writes the spec of a Story
The repository SHALL provide a workflow skill `write-spec` in `.agents/skills/write-spec`. It SHALL take a Story (an
issue number or link). Without one, it SHALL ask the user for a Story and stop, without picking an issue itself.

#### Scenario: Story given
- **WHEN** a maintainer runs `write-spec` with Story #47
- **THEN** the skill works on Story #47

#### Scenario: No Story given
- **WHEN** a maintainer runs `write-spec` without naming a Story
- **THEN** the skill asks for one, mentions that `write-story` can create one, and stops without creating a branch

#### Scenario: Change to amend given
- **WHEN** a maintainer asks `write-spec` to amend the merged change `add-foo` without naming a Story
- **THEN** the skill has no amend mode: it asks for a Story and stops without creating a branch or changing `add-foo`

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

#### Scenario: Amend mode keeps the name
- **WHEN** `write-spec` creates its branch
- **THEN** the branch is `docs/<change-name>-spec`, and the skill never creates a `docs/<change-name>-spec-fix` branch

### Requirement: Research, plan and approval match implement-story
`write-spec` SHALL research with `openspec-explore` and plan with `openspec-propose` on Opus 5.5, and get the plan
approved on Sonnet 5.5, as the Research, Plan and Approve plan steps of `implement-story` do. It SHALL write
`Story: #<n>` under the proposal's title, change only the files of the OpenSpec change and continue only after the
user's explicit approval.

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
outside the change and any ticked task in the change's `tasks.md`, SHALL NOT report missing implementation or tests,
SHALL NOT run the Commands, and SHALL end with an explicit APPROVE or REQUEST CHANGES verdict.

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

#### Scenario: Ticked task
- **WHEN** the change's `tasks.md` contains a ticked task (`- [x]`) on a branch reviewed in spec review mode
- **THEN** the reviewer reports it as a MAJOR finding and the verdict is REQUEST CHANGES

#### Scenario: Reported problem not fixed
- **WHEN** the reviewer agent file is read
- **THEN** its spec review mode names no `docs/<change-name>-spec-fix` branch and has no check for a problem a spec
  fix should solve

### Requirement: A Story goes spec-first by default
`AGENTS.md` SHALL route a Story to `write-spec` and, once its spec is merged, to `implement-spec` by default. It SHALL
route a Story to `implement-story`, which writes the spec and the code in one PR, only when the user asks for it. An
explicit request for `implement-story`, for the spec and code in one PR, for the spec of a Story or for `write-spec`
SHALL be routed as asked, without the lookup below. For any other Story request, `AGENTS.md` SHALL first look for an
unarchived change on `origin/<default-branch>` whose `proposal.md` names the Story.
`AGENTS.md`, `README.md`, `finish-work` and `setup-repository` SHALL name `implement-spec`. The skill descriptions of
`write-spec` and `implement-story` SHALL match this routing. `README.md` SHALL describe `write-spec` without an amend
mode.

#### Scenario: User asks to implement a Story
- **WHEN** the user asks to work on or implement a Story without asking for `implement-story` or for spec and code in
  one PR, and no unarchived change on `origin/<default-branch>` names the Story
- **THEN** the agent uses `write-spec` first, and `implement-spec` once the spec is merged

#### Scenario: Story with a merged spec
- **WHEN** the user asks to work on or implement a Story, and one unarchived change on `origin/<default-branch>` has
  `Story: #<n>` for it in its `proposal.md`
- **THEN** the agent uses `implement-spec` with that change

#### Scenario: Several merged specs for a Story
- **WHEN** more than one unarchived change on `origin/<default-branch>` names the Story
- **THEN** the agent asks the user which to implement

#### Scenario: User asks for the spec of a Story
- **WHEN** the user asks to write the spec of a Story, even when an unarchived change on `origin/<default-branch>`
  names the Story
- **THEN** the agent uses `write-spec`

#### Scenario: User asks to implement a merged spec
- **WHEN** the user asks to implement a change that `write-spec` merged
- **THEN** the agent uses `implement-spec`

#### Scenario: User asks for spec and code in one PR
- **WHEN** the user asks for `implement-story`, or for the spec and the code of a Story in one PR, even when an
  unarchived change on `origin/<default-branch>` names the Story
- **THEN** the agent uses `implement-story`

#### Scenario: User asks to amend a merged spec
- **WHEN** the user names a change that `write-spec` merged and asks to amend or fix it outside `implement-spec`
- **THEN** `AGENTS.md` routes it nowhere and names no `docs/<change-name>-spec-fix` branch, so the agent asks the user
  which workflow to use instead of using `write-spec` in an amend mode

#### Scenario: README names no amend mode
- **WHEN** the `write-spec` entry of `README.md` is read
- **THEN** it names no amend mode and no request to amend a merged spec

## ADDED Requirements

### Requirement: The amend-mode history stays archived
The archived change `openspec/changes/archive/2026-11-15-amend-merged-spec-with-write-spec/` SHALL stay unchanged as
the history of the removed amend mode.

#### Scenario: Archive untouched
- **WHEN** amend mode is removed from `write-spec`
- **THEN** every file in `openspec/changes/archive/2026-11-15-amend-merged-spec-with-write-spec/` is unchanged against
  `origin/<default-branch>`

## REMOVED Requirements

### Requirement: The amend mode starts from a merged change
**Reason**: Amend mode is removed. Its only planned user, the spec-fix pause of `implement-spec` (#51), was dropped.
**Migration**: Revise a wrong merged spec on the `implement-spec` feature branch with `openspec-update-change`, as the
spec-implementation requirement "A wrong spec goes to the user" defines.

### Requirement: An amendment is revised on Opus and approved
**Reason**: Amend mode is removed.
**Migration**: The approval of a spec revision during implementation follows the spec-implementation requirement
"A wrong spec goes to the user".

### Requirement: A spec fix is merged like a spec
**Reason**: Amend mode is removed, so there is no spec-fix branch or PR.
**Migration**: A spec revision merges with the code in the `implement-spec` PR.

### Requirement: A wrong Story is handled as in implement-spec
**Reason**: This was the wrong-Story exit of amend mode only.
**Migration**: A wrong Story found during implementation follows the spec-implementation requirement
"A wrong spec goes to the user".
