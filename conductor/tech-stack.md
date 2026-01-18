# Tech Stack - Git Environment Setup Tool

## Core Scripting Environments
- **Unix-like Systems (*nix):** 
    - **Bash (Primary):** The primary script will be written for Bash to ensure compatibility across Linux distributions and macOS.
    - **Zsh (Compatible):** Scripts will be verified to work in Zsh environments without modification.
- **Windows Systems:**
    - **PowerShell (5.1 & 7+):** The Windows implementation will target both the legacy Windows PowerShell 5.1 and modern PowerShell Core (7+) to ensure full coverage across all Windows installations.

## External Dependencies
- **Git:** The primary external tool managed and configured by these scripts.
- **OS Package Managers:**
    - **Windows:** Winget or Chocolatey (optional/suggested for Git installation).
    - **Linux:** apt, yum, dnf, pacman (detected and used for Git installation).
    - **macOS:** Homebrew (optional/suggested for Git installation).

## Configuration Management
- **Git Config:** Heavy usage of `git config --global`, `git config --includeIf`, and `core.sshCommand` for identity and authentication management.
- **Filesystem:** Native directory traversal and file manipulation provided by Bash/PowerShell.
