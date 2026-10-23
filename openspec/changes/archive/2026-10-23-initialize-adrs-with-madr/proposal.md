# Proposal

## Why

Significant decisions in this template and in repositories created from it are not recorded anywhere durable. OpenSpec
`design.md` files capture decisions per change, but they are archived with their change and are hard to find later.
Architecture decision records in the [MADR](https://adr.github.io/madr/) format give humans and agents one consistent,
discoverable place for decisions that outlive a single change (Story #4).

## What Changes

- Add `docs/decisions/` as the home for architecture decision records (ADRs).
- Vendor `docs/decisions/adr-template.md` unchanged from MADR 4.0.0 (`template/adr-template.md`), used under CC0-1.0.
  Only the full template is added; the minimal and bare variants are not.
- Add `docs/decisions/README.md` that records the template's source, version and license, and explains how to add a
  record.
- Add the first record, `docs/decisions/0000-use-markdown-architectural-decision-records.md`, adapted from MADR's own
  record for this repository.
- Extend the Documentation section of `AGENTS.md` with when to write an ADR versus an OpenSpec `design.md`, and link to
  `docs/decisions/`.
- List `docs/decisions/` under "What is included" in `README.md`.
- The vendored `adr-template.md` is an explicit exception to the Markdown Guide conventions: it is kept byte-identical to
  upstream so that it can be re-copied. Every other added or changed markdown file follows the Markdown Guide.

## Capabilities

### New Capabilities

- `decision-records`: where architecture decision records live, which template and naming they use, and how agents and
  humans find them and know when to write one.

### Modified Capabilities

None.

## Impact

- New files: `docs/decisions/README.md`, `docs/decisions/adr-template.md`,
  `docs/decisions/0000-use-markdown-architectural-decision-records.md`.
- Changed files: `AGENTS.md` (Documentation section), `README.md` (What is included).
- No code, CI, skill or dependency changes. Repositories created from the template inherit `docs/decisions/` with the
  template and record `0000`.
