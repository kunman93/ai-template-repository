#!/usr/bin/env bash
# Verifies the commits between <base> and HEAD using only git inspection.
# Usage: check-commits.sh <base> [<issue>]
# No "set -e": a failing rule must not stop the script, so that every bad commit gets reported.
set -uo pipefail

# Exit code 2 means "wrong call", as opposed to 1, which means "bad commits found".
usage() {
  echo "usage: check-commits.sh <base> [<issue>]" >&2
  exit 2
}

# Expect one or two arguments.
[ $# -ge 1 ] && [ $# -le 2 ] || usage
base="$1"
issue="${2:-}"
# The base must be a ref that git can resolve.
git rev-parse --verify --quiet "$base^{commit}" >/dev/null || usage
# The issue number, if given, must be a positive integer.
if [ -n "$issue" ]; then
  [[ "$issue" =~ ^[1-9][0-9]*$ ]] || usage
fi

max_subject_length=72
# type, optional (scope), optional ! for breaking changes, then ": " and a summary.
conventional='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([^()]+\))?!?: .+'
# Leftovers of `git commit --fixup` that the autosquash should have merged away.
fixup='^(fixup|squash|amend)! '

# Prints one line per broken rule and remembers that something failed.
failed=0
report() {
  echo "$1 $2: $3"
  failed=1
}

# Reads one commit per line, from the oldest, as "<short sha><tab><subject>" (see the git log at the end).
# Each rule below checks the subject of one commit.
while IFS=$'\t' read -r sha subject; do
  if [[ "$subject" =~ $fixup ]]; then
    report "$sha" "$subject" "leftover fixup"
  elif ! [[ "$subject" =~ $conventional ]]; then
    report "$sha" "$subject" "not a Conventional Commits subject"
  elif [ "${#subject}" -gt "$max_subject_length" ]; then
    report "$sha" "$subject" "longer than $max_subject_length characters"
  fi

  # Only issue branches need the trailer. A trailer is a "Key: value" line in the last paragraph of the message.
  if [ -n "$issue" ]; then
    # Lists the values of all Refs trailers, one per line.
    refs="$(git log -1 --no-show-signature --format='%(trailers:key=Refs,valueonly,separator=%x0A)' "$sha")"
    # -F plain text, -x whole line, -q silent: "#27" must not match "#270".
    if ! printf '%s\n' "$refs" | grep -Fxq "#$issue"; then
      report "$sha" "$subject" "missing Refs: #$issue"
    fi
  fi
# The list of commits on this branch: everything after <base> up to HEAD. --no-show-signature keeps a
# user's log.showSignature setting from adding extra lines.
done < <(git log --reverse --no-show-signature --format='%h%x09%s' "$base..HEAD")

# 0 when every commit passed, 1 when at least one rule failed.
exit "$failed"
