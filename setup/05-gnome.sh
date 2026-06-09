#!/usr/bin/env bash
# ==============================================================================
# AGY SRE BOOTSTRAP - 05 GNOME EXTENSIONS & DCONF
# ==============================================================================
# Execution Phase: Post-Virtualization
# Goal: Restore GNOME UI, Extensions, and dconf state directly from dotfiles.

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

echo -e "${C_CYAN}🧩 Starting Phase 05: GNOME Extensions & Dconf Restitution${C_RESET}\n"

DOTFILES_EXT_DIR="$HOME/Projects/dotfiles/config-apps/.config/gnome-extensions"

# ------------------------------------------------------------------------------
# 1. EXTENSION MANAGER (gext via pipx)
# ------------------------------------------------------------------------------
log_info "Installing pipx and gnome-extensions-cli (gext)..."
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
    log_success "All extensions installed."
else
    log_error "enabled-list.txt not found in dotfiles!"
    exit 1
fi

# ------------------------------------------------------------------------------
# 3. RESTORE DCONF DUMP (THE SINGLE SOURCE OF TRUTH)
# ------------------------------------------------------------------------------
log_info "Loading dconf dump from dotfiles..."
if [ -f "$DOTFILES_EXT_DIR/all-extensions.dconf" ]; then
    dconf load /org/gnome/shell/extensions/ < "$DOTFILES_EXT_DIR/all-extensions.dconf"
    log_success "GNOME dconf loaded successfully."
else
    log_error "all-extensions.dconf not found in dotfiles!"
    exit 1
fi

echo -e "\n${C_GREEN}🎉 PHASE 05 COMPLETED. GNOME ENVIRONMENT IS RESTORED.${C_RESET}"
