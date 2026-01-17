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

function Set-SSHKeys {
    Log-Info "Setting up SSH Keys..."
    
    $sshDir = Join-Path $HOME ".ssh"
    $keyFile = Join-Path $sshDir "id_ed25519"
    
    if (Test-Path $keyFile) {
        Log-Info "Existing SSH key found at $keyFile"
        $useExisting = Read-Host "Do you want to use this key? (Y/n)"
        if ($useExisting -notmatch "^[Nn]$") {
            Show-PublicKey "$keyFile.pub"
            return
        }
    }

    Log-Info "Generating a new Ed25519 SSH key..."
    if (-not (Test-Path $sshDir)) {
        New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
    }
    
    $email = git config --global user.email
    ssh-keygen -t ed25519 -C "$email" -f $keyFile -N '""'
    
    Log-Success "SSH key generated successfully."
    Show-PublicKey "$keyFile.pub"
}

function Show-SSHWalkthrough {
    Log-Info "Guided Walkthrough: Adding your SSH key to GitHub/GitLab"
    Write-Host ""
    Write-Host "1. Copy the public key shown above (starting with 'ssh-ed25519...')"
    Write-Host "2. Log in to your Git provider (GitHub, GitLab, etc.)"
    Write-Host "3. Go to 'Settings' -> 'SSH and GPG keys'"
    Write-Host "4. Click 'New SSH Key'"
    Write-Host "5. Give it a descriptive title (e.g., 'My Windows Laptop')"
    Write-Host "6. Paste your key into the 'Key' field"
    Write-Host "7. Click 'Add SSH Key'"
    Write-Host ""
    Read-Host "Press Enter when you have completed these steps"
}

function Show-PublicKey {
    param([string]$PubKeyFile)
    Log-Info "Your Public SSH Key:"
    Write-Host "----------------------------------------------------------------"
    if (Test-Path $PubKeyFile) {
        Get-Content $PubKeyFile
    } else {
        Log-Error "Public key file not found: $PubKeyFile"
    }
    Write-Host "----------------------------------------------------------------"
}

function Get-GitProfiles {
    $configLines = git config --global --list
    $profiles = @()
    foreach ($line in $configLines) {
        if ($line -match "^includeIf\.gitdir:(.+)\.path=(.+)$") {
            $profiles += [PSCustomObject]@{
                Path = $matches[1]
                ConfigPath = $matches[2]
            }
        }
    }
    return $profiles
}

function Show-GitProfiles {
    Log-Info "Current Folder-Based Profiles:"
    
    $profiles = Get-GitProfiles
    if ($profiles.Count -eq 0) {
        Write-Host "  No profiles found."
        return
    }

    for ($i = 0; $i -lt $profiles.Count; $i++) {
        $p = $profiles[$i]
        Write-Host "  $($i+1). $($p.Path)  ->  $($p.ConfigPath)"
    }
}

function Save-GitProfile {
    param(
        [string]$TargetDir,
        [string]$Name,
        [string]$Email,
        [string]$ProfileName
    )

    $configFile = Join-Path $HOME ".gitconfig-$ProfileName"
    
    Log-Info "Creating profile config at $configFile..."
    $configContent = "[user]`n    name = $Name`n    email = $Email"
    Set-Content -Path $configFile -Value $configContent

    Log-Info "Updating global .gitconfig with includeIf..."
    # Ensure directory path ends with / for includeIf and uses forward slashes for Git
    $gitDir = $TargetDir.Replace('\', '/')
    if (-not $gitDir.EndsWith('/')) { $gitDir += '/' }
    
    git config --global "includeIf.gitdir:$gitDir.path" "$configFile"
    Log-Success "Profile saved and linked to $gitDir"
}

function Add-GitProfile {
    Log-Info "--- Add New Git Profile ---"
    
    $targetDir = Read-Host "Enter the target directory path (e.g., C:\Work)"
    # Handle ~
    if ($targetDir.StartsWith("~")) {
        $targetDir = $targetDir.Replace("~", $HOME)
    }

    if (-not (Test-Path $targetDir)) {
        Log-Error "Directory does not exist: $targetDir"
        return
    }

    $name = Read-Host "Enter user name for this profile"
    $email = Read-Host "Enter email address for this profile"
    
    $profileName = Split-Path $targetDir -Leaf
    $profileName = $profileName.ToLower()
    
    Save-GitProfile -TargetDir $targetDir -Name $name -Email $email -ProfileName $profileName
    
    $genSsh = Read-Host "Do you want to generate a new SSH key for this profile? (y/N)"
    if ($genSsh -match "^[Yy]$") {
        $sshDir = Join-Path $HOME ".ssh"
        $keyFile = Join-Path $sshDir "id_ed25519_$profileName"
        Log-Info "Generating key at $keyFile..."
        
        ssh-keygen -t ed25519 -C $email -f $keyFile -N '""'
        Log-Success "SSH key generated."
        Show-PublicKey "$keyFile.pub"
        
        Log-Info "Note: You may need to configure ~/.ssh/config to use this key for specific hosts."
    }
}

function Remove-GitProfile {
    Log-Info "--- Remove Git Profile ---"
    
    $profiles = Get-GitProfiles
    if ($profiles.Count -eq 0) {
        Log-Error "No profiles found to remove."
        return
    }

    Show-GitProfiles
    $num = Read-Host "Enter the number of the profile to remove"
    
    $idx = 0
    if (-not [int]::TryParse($num, [ref]$idx) -or $idx -lt 1 -or $idx -gt $profiles.Count) {
        Log-Error "Invalid selection."
        return
    }

    $selected = $profiles[$idx - 1]
    Log-Info "Removing profile for $($selected.Path)..."
    
    git config --global --unset "includeIf.gitdir:$($selected.Path).path"
    
    if (Test-Path $selected.ConfigPath) {
        Remove-Item $selected.ConfigPath
        Log-Success "Deleted config file: $($selected.ConfigPath)"
    }
    
    Log-Success "Profile removed."
}

function Edit-GitProfile {
    Log-Info "--- Edit Git Profile ---"
    
    $profiles = Get-GitProfiles
    if ($profiles.Count -eq 0) {
        Log-Error "No profiles found to edit."
        return
    }

    Show-GitProfiles
    $num = Read-Host "Enter the number of the profile to edit"
    
    $idx = 0
    if (-not [int]::TryParse($num, [ref]$idx) -or $idx -lt 1 -or $idx -gt $profiles.Count) {
        Log-Error "Invalid selection."
        return
    }

    $selected = $profiles[$idx - 1]
    Log-Info "Editing profile for $($selected.Path) (stored in $($selected.ConfigPath))"
    
    # We can use git config -f to read/write specific files
    $currentName = git config -f $selected.ConfigPath user.name
    $currentEmail = git config -f $selected.ConfigPath user.email
    
    $name = Read-Host "Enter new name [$currentName]"
    if (-not $name) { $name = $currentName }
    
    $email = Read-Host "Enter new email [$currentEmail]"
    if (-not $email) { $email = $currentEmail }
    
    Log-Success "Profile updated."
}

function Show-ProfileMenu {
    while ($true) {
        Log-Info "--- Manage Folder-Based Git Profiles ---"
        Write-Host "1. List Profiles"
        Write-Host "2. Add New Profile"
        Write-Host "3. Edit Existing Profile"
        Write-Host "4. Remove Profile"
        Write-Host "5. Back to Main Menu"
        $choice = Read-Host "Select an option [1-5]"
        
        switch ($choice) {
            "1" { Show-GitProfiles }
            "2" { Add-GitProfile }
            "3" { Edit-GitProfile }
            "4" { Remove-GitProfile }
            "5" { return }
            default { Log-Error "Invalid option." }
        }
        Write-Host ""
    }
}

function Main {
    Log-Info "Starting Git Environment Setup on Windows..."
    if (-not (Test-GitInstalled)) {
        Install-Git
    }
    
    while ($true) {
        Write-Host "`n--- Main Menu ---"
        Write-Host "1. Configure Global Identity"
        Write-Host "2. Setup SSH Keys"
        Write-Host "3. Manage Folder-Based Profiles"
        Write-Host "4. Exit"
        $mainChoice = Read-Host "Select an option [1-4]"
        
        switch ($mainChoice) {
            "1" { Set-GitIdentity }
            "2" { Set-SSHKeys; Show-SSHWalkthrough }
            "3" { Show-ProfileMenu }
            "4" { Log-Success "Exiting. Happy coding!"; return }
            default { Log-Error "Invalid option." }
        }
    }
}

# Run Main only if executed directly (not dot-sourced)
if ($MyInvocation.InvocationName -ne '.') {
    Main
}
