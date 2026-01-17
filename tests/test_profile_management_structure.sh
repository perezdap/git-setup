#!/bin/bash
# tests/test_profile_management_structure.sh
source ./setup.sh > /dev/null
echo "Checking for Phase 3 functions in setup.sh..."

for func in remove_profile edit_profile; do
    if ! type $func &> /dev/null; then
        echo "FAIL: $func function not found"
        exit 1
    fi
done

echo "PASS: Phase 3 structure check"
