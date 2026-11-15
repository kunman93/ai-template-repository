# Design

## Context

- `write-spec` merges `openspec/changes/<change-name>/` unarchived into the default branch, with `Story: #<n>` under
  the title of `proposal.md`. Its PR uses `Refs #<n>`, so the Story stays open.
- `implement-story` runs research, plan and approve plan (steps 3–5) before it implements. On a merged spec those steps
  are already done and approved.
- `finish-work` Finalize history sub-step 4 archives only a change the branch adds (`--diff-filter=A`), and skips for
  `write-spec`. On an `implement-spec` branch the change already exists on the default branch, so the diff never lists
  it as added. At most its `tasks.md` shows up as modified.
- The closed PR #46 drafted `implement-spec` and a per-workflow archive rule in `finish-work`. This change takes both
  over and adds what Story #48 asks beyond the draft. See `proposal.md` for the motivation.

## Goals / Non-Goals

**Goals:**

- `implement-spec` reads like `implement-story` and `write-spec`: numbered steps, a model named per step and the
  approval gates kept in the skill.
- `finish-work` stays the only place that knows how to create, finalize, archive and merge.

**Non-Goals:**

- Changes to the steps of `implement-story` or `write-spec`, the reviewer agent, the PR template or `check-commits.sh`.
- Resuming an existing `feature/<change-name>` branch. The skill asks the user instead (decision 3).
- Removing an obsolete merged change on the changed-Story path. The user decides, for example with `do-chore`.

## Decisions

### 1. Steps of `implement-spec`

| Step | Name | Model |
|------|------|-------|
| 0 | Check workflow setup: change named, merged and unarchived, Story read, model and agent | Sonnet 5.5 |
| 1 | Create feature branch | Sonnet 5.5 |
| 2 | Verify clean state | Sonnet 5.5 |
| 3 | Implement (a revision of the change runs on Opus 5.5) | Sonnet 5.5 |
| 4 | Review | Sonnet 5.5, `reviewer` on Opus 5.5 |
| 5 | Create PR | Sonnet 5.5 |
| 6 | Archive | Sonnet 5.5 |
| 7 | Merge | Sonnet 5.5 |

- No research, plan or approve plan step: the spec was approved and merged by `write-spec`.
- Steps 3–7 follow steps 6–10 of `implement-story`, so the skill points to `finish-work` for Create PR, Archive,
  Finalize history and Merge, and does not repeat them.
- The `reviewer` gets the change name and the Story in its prompt, because the change's artifacts are on the default
  branch, not in the branch diff. No new reviewer mode is needed.

### 2. Merged and unarchived means `proposal.md` on `origin/<default-branch>`

After `git fetch origin <default-branch>`, the skill runs
`git cat-file -e origin/<default-branch>:openspec/changes/<change-name>/proposal.md`.

- An archived change lives under `openspec/changes/archive/<date>-<change-name>/`, so it fails this check without a
  separate rule.
- The working tree and local branches are not consulted: an unmerged `docs/` branch must not pass.
- The change name must be kebab-case without `/`. Otherwise the skill asks for a plain change name and stops: a path
  such as `archive/<date>-<change-name>` would pass the check above.
- The Story comes from the `Story: #<n>` line of the same file on `origin/<default-branch>`
  (`git show origin/<default-branch>:openspec/changes/<change-name>/proposal.md`). If it is missing, the skill asks for
  the Story number. A spec merged before `write-spec` existed may lack the line.

### 3. An existing `feature/<change-name>` stops the skill

Before creating the branch, the skill checks it locally (`git show-ref --verify refs/heads/feature/<change-name>`) and
on origin (`git ls-remote --exit-code --heads origin feature/<change-name>`), as `write-spec` does for its docs branch.
If either exists, it tells the user, asks what to do and creates no branch.

- Alternative: offer to resume on the existing branch. Rejected by the user: the simplest rule, and the user knows
  whether the branch is a second run or an abandoned attempt.

### 4. A wrong spec: incomplete or changed

Step 3 keeps the "stop and tell the user" rule of `implement-story`, but the changed-Story path cannot restart
research and plan on the same branch: the spec is already merged.

- Artifact wrong, Story right: revise with `openspec-update-change` on Opus 5.5, commit, get approval, resume on Sonnet
  5.5.
- Story wrong: the agent says whether it thinks the Story is incomplete (goal and every existing criterion hold,
  criteria are only added or sharpened) or changed (anything else), with a one-sentence reason, and proposes changed
  when unsure. The user decides and corrects the Story issue.
  - Incomplete: the same path as an artifact that is wrong.
  - Changed: the agent asks what to do with the merged change, the branch and the work already committed, and
    recommends removing the obsolete change from the default branch with `do-chore`. It tells the user to write a new
    spec with `write-spec` under a new change name. It deletes no branch and opens no PR itself.
- Alternative: amend the merged change in place for a changed Story. Rejected: `openspec-update-change` does not change
  a change's intent, and the approved spec on the default branch would silently stop matching its PR.

### 5. `finish-work` archives per workflow

Finalize history sub-step 4 becomes a per-workflow rule, as drafted on PR #46:

- `implement-spec`: archive the change the workflow names if `openspec/changes/<change-name>/` exists on the branch.
  If it does not, skip only if `openspec/changes/archive/<date>-<change-name>/` (`<date>` is `YYYY-MM-DD`) exists on
  the branch: an earlier run archived it. The date prefix keeps a change whose name only ends the same way from
  matching. If neither exists (for example, the change was removed on the default branch), tell the user and archive
  nothing.
- `implement-story`: the existing `--diff-filter=A` check, unchanged.
- `write-spec`, `fix-bug`, `do-chore` and `setup-repository`: never archive.

The workflow in use is explicit in every call of `finish-work`, so no detection by branch name is needed. The intro of
Finalize history, the skill's description and intro name `implement-spec` with the other workflows.

### 6. Routing and skill descriptions

- `AGENTS.md` Implementation Workflow: a Story goes to `write-spec`, and its merged spec to `implement-spec`. A Story
  goes to `implement-story` only when the user asks for it or for the spec and code in one PR.
- An explicit request for `implement-story` (or the spec and code in one PR), for the spec of a Story or for
  `write-spec` is routed before the lookup below. Otherwise a spec the user rejected on the changed-Story path
  (decision 4), still unarchived on the default branch, would be implemented instead of written anew.
- To tell the two apart for any other Story request, `AGENTS.md` fetches the default branch and looks for an
  unarchived change that names the
  Story: `git grep -l "^Story: #<n>$" origin/<default-branch> -- 'openspec/changes/*/proposal.md' ':!openspec/changes/archive'`.
  - One match: `implement-spec` with that change.
  - No match: `write-spec`.
  - Several matches: ask the user.
  - Alternative: the check as a first step of `write-spec`. Rejected: it changes the steps of `write-spec`, and the
    routing stays in one place.
- The `description` of `write-spec` triggers on writing the spec of a Story, and on working on, starting or picking
  up a Story without a merged, unarchived spec, as the default. The
  `description` of `implement-story` triggers only on an explicit request for it or for one PR. Without this, skill
  auto-selection would keep routing Stories to `implement-story`. The steps of both skills stay unchanged.
- `README.md`: the Story skills, the users of `finish-work` and the workflow overview name `implement-spec` and the
  default order.

## Risks / Trade-offs

- [The merged spec is stale because later changes touched the same code or specs] → Step 3 sends it to the user as a
  wrong spec. Archive conflicts in synced specs surface in Finalize history, whose conflict rules apply.
- [Two runs implement the same change at once] → The existing-branch check stops a second run only once the first
  branch exists locally or on origin. Two runs in separate clones that both start before either pushes still
  duplicate work. Accepted: maintainers coordinate, for example by assigning the Story.
- [An `implement-spec` PR merges without archiving, so the change stays unarchived and could be implemented again] →
  The per-workflow archive rule archives by name in Finalize history, which runs before every merge.
- [An older archived change of the same name, such as `2025-03-01-add-foo`, makes Finalize history skip silently when
  the current `add-foo` was removed from the default branch] → Accepted as rare. The branch ticked `add-foo/tasks.md`,
  so the rebase in Finalize history stops on a modify/delete conflict. As a non-trivial conflict it goes to the user,
  and the Review step runs again.
- [After a changed Story, the rejected change stays unarchived on the default branch until it is removed, so a plain
  request to work on the Story routes to it] → Decision 4 recommends removing it with `do-chore`, and an explicit
  request for `write-spec` is routed before the lookup.
- [Changing `implement-story`'s description changes how existing users reach it] → An explicit `/implement-story`
  still works. Only implicit selection changes, which is the point of the Story.
