# Specification: Global SSH Configuration

## Overview
Currently, the Git Setup Tool allows configuring specific SSH keys for specific directories (profiles) but relies on the system default (usually `~/.ssh/id_ed25519` or `~/.ssh/id_rsa`) for the global scope. This feature adds the ability to explicitly configure a global SSH key using `git config --global core.sshCommand`.

## Functional Requirements
1.  **Global Identity Configuration Update**:
    - The "Configure Global Identity" flow (Option 1 in the main menu) must be expanded.
    - After setting `user.name` and `user.email`, prompt the user to configure the global SSH key.
2.  **SSH Key Selection**:
    - Show the current global `core.sshCommand` value (if any).
    - Allow the user to:
        - **Keep current**: Don't change anything.
        - **Select existing key**: Choose from keys found in `~/.ssh/`.
        - **Generate new key**: Create a new key and assign it globally.
        - **Use System Default**: Unset `core.sshCommand` to revert to default behavior.
3.  **Git Configuration**:
    - If a key is selected, execute: `git config --global core.sshCommand "ssh -i <path/to/key>"`
    - If "System Default" is chosen, execute: `git config --global --unset core.sshCommand`

## Non-Functional Requirements
- **Consistency**: The user experience should match the "Add Profile" SSH selection flow.
- **Cross-Platform**: Must work on both PowerShell (`setup.ps1`) and Bash (`setup.sh`).
