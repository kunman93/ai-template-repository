# Decisions

This directory holds the architecture decision records (ADRs) of this repository, written in the
[MADR](https://adr.github.io/madr/) format. See the Documentation section of [AGENTS.md](../../AGENTS.md) for when to
write one.

## Adding a record

1. Copy [adr-template.md](adr-template.md) to `NNNN-<title-in-kebab-case>.md`, using the next free four-digit number.
2. Fill it in and delete the optional sections you do not need.
3. Set `status` to `proposed` or `accepted`. To replace a decision, write a new record and set the old one to
   `superseded by ADR-NNNN`.

## Template source

`adr-template.md` is copied unchanged from `template/adr-template.md` of
[MADR 4.0.0](https://github.com/adr/madr/tree/4.0.0), which is available under `MIT OR CC0-1.0`; this repository uses it
under CC0-1.0. Never edit it locally. To upgrade, re-copy it from a newer MADR release.

It is the only file here that does not follow the [Markdown Guide](https://www.markdownguide.org/) conventions, because
it is kept identical to upstream.
