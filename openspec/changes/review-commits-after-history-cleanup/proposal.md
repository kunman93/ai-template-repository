# Proposal

## Why

The commits that reach the default branch are never reviewed: the `reviewer` agent runs before the Create PR step of
`finish-work` cleans up the history, and it only runs `git log --oneline` to spot unrelated commits. So a squashed
fixup can sit under a message that does not mention it, as in `d0a55e2` (#26).

## What Changes

- The `reviewer` agent gets a commit review mode. When asked for it, it checks only the commits of the branch, not the
  diff: Conventional Commits subjects, messages that match their diffs, and commits that do not mix unrelated changes.
  It stays read-only and uses only `git fetch`, `git log` and `git show`.
- Commit findings use the reviewer's existing severity levels and verdict, so any MAJOR finding forces REQUEST CHANGES.
- The Create PR procedure of `finish-work` runs the `reviewer` in commit review mode on the cleaned-up history, before
  the push. On REQUEST CHANGES it rewrites the history again and reruns the commit review until no CRITICAL or MAJOR
  finding remains.
- `README.md` says that `finish-work` has the cleaned-up commits reviewed before it creates the PR, and the Create PR
  bullet of the four workflow skills mentions the step.
- Out of scope: checking the history after the autosquash in Finalize history (#27, which checks mechanically without a
  model). A fixup squashed there can still leave a message that omits its change.

## Capabilities

### New Capabilities

- `commit-review`: the reviewer's review of a branch's commits after the history cleanup and before the push, and the
  findings it reports.

### Modified Capabilities

_None._

## Impact

- `.github/agents/reviewer.agent.md` (new commit review mode)
- `.agents/skills/finish-work/SKILL.md` (Create PR)
- `.agents/skills/implement-story/SKILL.md`, `fix-bug`, `do-chore` and `setup-repository` (their Create PR bullet)
- `README.md` (the `finish-work` entry)
- Verified end to end in `kunman93/git-sandbox` on a throwaway branch and PR.
- No code, dependencies or CI changes.
