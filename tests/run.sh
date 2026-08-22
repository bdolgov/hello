#!/bin/sh
# Run the full test suite.
#
# Usage:  tests/run.sh [suite-number...]
#         BIN=/path/to/hello tests/run.sh
#         CC=clang tests/run.sh
#
# Exits 0 only if every suite passes.
set -u
ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
BIN="${BIN:-$ROOT/hello}"
CC="${CC:-cc}"
export BIN CC

if [ ! -x "$BIN" ]; then
    printf 'building %s\n' "$BIN"
    $CC -Wall -Wextra -pedantic -std=c99 -O2 -o "$BIN" "$ROOT/hello.c" || exit 1
fi

# Suite selection is done by resetting the positional parameters rather
# than by building a string of paths: the repository may live under a
# directory containing spaces, and an unquoted glob variable would split
# on them.
if [ "$#" -gt 0 ]; then
    set -- "$@" --
    while [ "$1" != "--" ]; do
        n=$1; shift
        for f in "$ROOT/tests/0$n-"*.sh; do
            [ -f "$f" ] && set -- "$@" "$f"
        done
    done
    shift   # drop the -- sentinel
else
    set --
    for f in "$ROOT"/tests/0*.sh; do
        [ -f "$f" ] && set -- "$@" "$f"
    done
fi

# The documented assertion floor. README section 16 states the suite
# totals more than this many assertions; a floor rather than an exact
# figure because the number of suites skipped varies by platform (valgrind
# on Linux, static linking off macOS, and so on).
ASSERTION_FLOOR=300

FAILED=""
TOTAL=0
ASSERTIONS=0
OUT=$(mktemp)
STATUS=$(mktemp)
trap 'rm -f "$OUT" "$STATUS"' EXIT INT TERM

for suite in "$@"; do
    [ -f "$suite" ] || continue
    name=$(basename "$suite" .sh)
    printf '\n\033[1m--- %s ---\033[0m\n' "$name"

    # The suite's exit status is written to a file from inside the pipeline
    # rather than read from the pipeline itself. `sh "$suite" | tee "$OUT"`
    # returns tee's status, not the suite's, so a failing suite was reported
    # as passing -- which is what this runner exists to notice. POSIX sh has
    # no PIPESTATUS, so the status is carried out of the pipeline by hand.
    { sh "$suite"; echo $? > "$STATUS"; } | tee "$OUT"
    rc=$(cat "$STATUS")

    if [ "$rc" -eq 0 ]; then
        TOTAL=$((TOTAL + 1))
    else
        FAILED="$FAILED $name"
    fi

    n=$(grep -cE '^ +(PASS|FAIL)' "$OUT" 2>/dev/null || echo 0)
    ASSERTIONS=$((ASSERTIONS + n))
done

printf '\n========================================\n'
printf '%d assertions across %d suites\n' "$ASSERTIONS" "$TOTAL"

if [ "$ASSERTIONS" -lt "$ASSERTION_FLOOR" ]; then
    printf 'FAIL: README claims more than %d assertions; only %d ran.\n' \
        "$ASSERTION_FLOOR" "$ASSERTIONS"
    printf '      Either a suite failed to execute, or the claim is stale.\n'
    FAILED="$FAILED assertion-count"
fi

if [ -z "$FAILED" ]; then
    printf 'ALL SUITES PASSED (%d)\n' "$TOTAL"
    exit 0
else
    printf 'FAILED:%s\n' "$FAILED"
    exit 1
fi
