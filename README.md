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

## Installation & Usage

You can run this tool by cloning the repository or executing a one-liner directly from your terminal.

### Option 1: Direct Execution (Recommended)

1. **Clone the repository:**
   \\\ash
   git clone https://github.com/perezdap/git-setup.git
   cd git-setup
   \\\

2. **Run the script:**

   - **Windows (PowerShell):**
     \\\powershell
     .\setup.ps1
     \\\

   - **macOS / Linux:**
     \\\ash
     chmod +x setup.sh
     ./setup.sh
     \\\

### Option 2: One-Liner (Remote)

*Note: These commands fetch the latest version from the main branch.*

- **Windows (PowerShell):**
  \\\powershell
  iex (irm https://raw.githubusercontent.com/perezdap/git-setup/main/setup.ps1)
  \\\

- **macOS / Linux:**
  \\\ash
  curl -sL https://raw.githubusercontent.com/perezdap/git-setup/main/setup.sh | bash
  \\\


## Troubleshooting

### Windows Execution Policy
If you encounter an error stating that "running scripts is disabled on this system," you need to set the execution policy for your current session:
\\\powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
\\\

### Git Not Found
The script attempts to install Git if it's missing, but if the installation fails, please install it manually from [git-scm.com](https://git-scm.com/downloads).

## Contributing

Contributions are welcome! If you have suggestions for improvements or encounter bugs, please open an issue or submit a pull request.

1. Fork the repository.
2. Create your feature branch (\git checkout -b feature/AmazingFeature\).
3. Commit your changes (\git commit -m 'feat: Add some AmazingFeature'\).
4. Push to the branch (\git push origin feature/AmazingFeature\).
5. Open a Pull Request.

## License

Distributed under the MIT License. See \LICENSE\ for more information.

