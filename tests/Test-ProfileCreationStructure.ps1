# tests/Test-ProfileCreationStructure.ps1
. ./setup.ps1
Write-Host "Checking for Phase 2 functions in setup.ps1..."

if (-not (Get-Command Add-GitProfile -ErrorAction SilentlyContinue)) {
    Write-Error "FAIL: Add-GitProfile function not found"
    exit 1
}

if (-not (Get-Command Save-GitProfile -ErrorAction SilentlyContinue)) {
    Write-Error "FAIL: Save-GitProfile function not found"
    exit 1
}

Write-Host "PASS: Phase 2 structure check"
