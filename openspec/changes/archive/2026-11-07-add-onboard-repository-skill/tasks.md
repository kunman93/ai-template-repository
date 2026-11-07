# Tasks

## 1. Skill

- [x] 1.1 Create `.agents/skills/onboard-repository/SKILL.md` with frontmatter (`name`, a `description` that says when to
  use it) and step 0 (model and default agent check, Sonnet 5.5; `gh` signed in), matching the structure of
  `setup-repository`; verify `gh skill install kunman93/ai-template-repository onboard-repository@<feature-branch-sha>
  --allow-hidden-dirs --dir .agents/skills` in an empty temp repository installs it with `metadata.github-repo` and
  `github-ref`, and record the exact hidden-directory warning `gh` prints and the `github-ref` a SHA pin produces
- [x] 1.2 Write the gather step as in design.md: clean-tree check ignoring `.agents/skills/onboard-repository/`, metadata
  read (stop without it), `template` remote (ask on another URL), fetch and resolve `T`, default branch, base
  (`chore/adopt-template` reuse question or `origin/<default-branch>`), `Template-Commit` baseline `B`, and the file
  set from the README path list minus the skill's own directory; verify against the "Dirty working tree", "Freshly
  installed skill", "Installed from a fork", "Copy without metadata" and "Branch already exists" scenarios
- [x] 1.3 Write the classification and decision step with the table in design.md (copy, ask keep/take/merge, keep or
  delete, nothing), one overview before any change, merge recommended for `AGENTS.md`, `ci.yml` and
  `ISSUE_TEMPLATE/config.yml`, merge prepared with `git merge-file` when `B` exists and by editing otherwise, and
  finished by the maintainer; verify against the "A file already exists", "Files that mix generic and project
  content", "Other files are untouched", "Copy step scope", "Second run without template changes" and "Run after a
  template change" scenarios
- [x] 1.4 Write the branch, commit and hand-over steps: create or switch to `chore/adopt-template` only when a file
  changes, never commit on `<default-branch>`, one commit with the `git-commit` skill ending in
  `Template-Commit: <T>`, then load `setup-repository`; with nothing to change only report; verify against the
  "Repository on master", "Onboarding committed" and "Nothing to change" scenarios
- [x] 1.5 Check that `SKILL.md` names the default branch only as `<default-branch>`; verify
  `git grep -nwE "main|master" -- .agents/skills/onboard-repository` shows no branch use

## 2. Documentation and references

- [x] 2.1 Rewrite the existing-repository path of "Adopting the template" in `README.md`: install command, the
  hidden-directory warning recorded in 1.1 with why it is expected, run `onboard-repository` (it runs `setup-repository`),
  and how to pull later template changes; keep the current git steps unchanged as a "Manual onboarding" fallback;
  verify against the "Two adoption paths", "Existing repository with the skill", "Manual Setup" and "No more work than
  a new repository" scenarios
- [x] 2.2 Add `onboard-repository` to "What is included" in `README.md` and to the Implementation Workflow of `AGENTS.md`;
  in `setup-repository/SKILL.md` point to `onboard-repository` instead of the README steps and add it to the template
  skills of the Gather step; verify with `git grep -n "Adopting the template\|onboard-repository"` that every reference
  is consistent
- [x] 2.3 Run `openspec validate add-onboard-repository-skill --strict`; verify it passes

## 3. Verification in git-sandbox

Scenarios run one at a time, each in a fresh `general-purpose` subagent with scripted maintainer answers and a fresh
clone of `kunman93/git-sandbox` in the session workspace. Each commits its project state on `scenario-<n>` from
`master`, makes it the default branch on GitHub, installs the skill pinned to this feature branch's SHA and runs it.
After every scenario, whatever the outcome, the default branch is switched back to `master`.

- [x] 3.1 Scenario 7, dirty working tree (scenario 1 state plus an uncommitted edit to `README.md`); verify the skill
  stops and no branch, remote, file or commit was created
- [x] 3.2 Scenario 1, bare repository (run as the first run of scenario 6); verify every template file is copied, `.gitignore` is asked about, the commit has
  the `Template-Commit` trailer, `setup-repository` runs on `chore/adopt-template` and `ci` runs on the one PR
- [x] 3.3 Scenario 2, React (Vite, npm), no CI; verify no file is asked about, Commands and `ci` come from
  `package.json`, `ci` passes on the PR, then merge that PR into `scenario-2` only
- [x] 3.4 Scenario 3, Spring Boot (Maven wrapper) with `build.yml`; verify `build.yml` is byte-identical to the
  scenario base
- [x] 3.5 Scenario 4, Spring Boot (Gradle wrapper) with own `AGENTS.md`, `ci.yml` (job `build`) and
  `.agents/skills/sandbox-style`; verify keep/take/merge is offered for `AGENTS.md` and `ci.yml` with merge proposed,
  and the kept files are byte-identical to the scenario base
- [x] 3.6 Scenario 5, second run on `scenario-2` after 3.3; verify nothing is offered and no branch, commit or PR is
  created
- [x] 3.7 Scenario 6, after its own first run is merged into `scenario-6`, push one template change to a throwaway
  branch of this repository, reinstall the skill from it with `--force` and run; verify only the changed file is offered and the new commit records the new
  `Template-Commit`; delete the throwaway branch
- [x] 3.8 Close every sandbox PR unmerged (except those merged into a scenario branch), delete all scenario branches,
  confirm the default branch is `master` and `git rev-parse origin/master` is unchanged from before 3.1
- [x] 3.9 Record every scenario result in a scenario table in this PR's description, and list the scenarios checked by
  review only (design.md)

## Workflow follow-up

- Archive the change after the maintainer approves the PR (`implement-story` step 9).
