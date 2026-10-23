# Spec Delta

## Purpose

Gives the repository one consistent, discoverable place for architecture decision records in the MADR format, so that
significant decisions that outlive a single change are documented for humans and agents.

## ADDED Requirements

### Requirement: Decision records live in docs/decisions

Architecture decision records SHALL be stored as markdown files in `docs/decisions/`, named
`NNNN-<title-in-kebab-case>.md` with a four-digit, zero-padded sequence number that is unique in the directory.

#### Scenario: Adding a record

- **WHEN** a contributor or agent records a new decision
- **THEN** it is added to `docs/decisions/` with the next free four-digit number and a kebab-case title

### Requirement: New records start from the vendored MADR template

`docs/decisions/adr-template.md` SHALL be byte-identical to `template/adr-template.md` of MADR 4.0.0, and
`docs/decisions/README.md` SHALL state its source, version and license (CC0-1.0) and that new records start from it.

#### Scenario: Template matches upstream

- **WHEN** `docs/decisions/adr-template.md` is compared with `template/adr-template.md` of the MADR 4.0.0 tag
- **THEN** the files are identical

#### Scenario: Source is documented

- **WHEN** a reader opens `docs/decisions/README.md`
- **THEN** it names MADR 4.0.0, the upstream path of the template, its license, and how to start a new record from it

### Requirement: Use of MADR is itself recorded

`docs/decisions/0000-use-markdown-architectural-decision-records.md` SHALL record the decision to use MADR with status
`accepted`, the options considered and the reasons for the choice.

#### Scenario: First record

- **WHEN** a reader opens `docs/decisions/0000-use-markdown-architectural-decision-records.md`
- **THEN** it has status `accepted` and states that MADR 4.0.0 was chosen, the options considered, and why

### Requirement: Agents know when to write a record

`AGENTS.md` SHALL link to `docs/decisions/` and state when to write an ADR: for a significant decision that outlives a
single change and is costly to reverse, while change-scoped design choices stay in the OpenSpec `design.md`.
`README.md` SHALL list `docs/decisions/` among the included files.

#### Scenario: Agent looks for guidance

- **WHEN** an agent reads `AGENTS.md`
- **THEN** it finds a link to `docs/decisions/` and the rule for choosing between an ADR and an OpenSpec `design.md`

#### Scenario: Human looks at what is included

- **WHEN** a reader reads the "What is included" section of `README.md`
- **THEN** `docs/decisions/` is listed

### Requirement: Decision records follow the Markdown Guide

Every markdown file in `docs/decisions/` except the vendored `adr-template.md` SHALL follow the
[Markdown Guide](https://www.markdownguide.org/) basic syntax best practices.

#### Scenario: Reviewing a record

- **WHEN** a record or `docs/decisions/README.md` is reviewed
- **THEN** headings and lists are surrounded by blank lines and each list uses one delimiter consistently
