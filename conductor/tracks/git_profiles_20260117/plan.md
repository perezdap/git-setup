# Implementation Plan: Folder-Based Identity Profiles

This plan outlines the implementation of folder-based Git identity profiles using Git's `includeIf` feature, supporting both Bash and PowerShell environments.

## Phase 1: Foundation & Profile Listing [checkpoint: 45738b7]
- [x] Task: Implement a mechanism to parse existing `includeIf` entries from `.gitconfig`. a6a496f
    - [x] Bash: Add helper to extract `includeIf` paths and their corresponding config files.
    - [x] PowerShell: Add helper to extract `includeIf` paths and their corresponding config files.
- [x] Task: Implement the "List Profiles" functionality. fb15ead
    - [x] Bash: Create `list_profiles` function.
    - [x] PowerShell: Create `Show-GitProfiles` function.
- [x] Task: Conductor - User Manual Verification 'Phase 1: Foundation & Profile Listing' (Protocol in workflow.md) 45738b7

## Phase 2: Interactive Profile Creation [checkpoint: 31ff979]
- [x] Task: Implement the "Add Profile" wizard. b77a164
    - [x] Bash: Create `add_profile` function with prompts for path, name, and email.
    - [x] PowerShell: Create `Add-GitProfile` function with prompts for path, name, and email.
- [x] Task: Implement `includeIf` configuration logic. b77a164
    - [x] Bash: Update `~/.gitconfig` and create the secondary config file.
    - [x] PowerShell: Update `~/.gitconfig` and create the secondary config file.
- [x] Task: Implement optional SSH key generation within the wizard. b77a164
    - [x] Bash: Integrate `setup_ssh` logic into `add_profile`.
    - [x] PowerShell: Integrate `Set-SSHKeys` logic into `Add-GitProfile`.
- [x] Task: Write TDD tests for profile creation. b77a164
    - [x] Verify `.gitconfig` modifications.
    - [x] Verify secondary config file content.
- [x] Task: Conductor - User Manual Verification 'Phase 2: Interactive Profile Creation' (Protocol in workflow.md) 31ff979

## Phase 3: Profile Management (Edit/Remove) [checkpoint: 5fc3c23]
- [x] Task: Implement "Remove Profile" functionality. e805f87
    - [x] Bash: Create `remove_profile` function (cleanup `.gitconfig` and delete secondary file).
    - [x] PowerShell: Create `Remove-GitProfile` function.
- [x] Task: Implement "Edit Profile" functionality. e805f87
    - [x] Bash: Create `edit_profile` function to update existing secondary config files.
    - [x] PowerShell: Create `Edit-GitProfile` function.
- [x] Task: Write TDD tests for management functions. e805f87
- [x] Task: Conductor - User Manual Verification 'Phase 3: Profile Management (Edit/Remove)' (Protocol in workflow.md) 5fc3c23

## Phase 4: Final Integration & Main Menu [checkpoint: b396722]
- [x] Task: Update the main interactive menu to include Profile Management. 0ffdd99
    - [x] Bash: Add "Manage Folder Profiles" option to the main loop.
    - [x] PowerShell: Add "Manage Folder Profiles" option to the main loop.
- [x] Task: Final cross-platform verification and cleanup. 0ffdd99
- [x] Task: Conductor - User Manual Verification 'Phase 4: Final Integration & Main Menu' (Protocol in workflow.md) b396722
