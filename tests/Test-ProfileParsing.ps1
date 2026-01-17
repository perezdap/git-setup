# tests/Test-ProfileParsing.ps1
$ErrorActionPreference = 'Stop'

Write-Host "Running tests for profile parsing..."

# Dot-source the setup script
. ./setup.ps1

# Mock Git command
function git {
    param($a, $b, $c)
    if ($a -eq "config" -and $b -eq "--global" -and $c -eq "--list") {
        # Simulate git config --list output
        Write-Output "includeIf.gitdir:~/Work/.path=~/.gitconfig-work"
        Write-Output "includeIf.gitdir:~/Personal/.path=~/.gitconfig-personal"
    } else {
        # Fallback to actual git if needed, or just do nothing
    }
}

if (-not (Get-Command Get-GitProfiles -ErrorAction SilentlyContinue)) {
    Write-Error "FAIL: Get-GitProfiles function not found"
    exit 1
}

$profiles = Get-GitProfiles

if ($profiles.Count -ne 2) {
    Write-Error "FAIL: Expected 2 profiles, got $($profiles.Count)"
    exit 1
}

if ($profiles[0].Path -ne "~/Work/" -or $profiles[0].ConfigPath -ne "~/.gitconfig-work") {
     Write-Error "FAIL: First profile mismatch"
     exit 1
}

Write-Host "PASS: Profiles parsed correctly"
