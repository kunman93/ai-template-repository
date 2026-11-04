# Tasks

## 1. Pull request template

- [x] 1.1 Add `.github/pull_request_template.md` with the sections Description, Type of change (Story, Bug fix, Chore,
  Breaking change), Related issues, Testing steps, Screenshots / evidence and Checklist (reviewer approval, Commands in
  `AGENTS.md`, documentation, OpenSpec change), each with one short HTML comment on what goes there and when to write
  `n/a`; verify it matches the "Template sections", "Type of change matches the workflows" and "Stack-agnostic
  checklist" scenarios
- [x] 1.2 List the template under "What is included" in `README.md` and verify it is listed next to the other
  `.github/` entries

## 2. Agent fills and maintains the description

- [x] 2.1 Extend the Create PR section of `.agents/skills/finish-work/SKILL.md`: fill every section of the template from
  the branch's commits, diff and linked issue, `n/a` where a section or checklist item does not apply, tick only true
  boxes, check for leftover `<!--` and placeholders, and create the PR with `gh pr create --body-file -`; verify each
  scenario of "The agent fills out every section" and "Checkboxes state only the truth" is covered by the text
- [x] 2.2 In the same skill, tell the agent to update the description with `gh pr edit <n> --body-file -` whenever
  pushed fixes (Create PR) or the archive (Finalize history) make a section inaccurate; verify both scenarios of "The
  description stays current" are covered
- [x] 2.3 Verify with `grep -n "gh pr create" .agents/skills` that `finish-work` is the only skill that creates PRs, and
  that `implement-story`, `fix-bug` and `do-chore` still reference its Create PR section unchanged

## 3. Verification

- [x] 3.1 Review every added or changed markdown file against the Markdown Guide basic syntax best practices
- [x] 3.2 Run `openspec validate add-pr-template --strict` and verify it passes

## Workflow follow-up

- Create this Story's PR with the new Create PR procedure and check its body against the scenarios of "The agent fills
  out every section" (no comments, no placeholders, `n/a` for Screenshots / evidence).
- After archiving, check that the PR description points to `openspec/changes/archive/`.
- Archive the change after the user approves the PR, with the `finish-work` skill.
