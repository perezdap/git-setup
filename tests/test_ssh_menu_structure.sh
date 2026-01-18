#!/bin/bash
# tests/test_ssh_menu_structure.sh

source ./setup.sh > /dev/null

echo "Checking for 'Manage SSH Keys' in main menu..."

# Mocking main menu loop by checking its content if possible or just verifying if the function exists
# and contains the string.
if grep -q "Manage SSH Keys" setup.sh; then
    echo "PASS: 'Manage SSH Keys' option found in setup.sh"
else
    echo "FAIL: 'Manage SSH Keys' option not found in setup.sh"
    exit 1
fi
