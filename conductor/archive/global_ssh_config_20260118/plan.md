# Implementation Plan: Global SSH Configuration

## Phase 1: PowerShell Implementation (`setup.ps1`)
- [ ] **Modify `Set-GitIdentity` function**:
    - Read current `core.sshCommand` using `git config --global core.sshCommand`.
    - Present options to the user:
        1. Select existing key (reuse `Get-SSHKeys` logic).
        2. Generate new key (reuse `New-SSHKey` logic).
        3. Revert to system default (unset config).
        4. Skip/Keep current.
    - Apply the configuration.

## Phase 2: Bash Implementation (`setup.sh`)
- [ ] **Modify `configure_identity` function**:
    - Read current `core.sshCommand`.
    - Implement similar selection logic as Phase 1 using `list_ssh_keys`.
    - Apply the configuration using `git config --global`.

## Phase 3: Verification
- [ ] **Manual Test**:
    - Run `setup.ps1` -> Option 1. Change global key. Verify with `git config --global --list`.
    - Run `setup.sh` (if environment permits, or rely on logic parity).
