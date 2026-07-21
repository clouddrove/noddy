#!/usr/bin/env bash
#
# noddy keeps a command in four places: the COMMANDS array in noddy, a case
# label in a plugin, usage text in toyland/misc/help, and a row in README.md.
# They drift apart silently, and the failure mode is a command that is listed
# everywhere but can never run.
#
# This checks the two registries that decide whether a command actually
# executes: COMMANDS and the plugin case labels. Entries in KNOWN_DRIFT are
# pre-existing breakage, reported but not fatal, so that CI catches new drift
# without demanding the backlog be cleared first.

set -uo pipefail

cd "$(dirname "$0")/../.." || exit 1

RED=$'\033[1;31m'; YELLOW=$'\033[1;33m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
failures=0

# Commands that are dispatched by toyland/misc/help rather than by a plugin.
HELP_HANDLED=(list help usage categories)

# Category names are valid arguments; misc/help prints usage for them.
CATEGORIES=$(awk '/^noddyCategories=\(/{flag=1; next} /^\)/{exit} flag{gsub(/[ \t]/,""); if (length($0)) print}' toyland/misc/help)

# Pre-existing breakage. Remove an entry here once it is genuinely fixed.
KNOWN_DRIFT=(
    "terraform:check"     # toyland/plugins/terraform is a stub
    "tf:p" "tf:f" "tf:d"  # terraform stub arms with empty bodies
    "ansible:deploy"      # plugin uses a different label
    "ssh:list"            # documented in README but never implemented
    "terminal" "homebrew" "display"
    "update" "brew"
    "ssh:connect"
)

contains() {
    local needle="$1"; shift
    local item
    for item in "$@"; do
        [ "$item" = "$needle" ] && return 0
    done
    return 1
}

commands_list=$(awk '/^COMMANDS=\(/{flag=1; next}
                     /END OF COMMANDS/{exit}
                     flag{gsub(/[ \t]/,""); if (length($0) && $0 != ")") print}' noddy)

# Case labels across every plugin that noddy actually sources.
sourced_plugins=$(grep -o 'toyland/plugins/[a-z]*' noddy | sort -u)

plugin_labels=""
for plugin in $sourced_plugins; do
    if [ ! -f "$plugin" ]; then
        echo "${RED}MISSING${NC} noddy sources ${plugin}, which does not exist"
        failures=$((failures + 1))
        continue
    fi
    # Case arms may list several patterns: "time"|"clock") — take every one.
    labels=$(grep -oE '^[[:space:]]*"[a-zA-Z0-9:_-]+"([[:space:]]*\|[[:space:]]*"[a-zA-Z0-9:_-]+")*\)' "$plugin" \
        | grep -oE '"[a-zA-Z0-9:_-]+"' | tr -d '"')
    plugin_labels="${plugin_labels}${labels}"$'\n'
done

echo "== Registered commands with no plugin implementation"
unimplemented=0
while IFS= read -r cmd; do
    [ -z "$cmd" ] && continue
    contains "$cmd" $plugin_labels && continue
    contains "$cmd" "${HELP_HANDLED[@]}" && continue
    contains "$cmd" $CATEGORIES && continue

    if contains "$cmd" "${KNOWN_DRIFT[@]}"; then
        echo "  ${YELLOW}known${NC}  ${cmd}"
    else
        echo "  ${RED}NEW${NC}    ${cmd} is in COMMANDS but no sourced plugin implements it"
        unimplemented=$((unimplemented + 1))
    fi
done <<< "$commands_list"
[ "$unimplemented" -eq 0 ] && echo "  ${GREEN}no new drift${NC}"
failures=$((failures + unimplemented))

echo
echo "== Plugin commands missing from the COMMANDS array"
unregistered=0
while IFS= read -r label; do
    [ -z "$label" ] && continue
    contains "$label" $commands_list && continue
    if contains "$label" "${KNOWN_DRIFT[@]}"; then
        echo "  ${YELLOW}known${NC}  ${label}"
        continue
    fi
    echo "  ${RED}NEW${NC}    ${label} is implemented but not in COMMANDS, so it can never run"
    unregistered=$((unregistered + 1))
done <<< "$(echo "$plugin_labels" | sort -u)"
[ "$unregistered" -eq 0 ] && echo "  ${GREEN}all implemented commands are registered${NC}"
failures=$((failures + unregistered))

echo
if [ "$failures" -gt 0 ]; then
    echo "${RED}${failures} registry problem(s) found${NC}"
    exit 1
fi
echo "${GREEN}Registries are consistent${NC}"
