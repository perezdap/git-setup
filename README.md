# Git Environment Setup Tool

A cross-platform, interactive tool to seamlessly configure your Git environment on Windows and Unix-like systems. It handles identity management, SSH key generation, and folder-specific profiles with zero external dependencies.

## Core Features
- **Cross-Platform Support**: Native scripts for Windows (PowerShell) and Linux/macOS (Bash).
- **Interactive Setup**: Guided configuration for global user identity (Name/Email).
- **Folder-Based Profiles**: Manage distinct identities (e.g., Work vs. Personal) for specific directory trees using Git's `includeIf` feature.
- **SSH Key Management**: Automated detection and Ed25519 key generation with a guided walkthrough for GitHub/GitLab.
- **Zero Dependencies**: Relies only on standard OS tools and Git.

## Prerequisites

### Windows
- **OS**: Windows 10/11
- **Shell**: Windows PowerShell 5.1+ (PowerShell 7+ recommended)
- **Git**: Must be installed (the script can help install it via Winget/Chocolatey)

### macOS / Linux
- **Shell**: Bash 3.2+
- **Git**: Pre-installed or available via package manager (apt, dnf, brew, etc.)
