#!/bin/bash
# tests/test_ssh_generation.sh

source ./setup.sh > /dev/null

echo "Running tests for generate_new_ssh_key..."

TEST_SSH_DIR="./test_ssh_gen_keys"
mkdir -p "$TEST_SSH_DIR"

cleanup() {
    rm -rf "$TEST_SSH_DIR"
}
trap cleanup EXIT

# Mock ssh-keygen
ssh-keygen() {
    # Extract the -f argument to know where to write
    local output_file=""
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f)
                output_file="$2"
                shift # past argument
                shift # past value
                ;;
            *)
                shift # past argument
                ;;
        esac
    done
    
    if [ -z "$output_file" ]; then
        echo "Mock ssh-keygen: No output file specified"
        return 1
    fi
    
    touch "$output_file"
    touch "$output_file.pub"
    echo "Mock public key content" > "$output_file.pub"
}

# Mock git to return a dummy email
git() {
    if [[ "$*" == "config --global user.email" ]]; then
        echo "test@example.com"
    else
        command git "$@"
    fi
}

# Check existence
if ! type generate_new_ssh_key &> /dev/null; then
    echo "FAIL: generate_new_ssh_key function not found"
    exit 1
fi

# Test 1: Generate key with custom name
# Input: Key Name -> "my_test_key"
# Expected: File created at $TEST_SSH_DIR/id_ed25519_my_test_key

# We need to override the default SSH dir in the function or mock HOME.
# Let's verify if generate_new_ssh_key allows passing base dir. 
# If not, we use HOME mock.
HOME_BACKUP="$HOME"
export HOME="."
ln -s "$TEST_SSH_DIR" .ssh

# Run function with input
echo "my_test_key" | generate_new_ssh_key > /dev/null

# Verify
if [ -f ".ssh/id_ed25519_my_test_key" ]; then
    echo "PASS: Custom named key created"
else
    echo "FAIL: Custom named key not found"
    ls -l .ssh/
    exit 1
fi

# Cleanup
rm .ssh
export HOME="$HOME_BACKUP"
