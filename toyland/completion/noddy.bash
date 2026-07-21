#!/usr/bin/env bash

# Bash completion for noddy.
#
# The command list is read out of the COMMANDS array in the noddy script
# itself, between "COMMANDS=(" and the "END OF COMMANDS" marker, so adding a
# command to that array is all it takes to complete on it.

_noddy_commands() {
    local script
    script="$(command -v noddy 2>/dev/null)" || return 1
    [ -n "$script" ] || return 1

    awk '/^COMMANDS=\(/{flag=1; next}
         /END OF COMMANDS/{exit}
         flag{gsub(/[ \t]/, ""); if (length($0) && $0 != ")") print}' "$script"
}

_noddy() {
    local cur
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Only the first argument is a noddy command; everything after it is a
    # file, a branch name or free text, so fall back to filenames.
    if [ "$COMP_CWORD" -gt 1 ]; then
        COMPREPLY=( $(compgen -f -- "$cur") )
        return 0
    fi

    COMPREPLY=( $(compgen -W "$(_noddy_commands)" -- "$cur") )
    return 0
}

complete -F _noddy noddy
