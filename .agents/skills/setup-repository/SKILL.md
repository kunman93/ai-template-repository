---
name: setup-repository
description: 'Apply the project-specific Setup of a repository created from this template: default branch, Commands, ci job steps, security advisory link, stack skills and the ci ruleset. Asks before every change, keeps values that are already set, and can be run again. Use when the user asks to set up or configure a repository created from the template.'
---

# Set Up a Repository

Fills in the placeholders of a repository created from the template. Changes go through the `chore/setup-repository`
branch and a reviewed PR. The skill only fills in placeholders and leaves every other value as it is.

The whole workflow runs on Sonnet 5.5 in the main session. Step 5 runs the `reviewer` subagent, which is pinned to Opus 5.5 in its agent file.

## 0. Check workflow setup

- Before starting a step, check the main session model reported in your environment information against the model named in the step.
- If it does not match, or if you cannot tell, tell the user which model to pick with `/model` and stop.
- Also check that the main session runs the default agent, not a custom agent. If it does not, or if you cannot tell, tell the user to switch with `/agent` and stop.
- The check covers the main session only; subagent models are set by their agent file or the `model` argument.
- The skill needs `git` and `gh`, plus the project's own tools to run its Commands. If `gh` is not signed in, tell the user and stop.

## 1. Gather

Runs on Sonnet 5.5. Read only; change nothing. If `git status` shows uncommitted changes, tell the user to commit or
stash them and stop.

1. `gh repo view --json nameWithOwner,defaultBranchRef,viewerPermission`: the default branch (called `<gh-default>`
   here), the repository and the user's permission. Then `git fetch origin <gh-default>`. When the fetch fails, report
   the fetch error, change nothing and stop.
2. Check the branch, so the working tree is the tree the skill commits from:
   - On `chore/setup-repository`: continue.
   - On `<gh-default>` with `HEAD` equal to `origin/<gh-default>`: continue, unless `chore/setup-repository` exists
     locally or on `origin` (`git ls-remote --heads origin chore/setup-repository`). Then stop and tell the user to
     switch to it or delete it.
   - On `<gh-default>` behind `origin`: stop and tell the user to fast-forward it from `origin`.
   - On `<gh-default>` ahead of or diverged from `origin`: stop and tell the user to move the local commits to another
     branch and reset `<gh-default>` to `origin/<gh-default>`. Never suggest pushing to the default branch.
   - On any other branch: stop and tell the user to switch to `<gh-default>` or to `chore/setup-repository`.
3. Check that `AGENTS.md` (with its Repository and Commands sections), `.github/workflows/ci.yml` and
   `.github/ISSUE_TEMPLATE/config.yml` exist. When one is missing, change nothing and tell the user that the
   repository was not created from the template. Never add a missing file or section.
4. Read:
   - The values in `AGENTS.md` (Repository and Commands sections), `.github/workflows/ci.yml` (both `branches`
     filters and the steps of the `ci` job) and `.github/ISSUE_TEMPLATE/config.yml` (security advisory URL).
   - The manifests in the repository root (for example `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`,
     `pom.xml`, `build.gradle`, `Makefile`).
   - The effective rules on the default branch: `gh api repos/{owner}/{repo}/rules/branches/<gh-default>`. If GitHub
     refuses it (for example on a private repository without a paid plan), the ruleset step is "cannot do" with
     GitHub's message, and the ruleset is not offered.

Classify each Setup step. A value is a placeholder only if it is the template's value:

| Setup step     | Placeholder                                                      |
|----------------|------------------------------------------------------------------|
| Default branch | `main` in `AGENTS.md` and in both `ci.yml` filters               |
| Commands       | `_not configured_`, per command                                  |
| `ci` steps     | the single `echo "No checks configured yet. ..."` step           |
| Security link  | an advisory URL whose `owner/repo` is not the current repository |
| Ruleset        | no effective `required_status_checks` rule with context `ci`     |

- Anything else counts as set.
- Default branch: the Repository section of `AGENTS.md` and both `ci.yml` filters are one value.

  | The three places                            | Outcome                                       |
  |---------------------------------------------|-----------------------------------------------|
  | all `main`, and `<gh-default>` differs      | to change: propose `<gh-default>`             |
  | all name `<gh-default>`                     | already set                                   |
  | anything else                               | not done: list each place and its value       |

Show one overview with every Setup step (default branch, Commands, `ci` steps, security link, stack skills, ruleset)
marked "to change", "already set", "not done" or "cannot do", with the reason.

## 2. Decide the changes

Runs on Sonnet 5.5. Ask about each change one at a time, showing the current and the proposed value. Apply a change
only after the user confirms it. A declined change stays unchanged and is reported as not done.

- **Default branch:** propose `<gh-default>` for the Repository section of `AGENTS.md` and both `ci.yml` filters as one
  change, confirmed or declined as a whole, and remove the `TODO` comments on the filters. When this step ends not
  done (the places disagree or the user declined), stop before any other Setup step and go to step 8: report every
  other step as not done because the default branch is unsettled.
- **Commands:** propose each unset command only from what a manifest defines or what its tool standardizes. When there
  is no recognized manifest or a command is unclear, ask the user; never invent one. Run each confirmed command once
  and show any failure before writing it.
- **`ci` steps:** derive them from the confirmed Commands (checkout, toolchain setup, then the commands) and keep the
  job name `ci`.
- **Security link:** propose the advisory URL of the current repository when the link points elsewhere.
- **Stack skills:** ask which stack skills to add; suggest none of your own. Install each named skill with
  `gh skill install <source> --dir .agents/skills` when given a GitHub source, or copy it from a path the user gives,
  and reference it in `AGENTS.md` next to the sentence about stack skills in Engineering Principles, or at the end of
  the file's list of skills or instructions when it has no such sentence. Never change a skill that is already under
  `.agents/skills/`: report a named skill whose directory already exists as already set and do not reinstall it. When
  the user names none, report the step as not done.
- **Ruleset:** decided here, created in step 7. Offer it only when all of these hold; otherwise report it as not done
  with the reason:
  - `viewerPermission` is `ADMIN`.
  - `ci.yml`, as it will be after a confirmed default-branch change, has a job named `ci` whose `pull_request` trigger
    covers `<gh-default>`, because requiring a check that never runs keeps every PR pending.
  - No effective rule already requires `ci` (then it is already set).

## 3. Branch and commit

Runs on Sonnet 5.5. Skip this step when no file change was confirmed.

- Never commit on the default branch; it is read-only.
- On `chore/setup-repository`, commit there. On `<gh-default>`, create `chore/setup-repository` from
  `origin/<gh-default>`.
- Make the confirmed changes and commit them with the `.agents/skills/git-commit` skill, one logical change per commit.
- Check that `ci.yml` is still valid YAML with a job named `ci`.

## 4. Check for a PR

Runs on Sonnet 5.5. If `chore/setup-repository` does not exist or has no commits that are not on
`origin/<gh-default>`, there is nothing to review or merge: skip steps 5 and 6 and continue with step 7.

## 5. Review

Runs on Sonnet 5.5. Have the custom `reviewer` subagent
([.github/agents/reviewer.agent.md](../../../.github/agents/reviewer.agent.md)), pinned to Opus 5.5, review the
branch; start it automatically. If there are any MAJOR findings, fix them with fixup commits (step 3) and run the
review again until there are none.

## 6. PR and merge

Runs on Sonnet 5.5.

- Clean up the history, have the `reviewer` subagent review the cleaned-up commits, push the branch, create the PR, wait for `ci`, and handle CI failures and PR review findings
  with the `finish-work` skill (section "Create PR").
- Wait for the user's explicit approval of the PR in the conversation. Then finalize the history and merge with the
  `finish-work` skill (sections "Finalize history" and "Merge"). Never merge without the user's approval and a green
  `ci`.

## 7. Ruleset

Runs on Sonnet 5.5, after the merge of step 6, or right away when there was no PR, so a `ci` that does not run yet on
`<gh-default>` cannot block the Setup PR. Skip it unless the user confirmed it in step 2. If the PR is not merged,
report the step as not done for that reason (a reason found in step 1 or 2 is reported as well).

Create it with `gh api -X POST repos/{owner}/{repo}/rulesets`: target `branch`, enforcement `active`, ref condition
`~DEFAULT_BRANCH`, one `required_status_checks` rule for the context `ci`. Never change an existing ruleset. If GitHub
refuses (for example rulesets on a private repository without a paid plan), report the step as not done with GitHub's
message.

## 8. Final report

Runs on Sonnet 5.5. Report every Setup step as done, already set, or not done with the reason, and remind the user
to describe the project in `README.md`. When nothing changed, only report: no branch, commit or PR.
