# tests/Test-SSHMenuStructure.ps1
$ErrorActionPreference = 'Stop'

Write-Host "Checking for 'Manage SSH Keys' in main menu..."

$content = Get-Content setup.ps1 -Raw
if ($content -match "Manage SSH Keys") {
    Write-Host "PASS: 'Manage SSH Keys' option found in setup.ps1"
} else {
    Write-Error "FAIL: 'Manage SSH Keys' option not found in setup.ps1"
    exit 1
}
