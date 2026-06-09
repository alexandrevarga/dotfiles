#!/usr/bin/env bash
# ==============================================================================
# AGY SRE BOOTSTRAP - 01 SYSTEM CORE (BTRFS & LOW LEVEL TUNING)
# ==============================================================================
# Execution Phase: Post-Bootstrap (After Base-02 Snapshot)
# Goal: Advanced BTRFS Resilience, Boot Menu Rollbacks, and Fast Boot.

set -euo pipefail

C_GREEN="\e[32m"
C_CYAN="\e[36m"
C_YELLOW="\e[33m"
C_RED="\e[31m"
C_RESET="\e[0m"

log_info() { echo -e "${C_CYAN}[INFO]${C_RESET} $1"; }
log_success() { echo -e "${C_GREEN}[SUCCESS]${C_RESET} $1"; }

echo -e "${C_CYAN}🛡️ Starting Phase 01: System Core Tuning (BTRFS & Low-Level)${C_RESET}\n"

# ------------------------------------------------------------------------------
# 1. SNAPPER ADVANCED TUNING & DNF TRIGGERS
# ------------------------------------------------------------------------------
log_info "Installing Snapper DNF plugin for auto-snapshots on package changes..."
sudo dnf5 install -y python3-dnf-plugin-snapper

log_info "Tuning Snapper retention limits to prevent disk exhaustion..."
# We use sed to edit the /etc/snapper/configs/root file safely
sudo sed -i 's/^TIMELINE_LIMIT_HOURLY=.*/TIMELINE_LIMIT_HOURLY="0"/' /etc/snapper/configs/root
sudo sed -i 's/^TIMELINE_LIMIT_DAILY=.*/TIMELINE_LIMIT_DAILY="5"/' /etc/snapper/configs/root
sudo sed -i 's/^TIMELINE_LIMIT_WEEKLY=.*/TIMELINE_LIMIT_WEEKLY="2"/' /etc/snapper/configs/root
sudo sed -i 's/^TIMELINE_LIMIT_MONTHLY=.*/TIMELINE_LIMIT_MONTHLY="1"/' /etc/snapper/configs/root
sudo sed -i 's/^TIMELINE_LIMIT_YEARLY=.*/TIMELINE_LIMIT_YEARLY="1"/' /etc/snapper/configs/root

log_info "Enabling Snapper timeline and cleanup services..."
sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer
log_success "Snapper tuning completed."

# ------------------------------------------------------------------------------
# 2. GRUB-BTRFS (ROLLBACK FROM BOOT MENU)
# ------------------------------------------------------------------------------
log_info "Installing grub-btrfs for disaster recovery via Boot Menu..."
sudo dnf5 install -y grub-btrfs

log_info "Enabling grub-btrfsd to auto-update GRUB when snapshots are taken..."
sudo systemctl enable --now grub-btrfsd.service
log_success "Grub BTRFS integration active."

# ------------------------------------------------------------------------------
# 3. BTRFS MAINTENANCE (HEALING & DEFRAGMENTATION)
# ------------------------------------------------------------------------------
log_info "Installing btrfsmaintenance (Scrub & Balance)..."
sudo dnf5 install -y btrfsmaintenance

log_info "Enabling auto-healing timers..."
sudo systemctl enable --now btrfs-scrub.timer
sudo systemctl enable --now btrfs-balance.timer
log_success "BTRFS Maintenance services activated."

# ------------------------------------------------------------------------------
# 4. NETWORK FAST BOOT (DISABLE WAIT-ONLINE)
# ------------------------------------------------------------------------------
log_info "Applying Network Fast Boot (Disabling NetworkManager-wait-online)..."
sudo systemctl disable NetworkManager-wait-online.service || true
log_success "Network Fast Boot configured."

echo -e "\n${C_GREEN}🎉 PHASE 01 COMPLETED. CORE SYSTEM IS BULLETPROOF.${C_RESET}"
