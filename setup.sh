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

main() {
    log_info "Starting Git Environment Setup on $(uname -s)..."
    check_git
    configure_identity
}

# Only run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
