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
    
    local change_identity="y"
    if [ ! -z "$current_name" ] || [ ! -z "$current_email" ]; then
        log_info "Current identity: $current_name <$current_email>"
        echo "Do you want to change your name/email? (y/N): "
        read change_identity
    fi

    if [[ "$change_identity" =~ ^[Yy]$ ]]; then
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
    fi

    # --- Part 2: Global SSH Key ---
    local current_ssh=$(git config --global core.sshCommand | sed 's/ssh -i //')
    log_info "Current Global SSH Key: ${current_ssh:-System Default}"
    
    echo "Do you want to configure the global SSH key? (y/N): "
    read configure_ssh
    
    if [[ "$configure_ssh" =~ ^[Yy]$ ]]; then
        echo "1. Select existing key from .ssh"
        echo "2. Generate new key"
        echo "3. Use System Default (Clear custom config)"
        echo "4. Skip"
        echo -n "Select an option [1-4]: "
        read ssh_opt
        
        case $ssh_opt in
            1)
                log_info "Existing SSH Keys:"
                local keys=$(list_ssh_keys)
                if [ -z "$keys" ]; then
                    log_error "No keys found."
                else
                    list_ssh_keys | nl
                    echo -n "Enter the number: "
                    read key_num
                    local selected_key=$(list_ssh_keys | sed -n "${key_num}p")
                    if [ ! -z "$selected_key" ]; then
                        git config --global core.sshCommand "ssh -i $HOME/.ssh/$selected_key"
                        log_success "Global SSH key set to: $HOME/.ssh/$selected_key"
                    fi
                fi
                ;;
            2)
                generate_new_ssh_key
                echo -n "Enter the name of the key you just created (e.g. id_ed25519_work): "
                read key_name
                local key_path="$HOME/.ssh/id_ed25519_$key_name"
                if [ -f "$key_path" ]; then
                    git config --global core.sshCommand "ssh -i $key_path"
                    log_success "Global SSH key set to: $key_path"
                else
                    log_error "Key not found: $key_path"
                fi
                ;;
            3)
                git config --global --unset core.sshCommand
                log_success "Reverted to System Default SSH key."
                ;;
        esac
    fi
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

list_ssh_keys() {
    local target_dir="${1:-$HOME/.ssh}"
    
    if [ ! -d "$target_dir" ]; then
        return
    fi
    
    # List files in .ssh, ignoring known non-key files and public keys
    # We look for files that are NOT directories
    find "$target_dir" -maxdepth 1 -type f | while read -r file; do
        local filename=$(basename "$file")
        
        # Filter out common non-private-key files
        if [[ "$filename" == *.pub ]] || \
           [[ "$filename" == "known_hosts" ]] || \
           [[ "$filename" == "known_hosts.old" ]] || \
           [[ "$filename" == "authorized_keys" ]] || \
           [[ "$filename" == "config" ]] || \
           [[ "$filename" == "environment" ]]; then
            continue
        fi
        
        # Optional: Check if file starts with "---- BEGIN" to be sure it's a key?
        # For now, sticking to file exclusion as implied by spec/test
        echo "$filename"
    done
}

generate_new_ssh_key() {
    local target_dir="${1:-$HOME/.ssh}"
    local email_arg="$2"
    mkdir -p "$target_dir"
    chmod 700 "$target_dir"

    echo "Enter a name for the new key (e.g., 'work', 'personal')."
    echo "The key will be saved as 'id_ed25519_<name>': "
    read key_suffix
    
    while [ -z "$key_suffix" ]; do
        log_error "Key name cannot be empty."
        read key_suffix
    done

    local key_file="$target_dir/id_ed25519_$key_suffix"
    local email=${email_arg:-$(git config --global user.email)}
    
    log_info "Generating key: $key_file for $email"
    ssh-keygen -t ed25519 -C "$email" -f "$key_file" -N ""
    
    log_success "SSH key generated."
    show_public_key "$key_file.pub"
}

show_ssh_walkthrough() {
    log_info "Guided Walkthrough: SSH Key Management"
    echo ""
    echo "This tool now supports multiple SSH keys mapped to specific folders."
    echo ""
    echo "1. Create or Select a key in 'Manage SSH Keys' or during 'Add Profile'."
    echo "2. Copy the public key content (starting with 'ssh-ed25519...')."
    echo "3. Log in to your Git provider (GitHub, GitLab, etc.)."
    echo "4. Go to 'Settings' -> 'SSH and GPG keys' and click 'New SSH Key'."
    echo "5. Give it a title and paste your key."
    echo ""
    echo "When you enter a folder linked to a profile with an assigned key,"
    echo "Git will automatically use that specific key for authentication."
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
    local ssh_key=$5

    local config_file="$HOME/.gitconfig-$profile_name"
    
    log_info "Creating profile config at $config_file..."
    cat > "$config_file" <<EOF
[user]
    name = $name
    email = $email
EOF

    if [ ! -z "$ssh_key" ]; then
        log_info "Assigning SSH key $ssh_key to profile..."
        # Ensure path is absolute for sshCommand
        local ssh_key_path="$HOME/.ssh/$ssh_key"
        cat >> "$config_file" <<EOF
[core]
    sshCommand = ssh -i $ssh_key_path
EOF
    fi

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
    
    local selected_ssh_key=""
    echo "Do you want to assign an SSH key to this profile? (y/N): "
    read assign_ssh
    if [[ "$assign_ssh" =~ ^[Yy]$ ]]; then
        echo "1. Select existing key"
        echo "2. Generate new key"
        echo "3. Skip"
        echo -n "Select an option [1-3]: "
        read ssh_opt
        case $ssh_opt in
            1)
                log_info "Existing SSH Keys:"
                local keys=$(list_ssh_keys)
                if [ -z "$keys" ]; then
                    log_error "No keys found. You may want to generate one."
                else
                    list_ssh_keys | nl
                    echo -n "Enter the number: "
                    read key_num
                    selected_ssh_key=$(list_ssh_keys | sed -n "${key_num}p")
                fi
                ;;
            2)
                generate_new_ssh_key "$HOME/.ssh" "$email"
                # Assume the new key is the one we want. 
                # We need generate_new_ssh_key to return or set a variable.
                # For now, let's just ask for the name again or improve the flow.
                echo -n "Enter the name of the key you just created (e.g. id_ed25519_work): "
                read selected_ssh_key
                ;;
        esac
    fi

    save_git_profile "$target_dir" "$name" "$email" "$profile_name" "$selected_ssh_key"
}

remove_profile() {
    log_info "--- Remove Git Profile ---"
    
    local profiles=$(get_git_profiles)
    if [ -z "$profiles" ]; then
        log_error "No profiles found to remove."
        return
    fi

    list_profiles
    echo "Enter the number of the profile to remove: "
    read num
    
    local selected=$(get_git_profiles | sed -n "${num}p")
    if [ -z "$selected" ]; then
        log_error "Invalid selection."
        return
    fi

    local dir=${selected%%:*}
    local config=${selected#*:}
    
    log_info "Removing profile for $dir..."
    git config --global --unset "includeIf.gitdir:$dir.path"
    
    if [ -f "$config" ]; then
        rm "$config"
        log_success "Deleted config file: $config"
    fi
    
    log_success "Profile removed."
}

edit_profile() {
    log_info "--- Edit Git Profile ---"
    
    local profiles=$(get_git_profiles)
    if [ -z "$profiles" ]; then
        log_error "No profiles found to edit."
        return
    fi

    list_profiles
    echo "Enter the number of the profile to edit: "
    read num
    
    local selected=$(get_git_profiles | sed -n "${num}p")
    if [ -z "$selected" ]; then
        log_error "Invalid selection."
        return
    fi

    local dir=${selected%%:*}
    local config=${selected#*:}
    
    log_info "Editing profile for $dir (stored in $config)"
    
    local current_name=$(git config -f "$config" user.name)
    local current_email=$(git config -f "$config" user.email)
    local current_ssh=$(git config -f "$config" core.sshCommand | sed 's/ssh -i //')
    
    echo "Enter new name [$current_name]: "
    read name
    name=${name:-$current_name}
    
    echo "Enter new email [$current_email]: "
    read email
    email=${email:-$current_email}
    
    git config -f "$config" user.name "$name"
    git config -f "$config" user.email "$email"
    
    echo "Current SSH Key: ${current_ssh:-None}"
    echo "Do you want to change SSH key? (y/N): "
    read change_ssh
    if [[ "$change_ssh" =~ ^[Yy]$ ]]; then
        log_info "Existing SSH Keys:"
        list_ssh_keys | nl
        echo "0. Remove SSH key assignment"
        echo -n "Enter the number: "
        read key_num
        if [ "$key_num" == "0" ]; then
            git config -f "$config" --unset core.sshCommand
        else
            local selected_ssh_key=$(list_ssh_keys | sed -n "${key_num}p")
            if [ ! -z "$selected_ssh_key" ]; then
                local ssh_key_path="$HOME/.ssh/$selected_ssh_key"
                git config -f "$config" core.sshCommand "ssh -i $ssh_key_path"
            fi
        fi
    fi
    
    log_success "Profile updated."
}

manage_profiles() {
    while true; do
        log_info "--- Manage Folder-Based Git Profiles ---"
        echo "1. List Profiles"
        echo "2. Add New Profile"
        echo "3. Edit Existing Profile"
        echo "4. Remove Profile"
        echo "5. Back to Main Menu"
        echo -n "Select an option [1-5]: "
        read choice
        
        case $choice in
            1) list_profiles ;;
            2) add_profile ;;
            3) edit_profile ;;
            4) remove_profile ;;
            5) return ;;
            *) log_error "Invalid option." ;;
        esac
        echo ""
    done
}

delete_ssh_key() {
    log_info "--- Delete SSH Key ---"
    
    local keys=$(list_ssh_keys)
    if [ -z "$keys" ]; then
        log_error "No keys found."
        return
    fi
    
    list_ssh_keys | nl
    echo -n "Select the key number to delete: "
    read key_num
    
    local selected_key=$(list_ssh_keys | sed -n "${key_num}p")
    if [ -z "$selected_key" ]; then
        log_error "Invalid selection."
        return
    fi
    
    echo "WARNING: This will permanently delete '$selected_key' and its public key."
    echo "Are you sure? (type 'yes' to confirm): "
    read confirm
    
    if [ "$confirm" == "yes" ]; then
        local key_path="$HOME/.ssh/$selected_key"
        rm -f "$key_path" "$key_path.pub"
        log_success "Deleted key: $selected_key"
    else
        log_info "Deletion cancelled."
    fi
}

manage_ssh_keys() {
    while true; do
        log_info "--- Manage SSH Keys ---"
        echo "1. List Existing Keys"
        echo "2. Generate New SSH Key"
        echo "3. View Public Key"
        echo "4. Delete SSH Key"
        echo "5. Back to Main Menu"
        echo -n "Select an option [1-5]: "
        read ssh_choice
        
        case $ssh_choice in
            1) 
                log_info "Existing SSH Keys:"
                list_ssh_keys
                ;;
            2) generate_new_ssh_key ;;
            3)
                log_info "Select a key to view its public content:"
                local keys=$(list_ssh_keys)
                if [ -z "$keys" ]; then
                    log_error "No keys found."
                else
                    list_ssh_keys | nl
                    echo -n "Enter the number: "
                    read key_num
                    local selected_key=$(list_ssh_keys | sed -n "${key_num}p")
                    if [ -z "$selected_key" ]; then
                        log_error "Invalid selection."
                    else
                        show_public_key "$HOME/.ssh/$selected_key.pub"
                    fi
                fi
                ;;
            4) delete_ssh_key ;;
            5) return ;;
            *) log_error "Invalid option." ;;
        esac
        echo ""
    done
}

main() {
    log_info "Starting Git Environment Setup on $(uname -s)..."
    check_git
    
    while true; do
        echo "--- Main Menu ---"
        echo "1. Configure Global Identity"
        echo "2. Setup SSH Keys"
        echo "3. Manage Folder-Based Profiles"
        echo "4. Manage SSH Keys"
        echo "5. Exit"
        echo -n "Select an option [1-5]: "
        read main_choice
        
        case $main_choice in
            1) configure_identity ;;
            2) setup_ssh; show_ssh_walkthrough ;;
            3) manage_profiles ;;
            4) manage_ssh_keys ;;
            5) log_success "Exiting. Happy coding!"; exit 0 ;;
            *) log_error "Invalid option." ;;
        esac
    done
}

# Only run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
