# Proposal

Story: #48

## Why

`write-spec` merges the spec of a Story into the default branch as an unarchived OpenSpec change, but no workflow
implements it. The Story stays open, and `implement-story` cannot pick the change up, because it always writes a new
spec. An `implement-spec` skill builds, reviews and merges the code for a merged spec in its own PR, so the spec-first
path is complete and can become the default for Stories.

## What Changes

- New skill `implement-spec` in `.agents/skills/implement-spec`:
  - It takes the name of an OpenSpec change. Without one, it asks for it and stops. It also stops if the name is not
    kebab-case or contains `/`.
  - It stops if the change does not exist unarchived on `origin/<default-branch>`.
  - It reads the Story from the proposal's `Story: #<n>` line.
  - If `feature/<change-name>` already exists locally or on origin, it tells the user, asks what to do and creates no
    branch.
  - Otherwise it creates `feature/<change-name>` and runs implement, review, PR, archive and merge, with the model and
    agent checks of its step 0. Every commit carries `Refs: #<n>`, and the PR closes the Story.
  - When the spec turns out wrong during implementation, the user decides whether the Story is:
    - incomplete: the change is amended with `openspec-update-change` and approved again;
    - changed: a new spec is written with `write-spec` under a new change name. The agent deletes no branches and
      opens no PRs on this path.
- `finish-work`:
  - Archives the named change on an `implement-spec` branch, although the change was added on the default branch. It
    skips only if the change was already archived, and otherwise tells the user.
  - Keeps archiving the change an `implement-story` branch adds, and never archives for `write-spec`, `fix-bug`,
    `do-chore` and `setup-repository`.
  - Names `implement-spec` among its workflows.
- Routing: a Story goes to `write-spec` and then `implement-spec` by default, and to `implement-story` only when the
  user asks for it.
  - An explicit request for `implement-story` (or the spec and code in one PR), for the spec of a Story or for
    `write-spec` goes to that skill, before any lookup.
  - Any other Story request first looks for an unarchived change on `origin/<default-branch>` that names the Story:
    one match goes to `implement-spec`, several make the agent ask the user, none goes to `write-spec`.
  - `AGENTS.md` (Implementation Workflow and the branch-naming rule), `README.md` and `setup-repository` name
    `implement-spec`.
  - The `description` triggers of `write-spec` and `implement-story` follow the new routing; their steps stay unchanged.
- Live specs that list the workflow skills also name `implement-spec`. Archived changes stay untouched.

## Capabilities

### New Capabilities

- `spec-implementation`: how a spec merged by `write-spec` is implemented, reviewed, archived and merged on its own
  `feature/` branch and PR, which closes the Story.

### Modified Capabilities

- `spec-writing`: the routing requirement flips. A Story goes spec-first by default and to `implement-story` only on
  request.
- `pull-requests`: `implement-spec` opens PRs through `finish-work`, and its PR closes the Story like a Story PR.
- `default-branch`: the workflow skills that must not hard-code the default branch include `implement-spec`.

## Impact

- New: `.agents/skills/implement-spec/SKILL.md`.
- `.agents/skills/finish-work/SKILL.md`: the description, intro, Finalize history sub-step 4 and its intro.
- `.agents/skills/setup-repository/SKILL.md`: the list of template skills.
- `.agents/skills/write-spec/SKILL.md` and `.agents/skills/implement-story/SKILL.md`: only the `description` trigger.
- `AGENTS.md`: the Implementation Workflow and the branch-naming rule.
- `README.md`: the skill list, the users of `finish-work` and the workflow overview.
- `openspec/specs/`: `spec-writing`, `pull-requests` and `default-branch`, plus the new `spec-implementation`.
- Unchanged: the steps of `implement-story` and `write-spec`, the reviewer agent, the PR template and
  `check-commits.sh`.
