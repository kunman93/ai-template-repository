# Tasks

## 1. Remove the app and its stack

- [x] 1.1 Delete `src/`, `public/`, `index.html`, `features/`, `scripts/`, `package.json`, `package-lock.json`,
  `eslint.config.js`, `vite.config.ts`, `tsconfig.json`, `tsconfig.app.json`, `tsconfig.node.json`,
  `playwright.config.ts`, `.prettierrc.json` and `.prettierignore`; verify `git ls-files` lists none of them
- [x] 1.2 Reduce `.gitignore` to stack-agnostic entries (logs, `.env`, `.env.*`, `*.local`, editor and OS files); verify
  it has no Node, build-output or local-wishes entries
- [x] 1.3 Replace the steps of the `ci` job in `.github/workflows/ci.yml` with one `run` step that prints that no checks
  are configured yet, keeping the job name, triggers, permissions and concurrency; verify the job is still named `ci`
  and the file has no `npm`, `node` or `playwright`
- [x] 1.4 Turn the Commands section of `AGENTS.md` into the placeholder from design.md (Install, Build, Test,
  Lint/format marked as not configured, plus the "say so instead of running it" rule); verify no npm command remains
  in `AGENTS.md`
- [x] 1.5 Point the verification check of `.github/agents/reviewer.agent.md` at the Commands section of `AGENTS.md`
  and change "a new npm script" to "a new script"; verify the agent file has no `npm`

## 2. Remove the stack-specific skills and agent

- [x] 2.1 Delete `.agents/skills/gsap-*`, `.agents/skills/threejs`, `.agents/skills/react-ui` and
  `.github/agents/react-developer.agent.md`; verify `git ls-files` lists none of them
- [x] 2.2 Remove the `react-developer` frontend-work bullet from `implement-story`, `fix-bug` and `do-chore`; verify
  no file under `.agents/skills/` mentions `react-developer`, `react-ui`, `gsap` or `threejs`
- [x] 2.3 In `AGENTS.md`, keep only the `reviewer` emoji line, drop the Playwright `--repeat-each` hint and point
  language- and framework-specific readings at skills an adopter adds; verify `AGENTS.md` has no `react` or
  `playwright`
- [x] 2.4 Cut `.agents/skills/VENDORED.md` down to the "copied unchanged, do not edit" rule, noting that a vendored skill
  records its source in its own frontmatter; verify it has no `gsap`

## 3. Remove the OpenSpec history

- [x] 3.1 Delete `openspec/changes/archive/`; verify `openspec list --json` shows only this change and
  `openspec validate --all` passes

## 4. Document the template

- [x] 4.1 Point the security advisory link in `.github/ISSUE_TEMPLATE/config.yml` at
  kunman93/ai-template-repository; verify the URL
- [x] 4.2 Rewrite `README.md` as the template description from design.md: what is included, prerequisites (GitHub
  Copilot CLI, `gh`, OpenSpec CLI) and adoption steps (create from template, fill in Commands, add stack steps to `ci`
  without renaming it, require `ci` in the branch ruleset, update the security link, add stack-specific skills) and
  how to keep the template up to date and sync a project with it;
  verify every path and command it names exists or is marked as one the adopter adds
- [x] 4.3 Replace the browsers dropdown in `.github/ISSUE_TEMPLATE/bug_report.yml` with a generic Environment field and
  update the `write-bug-report` example; verify the field labels in the form and the example match and neither
  mentions browsers

## 5. Integration checks

- [x] 5.1 Run the search from design.md (`git grep -n -i -E 'age-of-majority|birthday|families|react|cloudflare'`
  excluding this change's folder and, before archive, `openspec/specs/`); verify it returns nothing
- [x] 5.2 Search the kept files for `npm|node|vite|vitest|playwright|eslint|prettier|tailwind|typescript|gsap|three`;
  verify every hit is unrelated wording
- [x] 5.3 Delete the untracked local build output (`node_modules/`, `dist/`, `test-results/`, `.features-gen/`); verify
  `git status --short --ignored` lists none of them

## Workflow follow-up

- The PR's `ci` run must pass with the echo step (covers the `ci-check` pull request and no-stack scenarios).
- Archiving this change retires the ten card capabilities and creates the `ci-check` spec; verify
  `openspec list --specs` then shows only `ci-check`.
- After archive, run the criterion search from design.md without the `openspec/specs/` exclusion; verify it returns
  nothing.
- After merge, confirm `ci` ran on the push to `main`.
