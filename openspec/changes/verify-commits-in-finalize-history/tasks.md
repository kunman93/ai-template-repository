# Tasks

## 1. The check script

- [x] 1.1 Write `.agents/skills/finish-work/scripts/check-commits.test.sh` with one case per scenario of
  `specs/commit-check/spec.md` that concerns the script (fixup, no type, unknown type, 73
  characters, valid subjects incl. scope and `!`, missing / wrong / non-trailer `Refs:`, no issue, clean history,
  unknown base, non-numeric issue), each in a throwaway repository under `mktemp -d`; verify it fails because the script does not exist yet
- [x] 1.2 Write `.agents/skills/finish-work/scripts/check-commits.sh <base> [<issue>]` per design.md (git only,
  `<short-sha> <subject>: <reason>` lines, exit 0 / 1 / 2) and make both files executable; verify the test script
  passes 10 times in a row, and that it fails when the 72-character limit, the `amend!` marker or the trailer-only
  `Refs:` lookup is broken on purpose (restore each afterwards)

## 2. finish-work and documentation

- [ ] 2.1 In the Create PR section of `.agents/skills/finish-work/SKILL.md`, run the check after the content check and
  before the commit review, passing `<issue>` on `feature/` and `fix/` branches and none on `chore/`; on failure fix
  the history, repeat the content check against the backup and rerun the check; verify by walking the "Chore branch"
  scenario through the new text
- [ ] 2.2 In the Finalize history section, run the check after the archive sub-step and before the push, with the fix
  loop of design.md (record `HEAD`, fix, prove `git diff <recorded> HEAD` empty, rerun; reset and ask on a content
  change); verify by walking the "Missing trailer on the archive commit" scenario through the new text
- [ ] 2.3 In the Git Workflow section of `AGENTS.md`, state the `Refs: #<n>` trailer rule for branches that belong to
  an issue, in the same trailer block as `Co-authored-by` with no blank line; verify against the "Reader looks up the
  rule" scenario
- [ ] 2.4 In `README.md`, mention in the `finish-work` entry that it checks the commits mechanically before each push
  of a rewritten history; verify the entry matches the new sections

## 3. Verification in git-sandbox

Runs from the main session in a clone of `kunman93/git-sandbox` (default branch `master`) in the session workspace, on
a throwaway branch `feature/commit-check-e2e` cut from `origin/master`, against a throwaway issue in `git-sandbox`.
Record `git ls-remote origin master` before starting.

- [ ] 3.1 Commit a valid history with `Refs: #<n>` trailers plus a `fixup!` commit, push and create a PR to `master`;
  run Finalize history with this branch's script, with an archive-like last commit that lacks the trailer and a
  commit with a non-conventional subject; verify the check fails naming those commits by short SHA and subject, and
  that nothing is pushed
- [ ] 3.2 Fix the history per the Finalize history fix loop; verify `git diff <recorded> HEAD` is empty, the check
  passes, and the push succeeds
- [ ] 3.3 Close the PR and the issue, delete the remote and local throwaway branches and the clone; verify
  `git ls-remote origin master` shows the same commit as before

## 4. Validation

- [ ] 4.1 Run `openspec validate verify-commits-in-finalize-history --strict`; verify it passes

## Workflow follow-up

- Record the results of 3.1 to 3.3 in this PR's description, including the `git-sandbox` PR and issue (closed) and the
  unchanged `master`.
- Archive the change after the user approves the PR, which creates `openspec/specs/commit-check/spec.md`.
