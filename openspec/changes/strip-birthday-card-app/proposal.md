# Proposal

## Why

This repository is meant to be the base for every future repository, in any language or framework. It still carries
the age-of-majority birthday-card app and its React stack, so every adopter has to remove them first. Stripping them
leaves only the stack-agnostic AI-assisted workflow: agents, skills, OpenSpec, issue forms, a CI skeleton and the git
conventions.

## What Changes

- **BREAKING** Remove the birthday-card app: `src/`, `public/`, `index.html`, `features/` (BDD features and steps),
  `scripts/` (Cloudflare deploy) and the git-ignored local wishes entry.
- **BREAKING** Remove the React/TypeScript/Vite/Tailwind/Vitest/Playwright stack: `package.json`, `package-lock.json`,
  ESLint, Vite, TypeScript, Playwright and Prettier config. Prettier only formatted the app's Node toolchain, so it goes
  with it.
- Remove the stack-specific skills and agent: `gsap-*`, `threejs`, `react-ui` and `react-developer`. Cut
  `.agents/skills/VENDORED.md` down to the remaining vendored skill.
- Remove all ten card capabilities from `openspec/specs/` and the whole `openspec/changes/archive/`, including the
  workflow history, so the template starts with an empty OpenSpec history. The OpenSpec setup (config, skills, prompts)
  stays.
- Make the kept workflow stack-agnostic: drop the `react-developer` delegation from `implement-story`, `fix-bug` and
  `do-chore`, point the `reviewer` agent at the Commands section of `AGENTS.md` instead of hard-coded npm commands, and
  remove the React and Playwright examples from `AGENTS.md`.
- Turn the Commands section of `AGENTS.md` into a placeholder that each repository fills in.
- Rewrite `README.md` to describe the template and explain how to adopt it.
- Keep the CI job `ci`, but replace its npm steps with a harmless default step, so the branch ruleset's required check
  still passes before a stack is added.
- Point the security advisory link in `.github/ISSUE_TEMPLATE/config.yml` at this repository, replace the web-only
  browsers field of the bug report form (and its `write-bug-report` example) with a generic Environment field, and make
  `.gitignore` stack-agnostic.

## Capabilities

### New Capabilities

- `ci-check`: the required `ci` status check that runs on every pull request to `main` and every push to `main`.

### Modified Capabilities

All requirements of these capabilities are removed and the capabilities are retired, which deletes their specs:

- `background-scene`
- `birthday-cake`
- `birthday-finale`
- `birthday-greeting`
- `content-choreography`
- `deployment`
- `family-messages`
- `ornaments`
- `scroll-morph`
- `visual-design`

## Impact

- Code: everything under `src/`, `public/`, `features/` and `scripts/` is deleted. No application code remains.
- Dependencies: all npm dependencies are removed. `npm ci`, `npm run build`, `npm test`, `npm run test:bdd`,
  `npm run lint` and `npm run format:check` no longer exist.
- CI: the `ci` job keeps its name, so the required check on `main` still works, but it no longer builds, tests or lints
  anything until an adopter adds a stack.
- AI instructions: `AGENTS.md`, the workflow skills and the `reviewer` agent change. The OpenSpec-generated
  `.github/skills/openspec-*` and `.github/prompts/opsx-*` stay untouched.
- Deployment: the Cloudflare Pages deploy is gone. The live card is unaffected; it stays in the source repository
  kunman93/age-of-majority.
