#!/usr/bin/env bats
#
# Core dispatch, help, and the macOS-specific plugins that broke on current
# systems. Hardware-dependent commands are driven against stub output so the
# parsing is tested rather than the machine.

load helper

setup() {
    setup_sandbox
}

@test "help lists categories" {
    run "${NODDY}" help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Git Utilities"* ]]
}

@test "categories lists every registered category" {
    run "${NODDY}" categories
    [ "$status" -eq 0 ]
    for c in ansible bluetooth brew compress docker general git network performance search ssh terraform volume wifi xcode; do
        [[ "$output" == *"$c"* ]]
    done
}

@test "no arguments defaults to the command list" {
    run "${NODDY}"
    [ "$status" -eq 0 ]
    [[ "$output" == *"noddy"* ]]
}

@test "every registered command resolves to an implementation" {
    run "${NODDY_ROOT}/.github/scripts/check-registries.sh"
    [ "$status" -eq 0 ]
}

@test "the LAMP era commands are gone" {
    for cmd in mysql:list mamp:start php:info hosts:edit; do
        run bash -c "'${NODDY}' ${cmd} < /dev/null"
        [ "$status" -eq 1 ]
        [[ "$output" == *"Command not found"* ]]
    done
}

@test "git:config and git:settings both work" {
    cd "${NODDY_ROOT}"
    run "${NODDY}" git:config
    [ "$status" -eq 0 ]

    run "${NODDY}" git:settings
    [ "$status" -eq 0 ]
}

@test "wifi:status parses system_profiler rather than the removed airport binary" {
    stub networksetup <<'EOF'
if [[ "$*" == *listallhardwareports* ]]; then
    printf 'Hardware Port: Wi-Fi\nDevice: en0\n'
    exit 0
fi
if [[ "$*" == *getairportpower* ]]; then
    echo "Wi-Fi Power (en0): On"
    exit 0
fi
EOF
    stub system_profiler <<'EOF'
cat <<'INNER'
          Current Network Information:
            TestNetwork:
              PHY Mode: 802.11ac
              Channel: 36 (5GHz, 80MHz)
          Other Local Wi-Fi Networks:
            Neighbour:
              PHY Mode: 802.11n
INNER
EOF

    run "${NODDY}" wifi:status

    [ "$status" -eq 0 ]
    [[ "$output" == *"en0"* ]]
    [[ "$output" == *"TestNetwork"* ]]
    # The neighbour list belongs to wifi:scan, not wifi:status.
    [[ "$output" != *"Neighbour"* ]]
}

@test "wifi:scan lists nearby networks only" {
    stub system_profiler <<'EOF'
cat <<'INNER'
          Current Network Information:
            TestNetwork:
              PHY Mode: 802.11ac
          Other Local Wi-Fi Networks:
            Neighbour:
              PHY Mode: 802.11n
INNER
EOF

    run "${NODDY}" wifi:scan

    [ "$status" -eq 0 ]
    [[ "$output" == *"Neighbour"* ]]
}

@test "wifi:status fails clearly when there is no Wi-Fi hardware" {
    stub networksetup <<'EOF'
exit 0
EOF

    run "${NODDY}" wifi:status

    [ "$status" -eq 1 ]
    [[ "$output" == *"No Wi-Fi hardware"* ]]
}

@test "lock refuses to pretend when it cannot actually lock" {
    stub osascript <<'EOF'
echo "execution error: osascript is not allowed to send keystrokes. (1002)" >&2
exit 1
EOF
    stub sysadminctl <<'EOF'
echo "screenLock is off"
EOF

    run "${NODDY}" lock

    [ "$status" -eq 1 ]
    [[ "$output" == *"Could not lock"* ]]
}

@test "lock falls back to the screensaver when screen lock is enabled" {
    stub osascript <<'EOF'
exit 1
EOF
    stub sysadminctl <<'EOF'
echo "screenLock is on"
EOF
    stub_recording open

    run "${NODDY}" lock

    [[ "$output" == *"screensaver"* ]]
    called "ScreenSaverEngine"
}

@test "noddy works when invoked through a symlink" {
    ln -s "${NODDY}" "${SANDBOX}/linked-noddy"

    run "${SANDBOX}/linked-noddy" uptime

    [ "$status" -eq 0 ]
}
