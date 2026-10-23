# Tasks

## 1. Decision records directory

- [x] 1.1 Download `template/adr-template.md` from the MADR `4.0.0` tag to `docs/decisions/adr-template.md` and verify
  `diff` against `https://raw.githubusercontent.com/adr/madr/4.0.0/template/adr-template.md` reports no difference
- [x] 1.2 Write `docs/decisions/README.md`: what an ADR is for, file naming `NNNN-<title-in-kebab-case>.md`, how to
  start a new record by copying `adr-template.md`, and the template's source (MADR 4.0.0, `template/adr-template.md`),
  license (CC0-1.0) and Markdown Guide exception; verify each point of the "Source is documented" scenario is present
- [x] 1.3 Write `docs/decisions/0000-use-markdown-architectural-decision-records.md` adapted from MADR's own `0000`, with
  front matter `status: accepted` and today's date, the considered options and the reasons; verify it matches the
  "First record" scenario

## 2. Discoverability

- [ ] 2.1 Extend the Documentation section of `AGENTS.md` with a link to `docs/decisions/` and the rule for when to write
  an ADR versus an OpenSpec `design.md`; verify it matches the "Agent looks for guidance" scenario
- [ ] 2.2 List `docs/decisions/` under "What is included" in `README.md`; verify it matches the "Human looks at what is
  included" scenario

## 3. Verification

- [ ] 3.1 Review every added or changed markdown file except `adr-template.md` against the Markdown Guide basic syntax
  best practices (blank lines around headings and lists, one list delimiter per list), and re-run the `diff` from 1.1
- [ ] 3.2 Run `openspec validate initialize-adrs-with-madr --strict` and verify it passes

## Workflow follow-up

- Archive the change after the user approves the PR, with the `finish-work` skill.
