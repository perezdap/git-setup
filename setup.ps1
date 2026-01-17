<#
.SYNOPSIS
    Git Environment Setup for Windows
.DESCRIPTION
    Part of the Git Environment Setup Tool. Handles Git installation and configuration.
#>

$ErrorActionPreference = "Stop"

function Log-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Log-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Log-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Test-GitInstalled {
    Log-Info "Checking for Git..."
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $gitVersion = git --version
        Log-Success "Git is already installed: $gitVersion"
        return $true
    }
    else {
        Log-Error "Git is not installed."
        return $false
    }
}

function Install-Git {
    Log-Info "Attempting to install Git..."
    
    # Try Winget first (Windows 10/11 default)
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Log-Info "Using Winget to install Git..."
        winget install --id Git.Git -e --source winget
    }
    # Fallback to Chocolatey
    elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        Log-Info "Using Chocolatey to install Git..."
        choco install git -y
    }
    else {
        Log-Error "No supported package manager found (Winget or Chocolatey)."
        Log-Error "Please install Git manually from https://git-scm.com/download/win"
        exit 1
    }

    # Verify
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Log-Success "Git installed successfully!"
    }
    else {
        Log-Error "Git installation failed or path not updated. Please restart your terminal."
        exit 1
    }
}

function Set-GitIdentity {
    Log-Info "Configuring Global Git Identity..."
    
    $currentName = git config --global user.name
    $currentEmail = git config --global user.email
    
    if ($currentName -or $currentEmail) {
        Log-Info "Current identity: $currentName <$currentEmail>"
        $changeIdentity = Read-Host "Do you want to change it? (y/N)"
        if ($changeIdentity -notmatch "^[Yy]$") {
            return
        }
    }

    $name = Read-Host "Enter your full name"
    while (-not $name) {
        Log-Error "Name cannot be empty."
        $name = Read-Host "Enter your full name"
    }

    $email = Read-Host "Enter your email address"
    while ($email -notmatch "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$") {
        Log-Error "Invalid email format."
        $email = Read-Host "Enter your email address"
    }

    git config --global user.name "$name"
    git config --global user.email "$email"
    
    Log-Success "Global identity configured: $(git config --global user.name) <$(git config --global user.email)>"
}

function Main {
    Log-Info "Starting Git Environment Setup on Windows..."
    if (-not (Test-GitInstalled)) {
        Install-Git
    }
    Set-GitIdentity
}

# Run Main
Main
