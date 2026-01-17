# tests/Test-ProfileManagementStructure.ps1
. ./setup.ps1
Write-Host "Checking for Phase 3 functions in setup.ps1..."

foreach ($func in "Remove-GitProfile", "Edit-GitProfile") {
    if (-not (Get-Command $func -ErrorAction SilentlyContinue)) {
        Write-Error "FAIL: $func function not found"
        exit 1
    }
}

Write-Host "PASS: Phase 3 structure check"
