---
status: accepted
date: 2026-10-23
---

# Use Markdown Architectural Decision Records

## Context and Problem Statement

We want to record the significant decisions made in this repository, whether they concern the architecture, the code or
the workflow. Which format and structure should these records follow?

## Considered Options

- [MADR](https://adr.github.io/madr/) 4.0.0, the Markdown Architectural Decision Records
- [Michael Nygard's template](http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions), the first
  incarnation of the term "ADR"
- [Y-Statements](https://www.infoq.com/articles/sustainable-architectural-design-decisions) from Sustainable
  Architectural Decisions
- Formless, with no conventions for file format and structure

## Decision Outcome

Chosen option: "MADR 4.0.0", because it captures any decision in a lean, structured markdown format that is easy for
humans and agents to read, write and maintain.

### Consequences

- Good, because decisions are documented consistently and are discoverable in `docs/decisions/`.
- Good, because the template is plain markdown and needs no tooling.
- Bad, because contributors have to decide when a decision deserves a record. `AGENTS.md` states the rule.
