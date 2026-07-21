#!/usr/bin/env bats
#
# Regression tests for bugs that survived a green CI run.
#
# CI proved commands exited 0; none of these bugs changed an exit status, so
# none were caught. Each test here fails against the code as it was.

load helper

setup() {
    setup_sandbox
}

#--------------------------------------------------------------------
# files:remove-older announced a deletion and deleted nothing.
# It piped into "xargs -0 -n1" with no utility, and xargs defaults to echo.
#--------------------------------------------------------------------

@test "files:remove-older actually deletes when confirmed" {
    make_old_file "${SANDBOX}/ancient.log"

    cd "$SANDBOX"
    run bash -c "echo Yes | '${NODDY}' files:remove-older 30"

    [ "$status" -eq 0 ]
    [ ! -f "${SANDBOX}/ancient.log" ]
}

@test "files:remove-older keeps files when declined" {
    make_old_file "${SANDBOX}/ancient.log"

    cd "$SANDBOX"
    run bash -c "echo No | '${NODDY}' files:remove-older 30"

    [ "$status" -eq 0 ]
    [ -f "${SANDBOX}/ancient.log" ]
    [[ "$output" == *"Cancelled"* ]]
}

@test "files:remove-older leaves recent files alone" {
    touch "${SANDBOX}/fresh.log"

    cd "$SANDBOX"
    run bash -c "echo Yes | '${NODDY}' files:remove-older 30"

    [ -f "${SANDBOX}/fresh.log" ]
    [[ "$output" == *"Nothing to remove"* ]]
}

@test "files:remove-older requires an age argument" {
    cd "$SANDBOX"
    run "${NODDY}" files:remove-older

    [ "$status" -eq 1 ]
    [[ "$output" == *"specify an age"* ]]
}

#--------------------------------------------------------------------
# apps:close-all truncated application names containing spaces, because it
# cut a single whitespace-delimited field out of ps output.
#--------------------------------------------------------------------

@test "apps:close-all shows full application names containing spaces" {
    stub ps <<'EOF'
echo "user 501 0.0 0.1 100 200 ?? S 1:00PM 0:01.00 /Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
echo "user 502 0.0 0.1 100 200 ?? S 1:00PM 0:01.00 /Applications/Visual Studio Code.app/Contents/MacOS/Electron"
EOF

    run bash -c "echo No | '${NODDY}' apps:close-all"

    [[ "$output" == *"Google Chrome.app"* ]]
    [[ "$output" == *"Visual Studio Code.app"* ]]
    # The old implementation produced these truncated forms.
    [[ "$output" != *"  Google"$'\n'* ]]
}

@test "apps:close-all does not kill anything when declined" {
    stub ps <<'EOF'
echo "user 501 0.0 0.1 100 200 ?? S 1:00PM 0:01.00 /Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
EOF
    stub_recording kill

    run bash -c "echo No | '${NODDY}' apps:close-all"

    [[ "$output" == *"Cancelled"* ]]
    ! called "kill"
}

#--------------------------------------------------------------------
# eject-all filtered on a Finder property that does not exist, so every run
# failed with -2753 and nothing was ever ejected.
#--------------------------------------------------------------------

@test "eject-all does not use the undefined 'executable' property" {
    # Emulate Finder: reject the property that does not exist, the way
    # osascript really does, and answer for the one that does.
    stub osascript <<'EOF'
args="$*"
if [[ "$args" == *executable* ]]; then
    echo "execution error: The variable executable is not defined. (-2753)" >&2
    exit 1
fi
if [[ "$args" == *"get name of every disk"* ]]; then
    echo "BACKUP_DRIVE"
    exit 0
fi
exit 0
EOF

    run "${NODDY}" eject-all

    [ "$status" -eq 0 ]
    [[ "$output" == *"BACKUP_DRIVE"* ]]
    [[ "$output" != *"-2753"* ]]
}

@test "eject-all reports plainly when nothing is mounted" {
    stub osascript <<'EOF'
exit 0
EOF

    run "${NODDY}" eject-all

    [ "$status" -eq 0 ]
    [[ "$output" == *"No ejectable volumes"* ]]
}

#--------------------------------------------------------------------
# An unknown command ended in "kill -INT $$", which signalled the process
# group and killed the calling shell instead of exiting.
#--------------------------------------------------------------------

@test "unknown command exits 1 without signalling the caller" {
    run bash -c "'${NODDY}' definitely:not:a:command < /dev/null; echo CALLER_ALIVE=\$?"

    [[ "$output" == *"Command not found"* ]]

    # Compare the whole last line, not a substring: "CALLER_ALIVE=1" also
    # matches inside "CALLER_ALIVE=130", which is what the old kill -INT
    # produced, so a substring test passed against the broken code.
    local last
    last="$(printf '%s\n' "$output" | tail -1)"
    [ "$last" = "CALLER_ALIVE=1" ]
}

@test "unknown command does not block when stdin is not a terminal" {
    run bash -c "echo '' | '${NODDY}' definitely:not:a:command"

    [ "$status" -eq 1 ]
}
