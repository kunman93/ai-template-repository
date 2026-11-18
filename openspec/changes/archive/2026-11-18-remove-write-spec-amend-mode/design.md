# Design

## Context

Amend mode lives in four files (`write-spec`, the reviewer agent, `AGENTS.md`, `README.md`) and in the
`spec-writing` spec. It was added by the archived change `2026-11-15-amend-merged-spec-with-write-spec`. See
proposal.md for why it goes.

## Goals / Non-Goals

**Goals:**

- Remove every amend-mode path outside the archive, so that `write-spec` reads as it did before #50, plus the later
  chores that are not about amend mode.

**Non-Goals:**

- Reverting PR #53 with `git revert`: it conflicts with later chores and would delete the archived change.
- Touching the archive, `implement-spec`, `implement-story` or `finish-work`.

## Decisions

- **Rewrite removed scenarios instead of dropping them.** OpenSpec 2.0 rejects a MODIFIED requirement that omits a
  scenario of the main spec, and it matches scenarios by name, so a scenario cannot be renamed either. The four
  amend-mode scenarios inside requirements that stay keep their names. Each one now states that amend mode is gone,
  which also makes the removal testable. The names read oddly, but that is the price of keeping the delta valid.
  - Alternative: REMOVE and ADD the requirements under new names. Rejected: it renames five requirements whose
    behavior does not change.
- **Keep the ticked-task check of the spec review mode.** #50 added it with amend mode, but it guards every spec
  branch, including `docs/<change-name>-spec` and the plan of `implement-story`. Only the "Reported problem" check
  and the `docs/<change-name>-spec-fix` mention are spec-fix rules.
- **No routing rule replaces the amend rule.** A wrong merged spec is revised on the `implement-spec` branch, as the
  `spec-implementation` spec already defines. Any other amend request is unclear, so `AGENTS.md`'s "ask instead of
  guessing" rule applies.
- **Name the `implement-story` steps, not their numbers.** PR #63 inserted Review plan as step 5 of
  `implement-story`, so "steps 3–5" now includes a review that `write-spec` runs after approval, not before. Step names
  survive a later renumbering.
- **Restore the pre-#50 wording where it fits.** Use the text of `write-spec` from before PR #53 as a guide for the
  intro and steps, but keep the later changes, such as the triage step from PR #59.

## Risks / Trade-offs

- [A leftover amend reference in a file the change does not list] → The final task greps the repository outside the
  archive for `amend mode`, `spec-fix` and `spec fix`.
