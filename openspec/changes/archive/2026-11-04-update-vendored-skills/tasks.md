# Tasks

## 1. Update the vendored git-commit skill

- [x] 1.1 Run `gh skill update git-commit` and verify `gh skill update git-commit --dry-run` reports no available update
- [x] 1.2 Verify `.agents/skills/git-commit/SKILL.md` below the frontmatter is byte-identical to upstream
  `skills/git-commit/SKILL.md` on `main` (diff against `gh api` content), and that the frontmatter differs only in the
  metadata `gh` writes

## 2. Keep the workflow authorized under the new safety rules

- [x] 2.1 Reword the history-rewrite exemption in the Git Workflow section of `AGENTS.md` to name pushes, rebases,
  `git reset --hard` and force pushes as explicitly requested by the `finish-work` procedures. Verify by reading the
  updated `git-commit` Safety Rules next to `AGENTS.md`, `finish-work`, `implement-story`, `fix-bug`, `do-chore` and
  `.github/agents/reviewer.agent.md`: no rule on push, history rewrite or interactive staging contradicts another

## 3. Document Git and the update procedure

- [x] 3.1 Add Git 2.56 or later, with the reason (`git add --resolved`), to Prerequisites in `README.md` and verify it
  matches the `compatibility` field of the updated skill
- [x] 3.2 Replace "re-copy it from there" for vendored skills in "Maintaining the template" in `README.md` with
  `gh skill update --all --dir .agents/skills` and verify the flags exist with `gh skill update --help`

## 4. Verify OpenSpec

- [x] 4.1 Verify `openspec --version` is the latest release (`npm view @fission-ai/openspec version`) and
  `openspec update --dry-run` reports no changes

## Workflow follow-up

- Re-run `gh skill update git-commit --dry-run` before merging, in case upstream changed again.
- Archive the change after the user approves the PR.
