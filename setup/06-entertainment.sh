#!/usr/bin/env bash
# ==============================================================================
# AGY SRE BOOTSTRAP - 06 ENTERTAINMENT & GAMING
# ==============================================================================
# Execution Phase: Post-GNOME
# Goal: Provision Steam, Heroic Games Launcher, and Stremio via Flatpak.

set -euo pipefail

C_GREEN="\e[32m"
C_CYAN="\e[36m"
C_YELLOW="\e[33m"
C_RED="\e[31m"
C_RESET="\e[0m"

log_info() { echo -e "${C_CYAN}[INFO]${C_RESET} $1"; }
log_success() { echo -e "${C_GREEN}[SUCCESS]${C_RESET} $1"; }

echo -e "${C_CYAN}🎮 Starting Phase 06: Entertainment & Gaming${C_RESET}\n"

APPS=(
    "com.valvesoftware.Steam"
    "com.heroicgameslauncher.hgl"
    "com.stremio.Stremio"
)

log_info "Installing Gaming and Media Flatpaks..."
for app in "${APPS[@]}"; do
    log_info "Installing $app..."
    sudo flatpak install -y flathub "$app"
done
log_success "Entertainment ecosystem installed."

echo -e "\n${C_YELLOW}🛑 RESTORE INTERVENTION:${C_RESET}"
echo -e "If you have local saves/configs for Steam or Heroic, plug in your backup USB."
echo -e "Run the following commands manually to restore:"
echo -e "  rsync -avh /mnt/bak/flatpak_data/com.valvesoftware.Steam/ ~/.var/app/com.valvesoftware.Steam/"
echo -e "  rsync -avh /mnt/bak/flatpak_data/com.heroicgameslauncher.hgl/ ~/.var/app/com.heroicgameslauncher.hgl/"

echo -e "\n${C_GREEN}🎉 PHASE 06 COMPLETED. ENTERTAINMENT IS READY.${C_RESET}"
