# tests/Test-ProfileSSHIntegration.ps1
$ErrorActionPreference = 'Stop'

Write-Host "Running tests for profile SSH integration..."

. ./setup.ps1

$TestDir = Join-Path $PWD "test_project_ssh_ps"
New-Item -ItemType Directory -Path $TestDir -Force | Out-Null

$TempHome = Join-Path $PWD "temp_home_ps"
New-Item -ItemType Directory -Path $TempHome -Force | Out-Null

$ProfileName = "test_ssh_profile_tdd"
# We can't mock $HOME, so we'll just check if we can pass paths or if we can mock the functions that use it.

# Let's mock Get-Item for $HOME if possible? No.
# Let's just use the real $HOME but with a unique name and CLEAN UP.

$ConfigFile = Join-Path $HOME ".gitconfig-$ProfileName"
$SshDir = Join-Path $HOME ".ssh"
$KeyFile = Join-Path $SshDir "id_ed25519_test_tdd"

# Mock git
function git {
    param([Parameter(ValueFromRemainingArguments=$true)]$args)
    return
}

try {
    # Create a dummy key
    if (-not (Test-Path $SshDir)) { New-Item -ItemType Directory -Path $SshDir -Force | Out-Null }
    New-Item -ItemType File -Path $KeyFile -Force | Out-Null

    # Test Save-GitProfile with SSH key
    Save-GitProfile -TargetDir $TestDir -Name "Test User" -Email "test@example.com" -ProfileName $ProfileName -SshKey "id_ed25519_test_tdd"

    if (Test-Path $ConfigFile) {
        $content = Get-Content $ConfigFile -Raw
        if ($content -match "sshCommand = ssh -i" -and $content -match "id_ed25519_test_tdd") {
            Write-Host "PASS: .gitconfig contains correct sshCommand"
        } else {
            Write-Error "FAIL: .gitconfig does not contain correct sshCommand"
            Write-Host "Content: $content"
            exit 1
        }
    } else {
        Write-Error "FAIL: Config file not found at $ConfigFile"
        exit 1
    }
} finally {
    Remove-Item -Recurse $TestDir -Force -ErrorAction SilentlyContinue
    if (Test-Path $ConfigFile) { Remove-Item $ConfigFile -Force }
    if (Test-Path $KeyFile) { Remove-Item $KeyFile -Force }
}
