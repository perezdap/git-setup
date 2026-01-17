# tests/Test-ListProfiles.ps1
$ErrorActionPreference = 'Stop'

Write-Host "Running tests for Show-GitProfiles..."

. ./setup.ps1

# Mock Get-GitProfiles
function Get-GitProfiles {
    return @(
        [PSCustomObject]@{ Path = "~/Work/"; ConfigPath = "~/.gitconfig-work" },
        [PSCustomObject]@{ Path = "~/Personal/"; ConfigPath = "~/.gitconfig-personal" }
    )
}

if (-not (Get-Command Show-GitProfiles -ErrorAction SilentlyContinue)) {
    Write-Error "FAIL: Show-GitProfiles function not found"
    exit 1
}

# Run Show-GitProfiles (we can't easily capture host output without redirection, but we can just check it runs)
# For a robust test, we might want to change Show-GitProfiles to return string or write to a stream we can capture.
# For now, let's just check existence and that it runs without error.

try {
    Show-GitProfiles
    Write-Host "PASS: Show-GitProfiles ran successfully"
} catch {
    Write-Error "FAIL: Show-GitProfiles threw an error: $_"
    exit 1
}
