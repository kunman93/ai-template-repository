#!/usr/bin/env bash
# Runs check-commits.sh against throwaway repositories, one per scenario of the commit-check spec.
set -uo pipefail

script="$(cd "$(dirname "$0")" && pwd)/check-commits.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1

failures=0
case_name=""
repo=""
status=0
output=""

new_repo() {
  repo="$(mktemp -d "$tmp/repo.XXXXXX")"
  git -C "$repo" init -q -b main
  git -C "$repo" commit -q --allow-empty -m "chore: init"
  git -C "$repo" tag base
}

commit() {
  printf '%b' "$1" | git -C "$repo" commit -q --allow-empty -F -
}

sha() {
  git -C "$repo" rev-parse --short HEAD
}

run_check() {
  output="$(cd "$repo" && "$script" "$@" 2>&1)"
  status=$?
}

fail() {
  echo "FAIL: $case_name: $1"
  failures=$((failures + 1))
}

expect_status() {
  [ "$status" -eq "$1" ] || fail "expected exit $1, got $status ($output)"
}

expect_output() {
  case "$output" in
    *"$1"*) ;;
    *) fail "expected output to contain '$1', got: $output" ;;
  esac
}

expect_no_output() {
  [ -z "$output" ] || fail "expected no output, got: $output"
}

expect_not_output() {
  case "$output" in
    *"$1"*) fail "expected output not to contain '$1', got: $output" ;;
  esac
}

case_name="leftover fixup commit"
new_repo
commit "fixup! feat(skills): add the check"
run_check base
expect_status 1
expect_output "$(sha) fixup! feat(skills): add the check: leftover fixup"
expect_not_output "not a Conventional Commits subject"

case_name="leftover squash and amend commits"
new_repo
commit "squash! feat: a"
squash_sha="$(sha)"
commit "amend! feat: a"
run_check base
expect_status 1
expect_output "$squash_sha squash! feat: a: leftover fixup"
expect_output "$(sha) amend! feat: a: leftover fixup"

case_name="several offending commits"
new_repo
commit "update readme"
first_sha="$(sha)"
commit "docs: fine"
commit "fixup! docs: fine"
run_check base
expect_status 1
expect_output "$first_sha update readme: not a Conventional Commits subject"
expect_output "$(sha) fixup! docs: fine: leftover fixup"

case_name="subject without a type"
new_repo
commit "update readme"
run_check base
expect_status 1
expect_output "$(sha) update readme: not a Conventional Commits subject"

case_name="unknown type"
new_repo
commit "feature: add the check"
run_check base
expect_status 1
expect_output "$(sha) feature: add the check: not a Conventional Commits subject"

case_name="subject over 72 characters"
new_repo
long_subject="docs: $(printf 'x%.0s' $(seq 1 67))"
commit "$long_subject"
run_check base
expect_status 1
expect_output "$(sha) $long_subject: longer than 72 characters"

case_name="subject of exactly 72 characters"
new_repo
commit "docs: $(printf 'x%.0s' $(seq 1 66))"
run_check base
expect_status 0
expect_no_output

case_name="valid subjects"
new_repo
commit "docs: fix a typo"
commit "feat(skills): add the check"
commit "feat(api)!: remove the v1 endpoints"
run_check base
expect_status 0
expect_no_output

case_name="missing Refs trailer"
new_repo
commit "feat: add the check"
run_check base 27
expect_status 1
expect_output "$(sha) feat: add the check: missing Refs: #27"

case_name="wrong issue in the Refs trailer"
new_repo
commit "feat: add the check\n\nRefs: #26"
run_check base 27
expect_status 1
expect_output "$(sha) feat: add the check: missing Refs: #27"

case_name="issue number that only starts like the wanted one"
new_repo
commit "feat: add the check\n\nRefs: #270"
run_check base 27
expect_status 1
expect_output "$(sha) feat: add the check: missing Refs: #27"

case_name="Refs line outside the trailer block"
new_repo
commit "feat: add the check\n\nRefs: #27\n\nCo-authored-by: Copilot <c@example.com>"
run_check base 27
expect_status 1
expect_output "$(sha) feat: add the check: missing Refs: #27"

case_name="Refs trailer in the final trailer block"
new_repo
commit "feat: add the check\n\nRefs: #27\nCo-authored-by: Copilot <c@example.com>"
run_check base 27
expect_status 0
expect_no_output

case_name="no issue number skips the Refs check"
new_repo
commit "feat: add the check"
run_check base
expect_status 0
expect_no_output

case_name="clean history"
new_repo
commit "feat: add the check\n\nRefs: #27"
commit "docs: document the check\n\nRefs: #27"
run_check base 27
expect_status 0
expect_no_output

case_name="unknown base"
new_repo
commit "update readme"
run_check no-such-ref
expect_status 2
expect_output "usage:"

case_name="non-numeric issue"
new_repo
commit "feat: add the check"
run_check base abc
expect_status 2
expect_output "usage:"

if [ "$failures" -ne 0 ]; then
  echo "$failures check(s) failed"
  exit 1
fi
echo "all checks passed"
