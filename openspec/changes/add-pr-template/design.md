# Design

## Context

PR creation is described only in the Create PR section of `.agents/skills/finish-work/SKILL.md`, which the
`implement-story`, `fix-bug` and `do-chore` skills reference. The agent creates PRs with `gh pr create`, which uses
`.github/pull_request_template.md` only in its interactive mode; with `--body`, `--body-file` or `--fill` the template
is ignored. Past PR descriptions were free-form and some went stale, for example PR #5 still points to the OpenSpec
change in `openspec/changes/` after it was archived. No build, test or lint commands are configured.

## Goals / Non-Goals

**Goals:**

- One template that works for humans in the GitHub web UI and for the agent.
- PR descriptions the reviewer can trust: complete, truthful and current.

**Non-Goals:**

- Several templates per change type (`PULL_REQUEST_TEMPLATE/` directory). GitHub only prefills one by default.
- CI checks or a linter that validate PR bodies.
- Changes to `implement-story`, `fix-bug` or `do-chore`.

## Decisions

- **The agent fills the template itself and passes it as the body.** It reads `.github/pull_request_template.md`,
  replaces every comment and placeholder, and passes the result to `gh pr create --body-file -` on stdin. Alternative:
  `gh pr create` without a body, which opens an editor and cannot run unattended. Stdin avoids a temporary file that
  could be committed by accident.
- **Tailored Type of change and Checklist (user decision).** Type of change offers Story, Bug fix, Chore and Breaking
  change, matching the branch prefixes. The Checklist covers reviewer approval without MAJOR findings, the Commands in
  `AGENTS.md`, documentation, and the OpenSpec change. Alternative: the reference template from the issue, whose items
  ("unit tests added", "project style guidelines") assume a stack and cannot be ticked truthfully in a template
  without one.
- **Template comments guide both humans and the agent.** Each section has one short HTML comment saying what goes there
  and that `n/a` is used when it does not apply. The agent removes all comments. This keeps the fill rules next to the
  sections they describe, while the `finish-work` skill states only the procedure.
- **`n/a` and honest checkboxes.** A section that does not apply says `n/a`; a checklist item is ticked only when true,
  otherwise it stays unticked with a short reason or `n/a`. A ticked box that is not true is worse than an empty one.
- **Refresh with `gh pr edit <n> --body-file -` (user decision).** After pushes in Create PR (CI or review fixes) and in
  Finalize history (archive), the agent checks the description against the branch and updates it when a section is
  inaccurate. Alternative: fill it only once, which leaves stale paths after the archive.
- **No ADR.** The template is a single, easily reversed convention, so this design is the record.

## Risks / Trade-offs

- [The agent leaves a comment or placeholder in the body] → The skill tells it to check the body for `<!--` and
  bracket placeholders before creating or editing the PR.
- [Behavior can only be validated on a real PR, there are no tests] → The PR for this Story is created with the new
  procedure and checked against the spec scenarios.
- [Humans in the web UI may skip sections] → Accepted. The template comments ask for `n/a`, but enforcement is out of
  scope.
