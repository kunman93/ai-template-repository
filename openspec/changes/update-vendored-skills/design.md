# Design

## Context

`.agents/skills/git-commit/SKILL.md` records its source in its frontmatter `metadata` (`github-repo`, `github-path`,
`github-ref`, `github-tree-sha`), which `gh skill update` reads. `gh skill update git-commit --dry-run` reports
`883a6a74 > 266a4c3f`. The workflow skills commit through `git-commit`, but `finish-work` rebases, resets to a backup
branch, pushes and force pushes on its own. `AGENTS.md` lines 47-49 name `finish-work` as the explicit request for
"`git reset --hard` and force pushes that the `git-commit` skill requires". The updated skill's Safety Rules also
forbid `git rebase`, any history change and any push unless the user asks.

## Goals / Non-Goals

**Goals:**

- The vendored skill is byte-identical to upstream apart from the metadata `gh` writes.
- Every git operation the workflow already performs stays explicitly authorized under the new rules.

**Non-Goals:**

- No change to what `finish-work` or the other workflow skills do.
- No edit to the vendored skill or to the generated OpenSpec skills and prompts.

## Decisions

- **Update with `gh skill update git-commit`, not a manual copy.** It writes the new tree SHA into the metadata, so the
  next `--dry-run` is accurate. A manual copy would leave a stale SHA, or need the SHA edited by hand. The README
  maintenance step names `gh skill update --all`, so it covers every vendored skill without a list to keep current.
- **No update script.** The vendored sources update with two commands, `gh skill update --all` and `openspec update`,
  and both produce diffs that need review anyway. A script would chain them and add code to maintain.
- **Widen the exemption in `AGENTS.md`, not in each workflow skill.** `AGENTS.md` already holds the one sentence that
  overrides `git-commit`'s safety rules. Naming pushes, rebases, `git reset --hard` and force pushes there keeps a single
  source. The bullet "Pushing the feature branch is allowed" stays, and the exemption still names only the `finish-work`
  procedures for rewriting. Repeating the authorization in `finish-work`, `implement-story`, `fix-bug` and `do-chore`
  would duplicate it four times.
- **Git 2.56 as a hard minimum.** `finish-work` resolves rebase conflicts, and the updated skill tells agents to stage
  resolved files with `git add --resolved`. A soft "recommended" note would let maintainers run the workflow on a Git
  that fails at exactly that step.
- **No spec delta (`skip_specs: true`).** No existing capability covers the git safety rules, and the workflow behaves
  as before. A new requirement would only restate `AGENTS.md`.

## Risks / Trade-offs

- [Maintainers on Apple Git 2.54 cannot use `git add --resolved`] → The README prerequisite names 2.56, and the proposal
  notes that macOS users need a newer Git, for example from Homebrew.
- [`gh skill update` rewrites the frontmatter layout or adds fields] → Accepted. The acceptance criteria allow the
  metadata `gh` writes. The diff review checks that nothing else changed.
- [Upstream changes again before merge] → Run `gh skill update git-commit --dry-run` again before the PR is merged.
