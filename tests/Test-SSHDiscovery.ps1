# tests/Test-SSHDiscovery.ps1
$ErrorActionPreference = 'Stop'

Write-Host "Running tests for Get-SSHKeys..."

. ./setup.ps1

# Setup mock SSH directory
$TestSSHDir = Join-Path $PWD "test_ssh_keys_ps"
New-Item -ItemType Directory -Path $TestSSHDir -Force | Out-Null

# Cleanup block
try {
    # Create dummy keys
    New-Item -ItemType File -Path (Join-Path $TestSSHDir "id_rsa") | Out-Null
    New-Item -ItemType File -Path (Join-Path $TestSSHDir "id_ed25519") | Out-Null
    New-Item -ItemType File -Path (Join-Path $TestSSHDir "id_ed25519_work") | Out-Null
    New-Item -ItemType File -Path (Join-Path $TestSSHDir "known_hosts") | Out-Null
    New-Item -ItemType File -Path (Join-Path $TestSSHDir "config") | Out-Null

    if (-not (Get-Command Get-SSHKeys -ErrorAction SilentlyContinue)) {
        Write-Error "FAIL: Get-SSHKeys function not found (Expected failure for TDD)"
        exit 1
    }

    # Run Get-SSHKeys. We need to support passing the path or mock HOME.
    # Let's assume we update Get-SSHKeys to take an optional path for testing.
    $keys = Get-SSHKeys -Path $TestSSHDir

    $keyNames = $keys | ForEach-Object { $_.Name }

    if ($keyNames -contains "id_rsa" -and $keyNames -contains "id_ed25519" -and $keyNames -contains "id_ed25519_work") {
        if ($keyNames -notcontains "known_hosts" -and $keyNames -notcontains "config") {
            Write-Host "PASS: Get-SSHKeys correctly listed keys and ignored non-keys"
        } else {
            Write-Error "FAIL: Get-SSHKeys listed non-key files"
            exit 1
        }
    } else {
        Write-Error "FAIL: Get-SSHKeys failed to list all keys"
        exit 1
    }

} finally {
    Remove-Item -Recurse -Path $TestSSHDir -Force -ErrorAction SilentlyContinue
}
