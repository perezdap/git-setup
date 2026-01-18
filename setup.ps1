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
    
    # --- Part 1: User Name & Email ---
    $currentName = git config --global user.name
    $currentEmail = git config --global user.email
    
    $changeIdentity = "y"
    if ($currentName -or $currentEmail) {
        Log-Info "Current identity: $currentName <$currentEmail>"
        $changeIdentity = Read-Host "Do you want to change your name/email? (y/N)"
    }

    if ($changeIdentity -match "^[Yy]$") {
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

    # --- Part 2: Global SSH Key ---
    $currentSsh = git config --global core.sshCommand
    if ($currentSsh) { $currentSsh = $currentSsh.Replace("ssh -i ", "") }
    
    Log-Info "Current Global SSH Key: $($currentSsh -or 'System Default')"
    
    $configureSsh = Read-Host "Do you want to configure the global SSH key? (y/N)"
    if ($configureSsh -match "^[Yy]$") {
        Write-Host "1. Select existing key from .ssh"
        Write-Host "2. Generate new key"
        Write-Host "3. Use System Default (Clear custom config)"
        Write-Host "4. Skip"
        
        $sshOpt = Read-Host "Select an option [1-4]"
        
        switch ($sshOpt) {
            "1" {
                Log-Info "Existing SSH Keys:"
                $keys = Get-SSHKeys
                if ($keys.Count -eq 0) {
                    Log-Error "No keys found."
                } else {
                    for ($i = 0; $i -lt $keys.Count; $i++) {
                        Write-Host "  $($i+1). $($keys[$i].Name)"
                    }
                    $num = Read-Host "Enter the number"
                    $idx = 0
                    if ([int]::TryParse($num, [ref]$idx) -and $idx -ge 1 -and $idx -le $keys.Count) {
                        $selectedKey = $keys[$idx-1].FullName.Replace('\', '/')
                        git config --global core.sshCommand "ssh -i $selectedKey"
                        Log-Success "Global SSH key set to: $selectedKey"
                    }
                }
            }
            "2" {
                New-SSHKey -Email (git config --global user.email)
                $keyName = Read-Host "Enter the name of the key you just created (e.g. id_ed25519_work)"
                $sshDir = Join-Path $HOME ".ssh"
                $keyPath = Join-Path $sshDir "id_ed25519_$keyName"
                if (Test-Path $keyPath) {
                    $keyPath = $keyPath.Replace('\', '/')
                    git config --global core.sshCommand "ssh -i $keyPath"
                    Log-Success "Global SSH key set to: $keyPath"
                } else {
                    Log-Error "Key not found: $keyPath"
                }
            }
            "3" {
                git config --global --unset core.sshCommand
                Log-Success "Reverted to System Default SSH key."
            }
        }
    }
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
    
    if (Test-Path $keyFile) {
        Remove-Item $keyFile -Force
        if (Test-Path "$keyFile.pub") { Remove-Item "$keyFile.pub" -Force }
    }

    $email = git config --global user.email
    ssh-keygen -t ed25519 -C "$email" -f $keyFile -N '""'
    
    Log-Success "SSH key generated successfully."
    Show-PublicKey "$keyFile.pub"
}

function Get-SSHKeys {
    param([string]$Path = (Join-Path $HOME ".ssh"))
    
    if (-not (Test-Path $Path)) {
        return @()
    }

    $excluded = @("known_hosts", "known_hosts.old", "authorized_keys", "config", "environment")
    
    # Get all files that don't end in .pub and aren't in the excluded list
    Get-ChildItem -Path $Path -File | Where-Object {
        $_.Extension -ne ".pub" -and $excluded -notcontains $_.Name
    } | ForEach-Object {
        # Return simplified object
        [PSCustomObject]@{
            Name = $_.Name
            FullName = $_.FullName
        }
    }
}

function New-SSHKey {
    param(
        [string]$Name,
        [string]$Path = (Join-Path $HOME ".ssh"),
        [string]$Email
    )
    
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }

    if (-not $Name) {
        $Name = Read-Host "Enter a name for the new key (e.g., 'work', 'personal'). The key will be saved as 'id_ed25519_<name>'"
    }

    while (-not $Name) {
        Log-Error "Key name cannot be empty."
        $Name = Read-Host "Enter a name for the new key"
    }

    $keyFile = Join-Path $Path "id_ed25519_$Name"
    
    if (-not $Email) {
        $Email = git config --global user.email
    }
    
    Log-Info "Generating key: $keyFile for $Email"
    
    if (Test-Path $keyFile) {
        $force = Read-Host "Key '$Name' already exists. Overwrite? (y/N)"
        if ($force -match "^[Yy]$") {
            Remove-Item $keyFile -Force
            if (Test-Path "$keyFile.pub") { Remove-Item "$keyFile.pub" -Force }
        } else {
            Log-Info "Operation cancelled."
            return
        }
    }

    ssh-keygen -t ed25519 -C "$Email" -f $keyFile -N '""'
    
    Log-Success "SSH key generated."
    Show-PublicKey "$keyFile.pub"
}

function Show-SSHWalkthrough {
    Log-Info "Guided Walkthrough: SSH Key Management"
    Write-Host ""
    Write-Host "This tool now supports multiple SSH keys mapped to specific folders."
    Write-Host ""
    Write-Host "1. Create or Select a key in 'Manage SSH Keys' or during 'Add Profile'."
    Write-Host "2. Copy the public key content (starting with 'ssh-ed25519...')."
    Write-Host "3. Log in to your Git provider (GitHub, GitLab, etc.)."
    Write-Host "4. Go to 'Settings' -> 'SSH and GPG keys' and click 'New SSH Key'."
    Write-Host "5. Give it a title and paste your key."
    Write-Host ""
    Write-Host "When you enter a folder linked to a profile with an assigned key,"
    Write-Host "Git will automatically use that specific key for authentication."
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
        [string]$ProfileName,
        [string]$SshKey
    )

    $configFile = Join-Path $HOME ".gitconfig-$ProfileName"
    
    Log-Info "Creating profile config at $configFile..."
    $configContent = "[user]`n    name = $Name`n    email = $Email"
    
    if ($SshKey) {
        Log-Info "Assigning SSH key $SshKey to profile..."
        $sshKeyPath = Join-Path $HOME ".ssh\$SshKey"
        # Git prefers forward slashes in config
        $sshKeyPath = $sshKeyPath.Replace('\', '/')
        $configContent += "`n`n[core]`n    sshCommand = ssh -i $sshKeyPath"
    }

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
    
    $selectedSshKey = ""
    $assignSsh = Read-Host "Do you want to assign an SSH key to this profile? (y/N)"
    if ($assignSsh -match "^[Yy]$") {
        Write-Host "1. Select existing key"
        Write-Host "2. Generate new key"
        Write-Host "3. Skip"
        $sshOpt = Read-Host "Select an option [1-3]"
        switch ($sshOpt) {
            "1" {
                Log-Info "Existing SSH Keys:"
                $keys = Get-SSHKeys
                if ($keys.Count -eq 0) {
                    Log-Error "No keys found."
                } else {
                    for ($i = 0; $i -lt $keys.Count; $i++) {
                        Write-Host "  $($i+1). $($keys[$i].Name)"
                    }
                    $num = Read-Host "Enter the number"
                    $idx = 0
                    if ([int]::TryParse($num, [ref]$idx) -and $idx -ge 1 -and $idx -le $keys.Count) {
                        $selectedSshKey = $keys[$idx-1].Name
                    }
                }
            }
            "2" {
                New-SSHKey -Email $email
                $selectedSshKey = Read-Host "Enter the name of the key you just created (e.g. id_ed25519_work)"
            }
        }
    }

    Save-GitProfile -TargetDir $targetDir -Name $name -Email $email -ProfileName $profileName -SshKey $selectedSshKey
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
    $currentSsh = git config -f $selected.ConfigPath core.sshCommand
    if ($currentSsh) { $currentSsh = $currentSsh.Replace("ssh -i ", "") }
    
    $name = Read-Host "Enter new name [$currentName]"
    if (-not $name) { $name = $currentName }
    
    $email = Read-Host "Enter new email [$currentEmail]"
    if (-not $email) { $email = $currentEmail }
    
    git config -f $selected.ConfigPath user.name "$name"
    git config -f $selected.ConfigPath user.email "$email"

    Log-Info "Current SSH Key: $($currentSsh -or 'None')"
    $changeSsh = Read-Host "Do you want to change SSH key? (y/N)"
    if ($changeSsh -match "^[Yy]$") {
        Log-Info "Existing SSH Keys:"
        $keys = Get-SSHKeys
        for ($i = 0; $i -lt $keys.Count; $i++) {
            Write-Host "  $($i+1). $($keys[$i].Name)"
        }
        Write-Host "  0. Remove SSH key assignment"
        $keyNum = Read-Host "Enter the number"
        if ($keyNum -eq "0") {
            git config -f $selected.ConfigPath --unset core.sshCommand
        } else {
            $kIdx = 0
            if ([int]::TryParse($keyNum, [ref]$kIdx) -and $kIdx -ge 1 -and $kIdx -le $keys.Count) {
                $selectedSshKey = $keys[$kIdx-1].FullName.Replace('\', '/')
                git config -f $selected.ConfigPath core.sshCommand "ssh -i $selectedSshKey"
            }
        }
    }
    
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

function Remove-SSHKey {
    Log-Info "--- Delete SSH Key ---"
    
    $keys = Get-SSHKeys
    if ($keys.Count -eq 0) {
        Log-Error "No keys found."
        return
    }

    for ($i = 0; $i -lt $keys.Count; $i++) {
        Write-Host "  $($i+1). $($keys[$i].Name)"
    }
    
    $num = Read-Host "Select the key number to delete"
    $idx = 0
    if (-not [int]::TryParse($num, [ref]$idx) -or $idx -lt 1 -or $idx -gt $keys.Count) {
        Log-Error "Invalid selection."
        return
    }

    $selected = $keys[$idx - 1]
    
    Log-Info "WARNING: This will permanently delete '$($selected.Name)' and its public key."
    $confirm = Read-Host "Are you sure? (type 'yes' to confirm)"
    
    if ($confirm -eq "yes") {
        Remove-Item $selected.FullName -Force
        if (Test-Path "$($selected.FullName).pub") {
            Remove-Item "$($selected.FullName).pub" -Force
        }
        Log-Success "Deleted key: $($selected.Name)"
    } else {
        Log-Info "Deletion cancelled."
    }
}

function Show-SSHKeyMenu {
    while ($true) {
        Log-Info "--- Manage SSH Keys ---"
        Write-Host "1. List Existing Keys"
        Write-Host "2. Generate New SSH Key"
        Write-Host "3. View Public Key"
        Write-Host "4. Delete SSH Key"
        Write-Host "5. Back to Main Menu"
        $choice = Read-Host "Select an option [1-5]"
        
        switch ($choice) {
            "1" { 
                Log-Info "Existing SSH Keys:"
                Get-SSHKeys | ForEach-Object { Write-Host "  $($_.Name)" }
            }
            "2" { New-SSHKey }
            "3" {
                Log-Info "Select a key to view its public content:"
                $keys = Get-SSHKeys
                if ($keys.Count -eq 0) {
                    Log-Error "No keys found."
                } else {
                    for ($i = 0; $i -lt $keys.Count; $i++) {
                        Write-Host "  $($i+1). $($keys[$i].Name)"
                    }
                    $num = Read-Host "Enter the number"
                    $idx = 0
                    if ([int]::TryParse($num, [ref]$idx) -and $idx -ge 1 -and $idx -le $keys.Count) {
                        Show-PublicKey "$($keys[$idx-1].FullName).pub"
                    } else {
                        Log-Error "Invalid selection."
                    }
                }
            }
            "4" { Remove-SSHKey }
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
        Write-Host "4. Manage SSH Keys"
        Write-Host "5. Exit"
        $mainChoice = Read-Host "Select an option [1-5]"
        
        switch ($mainChoice) {
            "1" { Set-GitIdentity }
            "2" { Set-SSHKeys; Show-SSHWalkthrough }
            "3" { Show-ProfileMenu }
            "4" { Show-SSHKeyMenu }
            "5" { Log-Success "Exiting. Happy coding!"; return }
            default { Log-Error "Invalid option." }
        }
    }
}

# Run Main only if executed directly (not dot-sourced)
if ($MyInvocation.InvocationName -ne '.') {
    Main
}
