---
name: onboard-repository
description: 'Onboard an existing repository to the template, or pull later template changes into it: copy the template files the repository lacks, ask keep, take or merge for every file that differs, commit on chore/adopt-template and hand over to setup-repository. Never touches the default branch. Use when the user asks to adopt, onboard or update from the template in an existing repository.'
---

# Onboard a Repository

Brings the template's workflow files into an existing repository, and later pulls the template's changes into it. The
skill is installed with `gh skill install <template-repo> onboard-repository --allow-hidden-dirs --dir
.agents/skills`, which writes the template's repository and ref into this file's `metadata`. Changes go through the
branch `chore/adopt-template` and one reviewed PR together with the Setup of `setup-repository`. The skill never
renames, commits to or rewrites the default branch, and never pushes.

The whole workflow runs on Sonnet 5.5 in the main session.

## 0. Check workflow setup

- Before starting a step, check the main session model reported in your environment information against the model named in the step.
- If it does not match, or if you cannot tell, tell the user which model to pick with `/model` and stop.
- Also check that the main session runs the default agent, not a custom agent. If it does not, or if you cannot tell, tell the user to switch with `/agent` and stop.
- The check covers the main session only; subagent models are set by their agent file or the `model` argument.
- The skill needs `git` and `gh`. If `gh` is not signed in, tell the user and stop.

## 1. Gather

Runs on Sonnet 5.5. Nothing in the repository changes in this step; the only side effects are the `template` remote
and the fetches.

1. **Clean tree.** If `git status --porcelain -- . ':!.agents/skills/onboard-repository'` prints anything, tell the
   user to commit or stash it and stop. This skill's own directory is the exception: the install leaves it untracked or
   modified.
2. **Template source.** Read `metadata.github-repo` and `metadata.github-ref` from the frontmatter of
   `.agents/skills/onboard-repository/SKILL.md`. If either is missing, this copy was not installed with `gh skill
   install`: tell the user to run `gh skill install <template-repo> onboard-repository --allow-hidden-dirs --dir
   .agents/skills --force` and stop.
3. **Default branch.** `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`, then `git fetch origin
   <default-branch>`.
4. **Base.** Look for `chore/adopt-template` locally and on `origin` (`git ls-remote --heads origin
   chore/adopt-template`); fetch it when `origin` has it.
   - It exists: ask whether it is an unfinished onboarding to reuse. If its tip is already in
     `origin/<default-branch>` (`git merge-base --is-ancestor`), say so: it is left over from a merged onboarding. When
     the user declines, tell them to delete the branch themselves (`git switch <default-branch>`, `git branch -D
     chore/adopt-template`, `git push origin --delete chore/adopt-template`), run the skill again, and stop. The skill
     never deletes a branch. When the user agrees, the base is that branch's tip; when the local and the `origin` tip
     differ, stop and tell them to reconcile the two.
   - It does not exist: the base is `origin/<default-branch>`.
5. **Template remote.** If the remote `template` does not exist, add it with `git remote add template <github-repo>`.
   If it exists with another URL, show both and ask whether to change it or stop.
6. **Fetch.** `git fetch template <github-ref>`, then `git rev-parse FETCH_HEAD`. Call that SHA `<T>`, and use the SHA itself in every later command
   (shell variables do not persist between commands). Read the template only through `<T>` from here on.
7. **Baseline.** Take the value of the newest `Template-Commit` trailer on the base:
   `git log -1 --format='%(trailers:key=Template-Commit,valueonly)' --grep='^Template-Commit: ' <base>`. Use it as `B`
   only if `git cat-file -e <B>^{commit}` succeeds. Without `B`, this is a first run. When a `Template-Commit` line
   exists on the base but no `B` results, tell the user that the baseline was lost and that every differing file will
   be asked about again.
8. **File set.** The template's files that onboarding manages:
   `git ls-tree -r --name-only <T> -- AGENTS.md .agents .github docs/decisions/adr-template.md docs/decisions/README.md
   docs/decisions/0000-use-markdown-architectural-decision-records.md openspec/config.yaml .gitignore .editorconfig`,
   without everything under `.agents/skills/onboard-repository/`. The template's `README.md`, `openspec/specs/`,
   `openspec/changes/` and its other decision records are never in the set. Files that are not in the set are never
   touched.
9. **Classify** every path of the set, and with `B` also every path of `B`'s set that `T` no longer has. Compare blobs
   with `git rev-parse --verify -q <rev>:<path>` (it prints nothing for a missing path) and never check anything out. `L` is the base's blob, absent if the base has no
   such file.

   | Baseline | In the template                  | In the repository      | Result                                       |
   |----------|----------------------------------|------------------------|----------------------------------------------|
   | any      | `T` has it                       | `L` equals `T`         | nothing                                      |
   | none     | `T` has it                       | absent                 | copy                                         |
   | none     | `T` has it                       | `L` differs            | ask keep, take or merge                      |
   | `B`      | same blob in `B` and `T`         | any                    | nothing (the repository's own choice)        |
   | `B`      | not in `B`, in `T`               | absent                 | copy                                         |
   | `B`      | not in `B`, in `T`               | `L` differs from `T`   | ask keep, take or merge                      |
   | `B`      | differs between `B` and `T`      | `L` differs from `T`   | ask keep, take or merge                      |
   | `B`      | differs between `B` and `T`      | absent                 | report as removed here, do not add it again  |
   | `B`      | in `B`, not in `T`               | present                | ask keep or delete                           |
   | `B`      | in `B`, not in `T`               | absent                 | nothing                                      |

10. **Skill directory.** `.agents/skills/onboard-repository/` is committed as it is when it differs from the base
    (untracked or modified) and counts as a change. Never offer the template's copy of it: it would drop the metadata
    that the next run needs.

Show one overview: the number of files to copy with their directories, every file to ask about by name, and every file
reported as removed here. If nothing is to be copied, asked about, deleted, or committed in the skill directory, go
straight to step 5: no branch, commit or PR.

## 2. Decide

Runs on Sonnet 5.5. Ask about one file at a time. Apply nothing yet.

- For each file to ask about, show `git diff <base>:<path> <T>:<path>` (the repository's version against the
  template's) and, with `B`, `git diff <B>:<path> <T>:<path>` (what the template changed). Offer keep, take and merge, or
  keep and delete for a file the template removed.
- Recommend merge for `AGENTS.md`, `.github/workflows/ci.yml` and `.github/ISSUE_TEMPLATE/config.yml`, because they mix
  generic content with the project's. Recommend take when `L` equals the template's version at `B`, because the
  repository never changed it. Otherwise recommend nothing.
- Keep means the file is not written and stays byte-identical. When the user keeps `.github/workflows/ci.yml`, warn
  that `setup-repository` and the `ci` ruleset expect a job named `ci`.
- Merge: build each result in its own directory `<tmp>/<path>/`, with `<tmp>` = `$(git rev-parse
  --git-dir)/onboard-repository-tmp` (create each `<tmp>/<path>` with `mkdir -p`), never in the working tree. Write the base's version
  `<base>:<path>` to `mine`.
  - With `B`: write `<B>:<path>` to `baseline` and `<T>:<path>` to `template`, then run `cd <tmp>/<path> && git
    merge-file -L mine -L baseline -L template mine baseline template`. It writes the result into `mine` and leaves
    conflict markers in place; its exit code is the number of conflicts, so 1 is not a failure. A path that is not in
    `<B>` (the template added it after `B`) has no `baseline`: skip the `<B>..<T>` diff and merge as without `B`.
  - Without `B`: add the template's sections that are missing to `mine` and keep every line of the base's version;
    where a heading exists in both, keep the base's and add the template's content below it.

  Either way, show the diff of `mine` against the base's version. The user edits `mine` by hand until they confirm it.
  Keep it there: step 3 writes `<tmp>/<path>/mine` to `<path>` and removes `<tmp>`.
- A decision the user declines to make counts as keep.

## 3. Branch and commit

Runs on Sonnet 5.5. Skip this step when nothing is to be copied, taken, merged, deleted or committed in the skill
directory.

- Never commit on `<default-branch>`; it is read-only.
- Reuse `chore/adopt-template` when the user agreed in step 1 (`git switch chore/adopt-template`); otherwise
  `git switch -c chore/adopt-template --no-track origin/<default-branch>`. The untracked skill directory comes along. If
  git refuses (for example because the branch already tracks that directory, or local changes would be overwritten),
  stop and tell the user why. For a new branch, they run the skill again from an up-to-date checkout of
  `<default-branch>`; for a reused one, they switch to it first (git refuses while the skill directory is untracked and the branch has
  it committed: remove the untracked copy and run the skill from the branch).
- Copy and take with `git checkout <T> -- <path>`, delete with `git rm`, write each confirmed merge result `<tmp>/<path>/mine`
  to `<path>`, and stage merged files and the skill directory with `git add`. Check that no merged
  file still contains conflict markers, then remove the temporary directory.
- Commit once with the `.agents/skills/git-commit` skill, which exists once the files are copied: type `chore`, for example `chore: adopt template files`
  (`chore: update template files` on a re-run), a body that lists what was copied, taken, merged and deleted, and the
  footer `Template-Commit: <T>`. It is one logical change, adopting template commit `T`, and the trailer must be on
  exactly that commit. Put it in the same final trailer block as any `Co-authored-by` line, with no blank line
  between them: otherwise git does not read it as a trailer and the baseline lookup in step 1.7 finds nothing.

## 4. Hand over to setup-repository

Runs on Sonnet 5.5. Load the `setup-repository` skill and follow it from its step 1 on the current branch. It reuses
`chore/adopt-template`, adds its changes to the same branch, and does the review, the PR and the merge with the
`finish-work` skill, so onboarding and Setup end in one PR.

## 5. Final report

Runs on Sonnet 5.5, only when step 4 did not run (nothing to change). Report that the repository is up to date with
`T`, list the files the user kept in this run, and tell the user that `setup-repository` can still be run on its own. When step 4
ran, `setup-repository` writes the final report.
