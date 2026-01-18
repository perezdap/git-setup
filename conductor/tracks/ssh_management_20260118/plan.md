# Implementation Plan: SSH Key Management

## Phase 1: SSH Discovery and Generation Core [checkpoint: d5d260f]
Focus on building the underlying utility functions for both Bash and PowerShell to handle SSH keys.

- [x] Task: Implement SSH Key Discovery Utility
    - [x] **Bash:** Create function in `setup.sh` to scan `~/.ssh` for private keys.
    - [x] **PowerShell:** Create function in `setup.ps1` to scan `$HOME\.ssh` for private keys.
- [x] Task: Implement SSH Key Generation Utility
    - [x] **Bash:** Create function to wrap `ssh-keygen` with interactive naming and output display.
    - [x] **PowerShell:** Create function to wrap `ssh-keygen.exe` with interactive naming and output display.
- [x] Task: Conductor - User Manual Verification 'SSH Discovery and Generation Core' (Protocol in workflow.md)

## Phase 2: Standalone SSH Manager Menu [checkpoint: 447c938]
Add the interface for managing SSH keys independently of Git profiles.

- [x] Task: Create SSH Management Menu
    - [x] **Bash:** Implement "Manage SSH Keys" menu item and logic.
    - [x] **PowerShell:** Implement "Manage SSH Keys" menu item and logic.
- [x] Task: Implement "List Keys" and "View Public Key" actions
    - [x] **Bash:** Connect menu actions to Discovery/Generation utilities.
    - [x] **PowerShell:** Connect menu actions to Discovery/Generation utilities.
- [x] Task: Conductor - User Manual Verification 'Standalone SSH Manager Menu' (Protocol in workflow.md)

## Phase 3: Profile Integration (The "Hybrid" Flow)
Update the Git Profile wizard to include SSH key assignment.

- [ ] Task: Update Profile Creation/Editing Logic
    - [ ] **Bash:** Add SSH key selection/generation step to the profile wizard.
    - [ ] **PowerShell:** Add SSH key selection/generation step to the profile wizard.
- [ ] Task: Implement `core.sshCommand` Configuration
    - [ ] **Bash:** Update profile file writing logic to include `core.sshCommand` with native paths.
    - [ ] **PowerShell:** Update profile file writing logic to include `core.sshCommand` with native paths.
- [ ] Task: Conductor - User Manual Verification 'Profile Integration' (Protocol in workflow.md)

## Phase 4: Final Verification and Documentation
Ensure cross-platform parity and update any instructions.

- [ ] Task: Cross-Platform Path Verification
    - [ ] Verify `core.sshCommand` paths work correctly in PowerShell with Git for Windows.
    - [ ] Verify paths work correctly in Bash on *nix.
- [ ] Task: Update Internal Documentation
    - [ ] Add notes on SSH key management to the interactive help/guides.
- [ ] Task: Conductor - User Manual Verification 'Final Verification and Documentation' (Protocol in workflow.md)
