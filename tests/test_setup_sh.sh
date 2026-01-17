#!/bin/bash
# Simple test runner for setup.sh

echo "Running tests for setup.sh..."

# Check if setup.sh exists
if [ ! -f "./setup.sh" ]; then
    echo "FAIL: setup.sh not found"
    exit 1
fi

# Run setup.sh with a flag or dry-run to check logging (we'll implement a helper function test)
# For now, let's just grep for the logging function definition
if ! grep -q "log_info" ./setup.sh; then
    echo "FAIL: log_info function not found in setup.sh"
    exit 1
fi

echo "PASS: setup.sh structure check"
