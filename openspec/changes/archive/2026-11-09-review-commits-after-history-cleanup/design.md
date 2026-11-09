# Design

## Context

`.github/agents/reviewer.agent.md` defines one review: the branch diff against `origin/<default-branch>`, checks 1 to
10, severity levels and a verdict. It reads `git log --oneline` only to spot commits of an unrelated change. The
Create PR procedure of `.agents/skills/finish-work/SKILL.md` backs up the branch, rewrites the history, checks
`git diff backup/<branch> HEAD` is empty, deletes the backup and pushes. No one reads the rewritten commits. The
`implement-story`, `fix-bug`, `do-chore` and `setup-repository` workflows all reach this procedure.

## Goals / Non-Goals

**Goals:**
- One reviewer agent with two modes; the existing branch review is unchanged.
- The commit review runs inside the existing Create PR procedure, so all four workflows get it through `finish-work`;
  their skills only mention the extra step in their Create PR bullet.

**Non-Goals:**
- Reviewing commits in the Implement-step review: the history is still raw there (WIP and fixup commits).
- Checking commits after the push: review fixups and the Finalize history autosquash (#27).
- Checking trailers such as `Refs:` (#27).

## Decisions

- **A separate commit review mode, selected by the caller.** A new "Commit review" section in `reviewer.agent.md`
  applies when the prompt asks for a commit review. In that mode the reviewer skips checks 1 to 10 and runs only the
  commit checks. Rationale: the content is already reviewed and proven unchanged by the empty diff against the backup,
  so a second full review adds Opus time without new evidence. Alternative: add the commit checks to every review and
  rerun the full review after cleanup. Rejected: noise on raw history in the Implement step and duplicate work.
- **Per-commit evidence.** The reviewer lists the commits with `git log --format='%h %s' origin/<default-branch>..HEAD`
  and reads each one with `git show <sha>` (message and diff together). It judges each commit on its own diff, not on
  the branch diff, because a stale message is only visible per commit. It does not run the Commands: the content is
  unchanged since the branch review.
- **Severity mapping.** Non-conventional subject, a message that claims a change the diff lacks, a diff with a
  substantial change the message omits, and a commit mixing unrelated changes are MAJOR (a documented convention
  violated in a way that spreads into the default branch's history). Wording gaps that do not misdescribe the diff
  (for example a slightly vague summary) are MINOR. The reviewer's existing rule stands: torn between two levels, state
  both. "Conventional" means the format and types of the `git-commit` skill.
- **Findings reference the commit.** A commit finding names the short SHA and subject instead of `file:line`, plus the
  offending part of the diff by file where it helps, and a suggested direction (reword, split, or move a hunk to
  another commit).
- **Keep the backup through the loop.** In Create PR the commit review runs after the empty-diff check and before the
  backup is deleted. On REQUEST CHANGES the procedure rewrites again and repeats the content check against the same
  backup, so a fix that goes wrong can still be reset to the backup. Only after APPROVE is the backup deleted and the
  branch pushed. Alternative: a fresh backup per round. Rejected: the first backup is the reviewed content, which is
  exactly what every round must match.
- **No `/model` switch.** `finish-work` runs on Sonnet 5.5; the reviewer is pinned to Opus 5.5 in its agent file, as in
  the Review steps of the workflow skills, so the procedure starts it automatically.

## Risks / Trade-offs

- [Judging "substantial" and "unrelated" is subjective] -> Scenarios fix the clear cases; the reviewer must name the
  concrete change it found, and torn calls state both levels.
- [A session loads custom agents at start, so the end-to-end run might use the old `reviewer.agent.md`] -> The
  verification checks the report has the commit review format; if it does not, restart the session on the feature
  branch before running it.
- [A fixup squashed in Finalize history can still leave a stale message] -> Accepted and named in the proposal; #27
  covers the mechanical part of Finalize.

## Migration Plan

Repositories that adopted the template get the change through `onboard-repository`. No rollback concerns: reverting
the changed files restores the old procedure.
