# Design

## Context

The repository has no application code and every Command in `AGENTS.md` is `_not configured_`. The `ci` job only
echoes a placeholder. Node.js 22 and npm 10 are available locally. See `proposal.md` for motivation.

## Goals / Non-Goals

**Goals:**

- The smallest React setup that meets the Story's acceptance criteria and has a real test.

**Non-Goals:**

- Routing, styling beyond the scaffold's defaults, state management, deployment.
- Making the template stack-aware. This change is a demo and is not merged.

## Decisions

- **Vite (`create-vite`, `react-ts` template) over Create React App or a framework such as Next.js.** CRA is
  deprecated; a framework adds routing and server features the Story does not need. The Vite template also ships
  oxlint, which covers the lint command.
- **TypeScript.** Confirmed by the user. `npm run build` runs `tsc -b` before `vite build`, so the build also
  type-checks.
- **App in `app/`, not the repository root.** Confirmed by the user. It keeps the app's `package.json`,
  `node_modules` and config apart from the workflow files. Commands run from the repository root with
  `npm --prefix app <script>`.
- **Trim the scaffold.** Remove the counter, logos and demo CSS so `App` renders only "Hello Lutz". Less code to
  read keeps the focus on the workflow.
- **Vitest with Testing Library and jsdom.** Vitest reuses the Vite config, so no extra build setup. One test renders
  `App` and asserts "Hello Lutz" is visible, which is the observable outcome. Jest would need its own transform
  setup.
- **Lint/format is oxlint only.** Keep the template's linter instead of adding ESLint. The template ships no formatter, and adding Prettier is not needed for the
  Story. `.editorconfig` already sets basic formatting.
- **`ci` steps.** `actions/checkout@v7` and `actions/setup-node@v7` (version tags, as `update-skills.yml` uses for
  `actions/*`) with Node.js 22 and npm caching on `app/package-lock.json`, then `npm ci`, lint, test and build. No
  third-party actions. Branch filters and the job name `ci` stay unchanged.
- **Start command.** `npm --prefix app run dev` (Vite dev server, default `http://localhost:5173`), documented in
  `README.md` and listed in Commands next to Build.

## Risks / Trade-offs

- [The scaffold's dependency versions move fast] -> Commit `app/package-lock.json` and use `npm ci` in `ci`, so
  installs are reproducible.
- [`ci` now installs a toolchain, unlike the template's stack-free `ci`] -> Accepted: the PR is not merged into the
  template.
