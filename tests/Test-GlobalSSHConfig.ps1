Write-Host "Running content verification for Global SSH Config in setup.ps1..."

$content = Get-Content "./setup.ps1" -Raw

$checks = @(
    "function Set-GitIdentity",
    "Current Global SSH Key:",
    "Do you want to configure the global SSH key?",
    "git config --global core.sshCommand"
)

foreach ($check in $checks) {
    if ($content -notmatch [regex]::Escape($check)) {
        Write-Error "FAIL: Expected string '$check' not found in setup.ps1"
        exit 1
    }
}

Write-Host "PASS: setup.ps1 contains Global SSH Config logic"
