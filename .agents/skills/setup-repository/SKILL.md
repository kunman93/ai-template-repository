---
name: setup-repository
description: 'Apply the project-specific Setup of a repository that adopted this template: default branch, Commands, ci job steps, security advisory link, stack skills and the ci ruleset. Asks before every change, keeps values that are already set, and can be run again. Use when the user asks to set up, configure or finish adopting the template in a repository.'
---

# Set Up a Repository

Fills in the template placeholders of a repository whose template files, including `.agents/skills/`, are already in
place. To get the files, use the `onboard-repository` skill (or the manual steps in "Adopting the template" in
`README.md`). Changes go through a `chore/` branch and a
reviewed PR. The skill only fills in placeholders and leaves every other value as it is.

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

- `gh repo view --json nameWithOwner,defaultBranchRef,viewerPermission`: the default branch, the repository and the
  user's permission.
- The values in `AGENTS.md` (Repository and Commands sections), `.github/workflows/ci.yml` (both `branches` filters and
  the steps of the `ci` job) and `.github/ISSUE_TEMPLATE/config.yml` (security advisory URL).
- The manifests in the repository root (for example `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`,
  `pom.xml`, `build.gradle`, `Makefile`).
- The workflows under `.github/workflows/` other than `ci.yml` and `update-skills.yml` (the template's own, guarded to
  run only in the template repository), with their triggers and job names.
- The skills under `.agents/skills/` that are not template skills and whose name does not appear in `AGENTS.md`.
  Template skills are the ones on the `template` remote (when it exists), otherwise `write-story`,
  `implement-story`, `write-bug-report`, `fix-bug`, `do-chore`, `onboard-repository`, `setup-repository`, `finish-work`
  and `git-commit`.
- The effective rules on the default branch: `gh api repos/{owner}/{repo}/rules/branches/<default-branch>`. If GitHub
  refuses it (for example on a private repository without a paid plan), the ruleset step is "cannot do" with GitHub's
  message, and the ruleset is not offered.

Classify each Setup step. A value is a placeholder only if it is the template's value:

| Setup step     | Placeholder                                                      |
|----------------|------------------------------------------------------------------|
| Default branch | `main` in `AGENTS.md` and in both `ci.yml` filters               |
| Commands       | `_not configured_`, per command                                  |
| `ci` steps     | the single `echo "No checks configured yet. ..."` step           |
| Security link  | an advisory URL whose `owner/repo` is not the current repository |
| Ruleset        | no effective `required_status_checks` rule with context `ci`     |

- A missing Repository or Commands section in `AGENTS.md` counts as unset.
- Anything else counts as set.
- Default branch: compare the values that exist among the locations (the Repository section of `AGENTS.md` and the
  `ci.yml` filters; a missing section or filter is left out of the comparison) with each other and with GitHub.
  - All hold `main` and GitHub's default branch differs: placeholders.
  - All hold the same value, equal to GitHub's: already set.
  - `AGENTS.md` holds `main`, `ci.yml` has at least one filter, and every `ci.yml` filter holds GitHub's default
    branch, which is not `main`: `AGENTS.md` is a placeholder and `ci.yml` is already set.
  - Otherwise (the values disagree, or all hold another value than GitHub's): change none of them and report every
    location as a mismatch, so the skill never makes `AGENTS.md` and `ci.yml` name different branches.
- A `ci.yml` the maintainer kept from their own repository is never rewritten.

Show one overview with every Setup step (default branch, Commands, `ci` steps, security link, stack skills, ruleset)
marked "to change", "already set", "mismatch" or "cannot do", with the reason.

## 2. Decide the changes

Runs on Sonnet 5.5. Ask about each change one at a time, showing the current and the proposed value. Apply a change
only after the user confirms it. A declined change stays unchanged and is reported as not done.

- **Default branch:** propose the branch from GitHub for each of the Repository section of `AGENTS.md` and both
  `ci.yml` filters that is a placeholder (only `AGENTS.md` when `ci.yml` is already set), and remove the `TODO`
  comments on the filters it changes. When the section is
  missing, offer to add it with the template's wording, naming GitHub's default branch, and leave the rest of the file
  unchanged (append the section at the end when the file has no matching place).
- **Commands:** propose each unset command only from what a manifest defines or what its tool standardizes. When there
  is no recognized manifest or a command is unclear, ask the user; never invent one. Run each confirmed command once
  and show any failure before writing it. When the Commands section is missing, offer to add it with the template's
  wording.
- **Existing workflows:** before proposing `ci` steps, show each other workflow with its triggers and job names, and
  ask how `ci` relates to it:
  - `ci` runs it: the `ci` job calls it with `uses: ./.github/workflows/<file>`. This needs a `workflow_call` trigger,
    which you add only after confirming it; the user decides whether its own triggers stay.
  - Side by side: `ci` gets steps from the Commands and the workflow stays unchanged; warn that the same checks then
    run twice.
  - Leave it: the `ci` steps stay as they are; report the step as not done.

  Never offer to rename a job of another workflow to `ci`.
- **`ci` steps:** derive them from the confirmed Commands (checkout, toolchain setup, then the commands) and keep the
  job name `ci`.
- **Security link:** propose the advisory URL of the current repository when the link points elsewhere.
- **Stack skills:** offer to reference each unreferenced non-template skill from `AGENTS.md`, never changing its
  files. Then ask which stack skills to add; suggest none of your own. Install each named skill with
  `gh skill install <source> --dir .agents/skills` when given a GitHub source, or copy it from a path the user gives,
  and reference it in `AGENTS.md` next to the sentence about stack skills in Engineering Principles, or at the end of
  the file's list of skills or instructions when it has no such sentence.
- **Ruleset:** decided here, created in step 7. Offer it only when all of these hold; otherwise report it as not done
  with the reason:
  - `viewerPermission` is `ADMIN`.
  - `ci.yml` has a job named `ci` whose `pull_request` trigger covers `<default-branch>`, because requiring a check
    that never runs keeps every PR pending.
  - No effective rule already requires `ci` (then it is already set).

## 3. Branch and commit

Runs on Sonnet 5.5. Skip this step when no file change was confirmed.

- Never commit on `<default-branch>`; it is read-only.
- On `chore/adopt-template`, commit there, so onboarding and Setup end in one PR. On another `chore/` branch, ask
  whether to reuse it; if the user declines, treat it like any other branch. On any other branch, including
  `<default-branch>`, fetch it and create `chore/setup-repository` from `origin/<default-branch>`; if that branch
  already exists, ask whether to reuse it, otherwise stop and report.
- Check that `AGENTS.md`, `.github/workflows/ci.yml` and `.github/ISSUE_TEMPLATE/config.yml` exist on the branch. If
  not, the template files are not committed there: stop and tell the user to run the `onboard-repository` skill, or to
  put the manual onboarding on a `chore/adopt-template` branch (see "Adopting the template" in `README.md`).
- Make the confirmed changes and commit them with the `.agents/skills/git-commit` skill, one logical change per commit.
- Check that `ci.yml` is still valid YAML with a job named `ci`.

## 4. Check for a PR

Runs on Sonnet 5.5. If the current branch has no commits that are not on `<default-branch>`, there is nothing to
review or merge: skip steps 5 and 6 and continue with step 7.

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
`<default-branch>` cannot block the Setup PR. Skip it unless the user confirmed it in step 2. If the PR is not merged,
report the step as not done for that reason (a reason found in step 1 or 2 is reported as well).

Create it with `gh api -X POST repos/{owner}/{repo}/rulesets`: target `branch`, enforcement `active`, ref condition
`~DEFAULT_BRANCH`, one `required_status_checks` rule for the context `ci`. Never change an existing ruleset. If GitHub
refuses (for example rulesets on a private repository without a paid plan), report the step as not done with GitHub's
message.

## 8. Final report

Runs on Sonnet 5.5. Report every Setup step as done, already set, or not done with the reason, and remind the user
to describe the project in `README.md`. When nothing changed, only report: no branch, commit or PR.
