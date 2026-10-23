# Design

## Context

The repository has no `docs/` directory yet. Decisions are captured only in OpenSpec `design.md` files, which are scoped
to one change and archived with it. MADR 4.0.0 (September 2024) is the latest release. It ships four template variants
and its own `0000` record, under `MIT OR CC0-1.0`. Its full template puts `<!-- optional -->` comments directly above
headings without a blank line and has an unbalanced `{` in the `status` placeholder, so it does not fully follow the
Markdown Guide.

## Goals / Non-Goals

**Goals:**

- Keep the vendored template trivially re-syncable with upstream.
- Make the ADR versus `design.md` boundary explicit, so agents do not duplicate decisions in both.

**Non-Goals:**

- The minimal and bare MADR template variants.
- A markdown linter, CI checks, or ADR steps in the workflow skills.
- Back-filling ADRs for decisions taken before this change.

## Decisions

- **Vendor `adr-template.md` unchanged.** It stays byte-identical to MADR 4.0.0 `template/adr-template.md`, so an update
  is a plain re-copy. Alternative: adapt it to the Markdown Guide and fix the typo. Rejected by the user because local
  edits would have to be re-applied on every upgrade. The file is therefore the one exception to the Markdown Guide
  rule.
- **License under CC0-1.0.** MADR is dual-licensed `MIT OR CC0-1.0`. Choosing CC0 needs no copyright notice in the
  repository; `docs/decisions/README.md` records the choice. Alternative: MIT, which would require shipping the notice.
- **Record the source in `docs/decisions/README.md`.** The template has no room for metadata without editing it, and
  `.agents/skills/VENDORED.md` is about skills only. The README sits next to the template and also explains how to add a
  record. Alternative: put the note in `AGENTS.md`, which would load it into every agent session for no benefit.
- **Only the full template.** It is the only variant with the `status` and `date` metadata, and optional sections can be
  deleted per record. Alternative: ship all four variants, which adds choice without need (YAGNI).
- **Record `0000` is our own adaptation, not vendored.** It starts from MADR's own `0000`, adds `status: accepted` and a
  date as front matter, uses `-` list markers like the rest of the repository, and follows the Markdown Guide.
- **The when-to-write rule lives in `AGENTS.md`.** Agents always read it, so the rule is applied without loading extra
  files. The rule: write an ADR for a significant decision that outlives a single change and is costly to reverse
  (stack, architecture, cross-cutting conventions); change-scoped design choices stay in the OpenSpec `design.md`.

## Risks / Trade-offs

- [Vendored template breaks the Markdown Guide rule] → The exception is stated in the spec and in
  `docs/decisions/README.md`, so reviewers do not flag it.
- [Agents write ADRs for minor choices or skip them for major ones] → The rule in `AGENTS.md` names concrete examples and
  the ADR versus `design.md` boundary. The reviewer's general conventions check covers it.
- [Byte-identity drifts through editor settings] → `.editorconfig` would not alter the upstream file's content, and
  verification compares it against the tagged upstream file with `diff`.
