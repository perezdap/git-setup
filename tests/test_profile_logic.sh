#!/bin/bash
# tests/test_profile_logic.sh
source ./setup.sh > /dev/null

# Mock git config
git() {
    if [[ "$1" == "config" && "$2" == "--global" ]]; then
        return 0
    else
        command git "$@"
    fi
}

# Create a temp directory to simulate the target
TEMP_TARGET=$(mktemp -d)
PROFILE_NAME="test-logic"

# Call logic function
save_git_profile "$TEMP_TARGET" "Logic Test" "logic@test.com" "$PROFILE_NAME"

# Verify config file exists
if [ -f "$HOME/.gitconfig-$PROFILE_NAME" ]; then
    echo "PASS: Profile config file created"
    # Check content
    if grep -q "email = logic@test.com" "$HOME/.gitconfig-$PROFILE_NAME"; then
        echo "PASS: Config content correct"
    else
        echo "FAIL: Config content incorrect"
        rm "$HOME/.gitconfig-$PROFILE_NAME"
        exit 1
    fi
    # Cleanup
    rm "$HOME/.gitconfig-$PROFILE_NAME"
else
    echo "FAIL: Profile config file not created"
    exit 1
fi

rm -rf "$TEMP_TARGET"
