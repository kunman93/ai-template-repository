# Design

## Context

`finish-work` rewrites the history twice: Create PR cleans it up before the first push, and Finalize history squashes
the fixups, rebases on `origin/<default-branch>` and creates the archive commit. Create PR then has the `reviewer`
judge the commits. Finalize history pushes without any check, and its archive commit is created after every review.
Nothing in the repository runs code today: the Commands are not configured and `ci.yml` is a placeholder for adopting
repositories.

## Goals / Non-Goals

**Goals:**
- One script that both procedures call, with the same arguments, before they push a rewritten history.
- Runs on the bash 3.2 that macOS ships and on the bash of `ubuntu-latest`, with git 2.56 as the only other tool.

**Non-Goals:**
- Judging whether a message matches its diff, or whether a commit mixes changes. That stays with the `reviewer`.
- A commit-msg hook or a CI job. Hooks are per clone and skippable, and `ci.yml` belongs to the adopter.
- Rewriting commits already on `main`.

## Decisions

- **A bundled script in the skill, not a snippet in the prose.** The acceptance criterion says the check runs without
  a model. A snippet that the agent retypes is not mechanical, and a typo in it fails silently. The script lives at
  `.agents/skills/finish-work/scripts/check-commits.sh`, so `onboard-repository` copies it along with the skill.
- **Interface:** `check-commits.sh <base> [<issue>]`. `<base>` is `origin/<default-branch>`, so the script reads no
  configuration. `<issue>` is the branch's issue number, which the workflow skill already knows. Inferring it from the
  branch name is impossible (names do not hold the number), and reading it from the PR needs `gh`, which is not git
  inspection.
- **Git only.** `git rev-parse --verify` for the base, `git log --format='%h%x09%s' <base>..HEAD` for the subjects and
  `git log -1 --format='%(trailers:key=Refs,valueonly)' <sha>` for the trailers. `%(trailers)` reads only the final
  trailer block, which is exactly the rule. A `Refs:` line in its own paragraph above `Co-authored-by` therefore fails.
  Both `git log` calls pass `--no-show-signature`, so a user's `log.showSignature=true` cannot add lines to the output.
- **Subject rule.** The types table of the `git-commit` skill, an optional `(<scope>)` with no parentheses inside, an
  optional `!`, then `: ` and a non-empty summary, at most 72 characters. The type list is copied into the script. A
  second copy is acceptable (rule of three), and the test script pins it.
- **Fixups.** Subjects starting with `fixup!`, `squash!` or `amend!`, which are the three markers `--autosquash`
  consumes. These subjects also fail the subject rule. The script reports the leftover fixup reason only, because that
  points to the right fix (rerun the autosquash, not reword).
- **Output and exit codes.** One line per broken rule: `<short-sha> <subject>: <reason>`. Exit `1` if any line was
  printed, `0` otherwise, and `2` with a usage message on bad arguments, so a usage error is never mistaken for a
  clean history.
- **Placement.** Create PR runs it between the content check (sub-step 3) and the commit review (sub-step 4), so the
  Opus review never spends time on what a script catches. Finalize history runs it after the archive (sub-step 4) and
  before the push (sub-step 5), because the archive commit is the one that slipped through (`a1b22b6`).
- **Fix loop.** The agent fixes failures itself: it reruns the autosquash for a fixup, rewords subjects or adds the
  trailer with a non-interactive rebase, and runs the check again. In Create PR, it proves the content with the
  existing check against `backup/<branch>`. In Finalize history that backup predates the rebase on
  `origin/<default-branch>`, so the agent first records `git rev-parse HEAD` and proves `git diff <recorded> HEAD`
  is empty after the fix. If the content changed, it resets to the recorded commit and asks the user.
- **The rule is documented in `AGENTS.md`.** The Git Workflow section is where the branch and commit rules already
  live. `git-commit` is vendored from upstream, so it is not edited. No ADR: the rule is one line, enforced by a script
  that can be changed in one commit.
- **Tests.** `check-commits.test.sh` builds throwaway repositories in a `mktemp -d` directory, one per scenario of the
  spec, and asserts on exit code and on the reported short SHA. No framework: the repository has none and the script
  is small. It runs locally; `ci.yml` is left to adopters.

## Risks / Trade-offs

- [The type list drifts from the `git-commit` skill after an upstream update] -> The update procedure for vendored
  skills reviews the diff.
- [The agent forgets to pass the issue number and the `Refs:` check is skipped] -> Both procedures state which branches
  pass `<issue>`, and the end-to-end test covers a `feature/` branch.
- [Older commits on `main` use the paragraph form] -> The check covers only `<base>..HEAD`, so they never fail it.
