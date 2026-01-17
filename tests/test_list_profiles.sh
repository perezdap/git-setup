#!/bin/bash
# tests/test_list_profiles.sh

source ./setup.sh > /dev/null

echo "Running tests for list_profiles..."

# Mock get_git_profiles to return deterministic data
get_git_profiles() {
    echo "~/Work/:~/.gitconfig-work"
    echo "~/Personal/:~/.gitconfig-personal"
}

# Check if list_profiles exists
if ! type list_profiles &> /dev/null; then
    echo "FAIL: list_profiles function not found"
    exit 1
fi

# Run list_profiles
output=$(list_profiles)

# Check expectation
# We expect something like:
# Found 2 profiles:
# 1. Path: ~/Work/ -> Config: ~/.gitconfig-work
# 2. Path: ~/Personal/ -> Config: ~/.gitconfig-personal

if [[ "$output" == *"~/Work/"* ]] && [[ "$output" == *"~/.gitconfig-work"* ]]; then
    echo "PASS: list_profiles output looks correct"
else
    echo "FAIL: Output did not match expectation"
    echo "Got:"
    echo "$output"
    exit 1
fi
