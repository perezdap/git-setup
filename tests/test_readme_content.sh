#!/bin/bash
# tests/test_readme_content.sh

README="README.md"

if [ ! -f "$README" ]; then
    echo "FAIL: README.md not found"
    exit 1
fi

# Check for required sections
required_strings=(
    "# Git Environment Setup Tool"
    "## Core Features"
    "## Prerequisites"
    "Windows PowerShell 5.1+"
    "Bash 3.2+"
    "## Installation & Usage"
    "### Option 1: Direct Execution"
    "git clone https://github.com/perezdap/git-setup.git"
    "./setup.sh"
    ".\setup.ps1"
    "### Option 2: One-Liner (Remote)"
)

for str in "${required_strings[@]}"; do
    if ! grep -Fq "$str" "$README"; then
        echo "FAIL: Missing required string: '$str'"
        exit 1
    fi
done

echo "PASS: README content check"
