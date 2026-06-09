#!/usr/bin/env bash
# ==============================================================================
# AGY SRE BOOTSTRAP - 02 TERMINAL FORGE
# ==============================================================================
# Execution Phase: Post-System Core (Phase 01)
# Goal: Build the ultimate Rust/C based CLI environment and restore GPG keys.

set -euo pipefail

C_GREEN="\e[32m"
C_CYAN="\e[36m"
C_YELLOW="\e[33m"
C_RED="\e[31m"
C_RESET="\e[0m"

log_info() { echo -e "${C_CYAN}[INFO]${C_RESET} $1"; }
log_success() { echo -e "${C_GREEN}[SUCCESS]${C_RESET} $1"; }
log_error() { echo -e "${C_RED}[ERROR]${C_RESET} $1"; }

echo -e "${C_CYAN}🔨 Starting Phase 02: The Terminal Forge${C_RESET}\n"

# ------------------------------------------------------------------------------
# 1. GPG IDENTITY RESTORATION
# ------------------------------------------------------------------------------
log_info "Restoring GPG Keys from USB Backup..."
if [ -d "/mnt/bak/secrets/gnupg" ]; then
    cp -r /mnt/bak/secrets/gnupg/ ~/.gnupg/
    chmod 700 ~/.gnupg && chmod 600 ~/.gnupg/* 2>/dev/null || true
    gpg-connect-agent reloadagent /bye
    log_success "GPG keys restored."
else
    log_error "USB Backup not mounted at /mnt/bak. Please restore GPG manually later."
fi

# ------------------------------------------------------------------------------
# 2. FONTS
# ------------------------------------------------------------------------------
log_info "Restoring FiraCode Nerd Font..."
if [ -d "/mnt/bak/configs/fonts/FiraCode Nerd Font" ]; then
    mkdir -p ~/.fonts
    cp -r "/mnt/bak/configs/fonts/FiraCode Nerd Font/" ~/.fonts/
    fc-cache -fv
    log_success "Fonts installed."
else
    log_error "Font backup not found at /mnt/bak. Manual font installation required."
fi

# ------------------------------------------------------------------------------
# 3. OH-MY-POSH (PROMPT ENGINE)
# ------------------------------------------------------------------------------
log_info "Installing Oh-My-Posh..."
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
log_success "Oh-My-Posh installed."

# ------------------------------------------------------------------------------
# 4. RUST & C HEAVYWEIGHT TOOLS
# ------------------------------------------------------------------------------
log_info "Installing Ghostty, Tmux, btop, lsd, ripgrep, bat, fd-find, fzf, atuin, zoxide, git-delta, lazygit..."
sudo dnf5 install -y ghostty tmux btop lsd ripgrep bat fd-find fzf atuin zoxide git-delta lazygit
log_success "CLI tools installed."

# ------------------------------------------------------------------------------
# 5. PYTHON UV MANAGER & TMUXP
# ------------------------------------------------------------------------------
log_info "Installing uv (Python tool manager)..."
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.cargo/bin:$PATH" # Ensure uv is available in path temporarily
log_info "Installing tmuxp via uv..."
uv tool install tmuxp
log_success "Python UV and Tmuxp installed."

# ------------------------------------------------------------------------------
# 6. SRE ALERTING (DOTFILES MONITOR)
# ------------------------------------------------------------------------------
log_info "Creating Dotfiles Monitor Systemd Timer..."
mkdir -p ~/.local/bin
cat << 'EOF' > ~/.local/bin/check_dotfiles.sh
#!/bin/bash
cd ~/Projects/dotfiles || exit
if [ -n "$(git status --porcelain)" ]; then
    notify-send -u critical "⚠️ SRE Alert" "You have uncommitted changes in ~/Projects/dotfiles!"
fi
EOF
chmod +x ~/.local/bin/check_dotfiles.sh

mkdir -p ~/.config/systemd/user
cat << 'EOF' > ~/.config/systemd/user/dotfiles-alert.service
[Unit]
Description=Verify pending commits in dotfiles
[Service]
Type=oneshot
ExecStart=/home/alexandre/.local/bin/check_dotfiles.sh
EOF

cat << 'EOF' > ~/.config/systemd/user/dotfiles-alert.timer
[Unit]
Description=Daily timer for dotfiles alert
[Timer]
OnCalendar=daily
Persistent=true
[Install]
WantedBy=timers.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now dotfiles-alert.timer
log_success "Dotfiles Monitor Active."

# ------------------------------------------------------------------------------
# 7. APPLY STOW FOR CLI
# ------------------------------------------------------------------------------
log_info "Applying Stow for CLI tools and Ghostty..."
cd ~/Projects/dotfiles
make cli sys-monitors config-apps || true

echo -e "\n${C_GREEN}🎉 PHASE 02 COMPLETED. TERMINAL FORGE IS READY.${C_RESET}"
