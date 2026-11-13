# Spec Delta

## Purpose

A minimal React demo app that gives colleagues a real example to follow through the template's Story workflow end to
end.

## ADDED Requirements

### Requirement: The app shows Hello Lutz

The app SHALL render a single page that displays the text "Hello Lutz".

#### Scenario: Opening the app

- **WHEN** a user opens the app in a browser
- **THEN** the page displays the text "Hello Lutz"

### Requirement: The app starts locally with a documented command

The repository SHALL document one command that starts the app locally, and that command SHALL serve the app on a
local URL.

#### Scenario: Starting the app

- **WHEN** a developer installs the dependencies and runs the documented start command
- **THEN** the app is served on a local URL that shows "Hello Lutz"

### Requirement: The app builds, tests and lints with the documented Commands

The Commands section of `AGENTS.md` SHALL list the install, build, test and lint/format commands of the app, and
each of them SHALL succeed on a clean checkout.

#### Scenario: Running the Commands

- **WHEN** a developer runs the install, build, test and lint/format commands from `AGENTS.md` on a clean checkout
- **THEN** each command exits successfully and the build produces the app without errors

### Requirement: ci runs the app's checks

The `ci` check SHALL install the app's dependencies and run its lint, test and build commands, and SHALL fail when
any of them fails.

#### Scenario: A failing test

- **WHEN** a pull request makes the app's test fail
- **THEN** the `ci` check fails
