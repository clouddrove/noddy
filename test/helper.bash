#!/usr/bin/env bash
#
# Shared setup for the bats suite.
#
# Commands that touch hardware, kill processes or delete files are exercised
# against stub executables placed ahead of the real ones on PATH, so the tests
# assert on what noddy would do without doing it.

NODDY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export NODDY_ROOT
export NODDY="${NODDY_ROOT}/noddy"

# Sandbox with a stub directory at the front of PATH.
setup_sandbox() {
    SANDBOX="${BATS_TEST_TMPDIR}/sandbox"
    STUBS="${BATS_TEST_TMPDIR}/stubs"
    mkdir -p "$SANDBOX" "$STUBS"
    export SANDBOX STUBS
    export PATH="${STUBS}:${PATH}"
}

# stub <name>  — body is read from stdin
#
#   stub ps <<'EOF'
#   echo "..."
#   EOF
stub() {
    local name="$1"
    {
        echo "#!/usr/bin/env bash"
        cat
    } > "${STUBS}/${name}"
    chmod +x "${STUBS}/${name}"
}

# Record that a stub was called, so a test can assert something did NOT run.
stub_recording() {
    local name="$1"
    stub "$name" <<EOF
echo "\$0 \$*" >> "${BATS_TEST_TMPDIR}/calls.log"
exit 0
EOF
}

called() {
    grep -q "$1" "${BATS_TEST_TMPDIR}/calls.log" 2>/dev/null
}

# Create a file with an mtime far enough in the past to look old.
make_old_file() {
    local path="$1"
    touch "$path"
    touch -mt 202001010000 "$path"
}
