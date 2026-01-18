# Specification: SSH Key Management

## Overview
Implement automated SSH key management that integrates with the existing folder-based Git profile system. This enables users to automatically use different authentication keys based on the directory they are working in, matching their Git identity (user/email).

## Functional Requirements
- **Profile Integration:**
    - Update the profile creation/editing wizard to include an "Assign SSH Key" step.
    - Map specific SSH keys to folders using Git's `includeIf` and `core.sshCommand`.
- **Standalone SSH Manager:**
    - Add a dedicated menu to list, add, and generate SSH keys independently of profile setup.
- **Key Discovery & Generation:**
    - **Discovery:** Scan the standard `~/.ssh/` directory for existing private keys.
    - **Generation:** Interactively generate new ED25519 keys (via `ssh-keygen`) with descriptive names (e.g., `id_ed25519_work`).
- **Git Configuration:**
    - Use `core.sshCommand = "ssh -i <path_to_key>"` in the profile-specific configuration file.
    - Use absolute native paths (e.g., `C:/Users/...` on Windows, `/home/...` on *nix).
- **User Guidance:**
    - Automatically display the public key content when a key is selected or generated.
    - Provide contextual instructions for adding keys to GitHub, GitLab, and other providers.

## Non-Functional Requirements
- **Cross-Platform:** Full support for Bash (*nix) and PowerShell (Windows).
- **Dependency-Free:** Rely only on Git and native OS utilities (`ssh-keygen`).

## Acceptance Criteria
- [ ] Users can assign an existing SSH key to a Git profile during setup.
- [ ] Users can generate a new SSH key and assign it to a profile in one flow.
- [ ] `git config core.sshCommand` correctly reflects the assigned key when inside a profile's directory.
- [ ] The SSH Manager correctly lists keys from `~/.ssh/` on both Windows and *nix.
- [ ] Public keys are displayed clearly for manual copy-pasting to remote providers.

## Out of Scope
- Automated API integration for uploading keys to GitHub/GitLab (manual process via UI).
- Managing `ssh-agent` state or automatically adding keys to an agent.
