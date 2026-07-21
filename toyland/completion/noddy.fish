# Fish completion for noddy.
#
# The command list is read out of the COMMANDS array in the noddy script
# itself, between "COMMANDS=(" and the "END OF COMMANDS" marker, so adding a
# command to that array is all it takes to complete on it.

function __noddy_commands
    set -l script (command -v noddy)
    test -n "$script"; or return

    awk '/^COMMANDS=\(/{flag=1; next}
         /END OF COMMANDS/{exit}
         flag{gsub(/[ \t]/, ""); if (length($0) && $0 != ")") print}' $script
end

# Only the first argument is a noddy command; leave the rest to fish's
# default file completion.
complete -c noddy -f -n '__fish_is_first_arg' -a '(__noddy_commands)'
complete -c noddy -F -n 'not __fish_is_first_arg'
