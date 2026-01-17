#!/bin/bash
# tests/test_profile_creation_structure.sh
source ./setup.sh > /dev/null
echo "Checking for Phase 2 functions in setup.sh..."

if ! type add_profile &> /dev/null; then
    echo "FAIL: add_profile function not found"
    exit 1
fi

if ! type save_git_profile &> /dev/null; then
    echo "FAIL: save_git_profile function not found"
    exit 1
fi

echo "PASS: Phase 2 structure check"
