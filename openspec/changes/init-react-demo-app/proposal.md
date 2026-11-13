# Proposal

## Why

Colleagues learning this template's workflow need a real Story to follow end to end (proposal, implementation,
review, PR). A minimal React app gives them a concrete example without distracting from the workflow (#43).

This change is a demo. Its PR is not merged, because a React app in the template would ship to every repository
that adopts it and break the template's stack-agnostic promise.

## What Changes

- Scaffold a minimal React app with Vite and TypeScript in `app/`.
- The app renders a single page that shows the text "Hello Lutz".
- Add one Vitest and Testing Library test that proves "Hello Lutz" renders.
- Fill in the Commands section of `AGENTS.md` (install, build, test, lint/format) and document how to start the app
  locally.
- Replace the placeholder step of the `ci` job in `.github/workflows/ci.yml` with install, lint, test and build steps
  for the app.

## Capabilities

### New Capabilities

- `demo-app`: the React demo app: what it shows, how it starts locally, and that it builds, tests and lints with the
  commands documented in `AGENTS.md`.

### Modified Capabilities

None. `ci-check` already covers a repository that adds its own steps: its requirement only binds `ci` to pass without
a toolchain until a stack is added, and the check name and branch filters stay unchanged.

## Impact

- New directory `app/` with its own `package.json` and lockfile.
- New dev and runtime dependencies in `app/`: `react`, `react-dom`, `vite`, `@vitejs/plugin-react`, `typescript`,
  oxlint from the Vite template, and `vitest`, `@testing-library/react`, `@testing-library/jest-dom`, `jsdom` for the
  test.
- `AGENTS.md` Commands section is filled in.
- `.github/workflows/ci.yml` gains a Node.js setup and the app's steps, so `ci` installs a toolchain.
- `README.md` gets a short section on starting the demo app.
