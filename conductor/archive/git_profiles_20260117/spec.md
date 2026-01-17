# Specification: Folder-Based Identity Profiles

## Overview
This feature allows users to configure distinct Git identities (name, email, and optionally SSH keys) for different directory trees on their system. This is specifically designed for users who balance multiple Git accounts (e.g., Personal and Work) on a single machine.

## Functional Requirements
- **Interactive Profile Wizard**: A new interactive command/flow to add a profile.
    - Prompt for target directory path.
    - Prompt for user name and email.
    - Offer to generate a new SSH key for the profile (with the option to decline).
- **Git `includeIf` Implementation**: 
    - Automatically update the global `~/.gitconfig` to use conditional includes (`[includeIf "gitdir:<path>/"]`).
    - Create and manage profile-specific config files (e.g., `~/.gitconfig-work`) in the global Git directory.
- **Profile Management**:
    - **List**: Display all configured folder-based profiles.
    - **Edit**: Update the name or email of an existing profile.
    - **Remove**: Delete a profile configuration and remove its reference from the global `.gitconfig`.

## Non-Functional Requirements
- **Cross-Platform Consistency**: The feature must work identically in both the Bash/Zsh (`setup.sh`) and PowerShell (`setup.ps1`) versions of the tool.
- **Zero Dependencies**: Implementation must rely only on native shell commands and Git.

## Acceptance Criteria
- [ ] Users can successfully add a new profile for a specific folder.
- [ ] Git correctly uses the profile identity when inside the target folder (verified via `git config user.email`).
- [ ] Users can list, edit, and remove profiles through the interactive tool.
- [ ] SSH key generation is offered during profile creation but can be skipped.

## Out of Scope
- Automatic detection of account type based on folder names.
- Integration with third-party SSH managers (e.g., 1Password) beyond standard file-based key generation.
