# tests/Test-ReadmeContent.ps1
$ReadmePath = "README.md"

if (-not (Test-Path $ReadmePath)) {
    Write-Error "FAIL: README.md not found"
    exit 1
}

$Content = Get-Content $ReadmePath -Raw
$RequiredStrings = @(
    "# Git Environment Setup Tool",
    "## Core Features",
    "## Prerequisites",
    "Windows PowerShell 5.1+",
    "Bash 3.2+"
)

foreach ($str in $RequiredStrings) {
    if ($Content -notmatch [regex]::Escape($str)) {
        Write-Error "FAIL: Missing required string: '$str'"
        exit 1
    }
}

Write-Host "PASS: README content check"
