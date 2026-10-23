# Design

## Context

See proposal.md for motivation. After this change no language toolchain remains, so the current verification commands
(`npm test`, `npm run test:bdd`, `npm run lint`, `npm run format:check`) disappear. The workflow skills
(`implement-story`, `fix-bug`, `do-chore`, `finish-work`) and the `reviewer` agent tell the agent to run "all commands
in the Commands section of `AGENTS.md`", and the branch ruleset on `main` requires the `ci` check.

## Goals / Non-Goals

**Goals:**

- Every kept file reads correctly for a repository of any stack.
- The required `ci` check keeps working without a stack.
- The removal is verifiable by commands, not by inspection alone.

**Non-Goals:**

- Adding a replacement toolchain, linter or test runner for the template itself (Markdown or YAML lint, link checks).
- Optional stack add-ons (for example a React skill pack). Those come later in their own Stories.
- Changing the OpenSpec-generated `.github/skills/openspec-*` and `.github/prompts/opsx-*`, or the workflow steps and
  model pinning in the skills.

## Decisions

### Retire the card capabilities with REMOVED deltas

Each of the ten capabilities gets a delta that removes all its requirements, and `.openspec.yaml` sets
`retire_capabilities: true`, so `openspec archive` deletes their specs. Deleting `openspec/specs/*` by hand with
`skip_specs: true` was rejected: removing product behavior is a spec-level change, and the archive should record it.

The deltas name the removed requirements, so this change's own folder (active, and later archived) is the only place
allowed to mention the card. The search check excludes exactly that folder.

### Remove the whole OpenSpec archive

The archived workflow changes describe how this repository was built while it was the card, and several name its stack.
A template starts with an empty history; the source repository keeps the record. Agreed with the user in research.

### ci runs one echo step

`ci.yml` keeps the job name `ci`, its triggers, permissions and concurrency, and replaces all steps with a single `run`
step that prints that no checks are configured yet. No checkout, no toolchain. Alternatives: running `openspec validate`
or a Markdown linter would need Node and new dependencies, which the template is meant to avoid. Adopters replace the
step with their stack's build, test and lint steps.

### Commands section becomes a placeholder with an explicit rule

The `Commands` section in `AGENTS.md` keeps its four entries (Install, Build, Test, Lint/format), each marked as not
configured, plus one rule: until a command is filled in, the agent says so instead of running it. This keeps the
workflow skills unchanged ("run all commands in the Commands section") and makes the gap visible instead of silent.

### reviewer runs the Commands section

The `reviewer` agent's verification check refers to the Commands section of `AGENTS.md` instead of listing npm
commands, so one place defines the commands. Its "new npm script" example becomes "a new script".

### Smaller edits

- `implement-story`, `fix-bug`, `do-chore`: drop the bullet that hands frontend work to `react-developer`.
- `AGENTS.md`: keep only the `reviewer` emoji line, drop the Playwright `--repeat-each` hint and point
  "language- and framework-specific readings" at skills an adopter adds, not at `react-ui`.
- `.agents/skills/VENDORED.md`: keep the "copied unchanged, do not edit" rule and say that a vendored skill records its
  source in its own frontmatter. Drop the GSAP table, update steps and errata.
- `.github/ISSUE_TEMPLATE/config.yml`: point the security advisory link at kunman93/ai-template-repository. The README
  adoption steps tell adopters to change it. `feature_request.yml` and `story.yml` stay unchanged. `bug_report.yml`
  swaps its web-only browsers dropdown for a generic Environment field, and `write-bug-report` follows it.
- `.gitignore`: keep only stack-agnostic entries (logs, `.env`, `.env.*`, `*.local`, editor and OS files).
  `.editorconfig` stays.
- `README.md`: rewrite as a template description with what is included, prerequisites (GitHub Copilot CLI, `gh`,
  OpenSpec CLI) and adoption steps: create a repository from the template, fill in the Commands section, add stack
  steps to the `ci` job without renaming it, require `ci` in the branch ruleset, update the security link, and add
  stack-specific skills as needed. It also explains how to keep the template up to date (OpenSpec, vendored skills) and
  how to sync a project with it (copy paths, back-port with patches).

### Verification

There is no test runner, so the acceptance criteria are checked with commands, run in the Implement step and by the
reviewer:

- Search: `git grep -n -i -E 'age-of-majority|birthday|families|react|cloudflare' -- . ':!openspec/changes/strip-birthday-card-app' ':!openspec/changes/archive/*-strip-birthday-card-app/**'`
  returns nothing. Before archive, the retired card specs under `openspec/specs/` still match, so run it then with
  `':!openspec/specs'` added, and run it again without that exclusion after archive.
- Removed paths: `git ls-files` lists none of `src/`, `public/`, `features/`, `scripts/`, `package.json`, the stack
  config files, the removed skills or the `react-developer` agent.
- `openspec validate --all` passes, and `openspec validate --all --strict` passes after archive (before it, only the
  retired card specs have strict length warnings).
- `ci-check`: the PR's own `ci` run passes with the echo step, which covers the pull request scenario and the
  no-stack scenario. The push scenario is covered by the unchanged `push: branches: [main]` trigger and is seen
  after merge.

## Risks / Trade-offs

- [The workflow skills' "run all commands" steps do nothing useful until an adopter fills in the Commands section] →
  The placeholder rule makes the agent say so, and the README adoption steps put filling it in first.
- [`ci` passes without checking anything, so a template-derived repository can merge untested code] → The echo step
  says no checks are configured, and the README adoption steps require adding real steps.
- [Leftover stack wording that the search terms miss, such as npm, Vite or Playwright] → The Implement step also
  searches the kept files for `npm|node|vite|vitest|playwright|eslint|prettier|tailwind|typescript|gsap|three`, and
  every hit is either removed or is unrelated wording (for example "three things").
- [Untracked local build output (`node_modules/`, `dist/`, `test-results/`, `.features-gen/`) stays on disk once
  `.gitignore` no longer covers it] → Delete those directories locally as part of the change.
