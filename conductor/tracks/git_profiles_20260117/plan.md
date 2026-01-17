# Implementation Plan: Folder-Based Identity Profiles

This plan outlines the implementation of folder-based Git identity profiles using Git's `includeIf` feature, supporting both Bash and PowerShell environments.

## Phase 1: Foundation & Profile Listing
- [x] Task: Implement a mechanism to parse existing `includeIf` entries from `.gitconfig`. a6a496f
    - [x] Bash: Add helper to extract `includeIf` paths and their corresponding config files.
    - [x] PowerShell: Add helper to extract `includeIf` paths and their corresponding config files.
- [ ] Task: Implement the "List Profiles" functionality.
    - [ ] Bash: Create `list_profiles` function.
    - [ ] PowerShell: Create `Get-GitProfiles` function.
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Foundation & Profile Listing' (Protocol in workflow.md)

## Phase 2: Interactive Profile Creation
- [ ] Task: Implement the "Add Profile" wizard.
    - [ ] Bash: Create `add_profile` function with prompts for path, name, and email.
    - [ ] PowerShell: Create `Add-GitProfile` function with prompts for path, name, and email.
- [ ] Task: Implement `includeIf` configuration logic.
    - [ ] Bash: Update `~/.gitconfig` and create the secondary config file.
    - [ ] PowerShell: Update `~/.gitconfig` and create the secondary config file.
- [ ] Task: Implement optional SSH key generation within the wizard.
    - [ ] Bash: Integrate `setup_ssh` logic into `add_profile`.
    - [ ] PowerShell: Integrate `Set-SSHKeys` logic into `Add-GitProfile`.
- [ ] Task: Write TDD tests for profile creation.
    - [ ] Verify `.gitconfig` modifications.
    - [ ] Verify secondary config file content.
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
