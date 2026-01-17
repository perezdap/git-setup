# tests/Test-MainMenuStructure.ps1
. ./setup.ps1
Write-Host "Checking for profile management entry point in setup.ps1..."

if (-not (Get-Command Show-ProfileMenu -ErrorAction SilentlyContinue)) {
    Write-Error "FAIL: Show-ProfileMenu function not found"
    exit 1
}

Write-Host "PASS: Phase 4 structure check"
