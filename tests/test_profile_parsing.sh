#!/bin/bash
# tests/test_profile_parsing.sh

# Source the setup script (suppressing output)
source ./setup.sh > /dev/null

echo "Running tests for profile parsing..."

# Create a temporary directory for our test gitconfig
TEMP_DIR=$(mktemp -d)
TEST_CONFIG="$TEMP_DIR/gitconfig"

# Cleanup function
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Setup test data
cat > "$TEST_CONFIG" <<EOF
[user]
    name = Global User
    email = global@example.com
[includeIf "gitdir:~/Work/"]
    path = ~/.gitconfig-work
[includeIf "gitdir:~/Personal/"]
    path = ~/.gitconfig-personal
EOF

# Define the function we expect to exist (it's not in setup.sh yet, so this check will fail or the function call will fail)
if ! type get_git_profiles &> /dev/null; then
    echo "FAIL: get_git_profiles function not found"
    exit 1
fi

# Run the function with our test config (we'll need to allow injecting the config file path or mock 'git config --list')
# For now, let's assume the function parses 'git config --global --list'
# We will mock git for the duration of the test
git() {
    if [[ "$1" == "config" && "$2" == "--global" && "$3" == "--list" ]]; then
        # Simulate output of git config --list
        # includeIf.gitdir:~/Work/.path=~/.gitconfig-work
        # includeIf.gitdir:~/Personal/.path=~/.gitconfig-personal
        echo "includeIf.gitdir:~/Work/.path=~/.gitconfig-work"
        echo "includeIf.gitdir:~/Personal/.path=~/.gitconfig-personal"
    else
        command git "$@"
    fi
}

# Capture output
output=$(get_git_profiles)

# Check expectation
expected_work="~/Work/:~/.gitconfig-work"
expected_personal="~/Personal/:~/.gitconfig-personal"

if [[ "$output" == *"$expected_work"* ]] && [[ "$output" == *"$expected_personal"* ]]; then
    echo "PASS: Profiles parsed correctly"
else
    echo "FAIL: Output did not match expectation"
    echo "Got:"
    echo "$output"
    exit 1
fi
