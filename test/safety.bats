#!/usr/bin/env bats
#
# Destructive commands must show what they will destroy and ask first.

load helper

setup() {
    setup_sandbox
}

@test "git:remove keeps repositories when declined" {
    mkdir -p "${SANDBOX}/repo"
    git -C "${SANDBOX}/repo" init -q

    cd "$SANDBOX"
    run bash -c "echo No | '${NODDY}' git:remove"

    [ -d "${SANDBOX}/repo/.git" ]
    [[ "$output" == *"Cancelled"* ]]
}

@test "git:remove deletes only after confirmation" {
    mkdir -p "${SANDBOX}/repo"
    git -C "${SANDBOX}/repo" init -q

    cd "$SANDBOX"
    run bash -c "echo Yes | '${NODDY}' git:remove"

    [ ! -d "${SANDBOX}/repo/.git" ]
}

@test "git:remove is depth bounded and cannot reach deeply nested repositories" {
    mkdir -p "${SANDBOX}/top" "${SANDBOX}/parent/child/deep"
    git -C "${SANDBOX}/top" init -q
    git -C "${SANDBOX}/parent/child/deep" init -q

    cd "$SANDBOX"
    run bash -c "echo Yes | '${NODDY}' git:remove"

    [ ! -d "${SANDBOX}/top/.git" ]
    # Previously this recursed without limit and would have taken this too.
    [ -d "${SANDBOX}/parent/child/deep/.git" ]
}

@test "git:remove reports when there is nothing to remove" {
    cd "$SANDBOX"
    run "${NODDY}" git:remove

    [ "$status" -eq 0 ]
    [[ "$output" == *"No .git directory found"* ]]
}

@test "presentation warns about the Trash and browsers before acting" {
    stub_recording killall
    stub_recording osascript

    run bash -c "echo No | '${NODDY}' presentation"

    [[ "$output" == *"Desktop"* ]]
    [[ "$output" == *"Trash"* ]]
    [[ "$output" == *"Cancelled"* ]]
    ! called "killall"
    ! called "osascript"
}

@test "presentation no longer drives Do Not Disturb through System Events" {
    # Match the UI-scripting call itself, not prose: the comment explaining
    # why this was removed mentions Notification Center by name.
    run grep -c "click menu bar item" "${NODDY_ROOT}/toyland/plugins/general"
    [ "$output" = "0" ]
}

@test "trash:empty does not use sudo" {
    run grep -c "sudo rm -rf ~/.Trash" "${NODDY_ROOT}/toyland/plugins/performance"
    [ "$output" = "0" ]
}
