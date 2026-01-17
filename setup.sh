#!/bin/bash

# setup.sh - Git Environment Setup for *nix
# Part of the Git Environment Setup Tool

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_git() {
    log_info "Checking for Git..."
    if command -v git &> /dev/null; then
        local git_version=$(git --version)
        log_success "Git is already installed: $git_version"
        return 0
    else
        log_error "Git is not installed."
        install_git
    fi
}

install_git() {
    log_info "Attempting to install Git..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y git
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y git
        elif command -v yum &> /dev/null; then
            sudo yum install -y git
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm git
        else
            log_error "Unsupported package manager. Please install Git manually."
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install git
        else
            log_error "Homebrew not found. Please install Git manually."
            exit 1
        fi
    else
        log_error "Unsupported OS for automated install. Please install Git manually."
        exit 1
    fi
    
    # Verify installation
    if command -v git &> /dev/null; then
        log_success "Git installed successfully!"
    else
        log_error "Git installation failed."
        exit 1
    fi
}

configure_identity() {
    log_info "Configuring Global Git Identity..."
    
    local current_name=$(git config --global user.name)
    local current_email=$(git config --global user.email)
    
    if [ ! -z "$current_name" ] || [ ! -z "$current_email" ]; then
        log_info "Current identity: $current_name <$current_email>"
        echo "Do you want to change it? (y/N): "
        read change_identity
        if [[ ! "$change_identity" =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi

    echo "Enter your full name: "
    read name
    while [ -z "$name" ]; do
        log_error "Name cannot be empty."
        echo "Enter your full name: "
        read name
    done

    echo "Enter your email address: "
    read email
    while [[ ! "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; do
        log_error "Invalid email format."
        echo "Enter your email address: "
        read email
    done

    git config --global user.name "$name"
    git config --global user.email "$email"
    
    log_success "Global identity configured: $(git config --global user.name) <$(git config --global user.email)>"
}

setup_ssh() {
    log_info "Setting up SSH Keys..."
    
    local ssh_dir="$HOME/.ssh"
    local key_file="$ssh_dir/id_ed25519"
    
    if [ -f "$key_file" ]; then
        log_info "Existing SSH key found at $key_file"
        echo "Do you want to use this key? (Y/n): "
        read use_existing
        if [[ ! "$use_existing" =~ ^[Nn]$ ]]; then
            show_public_key "$key_file.pub"
            return 0
        fi
    fi

    log_info "Generating a new Ed25519 SSH key..."
    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"
    
    local email=$(git config --global user.email)
    ssh-keygen -t ed25519 -C "$email" -f "$key_file" -N ""
    
    log_success "SSH key generated successfully."
    show_public_key "$key_file.pub"
}

show_ssh_walkthrough() {
    log_info "Guided Walkthrough: Adding your SSH key to GitHub/GitLab"
    echo ""
    echo "1. Copy the public key shown above (starting with 'ssh-ed25519...')"
    echo "2. Log in to your Git provider (GitHub, GitLab, etc.)"
    echo "3. Go to 'Settings' -> 'SSH and GPG keys'"
    echo "4. Click 'New SSH Key'"
    echo "5. Give it a descriptive title (e.g., 'My Windows Laptop')"
    echo "6. Paste your key into the 'Key' field"
    echo "7. Click 'Add SSH Key'"
    echo ""
    echo "Press Enter when you have completed these steps..."
    read
}

show_public_key() {
    local pub_key_file=$1
    log_info "Your Public SSH Key:"
    echo "----------------------------------------------------------------"
    cat "$pub_key_file"
    echo "----------------------------------------------------------------"
}

get_git_profiles() {
    # Parses git config for includeIf directives
    # Format: includeIf.gitdir:<dir>.path=<config_file>
    git config --global --list | grep "includeIf.gitdir:" | while read -r line; do
        # Extract dir (remove 'includeIf.gitdir:' and everything after '.path=')
        local dir=${line#includeIf.gitdir:}
        dir=${dir%%.path=*}
        
        # Extract path (remove everything up to '=')
        local path=${line#*=}
        
        echo "$dir:$path"
    done
}

list_profiles() {
    log_info "Current Folder-Based Profiles:"
    
    # Check if we have any output from get_git_profiles
    if [ -z "$(get_git_profiles)" ]; then
        echo "  No profiles found."
        return
    fi

    local count=1
    get_git_profiles | while read -r line; do
        local dir=${line%%:*}
        local config=${line#*:}
        echo "  $count. $dir  ->  $config"
        ((count++))
    done
}

save_git_profile() {
    local target_dir=$1
    local name=$2
    local email=$3
    local profile_name=$4

    local config_file="$HOME/.gitconfig-$profile_name"
    
    log_info "Creating profile config at $config_file..."
    cat > "$config_file" <<EOF
[user]
    name = $name
    email = $email
EOF

    log_info "Updating global .gitconfig with includeIf..."
    # Ensure directory path ends with / for includeIf
    [[ "$target_dir" != */ ]] && target_dir="$target_dir/"
    
    git config --global "includeIf.gitdir:$target_dir.path" "$config_file"
    log_success "Profile saved and linked to $target_dir"
}

add_profile() {
    log_info "--- Add New Git Profile ---"
    
    echo "Enter the target directory path (e.g., ~/Work): "
    read target_dir
    # Expand ~ if present
    target_dir="${target_dir/#\~/$HOME}"
    
    if [ ! -d "$target_dir" ]; then
        log_error "Directory does not exist: $target_dir"
        return 1
    fi

    echo "Enter user name for this profile: "
    read name
    echo "Enter email address for this profile: "
    read email
    
    # Generate a simple profile name from the directory
    local profile_name=$(basename "$target_dir" | tr '[:upper:]' '[:lower:]')
    
    save_git_profile "$target_dir" "$name" "$email" "$profile_name"
    
    echo "Do you want to generate a new SSH key for this profile? (y/N): "
    read gen_ssh
    if [[ "$gen_ssh" =~ ^[Yy]$ ]]; then
        # We need a unique key name
        local key_file="$HOME/.ssh/id_ed25519_$profile_name"
        log_info "Generating key at $key_file..."
        ssh-keygen -t ed25519 -C "$email" -f "$key_file" -N ""
        log_success "SSH key generated."
        show_public_key "$key_file.pub"
        
        log_info "Note: You may need to configure ~/.ssh/config to use this key for specific hosts."
    fi
}

main() {
    log_info "Starting Git Environment Setup on $(uname -s)..."
    check_git
    configure_identity
    setup_ssh
    show_ssh_walkthrough
    log_success "Initial setup complete!"
}

# Only run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
