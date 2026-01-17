# Specification - Initial Setup Scripts

## Goal
Create the initial cross-platform entry points for the Git Environment Setup Tool. These scripts will handle environment detection, Git installation/verification, global identity configuration, and guided SSH key setup.

## Requirements

### Platform Support
- **Windows:** `setup.ps1` (PowerShell 5.1 and 7+).
- **Unix-like:** `setup.sh` (Bash/Zsh).

### Functional Requirements
1. **Git Detection & Installation:**
    - Check if `git` is available in the PATH.
    - If missing, offer to install it using the system's package manager (Winget for Windows, apt/yum/dnf/pacman/brew for *nix).
    - Provide manual installation instructions if automated installation fails or is not supported.
2. **Global Identity Configuration:**
    - Interactively prompt for `user.name` and `user.email`.
    - Validate input (e.g., non-empty, email format).
    - Set these globally using `git config --global`.
3. **SSH Key Setup (Interactive):**
    - Check for existing SSH keys (e.g., `~/.ssh/id_ed25519` or `~/.ssh/id_rsa`).
    - If missing or if the user wants a new one, guide them through generating an Ed25519 key.
    - Provide a step-by-step walkthrough for adding the public key to a remote host (GitHub, GitLab, etc.).
4. **Output & Tone:**
    - Adhere to the "Supportive & Educational" tone.
    - Use clear, sequential prompts.

## Implementation Details
- **Zero Dependencies:** Use only native shell features and common utilities (e.g., `ssh-keygen`).
- **Interactive Prompts:** Use standard input/output for dialogue.
- **Error Handling:** Use "Guided Recovery" as per product guidelines.
