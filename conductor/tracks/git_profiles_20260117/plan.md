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

## Phase 2: Interactive Profile Creation
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
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Interactive Profile Creation' (Protocol in workflow.md)

## Phase 3: Profile Management (Edit/Remove)
- [ ] Task: Implement "Remove Profile" functionality.
    - [ ] Bash: Create `remove_profile` function (cleanup `.gitconfig` and delete secondary file).
    - [ ] PowerShell: Create `Remove-GitProfile` function.
- [ ] Task: Implement "Edit Profile" functionality.
    - [ ] Bash: Create `edit_profile` function to update existing secondary config files.
    - [ ] PowerShell: Create `Edit-GitProfile` function.
- [ ] Task: Write TDD tests for management functions.
- [ ] Task: Conductor - User Manual Verification 'Phase 3: Profile Management (Edit/Remove)' (Protocol in workflow.md)

## Phase 4: Final Integration & Main Menu
- [ ] Task: Update the main interactive menu to include Profile Management.
    - [ ] Bash: Add "Manage Folder Profiles" option to the main loop.
    - [ ] PowerShell: Add "Manage Folder Profiles" option to the main loop.
- [ ] Task: Final cross-platform verification and cleanup.
- [ ] Task: Conductor - User Manual Verification 'Phase 4: Final Integration & Main Menu' (Protocol in workflow.md)
