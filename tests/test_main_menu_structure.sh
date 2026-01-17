#!/bin/bash
# tests/test_main_menu_structure.sh
source ./setup.sh > /dev/null
echo "Checking for profile management entry point in setup.sh..."

if ! type manage_profiles &> /dev/null; then
    echo "FAIL: manage_profiles function not found"
    exit 1
fi

echo "PASS: Phase 4 structure check"
