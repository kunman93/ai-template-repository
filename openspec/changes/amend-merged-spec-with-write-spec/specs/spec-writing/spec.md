# Spec Delta

## MODIFIED Requirements

### Requirement: The spec gets its own docs branch
For a new spec, `write-spec` SHALL run the workflow check of `implement-story`, derive a kebab-case change name from
the Story, and create the branch `docs/<change-name>-spec` from `origin/<default-branch>`. It SHALL ask for another
name when that change or branch already exists. It SHALL then verify the clean state with the Commands of `AGENTS.md`.
In amend mode, the branch follows the amend-mode requirement instead.

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
- **WHEN** `write-spec` runs in amend mode on `add-foo`, which exists on `origin/<default-branch>`
- **THEN** it does not ask for another name and does not create `docs/add-foo-spec`

### Requirement: Research, plan and approval match implement-story
`write-spec` SHALL research with `openspec-explore` and, for a new spec, plan with `openspec-propose` on Opus 5.5, and
get the plan approved on Sonnet 5.5, as steps 3–5 of `implement-story` do. For a new spec, it SHALL write
`Story: #<n>` under the proposal's title. In both modes, it SHALL change only the files of the OpenSpec change and
continue only after the user's explicit approval.

#### Scenario: Proposal records the Story
- **WHEN** `write-spec` creates the change for Story #47
- **THEN** the line `Story: #47` stands under the title of its `proposal.md`

#### Scenario: User requests changes
- **WHEN** the user asks for changes to the plan
- **THEN** the skill revises the change with `openspec-update-change` on Opus 5.5 and asks for approval again

#### Scenario: No code on the branch
- **WHEN** the docs branch is compared with the default branch
- **THEN** every changed file is under `openspec/changes/<change-name>/`

### Requirement: A skill writes the spec of a Story
The repository SHALL provide a workflow skill `write-spec` in `.agents/skills/write-spec`. It SHALL take a Story (an
issue number or link), or a merged change to amend (see the amend mode below). Without either, it SHALL ask the user
for a Story and stop, without picking an issue itself.

#### Scenario: Story given
- **WHEN** a maintainer runs `write-spec` with Story #47
- **THEN** the skill works on Story #47

#### Scenario: No Story given
- **WHEN** a maintainer runs `write-spec` without naming a Story or a change to amend
- **THEN** the skill asks for one, mentions that `write-story` can create one, and stops without creating a branch

#### Scenario: Change to amend given
- **WHEN** a maintainer asks `write-spec` to amend the merged change `add-foo`
- **THEN** the skill runs in amend mode on `add-foo` and does not create a new change

### Requirement: The reviewer has a spec review mode
The reviewer agent SHALL offer a spec review mode that the caller asks for. In it, the reviewer SHALL check the
OpenSpec change of the branch against its Story and its artifacts against each other, SHALL report any changed file
outside the change and any ticked task in the change's `tasks.md`, SHALL report a problem named by the caller that the
change does not fix, SHALL NOT report missing implementation or tests, SHALL NOT run the Commands, and SHALL end with
an explicit APPROVE or REQUEST CHANGES verdict.

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
- **WHEN** the change's `tasks.md` contains a ticked task (`- [x]`) on a branch reviewed in spec review mode, for a new
  spec or an amendment
- **THEN** the reviewer reports it as a MAJOR finding and the verdict is REQUEST CHANGES

#### Scenario: Reported problem not fixed
- **WHEN** the caller names the problem a spec fix should solve, and the amended artifacts still contain it
- **THEN** the reviewer reports it as a MAJOR finding and the verdict is REQUEST CHANGES

### Requirement: A Story goes spec-first by default
`AGENTS.md` SHALL route a Story to `write-spec` and, once its spec is merged, to `implement-spec` by default. It SHALL
route a Story to `implement-story`, which writes the spec and the code in one PR, only when the user asks for it. An
explicit request for `implement-story`, for the spec and code in one PR, for the spec of a Story or for `write-spec`
SHALL be routed as asked, without the lookup below. For any other Story request, `AGENTS.md` SHALL first look for an
unarchived change on `origin/<default-branch>` whose `proposal.md` names the Story.
`AGENTS.md`, `README.md`, `finish-work` and `setup-repository` SHALL name `implement-spec`. The skill descriptions of
`write-spec` and `implement-story` SHALL match this routing. A request to amend or fix a merged change that the user
names SHALL go to `write-spec` in amend mode.

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
- **WHEN** the user names a change that `write-spec` merged and asks to amend or fix it
- **THEN** the agent uses `write-spec` in amend mode with that change, not `implement-spec`

## ADDED Requirements

### Requirement: The amend mode starts from a merged change
In amend mode, `write-spec` SHALL accept only a kebab-case change name without `/` whose
`openspec/changes/<change-name>/proposal.md` exists on `origin/<default-branch>`, read the Story from its
`Story: #<n>` line, and create `docs/<change-name>-spec-fix` from `origin/<default-branch>`. It SHALL create no branch
when the check fails or when that branch exists locally or on origin.

#### Scenario: Merged change
- **WHEN** `write-spec` is asked to amend `add-foo`, which exists unarchived on `origin/<default-branch>` with
  `Story: #47`
- **THEN** it creates `docs/add-foo-spec-fix` from `origin/<default-branch>` and uses Story #47 for the trailers and
  the PR

#### Scenario: Change not merged or archived
- **WHEN** `openspec/changes/<change-name>/proposal.md` does not exist on `origin/<default-branch>`, for example
  because the change is only on an unmerged branch or is archived
- **THEN** the skill tells the user and stops without creating a branch

#### Scenario: Change name is a path
- **WHEN** the given change name is not kebab-case or contains `/`, such as `archive/2026-11-14-add-foo`
- **THEN** the skill asks for a plain change name and stops without creating a branch

#### Scenario: Spec-fix branch exists
- **WHEN** `docs/<change-name>-spec-fix` exists locally or on origin
- **THEN** the skill tells the user, asks what to do and creates no branch

#### Scenario: Story line missing
- **WHEN** the change's `proposal.md` has no `Story: #<n>` line
- **THEN** the skill asks the user for the Story number and waits, and the amendment adds `Story: #<n>` under the
  title of `proposal.md` with the confirmed number

### Requirement: An amendment is revised on Opus and approved
In amend mode, `write-spec` SHALL research the problem with `openspec-explore` and amend the existing change with
`openspec-update-change`, both on Opus 5.5, keep the `Story: #<n>` line or add it when it was missing, change only files
in `openspec/changes/<change-name>/`, and continue to the review and PR only after the user's explicit approval. If the
user has not said what is wrong with the spec, it SHALL ask before the research.

#### Scenario: Amendment approved
- **WHEN** the user approves the amended artifacts
- **THEN** the skill continues with the spec review and the PR

#### Scenario: No approval yet
- **WHEN** the user has not approved the amendment
- **THEN** the skill creates no PR

#### Scenario: Problem not stated
- **WHEN** the user asks to amend a change without saying what is wrong with it
- **THEN** the skill asks what is wrong before it starts the research

#### Scenario: Only the change is touched
- **WHEN** the spec-fix branch is compared with `origin/<default-branch>`
- **THEN** every changed file is under `openspec/changes/<change-name>/`, its `proposal.md` has the
  `Story: #<n>` line, and no task in its `tasks.md` is ticked

### Requirement: A spec fix is merged like a spec
In amend mode, `write-spec` SHALL review, open the PR, finalize and merge as it does for a new spec: the PR targets the
default branch, refers to the Story with `Refs #<n>` without closing it, names the amended change, and the change stays
unarchived. Its spec review prompt SHALL also name the problem the user reported.

#### Scenario: Spec fix merged
- **WHEN** the user approves the spec-fix PR and `ci` is green
- **THEN** the PR is merged into the default branch, `openspec/changes/<change-name>/` holds the amended artifacts
  unarchived, and the Story stays open

#### Scenario: Spec-fix PR body
- **WHEN** the agent creates the spec-fix PR
- **THEN** it targets `<default-branch>`, Related issues says `Refs #<n>` and no closing keyword, and the Description
  names the amended change

#### Scenario: Reviewer knows the problem
- **WHEN** `write-spec` runs the spec review on a spec-fix branch
- **THEN** the reviewer prompt names the amended change and the problem the user reported

### Requirement: A wrong Story is handled as in implement-spec
In amend mode, when the Story itself turns out wrong, `write-spec` SHALL stop, tell the user whether it thinks the
Story is incomplete or changed (changed when unsure) with a one-sentence reason, and wait for the user's decision and
the corrected Story issue. Incomplete SHALL continue the amendment. Changed SHALL end it. The agent SHALL delete no
branch and open or close no PR on this path.

#### Scenario: Story incomplete
- **WHEN** the user decides the Story is incomplete and confirms the corrected issue
- **THEN** the skill continues the amendment with `openspec-update-change` and asks for approval again

#### Scenario: Story changed
- **WHEN** the user decides the Story is changed
- **THEN** the skill stops the amendment, asks what to do with the spec-fix branch and any open spec-fix PR,
  recommends removing the obsolete change with `do-chore` and writing a new spec with `write-spec` under a new change
  name, and deletes no branch and closes no PR

#### Scenario: Unsure
- **WHEN** the agent cannot tell whether the Story is incomplete or changed
- **THEN** it proposes changed and waits for the user's decision
