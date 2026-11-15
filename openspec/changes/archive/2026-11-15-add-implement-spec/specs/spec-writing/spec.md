# Spec Delta

## RENAMED Requirements

- FROM: `### Requirement: Spec-only is opt-in`
- TO: `### Requirement: A Story goes spec-first by default`

## MODIFIED Requirements

### Requirement: A Story goes spec-first by default
`AGENTS.md` SHALL route a Story to `write-spec` and, once its spec is merged, to `implement-spec` by default. It SHALL
route a Story to `implement-story`, which writes the spec and the code in one PR, only when the user asks for it. An
explicit request for `implement-story`, for the spec and code in one PR, for the spec of a Story or for `write-spec`
SHALL be routed as asked, without the lookup below. For any other Story request, `AGENTS.md` SHALL first look for an
unarchived change on `origin/<default-branch>` whose `proposal.md` names the Story.
`AGENTS.md`, `README.md`, `finish-work` and `setup-repository` SHALL name `implement-spec`. The skill descriptions of
`write-spec` and `implement-story` SHALL match this routing.

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
