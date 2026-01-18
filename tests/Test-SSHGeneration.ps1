# tests/Test-SSHGeneration.ps1
$ErrorActionPreference = 'Stop'

Write-Host "Running tests for New-SSHKey..."

. ./setup.ps1

$TestSSHDir = Join-Path $PWD "test_ssh_gen_keys_ps"
New-Item -ItemType Directory -Path $TestSSHDir -Force | Out-Null

# Mock git
function git {
    param($a, $b, $c, $d)
    if ($c -eq "user.email") { return "test@example.com" }
    return "git output"
}

# Mock ssh-keygen
function ssh-keygen {
    param($t, $C, $f, $N)
    New-Item -ItemType File -Path $f -Force | Out-Null
    New-Item -ItemType File -Path "$f.pub" -Value "Mock public key" -Force | Out-Null
}

try {
    if (-not (Get-Command New-SSHKey -ErrorAction SilentlyContinue)) {
        Write-Error "FAIL: New-SSHKey function not found"
        exit 1
    }

    # Helper to mock Read-Host
    # Since we can't easily mock Read-Host in a script without more complex module injection,
    # we will modify New-SSHKey to accept parameters OR we assume it takes a name.
    # The requirement says "interactive naming". 
    # For testing, best practice is to allow parameter overrides.
    # Let's assume New-SSHKey takes a -Name parameter that overrides interactive input,
    # or -NonInteractive flag.
    # Or we can pipe input if it reads from stdin (but Read-Host doesn't work that way easily).
    
    # We'll try to implement New-SSHKey so it takes an optional Name parameter.
    
    # Test: Generate key with custom name
    New-SSHKey -Name "my_test_key" -Path $TestSSHDir

    if (Test-Path (Join-Path $TestSSHDir "id_ed25519_my_test_key")) {
        Write-Host "PASS: Custom named key created"
    } else {
        Write-Error "FAIL: Custom named key not found"
        exit 1
    }

} finally {
    Remove-Item -Recurse -Path $TestSSHDir -Force -ErrorAction SilentlyContinue
}
