#!/usr/bin/env bash
# ==============================================================================
# AGY BOOTSTRAP SRE - FRESH INSTALL PROVISIONING (TIER 0 & 1)
# ==============================================================================
# Executar logo após a instalação do Fedora e criação do usuário.
# Este script foi projetado para ser 100% idempotente (rode quantas vezes quiser).

set -euo pipefail

# 🎨 Configuração de cores para output
C_GREEN="\e[32m"
C_CYAN="\e[36m"
C_YELLOW="\e[33m"
C_RED="\e[31m"
C_RESET="\e[0m"

log_info() { echo -e "${C_CYAN}[INFO]${C_RESET} $1"; }
log_success() { echo -e "${C_GREEN}[SUCCESS]${C_RESET} $1"; }
log_warn() { echo -e "${C_YELLOW}[WARN]${C_RESET} $1"; }
log_error() { echo -e "${C_RED}[ERROR]${C_RESET} $1"; }

echo -e "${C_CYAN}🚀 Iniciando o Bootstrap SRE (Tier 0 e Tier 1)${C_RESET}\n"

# ==============================================================================
# TIER 0: IDENTIDADE & SEGURANÇA (O PROBLEMA DO OVO E DA GALINHA)
# ==============================================================================
log_info "Verificando chaves de identidade (SSH)..."

if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    log_warn "Chave SSH privada não encontrada em ~/.ssh/id_ed25519"
    echo "Para o script poder clonar os dotfiles e baixar os repositórios privados,"
    echo "você precisa restaurar suas chaves."
    
    # Instalando o Bitwarden RPM oficial (já que Flatpak quebra a sincronia nativa)
    if ! command -v bitwarden >/dev/null 2>&1; then
        log_info "Baixando o Bitwarden RPM oficial para restaurar as senhas..."
        sudo rpm --import https://vault.bitwarden.com/download/rpm/cert.cer
        sudo dnf5 install -y https://vault.bitwarden.com/download/linux/rpm
        log_success "Bitwarden instalado."
    fi

    echo -e "${C_YELLOW}--- AÇÃO MANUAL REQUERIDA ---${C_RESET}"
    echo "1. Abra o Bitwarden"
    echo "2. Copie a sua chave SSH privada"
    echo "3. Crie o arquivo executando: nano ~/.ssh/id_ed25519"
    echo "4. Rode chmod 600 ~/.ssh/id_ed25519"
    echo -e "Após configurar as chaves, rode este script novamente.\n"
    exit 1
else
    log_success "Chave SSH privada detectada."
fi

# ==============================================================================
# TIER 1: BASE DO SISTEMA (PACOTES ESSENCIAIS)
# ==============================================================================
log_info "Atualizando o sistema (dnf5 upgrade)..."
sudo dnf5 upgrade -y

log_info "Instalando dependências essenciais (Git, Stow, Zsh)..."
# Usando awk e xargs para não reinstalar se não precisar
DEPS=(git stow gh zsh curl wget unzip rsync make)
MISSING_DEPS=()

for dep in "${DEPS[@]}"; do
    if ! rpm -q "$dep" >/dev/null 2>&1; then
        MISSING_DEPS+=("$dep")
    fi
done

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    log_info "Instalando pacotes faltantes: ${MISSING_DEPS[*]}"
    sudo dnf5 install -y "${MISSING_DEPS[@]}"
else
    log_success "Dependências base já instaladas."
fi

# ==============================================================================
# DEPLOY DOS DOTFILES
# ==============================================================================
DOTFILES_DIR="$HOME/Projects/dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
    log_info "Clonando repositório de dotfiles..."
    mkdir -p "$HOME/Projects"
    git clone git@github.com:alexandrevarga/dotfiles.git "$DOTFILES_DIR"
    log_success "Dotfiles clonado com sucesso."
else
    log_info "Diretório de dotfiles já existe. Pulando clone."
fi

# Trocando a shell para o ZSH se necessário
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    log_info "Trocando a shell padrão para o ZSH..."
    sudo chsh -s /usr/bin/zsh "$USER"
    log_success "Shell atualizada. (Requer logout/login para fazer efeito)."
fi

# ==============================================================================
# SRE NETWORK TUNING (TCP BBR)
# ==============================================================================
if ! grep -q "bbr" /etc/sysctl.d/90-bbr.conf 2>/dev/null; then
    log_info "Aplicando SRE Network Tuning (TCP BBR)..."
    echo "net.core.default_qdisc=fq" | sudo tee /etc/sysctl.d/90-bbr.conf >/dev/null
    echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.d/90-bbr.conf >/dev/null
    sudo sysctl --system >/dev/null
    log_success "TCP BBR Ativado."
else
    log_info "TCP BBR já configurado."
fi

echo -e "\n${C_GREEN}🎉 TIER 0 e TIER 1 concluídos com sucesso!${C_RESET}"
echo "Próximo passo: cd ~/Projects/dotfiles && make shell"
