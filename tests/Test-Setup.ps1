Write-Host "Running tests for setup.ps1..."

if (-not (Test-Path "./setup.ps1")) {
    Write-Error "FAIL: setup.ps1 not found"
    exit 1
}

# Check for Log-Info function
$content = Get-Content "./setup.ps1" -Raw
if ($content -notmatch "function Log-Info") {
    Write-Error "FAIL: Log-Info function not found in setup.ps1"
    exit 1
}

Write-Host "PASS: setup.ps1 structure check"
