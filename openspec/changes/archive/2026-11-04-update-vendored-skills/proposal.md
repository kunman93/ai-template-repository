# Proposal

## Why

The vendored `git-commit` skill is at upstream tree `883a6a7` (January 2026). Upstream (github/awesome-copilot) has since
rewritten it in three commits: Git 2.56 support with `git add --resolved`, both footer separators, and unstaging
unrelated files before staging. The template and every repository onboarded from it should use the current, fixed
version. The new version also widens its safety rules: it forbids pushing and any history change unless the user
asks. `AGENTS.md` grants that request today only for `git reset --hard` and force pushes, so the rebases and normal
pushes of `finish-work` would no longer be covered.

## What Changes

- Update `.agents/skills/git-commit` to upstream tree `266a4c3` with `gh skill update git-commit`. The file stays
  unchanged from upstream apart from the metadata `gh` writes.
- Reword the history-rewrite exemption in the Git Workflow section of `AGENTS.md` so that the workflow skills and
  `finish-work` stay the explicit request for every push, rebase, `git reset --hard` and force push they perform.
- Add Git 2.56 or later to the prerequisites in `README.md`, because the updated skill uses `git add --resolved` after
  merge conflicts, which `finish-work` resolves during rebases.
- Replace "re-copy it from there" for vendored skills in "Maintaining the template" in `README.md` with
  `gh skill update --all --dir .agents/skills`, which updates every vendored skill without touching skills installed outside the repository.
- OpenSpec: no file change. OpenSpec CLI 1.16.0 is the latest release, and `openspec update --dry-run` reports no
  changes.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. The workflow behaves as before: the same steps push, rebase and force push. Only the vendored skill version and
the wording that authorizes those steps change, so the change sets `skip_specs: true`.

## Impact

- `.agents/skills/git-commit/SKILL.md` (vendored, replaced from upstream)
- `AGENTS.md` (Git Workflow section)
- `README.md` (Prerequisites, Maintaining the template)
- Maintainers need Git 2.56 or later. Apple Git on macOS currently ships 2.54, so macOS users need a newer Git, for
  example from Homebrew. The vendored skill's `compatibility` field states the same minimum for onboarded repositories.
- Onboarded repositories pick up the update through "Syncing a project with the template".
