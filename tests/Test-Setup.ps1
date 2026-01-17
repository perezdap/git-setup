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

# Check for Test-GitInstalled function
if ($content -notmatch "function Test-GitInstalled") {
    Write-Error "FAIL: Test-GitInstalled function not found in setup.ps1"
    exit 1
}

# Check for Set-GitIdentity function
if ($content -notmatch "function Set-GitIdentity") {
    Write-Error "FAIL: Set-GitIdentity function not found in setup.ps1"
    exit 1
}

# Check for Set-SSHKeys function
if ($content -notmatch "function Set-SSHKeys") {
    Write-Error "FAIL: Set-SSHKeys function not found in setup.ps1"
    exit 1
}

# Check for Show-SSHWalkthrough function
if ($content -notmatch "function Show-SSHWalkthrough") {
    Write-Error "FAIL: Show-SSHWalkthrough function not found in setup.ps1"
    exit 1
}

Write-Host "PASS: setup.ps1 structure check"
