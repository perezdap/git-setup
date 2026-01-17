# Initial Concept

I want to build a automated/scripted setup for a git env here's what I want
1. check if git is installed, if not install it
2. set git env - global user name and email
3. I want the option to set different git profiles depending on what folders I'm working in (work/personal)
4. I want this to work in both Windows and Nix environments
5. I want it to be interactive
6. I want the tool to provide instructions on how to do things if the user doesn't know how (setting up ssh keys for repo access, setup personal access tokens if needed)
7. I want this to work with any "remote" github, gitlab, privately hosted

# Product Definition - Git Environment Setup Tool

## Target Users
- **Individual Developers:** Setting up new personal or work machines and needing a reliable, repeatable process.
- **Team Leads:** Ensuring consistent Git configurations and identity management across a development team.
- **Educators and Mentors:** Providing a guided, low-friction setup experience for beginners.

## Core Goals
- **Rapid Onboarding:** Drastically reduce the time and effort required to go from a fresh OS install to a fully functional, authenticated Git environment.
- **Identity Integrity:** Eliminate "identity leak" (e.g., committing to a work repo with a personal email) through robust, folder-based profile management.
- **Educational Empowerment:** Lower the barrier to entry for Git by providing contextual help for complex tasks like SSH key generation and PAT management.
- **Platform Agnostic:** Provide a seamless experience across Windows (PowerShell) and *nix (Bash) environments.

## Essential Features
- **Smart Installation:** Detects existing Git installations and offers automated installation/update paths for Windows and various *nix distributions.
- **Interactive Profile Wizard:** A step-by-step guide to configure global and folder-specific identities, including GPG signing preferences.
- **Contextual Auth Guides:** Interactive instructions and automated helpers for setting up SSH keys and Personal Access Tokens for GitHub, GitLab, and private instances.
- **Platform Compatibility:** Dual-implementation (Bash/PowerShell) ensuring native performance and compatibility on all target systems.

## Implementation Approach
- **Native Scripting:** The tool will be implemented as a set of standalone, native scripts (Bash for Unix-like systems, PowerShell for Windows) to ensure zero dependencies beyond the OS itself.
