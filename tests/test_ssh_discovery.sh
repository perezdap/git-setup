#!/bin/bash
# tests/test_ssh_discovery.sh

source ./setup.sh > /dev/null

echo "Running tests for list_ssh_keys..."

# Setup mock SSH directory
TEST_SSH_DIR="./test_ssh_keys"
mkdir -p "$TEST_SSH_DIR"

# Cleanup function
cleanup() {
    rm -rf "$TEST_SSH_DIR"
}
trap cleanup EXIT

# Create dummy keys
touch "$TEST_SSH_DIR/id_rsa"
touch "$TEST_SSH_DIR/id_ed25519"
touch "$TEST_SSH_DIR/id_ed25519_work"
touch "$TEST_SSH_DIR/known_hosts" # Should be ignored
touch "$TEST_SSH_DIR/config" # Should be ignored

# Check if list_ssh_keys exists (we haven't implemented it yet, so this check validates the test itself)
if ! type list_ssh_keys &> /dev/null; then
    echo "Function list_ssh_keys not found (Expected failure for TDD)"
    # We exit 1 here to signal failure, but since we are in TDD Red phase, 
    # we proceed to checking if the output matches expectations if the function DID exist.
    # However, to properly fail, we'll just exit 1 now.
    exit 1
fi

# Run list_ssh_keys with the test directory
output=$(list_ssh_keys "$TEST_SSH_DIR")

# Expectations
if [[ "$output" == *"id_rsa"* ]] && [[ "$output" == *"id_ed25519"* ]] && [[ "$output" == *"id_ed25519_work"* ]]; then
    if [[ "$output" != *"known_hosts"* ]] && [[ "$output" != *"config"* ]]; then
        echo "PASS: list_ssh_keys correctly listed keys and ignored non-keys"
    else
        echo "FAIL: list_ssh_keys listed non-key files"
        echo "$output"
        exit 1
    fi
else
    echo "FAIL: list_ssh_keys failed to list all keys"
    echo "$output"
    exit 1
fi
