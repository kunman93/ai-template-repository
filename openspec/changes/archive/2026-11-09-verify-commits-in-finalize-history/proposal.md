# Proposal

## Why

Nothing checks the history that Finalize history produces before the merge. The archive commit `a1b22b6` reached the
default branch without the `Refs:` line that every other commit of its Story has (#27). The `Refs:` rule is not even
written down: it is a habit. Also, the existing `Refs: #<n>` lines sit in their own paragraph above `Co-authored-by`, so
git does not read them as trailers.

## What Changes

- A new script, `.agents/skills/finish-work/scripts/check-commits.sh`, checks every commit between a base ref and
  `HEAD`. It uses only git inspection, and no model. It fails when a commit:
  - is a `fixup!`, `squash!` or `amend!` commit,
  - has a subject that is not a Conventional Commits subject of the `git-commit` skill's types, or is longer than 72
    characters,
  - lacks a `Refs: #<n>` git trailer for the branch's issue, when an issue number is passed.

  It names each offending commit by short SHA and subject, and the reason.
- Finalize history in `finish-work` runs the check after the archive sub-step and before the push. On failure, the
  agent rewrites the history itself, proves the content is unchanged, and runs the check again.
- Create PR in `finish-work` runs the same check after the content check and before the commit review by the
  `reviewer`, with the same fix loop.
- `feature/` and `fix/` branches pass their issue number, so the check requires `Refs: #<n>`. `chore/` branches have no
  issue and pass none, so only the fixup and subject checks apply.
- `AGENTS.md` writes down the rule: on a branch that belongs to an issue, every commit ends with the trailer
  `Refs: #<n>` in the same trailer block as `Co-authored-by`, with no blank line between them.
- A plain bash test script next to the check covers its behavior. It runs locally; `ci.yml` stays a placeholder for
  adopting repositories.
- `README.md` mentions the check in the `finish-work` entry.
- Out of scope: rewriting commits already on `main` that use the old paragraph form.

## Capabilities

### New Capabilities

- `commit-check`: the mechanical, model-free check of a branch's commits (leftover fixups, subjects and the `Refs:`
  trailer) and where `finish-work` runs it.

### Modified Capabilities

_None._ The `commit-review` capability is unchanged: the reviewer still runs after the check in Create PR.

## Impact

- New: `.agents/skills/finish-work/scripts/check-commits.sh` and `check-commits.test.sh`
- `.agents/skills/finish-work/SKILL.md` (Create PR and Finalize history)
- `AGENTS.md` (Git Workflow: the `Refs:` trailer rule)
- `README.md` (the `finish-work` entry)
- Verified end to end in `kunman93/git-sandbox` on a throwaway branch and PR, with `master` left unchanged.
- No dependencies and no CI changes. The check needs only git and bash.
