#!/usr/bin/env bash
# ==============================================================================
# AGY SRE BOOTSTRAP - 05 GNOME EXTENSIONS & DCONF
# ==============================================================================
# Execution Phase: Post-Virtualization
# Goal: Automate GNOME extensions installation via pipx and execute setup_keys.sh.

set -euo pipefail

C_GREEN="\e[32m"
C_CYAN="\e[36m"
C_YELLOW="\e[33m"
C_RED="\e[31m"
C_RESET="\e[0m"

log_info() { echo -e "${C_CYAN}[INFO]${C_RESET} $1"; }
log_success() { echo -e "${C_GREEN}[SUCCESS]${C_RESET} $1"; }
log_warn() { echo -e "${C_YELLOW}[WARN]${C_RESET} $1"; }
log_error() { echo -e "${C_RED}[ERROR]${C_RESET} $1"; }

echo -e "${C_CYAN}🧩 Starting Phase 05: GNOME Extensions & Setup Keys${C_RESET}\n"

DOTFILES_EXT_DIR="$HOME/Projects/dotfiles/config-apps/.config/gnome-extensions"

# ------------------------------------------------------------------------------
# 1. EXTENSION AUTOMATION (gext via pipx)
# ------------------------------------------------------------------------------
log_info "Installing pipx and gnome-extensions-cli (gext) for automation..."
sudo dnf5 install -y pipx
pipx install gnome-extensions-cli
export PATH="$HOME/.local/bin:$PATH"
log_success "Extension CLI ready."

# ------------------------------------------------------------------------------
# 2. INSTALL EXTENSIONS FROM DOTFILES LIST
# ------------------------------------------------------------------------------
log_info "Reading enabled extensions from dotfiles..."
if [ -f "$DOTFILES_EXT_DIR/enabled-list.txt" ]; then
    while read -r ext; do
        # Ignore empty lines and comments
        [[ -z "$ext" || "$ext" == \#* ]] && continue
        log_info "Installing extension: $ext"
        gext install "$ext" || log_warn "Failed to install $ext, continuing..."
    done < "$DOTFILES_EXT_DIR/enabled-list.txt"
    log_success "All extensions installed automatically."
else
    log_error "enabled-list.txt not found in dotfiles!"
    exit 1
fi

# ------------------------------------------------------------------------------
# 3. CONFIGURE GNOME VIA SETUP_KEYS.SH
# ------------------------------------------------------------------------------
log_info "Running setup_keys.sh to map workspaces, shortcuts, and extension configs..."
if [ -x "$HOME/.local/bin/setup_keys.sh" ]; then
    "$HOME/.local/bin/setup_keys.sh"
    log_success "setup_keys.sh executed successfully."
else
    log_error "setup_keys.sh not found or not executable at ~/.local/bin/setup_keys.sh"
    log_info "Please ensure Phase 02 (make cli) was completed."
    exit 1
fi

echo -e "\n${C_GREEN}🎉 PHASE 05 COMPLETED. GNOME ENVIRONMENT IS FULLY AUTOMATED.${C_RESET}"
