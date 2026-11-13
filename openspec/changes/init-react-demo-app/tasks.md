# Tasks

## 1. Scaffold

- [ ] 1.1 Scaffold the app with `npm create vite@latest app -- --template react-ts`, run `npm --prefix app install`,
  and verify `app/package.json` and `app/package-lock.json` exist and `node_modules` is git-ignored
- [ ] 1.2 Add `vitest`, `@testing-library/react`, `@testing-library/jest-dom` and `jsdom` as dev dependencies,
  configure Vitest (jsdom environment, jest-dom matchers) and a `test` script (`vitest run`), and verify
  `npm --prefix app test` runs (exits with "no test files" until 2.1)

## 2. Hello Lutz page

- [ ] 2.1 Write `app/src/App.test.tsx` asserting "Hello Lutz" is visible, and verify it fails against the scaffold's
  default `App`
- [ ] 2.2 Trim `App` to render only "Hello Lutz" (remove counter, logos and unused assets and CSS), and verify the
  test passes, `npm --prefix app run lint` and `npm --prefix app run build` succeed
- [ ] 2.3 Add a short "Demo app" section to `README.md` with the start command `npm --prefix app run dev`, and verify
  the dev server serves a page showing "Hello Lutz"

## 3. Commands and ci

- [ ] 3.1 Fill in the Commands section of `AGENTS.md` (Install `npm --prefix app ci`, Build
  `npm --prefix app run build`, Test `npm --prefix app test`, Lint/format `npm --prefix app run lint`), and verify each
  runs successfully from the repository root
- [ ] 3.2 Replace the placeholder step of the `ci` job in `.github/workflows/ci.yml` with checkout, Node.js 22 setup
  with npm cache, install, lint, test and build, and verify the `ci` check passes on the pushed branch
