#!/usr/bin/env bash
# ==============================================================================
# AGY SRE BOOTSTRAP - FRESH INSTALL PROVISIONING (TIER 0 & 1)
# ==============================================================================
# Execute immediately after Fedora installation and user creation.
# This script is designed to be 100% idempotent.

set -euo pipefail

# 🎨 Color configuration for output
C_GREEN="\e[32m"
C_CYAN="\e[36m"
C_YELLOW="\e[33m"
C_RED="\e[31m"
C_RESET="\e[0m"

log_info() { echo -e "${C_CYAN}[INFO]${C_RESET} $1"; }
log_success() { echo -e "${C_GREEN}[SUCCESS]${C_RESET} $1"; }
log_warn() { echo -e "${C_YELLOW}[WARN]${C_RESET} $1"; }
log_error() { echo -e "${C_RED}[ERROR]${C_RESET} $1"; }

echo -e "${C_CYAN}🚀 Starting SRE Bootstrap (Tier 0 and Tier 1)${C_RESET}\n"

# ==============================================================================
# TIER 0: IDENTITY & SECURITY (CHICKEN AND EGG PROBLEM)
# ==============================================================================
log_info "Verifying identity keys (SSH)..."

if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    log_warn "Private SSH key not found in ~/.ssh/id_ed25519"
    echo "To clone the dotfiles and download private repositories,"
    echo "you must restore your keys."
    
    # Installing the official Bitwarden RPM (Flatpak breaks native syncing)
    if ! command -v bitwarden >/dev/null 2>&1; then
        log_info "Downloading official Bitwarden RPM to restore secrets..."
        sudo rpm --import https://vault.bitwarden.com/download/rpm/cert.cer
        sudo dnf5 install -y https://vault.bitwarden.com/download/linux/rpm
        log_success "Bitwarden installed."
    fi

    echo -e "${C_YELLOW}--- MANUAL ACTION REQUIRED ---${C_RESET}"
    echo "1. Open Bitwarden"
    echo "2. Copy your private SSH key"
    echo "3. Create the file by running: nano ~/.ssh/id_ed25519"
    echo "4. Run: chmod 600 ~/.ssh/id_ed25519"
    echo -e "After configuring your keys, run this script again.\n"
    exit 1
else
    log_success "Private SSH key detected."
fi

# ==============================================================================
# TIER 1: SYSTEM BASE (ESSENTIAL PACKAGES)
# ==============================================================================
log_info "Updating system (dnf5 upgrade)..."
sudo dnf5 upgrade -y

log_info "Installing essential dependencies (Git, Stow, Zsh)..."
# Using an array to avoid reinstalling existing packages
DEPS=(git stow gh zsh curl wget unzip rsync make)
MISSING_DEPS=()

for dep in "${DEPS[@]}"; do
    if ! rpm -q "$dep" >/dev/null 2>&1; then
        MISSING_DEPS+=("$dep")
    fi
done

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    log_info "Installing missing packages: ${MISSING_DEPS[*]}"
    sudo dnf5 install -y "${MISSING_DEPS[@]}"
else
    log_success "Base dependencies already installed."
fi

# ==============================================================================
# DOTFILES DEPLOYMENT
# ==============================================================================
DOTFILES_DIR="$HOME/Projects/dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
    log_info "Cloning dotfiles repository..."
    mkdir -p "$HOME/Projects"
    git clone git@github.com:alexandrevarga/dotfiles.git "$DOTFILES_DIR"
    log_success "Dotfiles cloned successfully."
else
    log_info "Dotfiles directory already exists. Skipping clone."
fi

# Changing default shell to ZSH
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    log_info "Changing default shell to ZSH..."
    sudo chsh -s /usr/bin/zsh "$USER"
    log_success "Shell updated to ZSH."
fi

# ==============================================================================
# SRE NETWORK TUNING (TCP BBR)
# ==============================================================================
if ! grep -q "bbr" /etc/sysctl.d/90-bbr.conf 2>/dev/null; then
    log_info "Applying SRE Network Tuning (TCP BBR)..."
    echo "net.core.default_qdisc=fq" | sudo tee /etc/sysctl.d/90-bbr.conf >/dev/null
    echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.d/90-bbr.conf >/dev/null
    sudo sysctl --system >/dev/null
    log_success "TCP BBR enabled."
else
    log_info "TCP BBR already configured."
fi

echo -e "\n${C_GREEN}🎉 TIER 0 and TIER 1 completed successfully!${C_RESET}"
log_info "Switching to ZSH seamlessly..."
cd "$DOTFILES_DIR"
make shell || true
exec zsh
