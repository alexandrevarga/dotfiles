#!/usr/bin/env bash
# ==============================================================================
# AGY SRE BOOTSTRAP - 04 VIRTUALIZATION
# ==============================================================================
# Execution Phase: Post-Workspace Core (Phase 03)
# Goal: Provision KVM/QEMU, Podman (default), and optionally Docker Engine.

set -euo pipefail

C_GREEN="\e[32m"
C_CYAN="\e[36m"
C_YELLOW="\e[33m"
C_RED="\e[31m"
C_RESET="\e[0m"

log_info() { echo -e "${C_CYAN}[INFO]${C_RESET} $1"; }
log_success() { echo -e "${C_GREEN}[SUCCESS]${C_RESET} $1"; }
log_warn() { echo -e "${C_YELLOW}[WARN]${C_RESET} $1"; }

echo -e "${C_CYAN}🐳 Starting Phase 04: Virtualization (KVM & Containers)${C_RESET}\n"

# ------------------------------------------------------------------------------
# 1. KVM / LIBVIRT / QEMU
# ------------------------------------------------------------------------------
log_info "Installing KVM, Libvirt, and Virt-Manager..."
sudo dnf5 install -y @virtualization
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt "$USER"
log_success "KVM/Libvirt virtualization ready."

# ------------------------------------------------------------------------------
# 2. PODMAN (Default Container Engine)
# ------------------------------------------------------------------------------
log_info "Installing Podman (Rootless/Native containers)..."
sudo dnf5 install -y podman podman-compose
log_success "Podman installed."

# ------------------------------------------------------------------------------
# 3. DOCKER ENGINE (Optional / Future-proofing)
# ------------------------------------------------------------------------------
echo -e "\n${C_YELLOW}❓ Docker Engine is heavy and conflicts with pure Podman environments.${C_RESET}"
read -p "Do you want to install Docker Engine with BTRFS optimizations? [y/N] " install_docker

if [[ "$install_docker" =~ ^[Yy]$ ]]; then
    log_info "Installing Docker Engine (moby-engine)..."
    sudo dnf5 install -y moby-engine docker-compose

    log_info "Applying SRE Data-Root optimization (Moving to /home/docker-data)..."
    sudo mkdir -p /home/docker-data
    # Disable BTRFS Copy-on-Write for Docker data to prevent fragmentation
    sudo chattr +C /home/docker-data || true
    sudo chmod 711 /home/docker-data

    sudo mkdir -p /etc/docker
    cat << 'EOF' | sudo tee /etc/docker/daemon.json >/dev/null
{
  "data-root": "/home/docker-data",
  "storage-driver": "btrfs"
}
EOF
    sudo systemctl enable --now docker
    sudo usermod -aG docker "$USER"
    log_success "Docker Engine provisioned and optimized."
else
    log_info "Skipping Docker Engine installation."
fi

echo -e "\n${C_GREEN}🎉 PHASE 04 COMPLETED. VIRTUALIZATION IS READY.${C_RESET}"
