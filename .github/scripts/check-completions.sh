#!/usr/bin/env bash
#
# Verifies that every shell completion resolves the same command list as the
# COMMANDS array in noddy.
#
# This lives in a file rather than inline in the workflow on purpose. The awk
# program contains characters that need escaping in shell, and nesting it
# inside a quoted -c argument inside YAML mangles it. A script file has one
# level of quoting and behaves the same locally as in CI.
#
# Usage: check-completions.sh [path-to-noddy] [completion-dir]

set -uo pipefail

cd "$(dirname "$0")/../.." || exit 1

NODDY="${1:-./noddy}"
COMPDIR="${2:-toyland/completion}"

RED=$'\033[1;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
failures=0

if [ ! -f "$NODDY" ]; then
    echo "${RED}noddy script not found at ${NODDY}${NC}"
    exit 1
fi

# Source of truth: the COMMANDS array itself.
expected=$(awk '/^COMMANDS=\(/{flag=1; next}
                /END OF COMMANDS/{exit}
                flag{gsub(/[ \t]/,""); if (length($0) && $0 != ")") print}' "$NODDY" | wc -l | tr -d ' ')

echo "COMMANDS array holds ${expected} entries"

if [ "$expected" -lt 100 ]; then
    echo "${RED}Only ${expected} commands extracted; the awk range is probably broken${NC}"
    exit 1
fi

report() {
    local shell="$1" got="$2"
    if [ "$got" = "$expected" ]; then
        echo "  ${GREEN}ok${NC}    ${shell} resolved ${got}"
    else
        echo "  ${RED}FAIL${NC}  ${shell} resolved ${got}, expected ${expected}"
        failures=$((failures + 1))
    fi
}

# The bash and fish completions resolve noddy through PATH, exactly as they do
# for a user. Put the script under test there so this works against a checkout
# as well as against an installed copy.
NODDY_DIR=$(cd "$(dirname "$NODDY")" && pwd)
export PATH="${NODDY_DIR}:${PATH}"
echo "Resolving noddy from ${NODDY_DIR}"

# bash: source the real completion and call the real function.
if [ -f "${COMPDIR}/noddy.bash" ]; then
    got=$(bash -c "source '${COMPDIR}/noddy.bash'; _noddy_commands | wc -l" 2>/dev/null | tr -d ' ')
    report "bash" "${got:-0}"
else
    echo "  ${RED}FAIL${NC}  ${COMPDIR}/noddy.bash is missing"
    failures=$((failures + 1))
fi

# zsh: the completion function itself needs the completion system to run, so
# check that the file parses and that the extraction it performs, taken from
# the shipped file rather than retyped here, yields the same list.
if [ -f "${COMPDIR}/_noddy" ]; then
    if zsh -n "${COMPDIR}/_noddy" 2>/dev/null; then
        echo "  ${GREEN}ok${NC}    zsh completion parses"
    else
        echo "  ${RED}FAIL${NC}  zsh completion has a syntax error"
        failures=$((failures + 1))
    fi

    # Pull the awk program out of the shipped completion and run it under zsh.
    awk_prog=$(awk '/awk .\/\^COMMANDS/,/print}./' "${COMPDIR}/_noddy" \
        | sed -e "s/^.*awk '//" -e "s/' \$script.*$//")

    if [ -n "$awk_prog" ]; then
        got=$(NODDY_PATH="$NODDY" AWK_PROG="$awk_prog" zsh -f -c \
            'print -r -- ${#${(f)"$(awk $AWK_PROG $NODDY_PATH)"}}' 2>/dev/null | tr -d ' ')
        report "zsh" "${got:-0}"
    else
        echo "  ${RED}FAIL${NC}  could not extract the awk program from the zsh completion"
        failures=$((failures + 1))
    fi
else
    echo "  ${RED}FAIL${NC}  ${COMPDIR}/_noddy is missing"
    failures=$((failures + 1))
fi

# fish: source the real completion and call the real function. Skipped rather
# than failed when fish is absent, since it is not a noddy dependency.
if [ -f "${COMPDIR}/noddy.fish" ]; then
    if command -v fish > /dev/null; then
        got=$(fish -c "source '${COMPDIR}/noddy.fish'; __noddy_commands | wc -l" 2>/dev/null | tr -d ' ')
        report "fish" "${got:-0}"
    else
        echo "  ${YELLOW}skip${NC}  fish is not installed"
    fi
else
    echo "  ${RED}FAIL${NC}  ${COMPDIR}/noddy.fish is missing"
    failures=$((failures + 1))
fi

echo
if [ "$failures" -gt 0 ]; then
    echo "${RED}${failures} completion check(s) failed${NC}"
    exit 1
fi
echo "${GREEN}All completions agree with the COMMANDS array${NC}"
