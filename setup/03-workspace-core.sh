#!/usr/bin/env bash
# ==============================================================================
# AGY SRE BOOTSTRAP - 03 WORKSPACE CORE
# ==============================================================================
# Execution Phase: Post-Terminal Forge
# Goal: Provision all primary GUI applications via Flatpak.

set -euo pipefail

C_GREEN="\e[32m"
C_CYAN="\e[36m"
C_YELLOW="\e[33m"
C_RED="\e[31m"
C_RESET="\e[0m"

log_info() { echo -e "${C_CYAN}[INFO]${C_RESET} $1"; }
log_success() { echo -e "${C_GREEN}[SUCCESS]${C_RESET} $1"; }

echo -e "${C_CYAN}🖥️  Starting Phase 03: Workspace Core (GUI & Flatpaks)${C_RESET}\n"

# ------------------------------------------------------------------------------
# 1. FLATPAK ARSENAL (Productivity & Comms)
# ------------------------------------------------------------------------------
log_info "Installing core graphical applications via Flatpak..."

APPS=(
    "com.visualstudio.code"
    "one.ablaze.floorp"
    "md.obsidian.Obsidian"
    "org.telegram.desktop"
    "com.github.wwmm.easyeffects"
    "io.mpv.Mpv"
)

for app in "${APPS[@]}"; do
    log_info "Installing $app..."
    sudo flatpak install -y flathub "$app"
done
log_success "Workspace GUI applications installed."

# ------------------------------------------------------------------------------
# 2. APPLY STOW FOR GUI CONFIGS
# ------------------------------------------------------------------------------
log_info "Linking EasyEffects and other GUI settings via Stow..."
cd ~/Projects/dotfiles
make easyeffects || true
log_success "Dotfiles linked for Workspace Core."

echo -e "\n${C_GREEN}🎉 PHASE 03 COMPLETED. WORKSPACE IS READY.${C_RESET}"
