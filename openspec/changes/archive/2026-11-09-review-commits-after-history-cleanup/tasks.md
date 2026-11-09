# Tasks

## 1. Reviewer commit review mode

- [x] 1.1 In `.github/agents/reviewer.agent.md`, add a "Commit review" section per design.md: when the prompt asks
  for a commit review, skip checks 1 to 10 and the Commands, list the commits with
  `git log --format='%h %s' origin/<default-branch>..HEAD` and read each with `git show <sha>`, and report
  non-conventional subjects, messages that claim changes the diff lacks, substantial changes the message omits, and
  commits that mix unrelated changes; verify by walking every scenario of `specs/commit-review/spec.md` that concerns
  the reviewer through the new text and confirming each is covered
- [x] 1.2 In the same file, state that commit findings use the existing severity levels with the mapping from
  design.md, reference a commit by short SHA and subject instead of `file:line`, and end with APPROVE or REQUEST
  CHANGES; update the frontmatter `description` and the Hard rules / Report back sections only where they would
  otherwise contradict the mode; verify `git grep -n "git show\|git log" -- .github/agents/reviewer.agent.md` shows
  the mode uses only `git fetch`, `git log` and `git show` and the Hard rules still forbid any write

## 2. finish-work Create PR

- [x] 2.1 In the Create PR section of `.agents/skills/finish-work/SKILL.md`, insert the commit review after the
  empty-diff check and before deleting the backup: run the custom `reviewer` subagent (pinned to Opus 5.5, no
  `/model` switch) asking for a commit review; on REQUEST CHANGES rewrite again, repeat the content check against the
  same backup and rerun the commit review; delete the backup and push only after APPROVE; verify by walking the
  "Clean history" and "Commit review requests changes" scenarios through the new steps
- [x] 2.2 In `README.md`, update the `finish-work` entry to say it has the cleaned-up commits reviewed before creating
  the PR; verify the entry matches the new Create PR section
- [x] 2.3 In the Create PR bullet of `implement-story`, `fix-bug`, `do-chore` and `setup-repository`, mention that the
  `reviewer` subagent reviews the cleaned-up commits, and in the intro of `finish-work` say that this step runs on
  Opus 5.5; verify `git grep -n "cleaned-up commits" -- .agents/skills` lists all four bullets

## 3. Verification in git-sandbox

Runs from the main session in a clone of `kunman93/git-sandbox` (default branch `master`) in the session workspace,
on a throwaway branch `feature/commit-review-e2e` cut from `origin/master`. Record `git ls-remote origin master`
before starting. The custom `reviewer` subagent is told that `<default-branch>` is `master` and to work in the clone.
If its report does not follow the new commit review format, the session loaded the old agent file: stop and ask the
user to restart the session on the feature branch.

- [x] 3.1 Commit a bad history on the throwaway branch: one commit with the subject `update readme`, one whose
  message claims a README change its diff lacks, one that mixes two unrelated changes, and one whose diff has a
  substantial change its message omits; run the Create PR procedure up to the commit review; verify the reviewer
  returns REQUEST CHANGES with a MAJOR finding naming each of the four commits, `git ls-remote origin
  feature/commit-review-e2e` is empty, and `git status --porcelain` and `git for-each-ref refs/heads` are the same
  before and after the review
- [x] 3.2 Rewrite the history into atomic, conventional commits with accurate messages, repeat the content check
  against the backup and rerun the commit review; verify it returns APPROVE, then push and create a PR to `master`
- [x] 3.3 Close the PR, delete the remote and local throwaway branches and the clone; verify
  `git ls-remote origin master` shows the same commit as before

## 4. Validation

- [x] 4.1 Run `openspec validate review-commits-after-history-cleanup --strict`; verify it passes

## Workflow follow-up

- Record the results of 3.1 to 3.3 in this PR's description, including `kunman93/git-sandbox#24` (closed) and `master`
  of `git-sandbox` still at `fda51af`.
- Archive the change after the user approves the PR, which creates `openspec/specs/commit-review/spec.md`.
