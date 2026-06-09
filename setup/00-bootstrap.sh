#!/usr/bin/env bash
# ==============================================================================
# AGY SRE BOOTSTRAP V2 - INCREMENTAL STATE ARCHITECTURE
# ==============================================================================
# Execution Phase: Post-Anaconda Install
# Goal: Build a Pristine OS, Inject AppSec, and Provision Identity with Snapshots.

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

echo -e "${C_CYAN}🚀 Starting SRE Bootstrap (V2 Incremental Architecture)${C_RESET}\n"

# ------------------------------------------------------------------------------
# 1. NETWORK ARMOR (BBR + DoT)
# ------------------------------------------------------------------------------
if ! grep -q "bbr" /etc/sysctl.d/90-bbr.conf 2>/dev/null; then
    log_info "Applying SRE Network Tuning (TCP BBR)..."
    echo "net.core.default_qdisc=fq" | sudo tee /etc/sysctl.d/90-bbr.conf >/dev/null
    echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.d/90-bbr.conf >/dev/null
    sudo sysctl --system >/dev/null
    log_success "TCP BBR enabled."
fi

if ! grep -q "DNSOverTLS=yes" /etc/systemd/resolved.conf 2>/dev/null; then
    log_info "Enabling DNS-over-TLS (Cloudflare)..."
    sudo mkdir -p /etc/systemd/resolved.conf.d
    echo -e "[Resolve]\nDNS=1.1.1.1 1.0.0.1\nDNSOverTLS=yes" | sudo tee /etc/systemd/resolved.conf.d/dns.conf >/dev/null
    sudo systemctl restart systemd-resolved
    log_success "DNS-over-TLS active."
fi

# ------------------------------------------------------------------------------
# 2. PRISTINE OS UPGRADE
# ------------------------------------------------------------------------------
log_info "Updating system to latest state (dnf5 upgrade)..."
sudo dnf5 upgrade -y

# ------------------------------------------------------------------------------
# 3 & 4. SNAPSHOT: BASE PRISTINE
# ------------------------------------------------------------------------------
if ! command -v snapper >/dev/null 2>&1; then
    log_info "Installing Snapper for Base Quarantine..."
    sudo dnf5 install -y snapper
fi

if [ ! -f "/etc/snapper/configs/root" ]; then
    log_info "Initializing BTRFS Root config for Snapper..."
    sudo snapper -c root create-config /
    sudo snapper -c root create -d "SRE-Base-01: Pristine Fedora Update"
    log_success "Virgin Snapshot [Base-01] saved."
fi

# ------------------------------------------------------------------------------
# 5. ZERO-TRUST APPSEC (FLATSEAL + AUTHENTICATOR)
# ------------------------------------------------------------------------------
log_info "Installing Flatpak ecosystem (Zero-Trust enforced)..."
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo flatpak install -y flathub com.github.tchx84.Flatseal com.belmoussaoui.Authenticator

# ------------------------------------------------------------------------------
# 6. IDENTITY VAULT (BITWARDEN)
# ------------------------------------------------------------------------------
if ! command -v bitwarden >/dev/null 2>&1; then
    log_info "Downloading official Bitwarden RPM..."
    sudo rpm --import https://vault.bitwarden.com/download/rpm/cert.cer
    sudo dnf5 install -y https://vault.bitwarden.com/download/linux/rpm
fi

# ------------------------------------------------------------------------------
# 7. THE HUMAN INTERVENTION (Single Block)
# ------------------------------------------------------------------------------
echo -e "\n${C_YELLOW}====================================================${C_RESET}"
echo -e "${C_YELLOW} 🛑 CEO INTERVENTION REQUIRED (Air-Gapped Identity) 🛑${C_RESET}"
echo -e "${C_YELLOW}====================================================${C_RESET}"
echo "1. Insert your Emergency USB Drive."
echo "2. Open Flatseal to audit permissions (if desired)."
echo "3. Open Authenticator and import your 2FA Backup."
echo "4. Open Bitwarden, authenticate using 2FA."
echo "5. Restore your Private SSH Key to ~/.ssh/id_ed25519"
echo "6. Run: chmod 600 ~/.ssh/id_ed25519"
echo "----------------------------------------------------"
read -p "Press [ENTER] only when the SSH key is securely in place..."

# ------------------------------------------------------------------------------
# 8. SECURITY VALIDATION
# ------------------------------------------------------------------------------
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    log_error "SSH Key not found! The operation cannot continue without identity."
    log_error "Rerun this script when you are ready."
    exit 1
fi
log_success "Identity confirmed. Resuming automation..."

# ------------------------------------------------------------------------------
# 9. DEPENDENCIES & DOTFILES
# ------------------------------------------------------------------------------
log_info "Installing Git, Stow, Zsh and core CLI tools..."
DEPS=(git stow gh zsh curl wget unzip rsync make)
for dep in "${DEPS[@]}"; do
    if ! rpm -q "$dep" >/dev/null 2>&1; then
        sudo dnf5 install -y "$dep"
    fi
done

DOTFILES_DIR="$HOME/Projects/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    log_info "Cloning dotfiles repository..."
    mkdir -p "$HOME/Projects"
    git clone git@github.com:alexandrevarga/dotfiles.git "$DOTFILES_DIR"
    log_success "Dotfiles cloned successfully."
    
    log_info "Applying Stow..."
    cd "$DOTFILES_DIR" && make shell || true
fi

if [ "$SHELL" != "/usr/bin/zsh" ]; then
    log_info "Changing default shell to ZSH..."
    sudo chsh -s /usr/bin/zsh "$USER"
fi

# ------------------------------------------------------------------------------
# 10. SNAPSHOT: IDENTITY & DOTFILES
# ------------------------------------------------------------------------------
sudo snapper -c root create -d "SRE-Base-02: Identity & Dotfiles Provisioned"
log_success "Incremental Snapshot [Base-02] saved."

echo -e "\n${C_GREEN}🎉 BOOTSTRAP V2 COMPLETED. WELCOME TO THE FUTURE.${C_RESET}"
exec zsh
