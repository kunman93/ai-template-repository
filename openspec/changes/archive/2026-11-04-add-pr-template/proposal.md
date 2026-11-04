# Proposal

## Why

Pull requests opened by the agent have free-form descriptions that vary in structure and detail, so a reviewer cannot
tell at a glance what a PR is about, how it was verified or what is still open. A single template that the agent fills
out completely gives every PR the same shape before review starts (Story #10).

## What Changes

- Add `.github/pull_request_template.md`, one generic template with the sections Description, Type of change, Related
  issues, Testing steps, Screenshots / evidence and Checklist. Type of change and Checklist are tailored to this
  workflow (Story, bug fix, chore, breaking change; reviewer approval, Commands in `AGENTS.md`, docs, OpenSpec change)
  instead of assuming a stack.
- Change the Create PR section of the `finish-work` skill: the agent fills every section of the template from the
  branch's commits, diff and linked issue, writes `n/a` in sections that do not apply, leaves no placeholders or HTML
  comments, ticks only boxes that are true, and passes the result to `gh pr create` as the body.
- The agent refreshes the PR description whenever pushed changes make it stale, including after the archive moves the
  OpenSpec change to `openspec/changes/archive/`.
- List the template under "What is included" in `README.md`.
- `implement-story`, `fix-bug` and `do-chore` are unchanged: they already reach PR creation only through `finish-work`.

## Capabilities

### New Capabilities

- `pull-requests`: the template every pull request follows and how the agent fills out and maintains the description
  of the PRs it opens.

### Modified Capabilities

None.

## Impact

- New file: `.github/pull_request_template.md`.
- Changed files: `.agents/skills/finish-work/SKILL.md` (Create PR and Finalize history), `README.md` (What is included).
- Humans opening a PR in the GitHub web UI also get the template prefilled.
- No code, CI or dependency changes. Repositories created from the template inherit the PR template.
