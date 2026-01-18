#!/bin/bash
# tests/test_profile_ssh_integration.sh

# Mock git before sourcing setup.sh if needed, but setup.sh uses git
# We'll just ensure it's in the path or mock it.
git() {
    if [[ "$*" == "config --global"* ]]; then
        return 0 # Mock global config success
    fi
    command git "$@"
}
export -f git

source ./setup.sh > /dev/null

echo "Running tests for profile SSH integration..."

TEST_DIR="./test_project_ssh"
mkdir -p "$TEST_DIR"

# Mock HOME to control where .ssh and .gitconfig are
HOME_BACKUP="$HOME"
export HOME="$PWD/temp_home"
mkdir -p "$HOME/.ssh"

cleanup() {
    rm -rf "$TEST_DIR"
    rm -rf "$HOME"
    export HOME="$HOME_BACKUP"
}
trap cleanup EXIT

# Create a dummy key
touch "$HOME/.ssh/id_ed25519_test"

# Test save_git_profile with ssh_key
# Arguments: target_dir, name, email, profile_name, ssh_key
save_git_profile "$TEST_DIR" "Test User" "test@example.com" "test_ssh_profile" "id_ed25519_test"

# Verify file content
config_file="$HOME/.gitconfig-test_ssh_profile"
if [ ! -f "$config_file" ]; then
    echo "FAIL: Config file not created at $config_file"
    exit 1
fi

if grep -q "sshCommand = ssh -i" "$config_file" && grep -q "id_ed25519_test" "$config_file"; then
    echo "PASS: .gitconfig contains correct sshCommand"
else
    echo "FAIL: .gitconfig does not contain correct sshCommand"
    cat "$config_file"
    exit 1
fi