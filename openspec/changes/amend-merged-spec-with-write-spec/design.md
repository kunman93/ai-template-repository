# Design

## Context

- `write-spec` creates a new change on `docs/<change-name>-spec` and rejects a name that already exists on
  `origin/<default-branch>`. It cannot touch a merged change.
- `implement-spec` step 0 already checks that a change is merged and unarchived
  (`git cat-file -e origin/<default-branch>:openspec/changes/<change-name>/proposal.md`), that its name is kebab-case
  without `/`, and reads the Story from `Story: #<n>`.
- `finish-work` already never archives for `write-spec`, uses `Refs` for a spec PR and treats a `write-spec` fixup as
  "the Implement step". The reviewer's spec review mode already flags any file outside the change.
- See `proposal.md` for the motivation.

## Goals / Non-Goals

**Goals:**

- One skill owns every spec PR: a new spec and an amendment share review, PR, finalize and merge.
- The amend mode differs from a new spec only where it must: input, checks, branch name and the planning skill.

**Non-Goals:**

- Any change to `implement-spec` (Story #51 pauses it for a spec fix and rebases).
- Changes to `finish-work`, the PR template or `check-commits.sh`.
- Amending an archived change, or a change that is only on an unmerged branch.

## Decisions

### 1. The mode follows the input

`write-spec` runs in amend mode when the user names a merged change to amend, and in new-spec mode when the user names a
Story.

- Alternative: detect amend mode when the Story's derived name already exists on the default branch. Rejected: a Story
  can need a second, separate change, and guessing which the user means is worse than asking for the change name.
- Alternative: a separate `amend-spec` skill. Rejected: it would copy steps 5–8 of `write-spec` almost word for word.

### 2. Steps in amend mode

| Step | New spec | Amend mode | Model |
|------|----------|------------|-------|
| 0 | Story given | Change given, name and merged-unarchived check as in `implement-spec`, Story from `Story: #<n>` (asked when missing), problem stated | Sonnet 5.5 |
| 1 | `docs/<change-name>-spec`, name unused | `docs/<change-name>-spec-fix`, branch unused | Sonnet 5.5 |
| 2 | Verify clean state | same | Sonnet 5.5 |
| 3 | Research the Story | Research the problem against the merged change and the Story | Opus 5.5 |
| 4 | `openspec-propose`, add `Story:` line | `openspec-update-change` on the existing change, keep `Story:` line or add the confirmed one, tick no task | Opus 5.5 |
| 5–8 | Approve, review, PR, finalize, merge | same; the reviewer prompt names the reported problem, and the PR names the amended change | Sonnet 5.5, `reviewer` on Opus 5.5 |

- The steps stay numbered once, with a short amend-mode line in each step that differs, so a reader sees both modes
  side by side.
- A wrong Story found in steps 3–6 leaves this table through decision 6.
- Step 0 copies the three checks of `implement-spec` instead of pointing to it, so `write-spec` does not depend on the
  wording of another skill. That is the second copy; DRY waits for a third.

### 3. Branch name `docs/<change-name>-spec-fix`

- The `docs/` prefix keeps the existing commit check (`Refs: #<n>`) and `finish-work` rules for issue branches.
- The suffix keeps it apart from the original `docs/<change-name>-spec`, which may still exist locally after its merge.
- An existing spec-fix branch means an earlier amendment is in flight or was not cleaned up. The skill asks the user
  instead of resuming it.

### 4. Spec review findings for ticked tasks and the reported problem

The reviewer's spec review mode reports any `- [x]` in the change's `tasks.md` as MAJOR. This covers both modes and
needs no check script, since only `implement-spec` and `implement-story` tick tasks, on feature branches.

When the caller names the problem a spec fix should solve, the reviewer also checks the amended artifacts against it and
reports it as MAJOR if it is still there. Naming the problem in the prompt alone would let an amendment that misses it
pass.

### 5. Routing

`AGENTS.md` gets one entry, above the `implement-spec` entry for a named merged spec: a request to amend or fix a merged
change that the user names goes to `write-spec` in amend mode. The branch-naming rule names
`docs/<change-name>-spec-fix`. The `write-spec` description adds the amend trigger. `implement-spec`'s description stays
unchanged (Non-Goal).

- A fix request that names only the Story is not routed to amend mode: as in decision 1, the user names the change.

### 6. A wrong Story is handled as in `implement-spec`

`openspec-update-change` does not change a change's intent, so amend mode cannot fix a Story whose intent changed.
`write-spec` reuses the incomplete/changed split of `implement-spec` step 3, so both skills treat a wrong Story alike.

- Incomplete continues the amendment, because adding or sharpening criteria is still a refinement.
- Changed ends the amendment: the user decides about the spec-fix branch and any open PR, and the agent recommends
  `do-chore` to remove the obsolete change and `write-spec` for a new one. The agent deletes and closes nothing.
- The split is copied, not shared: two copies, and DRY waits for a third.

## Risks / Trade-offs

- [`implement-spec` still revises the change on its feature branch until #51 lands, so a change can be amended in two
  places] → The amend mode is the only path that reaches the default branch before the code; #51 removes the other.
- [An amendment merges while an `implement-spec` branch for the same change is open] → Out of scope; #51 rebases that
  branch onto the amended spec.
