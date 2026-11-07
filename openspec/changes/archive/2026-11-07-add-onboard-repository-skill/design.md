# Design

## Context

See proposal.md - Why. Today the existing-repository path in `README.md` is five blocks of git commands built on a
`template` remote and one path list (`AGENTS.md .agents .github docs/decisions/adr-template.md docs/decisions/README.md
docs/decisions/0000-... openspec/config.yaml .gitignore .editorconfig`). The onboarding change rejected a skill because
it "would first have to be fetched from the template". `gh skill install --allow-hidden-dirs` removes that obstacle.

Verified with `gh skill install kunman93/ai-template-repository setup-repository --allow-hidden-dirs --dir
.agents/skills` in an empty repository:

- The installed `SKILL.md` gets `metadata.github-repo` (`https://github.com/kunman93/ai-template-repository`),
  `github-ref` (`refs/heads/main`), `github-path` and `github-tree-sha`, and its frontmatter keys are reordered. The
  installed copy therefore never matches the template's copy byte for byte.
- The installed directory is untracked in the working tree.
- `@<version>` and `--pin` accept a tag or commit SHA; `@main` also resolved to `refs/heads/main`.

The workflow skills are prose `SKILL.md` files that the main session follows on Sonnet 5.5 with a model check in step
0, like `setup-repository`.

## Goals / Non-Goals

**Goals:**

- One install command and one skill run to onboard an existing repository, ending in the same PR as Setup.
- The same skill pulls later template changes, asking only about what the template changed.

**Non-Goals:**

- Changing what Setup does (`setup-repository` keeps its behavior; only its references change).
- Updating the skill itself: that is `gh skill update` or `gh skill install --force`, since the skill is the one
  template file `gh` tracks.
- Supporting repositories created from the template without installing the skill (their copy has no metadata).
- Automatic merging without the maintainer seeing the result.

## Decisions

### A prose skill that hands over to setup-repository

`onboard-repository/SKILL.md` follows the structure of `setup-repository`: model and agent check, gather read-only, decide
per file, branch and commit, then load `setup-repository`, which reuses `chore/adopt-template` (its step 3 already does)
and does the review, PR and merge with `finish-work`. The onboarding skill therefore has no review or PR step of its
own, and onboarding plus Setup end in one PR. The name `onboard-repository` pairs with `setup-repository` (onboard,
then set up) and fits re-runs, which onboard template changes; the branch keeps the name `chore/adopt-template` that
`setup-repository` already reuses. Alternative considered: a shell script (portability and test burden in a
stack-agnostic template, cannot merge `AGENTS.md` sensibly).

### Template source from the skill's own metadata

The skill reads `metadata.github-repo` and `metadata.github-ref` from its own `SKILL.md`. It adds `github-repo` as the
remote `template` (if a `template` remote exists with another URL, it shows both and asks whether to change it or
stop), runs `git fetch template <github-ref>` and resolves `FETCH_HEAD` to one commit `T`. Every later read uses `T`,
so the run is consistent even if the template moves meanwhile, and `T` is the commit it records. A fork installs with
its own URL, so nothing needs editing. Without metadata (the skill copy in the template itself or in a repository
created from it), the skill tells the maintainer to install it with `gh skill install ... --force` and stops.
Alternative considered: a hard-coded template URL (breaks forks, which the Story rules out).

### The skill's own directory is special

`.agents/skills/onboard-repository/` is excluded from the file comparison, and changes in it are ignored by the
clean-tree check: the install leaves it untracked (first run) or modified (`gh skill update`), and taking the
template's copy would drop the metadata the next run needs. The directory is committed with the onboarding as it is.

### Gather first, then branch

The skill decides everything read-only before it creates anything:

1. Model check; `gh` signed in; working tree clean apart from its own directory, else stop.
2. Default branch from `gh repo view --json defaultBranchRef`; `git fetch origin <default-branch>`.
3. Base: when `chore/adopt-template` exists locally or on `origin`, ask whether to reuse it, saying when its tip is
   already in the default branch (a leftover from a merged onboarding). If declined, explain how the user deletes the
   branch and stop: the skill never deletes a branch. Otherwise `origin/<default-branch>`.
4. Template remote, fetch, `T` (above).
5. Baseline `B`: the `Template-Commit` trailer of the newest commit on the base that has one
   (`git log -1 --format='%(trailers:key=Template-Commit,valueonly)' --grep='^Template-Commit:' <base>`), used only
   if `git cat-file -e B^{commit}` succeeds after the fetch. Otherwise there is no baseline (first run).
6. Classify every file (below) by comparing blobs with `git rev-parse <rev>:<path>`, without checking anything out.
7. Show one overview, then ask per file.

Only when at least one file changes does it create `chore/adopt-template` from `origin/<default-branch>` (or switch to
the reused branch). The skill's untracked directory carries over the switch. A run with nothing to change has no side
effects except the `template` remote and fetch.

### File classification

The file set `S` is `git ls-tree -r --name-only T -- <path list>` minus `.agents/skills/onboard-repository/`. The path list
is the one `README.md` uses today, so the template's `README.md`, `openspec/specs/`, `openspec/changes/` and other
decision records are never in `S`. For each path, with `L` the base's blob (or absent):

| Baseline | Template                         | Repository              | Result                                  |
|----------|----------------------------------|-------------------------|-----------------------------------------|
| any      | in `T`                           | `L` = `T`               | nothing                                 |
| none     | in `T`                           | absent                  | copy                                    |
| none     | in `T`                           | `L` differs             | ask keep / take / merge                 |
| `B`      | unchanged `B` -> `T`             | any                     | nothing (the repository's own choice)   |
| `B`      | added after `B`                  | absent                  | copy                                    |
| `B`      | added after `B`                  | `L` differs from `T`    | ask keep / take / merge (no `B` version)|
| `B`      | changed `B` -> `T`               | `L` differs from `T`    | ask keep / take / merge                 |
| `B`      | changed `B` -> `T`               | absent                  | report "removed here", do not re-add    |
| `B`      | removed after `B` (path in `B`)  | present                 | ask keep / delete                       |
| `B`      | removed after `B` (path in `B`)  | absent                  | nothing                                 |

The overview lists new files to copy as a count with their directories, and every file to ask about by name, before
anything changes. For a file to ask about it shows `git diff` between the repository's version and the template's (and,
with a baseline, the template's own change `B..T`), and recommends merge for `AGENTS.md`, `.github/workflows/ci.yml`
and `.github/ISSUE_TEMPLATE/config.yml`, take when `L` equals the template's version at `B` (the maintainer never
changed it), and otherwise lets the maintainer pick without a recommendation.

### Merge: prepared by the skill, finished by the maintainer

With a baseline, the skill runs `git merge-file` on the repository's version, the template's version at `B` and at `T`
(a real three-way merge). Without one, it edits the repository's file to add the template's sections that are missing
and keeps every line of the repository's. In both cases it shows the resulting diff against the repository's version,
leaves conflict markers in place, and the maintainer edits the file by hand until they confirm it. A kept file is
never written, so it stays byte-identical.

### One commit with a Template-Commit trailer

All changes go into one commit made with the `git-commit` skill (type `chore`, for example
`chore: adopt template files`), whose message ends with the trailer `Template-Commit: <T>` before the
`Co-authored-by` trailer. One commit because it is one logical change (adopting template version `T`) and the trailer
must sit on exactly that change. The trailer survives `finish-work` (autosquash keeps the original message,
`gh pr merge --merge` keeps the commit). If a repository squash-merges and drops the body, the next run finds no
baseline and behaves like a first run: more questions, no data loss. When nothing is copied, asked about or taken, there is no
commit and the baseline does not advance. On a first run the freshly installed skill directory is always committed, so
the baseline advances even when the maintainer keeps every offered file, and those files are not offered again.
Alternatives considered (asked and decided with the user): a tracked version file (one more file in every
repository) and no baseline (offers `AGENTS.md` and `ci.yml` on every run after Setup, so a second run is never
clean).

### README and references

"Adopting the template", item 1, existing repository: the install command
`gh skill install <owner>/<template> onboard-repository --allow-hidden-dirs --dir .agents/skills`, the warning `gh` prints
about installing from a hidden directory (quoted from a real install, with one sentence that it is expected because
the template keeps its skills in `.agents/skills`), and "run `onboard-repository` in Copilot CLI; it runs
`setup-repository` for you". The current five git steps move into a collapsed "Manual onboarding" fallback below,
unchanged. A sentence tells maintainers to run the skill again (after `gh skill update onboard-repository --dir
.agents/skills`) to pull template changes. The skill list in "What is included" and `AGENTS.md` Implementation
Workflow add `onboard-repository`; `setup-repository` points to `onboard-repository` instead of the README steps and lists it
among the template skills in its Gather step.

### Verification instead of automated tests

The repository has no test runner and the change is prose, so it is verified end to end in `kunman93/git-sandbox`
(private, default branch `master`), like `setup-repository`. The skill reads the default branch from GitHub and always
branches from `origin/<default-branch>`, so a scenario's project state must be on the default branch. To keep
`master`'s content unchanged, each scenario commits its project state on a branch `scenario-<n>` cut from `master`,
pushes it and temporarily makes it the sandbox's default branch on GitHub (`gh repo edit --default-branch`). The skill
then runs unchanged, with a non-`main` default branch. Scenarios therefore run one at a time, each in a fresh
`general-purpose` subagent and a fresh clone in the session workspace; the subagent follows `SKILL.md` and plays the
maintainer with answers fixed in its prompt, so the author of the skill does not grade their own run. The skill is
installed from this feature branch pinned to a commit SHA. Each PR is closed unmerged, except those a later scenario builds on, which are merged into a scenario branch and never into `master`; afterwards the default branch is
switched back to `master` (also when a run fails) and every scenario branch is deleted.

| # | State on the default branch before the run                                     | Expected                                                       |
|---|--------------------------------------------------------------------------------|----------------------------------------------------------------|
| 1 | `README.md` and `.gitignore` only                                              | every template file copied, `.gitignore` asked, Setup runs     |
| 2 | React (Vite, npm), no CI                                                       | no conflicts, Commands and `ci` from `package.json`            |
| 3 | Spring Boot (Maven wrapper) with `.github/workflows/build.yml`                 | `build.yml` byte-identical                                     |
| 4 | Spring Boot (Gradle wrapper) with own `AGENTS.md`, `ci.yml` (job `build`), a skill | asked for each, merge proposed, kept files byte-identical |
| 5 | Scenario 2's adoption commit merged into `scenario-2` (not `master`)           | nothing to change: no branch, commit or PR                     |
| 6 | `README.md` and `.gitignore`; first run merged into `scenario-6`, then the skill reinstalled from a ref with one template change and a local edit of the same file | only the changed files are offered, merge result lands on the branch |
| 7 | Scenario 1 state with an uncommitted change                                    | stops before changing anything                                 |

For scenario 5 the scenario 2 PR targets `scenario-2` and is merged there. Scenario 6 is self-contained and merges its
two PRs into `scenario-6`. `master` stays unchanged. For scenario 6 the template change is one commit on a throwaway branch of this repository
(for example a changed line in `.github/ISSUE_TEMPLATE/feature_request.yml`), deleted after the run. Scenarios not run
live (remote `template` with another URL, copy without metadata, template removed a file, repository removed a file,
reuse of an existing, unfinished `chore/adopt-template`) are listed in the PR as checked by review only.

## Risks / Trade-offs

- [`gh skill` is in preview and its flags or metadata may change] → The manual git steps stay in `README.md` as a
  fallback, and the skill stops with a clear message when metadata is missing.
- [The agent merges `AGENTS.md` badly] → Merge result is shown as a diff, conflicts stay marked, and nothing is
  committed before the maintainer confirms; `finish-work` review and the PR follow.
- [Trailer lost through squash merges or history rewrites] → Falls back to first-run behavior (more questions, never
  overwrites).
- [`git fetch` of a pinned SHA fails on hosts that refuse unadvertised objects] → GitHub allows fetching reachable
  SHAs; the skill reports the fetch error and stops otherwise.
- [A failed scenario leaves the sandbox's default branch on `scenario-<n>`] → Cleanup switches it back to `master`
  after every scenario, whatever the outcome, and the final check confirms `master` is the default and unchanged.
