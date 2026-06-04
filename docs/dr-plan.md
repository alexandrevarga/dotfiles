# 🚀 Fresh Install Fedora 44 — Plano Definitivo

> **Gerado em:** 2026-05-29 | **Revisado via grill-me** | **Status:** Pronto para execução

---

## Princípio de Ouro

> **"Install default → use → detect what's missing → restore only that."**
>
> Nenhuma configuração é restaurada automaticamente. Cada item tem seu card independente.
> Você instala, usa com os padrões, e só intervém quando sentir a ausência de algo.
> Sem pressa. Sem poluição. Cada mudança com impacto rastreável.

---

## Índice

1. [Estado atual do disco](#1-estado-atual-do-disco)
2. [O que está SAFE — auditoria do dotfiles repo](#2-o-que-está-safe--auditoria-do-dotfiles-repo)
3. [Gaps a resolver ANTES da install](#3-gaps-a-resolver-antes-da-install)
4. [O que VAI pro backup (sda1) e o que NÃO vai](#4-o-que-vai-pro-backup-sda1-e-o-que-não-vai)
5. [Fase 0 — Pré-install: executar nesta ordem](#5-fase-0--pré-install-executar-nesta-ordem)
6. [Fase 1 — Particionamento Btrfs no Anaconda Installer](#6-fase-1--particionamento-btrfs-no-anaconda-installer)
7. [Fase 2 — Restauração Granular por Tiers](#7-fase-2--restauração-granular-por-tiers)
8. [Checklist de validação final](#8-checklist-de-validação-final)

---

## 1. Estado atual do disco

```
nvme0n1 — 931.5GB (NVMe principal)
├─ p1   100MB   vfat    /boot/efi       ← REUSAR, NÃO FORMATAR
├─ p2    16MB   —       (MSR Windows)   ← IGNORAR
├─ p3  465.7GB  ntfs    Windows         ← PRESERVAR (dual boot)
├─ p4   532MB   ntfs    (Recovery Win)  ← IGNORAR
├─ p5     1GB   ext4    /boot           ← REFORMATAR ext4
└─ p6  464.2GB  btrfs   / + /home       ← REFORMATAR → novos subvolumes

sda — 447.1GB (HD externo)
├─ sda1   93GB  ext4    /Bak  [VAZIO]   ← REFORMATAR como Btrfs → destino do backup
└─ sda2  354GB  ext4    /mnt/meuhd      ← INTOCADO
```

---

## 2. O que está SAFE — auditoria do dotfiles repo

> Repo: `git@github.com:alexandrevarga/dotfiles.git` — **100% em sync com GitHub**

| Stow Target | O que cobre |
|---|---|
| `shell/` | `.zshrc`, `.zshenv`, `.zprofile`, `.bashrc`, `.bash_profile`, `.aliases` |
| `cli/` | `.tmux.conf`, `.gitconfig`, `oh-my-posh/paradox.omp.json` *(versão customizada)*, `tmuxp/development.yaml`, scripts: `setup_keys.sh`, `mcp-self-heal`, `img_to_path.sh`, `late-autostart.sh` |
| `config-apps/` | `ghostty/config`, `lsd/`, `mpv/` *(mpv.conf + input.conf + 39 shaders Anime4K)*, `ulauncher/`, `autostart/*.desktop`, `systemd/user/late-autostart.service`, `mimeapps.list` |
| `easyeffects/` | `AgyBaseClean.json`, `AgyNightMode.json` *(os únicos presets que importam)* |
| `sys-monitors/` | `btop/btop.conf`, `btop/themes/agy-sre.theme`, `htop/htoprc`, `monitor-edid-map.env` |
| `theme/` | `gtk-3.0/settings.ini + bookmarks`, `gtk-4.0/settings.ini` |
| `agy/` | `Antigravity/User/settings.json`, sessions markdown |

---

## 3. Gaps a resolver ANTES da install

### 3.1 — Gaps do dotfiles repo (commitar e fazer push)

> [!CAUTION]
> Execute o bloco 5.1 antes de qualquer outra coisa. Estes gaps precisam estar no repo.

| Gap | Ação |
|---|---|
| `~/.config/frogminer/linux-tkg.cfg` | **Não precisa** — estava vazio. Suas escolhas estão 100% em `customization.cfg` + `custom_config.myfrag`, que já vão pro backup sda1. |
| `~/.config/monitors.xml` | Backup no sda1 somente (não stowar) |
| `~/.fonts/FiraCode Nerd Font/` | Somente FiraCode — é a única em uso no Ghostty |
| `~/.zshrc.local` ⚠️ TEM API KEY | **NÃO commitar** — backup no sda1 em `secrets/` |
| Manifesto DNF | Gerar `dnf-packages.txt` no repo |
| Manifesto Flatpak | Gerar `flatpak-packages.txt` no repo |
| Extensões GNOME + configs | Gerar `gnome-extensions.txt` + `dconf-extensions-backup.ini` |

### 3.2 — Projetos que precisam de remote GitHub privado

| Projeto | Ação | Motivo |
|---|---|---|
| `SRE/` | `gh repo create SRE --private --source=. --push` | Importante, já tem 5 commits |
| `atlas_bot/` | `git init && gh repo create atlas_bot --private --source=. --push` | Vai evoluir |

### 3.3 — Projetos que vão SOMENTE pro backup sda1 (sem remote)

`dio/`, `desafios/`, `meu-site/`, `contribuicoes/`, `freecodecamp/`, `BPPD/`, `Beginning_Programming-CPP/`, `desktop-tweaks/`, `wrapper/`

---

## 4. O que VAI pro backup (sda1) e o que NÃO vai

### ✅ VAI pro backup sda1

| Item | Tamanho aprox. | Localização no sda1 |
|---|---|---|
| `~/Documents/` | ~2.4GB | `home_data/Documents/` |
| `~/Pictures/` | ~199MB | `home_data/Pictures/` |
| `~/Games/` | ~18GB | `home_data/Games/` |
| `~/Archive/` | ~1.1GB | `home_data/Archive/` |
| `~/Documents/Livros/` | ~55MB | já dentro de Documents |
| `~/Downloads/` (exceto ISOs) | ~varia | `home_data/Downloads/` |
| `~/.ssh/` | ~16KB | `secrets/ssh/` |
| `~/.gnupg/` | ~92KB | `secrets/gnupg/` |
| `~/.config/dconf/` | ~156KB | `configs/dconf/` (fallback de emergência) |
| `~/.zhistory` | ~108KB | `configs/zhistory` |
| `~/.config/monitors.xml` | ~795B | `configs/monitors.xml` |
| FiraCode Nerd Font | ~MB | `configs/fonts/FiraCode/` |
| Conda `atlas_env` export | ~KB | `configs/atlas_env_export.yml` |
| **Flatpak data: Floorp** | ~1.7GB | `flatpak_data/one.ablaze.floorp/` |
| **Flatpak data: Obsidian** | ~62MB | `flatpak_data/md.obsidian.Obsidian/` |
| **Flatpak data: Authenticator** | ~5.8MB | `flatpak_data/com.belmoussaoui.Authenticator/` |
| **Flatpak data: Bitwarden** | ~24MB | `flatpak_data/com.bitwarden.desktop/` |
| **Flatpak data: Telegram** | ~390MB | `flatpak_data/org.telegram.desktop/` |
| **Flatpak data: Heroic** | ~1.8GB | `flatpak_data/com.heroicgameslauncher.hgl/` |
| **Flatpak data: Steam** | ~4.1GB | `flatpak_data/com.valvesoftware.Steam/` |
| Scripts: `g`, `gemini`, `gemini-daemon`, `mutter-deep-patcher.py` | ~KB | `configs/local_bin/` |
| Kernel/tunning/ (scripts, .py, .txt, gráficos) | ~616KB | `projects/Kernel_scripts/tunning/` |
| linux-tkg arquivos chave: `customization.cfg`, `custom_config.myfrag`, `ntsync.conf`, `kernelconfig.new`, `minimal-modprobed.db`, `current_env` | ~300KB | `projects/linux_tkg_config/` |
| Projetos sem remote (ver 3.3) | ~11GB | `projects/<nome>/` |

### ❌ NÃO vai pro backup

| Item | Motivo |
|---|---|
| `~/.cache/` | Cache regenerável |
| `~/anaconda3/` (6.3GB) | Recriar com `pip install -r requirements.txt` |
| `~/.conda/` (1.1GB) | Idem |
| `~/.ollama/` | `ollama pull <modelo>` quando precisar |
| `~/.npm/`, `~/.dotnet/` | Caches de pacotes |
| `~/Downloads/*.iso` | Redownload trivial |
| `~/.poshthemes/` (80 temas) | Legacy — só o paradox.omp.json customizado está no dotfiles |
| EasyEffects: `antes.json`, `LoudnessCrystal`, `LoudnessEqualizer` | Legacy confirmado, podem ser apagados |
| `~/.oh-my-zsh/` | Framework reinstalável |
| `~/.zcompdump*` | Cache de completions zsh |
| `~/.mozilla/` | Não usa Firefox como browser principal |
| Kernel/linux-tkg/linux-src-git/ (4GB) | Reclonado no build |
| Kernel/linux-tkg/linux-kernel.git/ (288MB) | Idem |
| Kernel/linux-tkg/RPMS/ (83MB) | RPMs descartáveis |
| Kernel/linux-tkg/logs/ | Logs de build |
| `mutter-gvariant-patcher.py` | Tentativa que não funcionou — descartável |

---

## 5. Fase 0 — Pré-install: executar nesta ordem

> [!IMPORTANT]
> Não execute o próximo passo sem confirmar que o anterior foi concluído.

### 5.1 — Commitar gaps no dotfiles repo

```bash
cd ~/Projects/dotfiles

# Manifesto de pacotes
dnf5 repoquery --userinstalled --qf '%{name}\n' 2>/dev/null | sort > dnf-packages.txt
flatpak list --app --columns=application | sort > flatpak-packages.txt

# Backup das configs de extensões GNOME
mkdir -p config-apps/.config/gnome-extensions
gsettings get org.gnome.shell enabled-extensions > config-apps/.config/gnome-extensions/enabled-list.txt
dconf dump /org/gnome/shell/extensions/ > config-apps/.config/gnome-extensions/all-extensions.dconf

# Commit e push
git add -A
git commit -m "backup(pre-install): add linux-tkg.cfg, package manifests and extensions config"
git push origin main
```

### 5.2 — Push remotes privados (SRE e atlas_bot)

```bash
# SRE — tem git local, sem remote
cd ~/Projects/SRE
gh repo create SRE --private --source=. --push

# atlas_bot — sem git
cd ~/Projects/atlas_bot
git init && git add -A
git commit -m "initial commit"
gh repo create atlas_bot --private --source=. --push
```

### 5.3 — Formatar sda1 como Btrfs

```bash
sudo umount /run/media/alexandre/Bak 2>/dev/null || true
sudo mkfs.btrfs -L BakSSD /dev/sda1
sudo mkdir -p /mnt/bak
sudo mount /dev/sda1 /mnt/bak
```

### 5.4 — Executar backup rsync

```bash
#!/usr/bin/env bash
# Executar após montar sda1 em /mnt/bak
set -euo pipefail

BAK="/mnt/bak"
H="/home/alexandre"
TIMESTAMP=$(date +%Y%m%d_%H%M)

echo "=== Backup pré-install: $TIMESTAMP ==="

mkdir -p "$BAK"/{home_data,secrets,configs,flatpak_data,projects,configs/local_bin,projects/Kernel_scripts,projects/linux_tkg_config}

# — DADOS PESSOAIS —
rsync -avh --progress "$H/Documents/"      "$BAK/home_data/Documents/"
rsync -avh --progress "$H/Pictures/"       "$BAK/home_data/Pictures/"
rsync -avh --progress "$H/Games/"          "$BAK/home_data/Games/"
rsync -avh --progress "$H/Archive/"        "$BAK/home_data/Archive/"
rsync -avh --progress --exclude="*.iso" --exclude="*.ISO" \
    "$H/Downloads/"                         "$BAK/home_data/Downloads/"

# — SECRETS —
rsync -avh "$H/.ssh/"      "$BAK/secrets/ssh/"
rsync -avh "$H/.gnupg/"    "$BAK/secrets/gnupg/"

# — CONFIGS —
rsync -avh "$H/.config/dconf/"            "$BAK/configs/dconf/"
cp "$H/.zhistory"                          "$BAK/configs/zhistory_$TIMESTAMP" || true
cp "$H/.config/monitors.xml"              "$BAK/configs/monitors.xml" || true
rsync -avh "$H/.fonts/FiraCode Nerd Font/" "$BAK/configs/fonts/FiraCode Nerd Font/"

# Scripts custom do local/bin (não estão no dotfiles)
for s in g gemini gemini-daemon mutter-deep-patcher.py; do
    [ -f "$H/.local/bin/$s" ] && cp "$H/.local/bin/$s" "$BAK/configs/local_bin/$s"
done

# Conda env export
conda env export -n atlas_env > "$BAK/configs/atlas_env_export.yml" 2>/dev/null || true

# — FLATPAK DATA —
for app in one.ablaze.floorp md.obsidian.Obsidian com.belmoussaoui.Authenticator \
           com.bitwarden.desktop org.telegram.desktop \
           com.heroicgameslauncher.hgl com.valvesoftware.Steam; do
    [ -d "$H/.var/app/$app" ] && \
        rsync -avh --progress "$H/.var/app/$app/" "$BAK/flatpak_data/$app/"
done

# — KERNEL / linux-tkg (só arquivos úteis, sem sources pesadas) —
# Nota: configs/ tinha só 1 txt legacy que foi deletado
rsync -avh "$H/Projects/Kernel/tunning/"  "$BAK/projects/Kernel_scripts/tunning/"
for f in customization.cfg custom_config.myfrag ntsync.conf \
          kernelconfig.new minimal-modprobed.db current_env; do
    [ -f "$H/Projects/Kernel/linux-tkg/$f" ] && \
        cp "$H/Projects/Kernel/linux-tkg/$f" "$BAK/projects/linux_tkg_config/"
done

# — PROJETOS SEM REMOTE —
for proj in dio desafios meu-site contribuicoes freecodecamp \
            BPPD Beginning_Programming-CPP desktop-tweaks wrapper; do
    [ -d "$H/Projects/$proj" ] && \
        rsync -avh --progress "$H/Projects/$proj/" "$BAK/projects/$proj/"
done

echo ""
echo "✅ Backup concluído. Total:"
du -sh "$BAK"
```

### 5.5 — Unificar Calibre antes de sair

```bash
# Verificar se há livros na Biblioteca do calibre que não estão em Documents/Livros/
diff <(ls ~/"Biblioteca do calibre"/) <(ls ~/Documents/Livros/) 2>/dev/null

# Se tudo já está em Livros/, apagar o diretório do Calibre
# (a Biblioteca do calibre contém só metadados — os EPUBs/PDFs já estão em Livros/)
rm -rf ~/"Biblioteca do calibre"
# Calibre Flatpak: será removido na fresh install (não reinstalar)
```

### 5.6 — Apagar EasyEffects legacy

```bash
rm -f ~/.var/app/com.github.wwmm.easyeffects/config/easyeffects/output/antes.json
rm -f ~/.var/app/com.github.wwmm.easyeffects/config/easyeffects/output/LoudnessCrystalEqualizer.json
rm -f ~/.var/app/com.github.wwmm.easyeffects/config/easyeffects/output/LoudnessEqualizer.json
```

### 5.7 — Validação final antes de bootar o USB

```bash
# Dotfiles
git -C ~/Projects/dotfiles status                # deve retornar: clean
git -C ~/Projects/dotfiles log --oneline -3

# Remotes novos
git -C ~/Projects/SRE remote -v                 # deve mostrar github.com
git -C ~/Projects/atlas_bot remote -v           # deve mostrar github.com

# Backup
ls /mnt/bak/{home_data,secrets,flatpak_data,projects}
ls /mnt/bak/secrets/                            # ssh/, gnupg/, zshrc.local
du -sh /mnt/bak/

# Desmontar com segurança
sync && sudo umount /mnt/bak
echo "✅ sda1 seguro para desconectar"
```

---

## 6. Fase 1 — Particionamento Btrfs no Anaconda Installer

### Layout alvo dos subvolumes

| Subvolume | Mountpoint | Notas |
|---|---|---|
| `@` | `/` | root do sistema |
| `@home` | `/home` | dados pessoais e VMs locais (com NoCoW) |
| `@flatpak` | `/var/lib/flatpak` | Isola seus 23GB de apps contra rollbacks e reinstalações |
| `@var_log` | `/var/log` | Mantém logs vivos pós-rollback para auditoria de erros |
| `@snapshots` | `/.snapshots` | destino do Snapper (sistema de rollback automático) |

> [!IMPORTANT]
> **`/boot` = 2GB** (padrão oficial Fedora 44 — mudou de 1GB). O Anaconda já aplica 2GB automaticamente no modo Custom. Confirmar durante o particionamento. Sua partição atual tem 974MB e está 55% cheia com apenas 1 kernel tkg — com múltiplos kernels isso aperta rápido.

### Passo a passo no Anaconda

1. Boot pelo Ventoy (já está no sdb) com ISO Fedora 44 Workstation
2. Iniciar "Install to Hard Drive"
3. **Installation Destination** → selecionar `nvme0n1`
4. Storage Configuration → **"Custom"** (não Automatic)
5. Clicar **"Done"** para abrir o editor manual
6. Mudar esquema para **"Btrfs"**
7. Configurar partições existentes:
   - `nvme0n1p1` → `/boot/efi` → **Reuse, NÃO formatar**
   - `nvme0n1p2`, `p3`, `p4` → **Ignorar** (Windows)
   - `nvme0n1p5` → `/boot` → **2GB** → formatar ext4 ✓  ← confirmar tamanho no Anaconda
   - `nvme0n1p6` → `/` → formatar Btrfs ✓ → subvolume name: `@`
8. Adicionar subvolumes via `+`:
   - `/home` → Btrfs → `@home`
   - `/var/lib/flatpak` → Btrfs → `@flatpak`
   - `/var/log` → Btrfs → `@var_log`
   - `/.snapshots` → Btrfs → `@snapshots`
9. **"Done"** → revisar → **"Accept Changes"**
10. Continuar install normalmente

> [!NOTE]
> GRUB detecta o Windows automaticamente via os-prober. Dual boot funciona igual ao atual.

---

## 7. Fase 2 — Restauração Granular por Tiers

> **Regra de ouro de cada card:**
> 1. Execute `[instalar]`
> 2. Use por um tempo com defaults
> 3. Se algo estiver faltando → execute `[restaurar config]`
> 4. Se os defaults já servirem → pule o restore

---

### TIER 1 — Base do sistema (primeiros 30 min)

---

#### 📦 Card: Atualização base

```bash
# [instalar]
sudo dnf5 upgrade -y

# [validar]
cat /etc/fedora-release    # Fedora Linux 44
uname -r                   # kernel padrão do Fedora
```

---

#### 📦 Card: Git + Stow + ZSH + ferramentas essenciais

```bash
# [instalar]
sudo dnf5 install -y git stow gh zsh curl wget unzip rsync make 

# [validar]
git --version && stow --version && zsh --version
```

---

#### 📦 Card: Clonar dotfiles e fazer deploy do shell

```bash
# [instalar]
git clone git@github.com:alexandrevarga/dotfiles.git ~/Projects/dotfiles
cd ~/Projects/dotfiles
make shell         # ZSH + aliases + profile

chsh -s $(which zsh)
# → Logout e login para ativar ZSH como shell padrão

# [validar]
echo $SHELL        # deve retornar /usr/bin/zsh
cat ~/.aliases | head -5
```

---

#### 📦 Card: SRE Network Tuning (TCP BBR)

> Garante que o BBR fique ativo mesmo quando você usar o kernel padrão do Fedora, melhorando throughput e latência.

```bash
# [instalar]
echo "net.core.default_qdisc=fq" | sudo tee /etc/sysctl.d/90-bbr.conf
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.d/90-bbr.conf
sudo sysctl --system

# [validar]
sysctl net.ipv4.tcp_congestion_control
# Deve retornar: bbr
```

---

#### 📦 Card: DNS-over-TLS (Cloudflare) e Fast Boot

> **DNS Blindado:** Impede a operadora de rastrear seus acessos e usa o servidor mais rápido (12ms).
> **Fast Boot:** Remove o atraso inútil do systemd esperando a rede antes do login.

```bash
# [configurar DNS-over-TLS]
sudo mkdir -p /etc/systemd/resolved.conf.d
cat << 'EOF' | sudo tee /etc/systemd/resolved.conf.d/dns_over_tls.conf
[Resolve]
DNS=1.1.1.1 1.0.0.1
DNSOverTLS=yes
EOF
sudo systemctl restart systemd-resolved

# [desativar wait-online para boot rápido]
sudo systemctl disable NetworkManager-wait-online.service

# [validar]
resolvectl status | grep "DNSOverTLS"    # Deve retornar: DNSOverTLS: yes
systemctl is-enabled NetworkManager-wait-online.service  # Deve retornar: disabled
```

---

### TIER 2 — Identidade e Segurança

---

#### 🔑 Card: SSH

```bash
# [instalar]
sudo mount /dev/sda1 /mnt/bak

mkdir -p ~/.ssh && chmod 700 ~/.ssh
cp /mnt/bak/secrets/ssh/id_ed25519     ~/.ssh/
cp /mnt/bak/secrets/ssh/id_ed25519.pub ~/.ssh/
chmod 600 ~/.ssh/id_ed25519

eval $(ssh-agent -s)
ssh-add ~/.ssh/id_ed25519

# [validar]
ssh -T git@github.com
# Esperado: "Hi alexandrevarga! You've successfully authenticated..."
```

---

#### 🔑 Card: GPG

```bash
# [instalar]
cp -r /mnt/bak/secrets/gnupg/ ~/.gnupg/
chmod 700 ~/.gnupg && chmod 600 ~/.gnupg/* 2>/dev/null || true
gpg-connect-agent reloadagent /bye

# [validar]
gpg --list-secret-keys     # deve listar suas chaves
```

---

### TIER 3 — Terminal e ambiente CLI

---

#### 📦 Card: Oh-My-Posh

```bash
# [instalar]
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin

# [validar]
oh-my-posh --version

# [restaurar config]
# O paradox.omp.json customizado já vem com make cli (Tier 3 abaixo)
# Se o tema não carregar corretamente:
cd ~/Projects/dotfiles && make cli
```

---

#### 📦 Card: CLI tools (tmux, btop, lsd, ripgrep)

```bash
# [instalar]
sudo dnf5 install -y tmux btop lsd ripgrep bat fd-find fzf

# [validar]
tmux -V && btop --version && lsd --version

# [restaurar config]
cd ~/Projects/dotfiles && make cli sys-monitors
# Isso linka: tmux.conf, tmuxp/, btop.conf, htop, agy-sre.theme
```

---

#### 📦 Card: Ghostty

```bash
# [instalar]
sudo dnf5 install -y ghostty

# [validar]
ghostty --version
# Abrir Ghostty — deve funcionar com config padrão

# [restaurar config]
cd ~/Projects/dotfiles && make config-apps
# Isso linka: ~/.config/ghostty/config
# Impacto: paleta SRE, FiraCode 16pt, cursor cyan block
```

---

#### 📦 Card: FiraCode Nerd Font

```bash
# [instalar — só se Ghostty reclamar de fonte ausente]
sudo mount /dev/sda1 /mnt/bak
cp -r "/mnt/bak/configs/fonts/FiraCode Nerd Font/" ~/.fonts/
fc-cache -fv

# [validar]
fc-list | grep -i fira
```

---

#### 📦 Card: Shell Upgrades Modernos (atuin + zoxide)

```bash
# [instalar]
sudo dnf5 install -y atuin zoxide

# [restaurar config]
# Adicionar ao ~/.zshrc (e futuramente commitar no dotfiles):
# eval "$(zoxide init zsh)"
# eval "$(atuin init zsh)"
```

---

#### 📦 Card: SRE Alerting (Monitor de Dotfiles)

> Um timer diário que avisa via notificação de desktop se houver commits pendentes no seu dotfiles, prevenindo perda de configs em formatações futuras.

```bash
# [instalar]
mkdir -p ~/.local/bin
cat << 'EOF' > ~/.local/bin/check_dotfiles.sh
#!/bin/bash
cd ~/Projects/dotfiles || exit
if [ -n "$(git status --porcelain)" ]; then
    notify-send -u critical "⚠️ Alerta SRE" "Você tem alterações não commitadas no ~/Projects/dotfiles!"
fi
EOF
chmod +x ~/.local/bin/check_dotfiles.sh

mkdir -p ~/.config/systemd/user
cat << 'EOF' > ~/.config/systemd/user/dotfiles-alert.service
[Unit]
Description=Verificar commits pendentes no dotfiles
[Service]
Type=oneshot
ExecStart=/home/alexandre/.local/bin/check_dotfiles.sh
EOF

cat << 'EOF' > ~/.config/systemd/user/dotfiles-alert.timer
[Unit]
Description=Timer diario para alerta do dotfiles
[Timer]
OnCalendar=daily
Persistent=true
[Install]
WantedBy=timers.target
EOF

# [ativar]
systemctl --user daemon-reload
systemctl --user enable --now dotfiles-alert.timer
```

---

#### 📦 Card: Tmux + tmuxp (sessão Development)

```bash
# [instalar]
uv tool install tmuxp

# [validar]
tmuxp load ~/Projects/dotfiles/cli/.config/tmuxp/development.yaml

# [restaurar config]
# O development.yaml já está no dotfiles (make cli)
```

> [!NOTE]
> **Como o Stow funciona:** `make config-apps` só cria symlinks — não instala software nem sobrescreve nada silenciosamente. Se o destino (ex: `~/.config/ghostty/config`) já existir como arquivo real, o Stow avisa e para. Se o app não estiver instalado, o symlink aponta pro nada e é inofensivo. Seguro rodar a qualquer momento.

---

### TIER 4 — Ambiente de desenvolvimento

---

#### 📦 Card: uv (Python tool manager)

```bash
# [instalar]
curl -LsSf https://astral.sh/uv/install.sh | sh

# [validar]
uv --version
```

---

#### 📦 Card: Git SRE Upgrades (delta + lazygit)

```bash
# [instalar]
sudo dnf5 install -y git-delta lazygit

# [restaurar config]
# delta: requer configuração simples na seção [pager] e [delta] do ~/.gitconfig.
# lazygit: basta rodar "lazygit" dentro de qualquer pasta de projeto.
```

---

#### 📦 Card: Flatpak (base)

```bash
# [instalar]
sudo dnf5 install -y flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# [validar]
flatpak remotes    # deve listar flathub
```

---

#### 📦 Card: Flatseal (Gerenciamento SRE de permissões)

> Essencial para manter a segurança do sistema. Permite restringir exatamente o que cada aplicativo Flatpak pode acessar (rede, webcams, arquivos, microfone).

```bash
# [instalar]
flatpak install flathub com.github.tchx84.Flatseal -y

# [validar]
# Abrir Flatseal e checar a lista de permissões dos seus apps (ex: revogar acesso a arquivos locais do Telegram se desejar)
```

---

#### 📦 Card: EasyEffects

```bash
# [instalar]
flatpak install flathub com.github.wwmm.easyeffects -y

# [validar]
# Abrir EasyEffects — deve funcionar sem preset (sem áudio customizado ainda)

# [restaurar config]
cd ~/Projects/dotfiles && make easyeffects
# Impacto: AgyBaseClean.json e AgyNightMode.json disponíveis
# Selecionar o preset na UI do EasyEffects
```

---

#### 📦 Card: MPV + Anime4K

```bash
# [instalar]
sudo dnf5 install -y mpv

# [validar]
mpv --version
# Reproduzir um vídeo — funciona com decoder padrão

# [restaurar config]
cd ~/Projects/dotfiles && make config-apps
# Impacto: mpv.conf (dither off, soxr, F4=432Hz), input.conf, 39 shaders Anime4K
# Para ativar Anime4K: Shift+A durante reprodução
```

---

#### 📦 Card: VS Code (Flatpak oficial)

```bash
# [instalar] — Flatpak oficial, atualiza automaticamente via flatpak update
flatpak install flathub com.visualstudio.code -y

# [validar]
flatpak run com.visualstudio.code --version

# [restaurar config]
# Extensions sincronizam automaticamente se Settings Sync estiver ativo
```

---

#### 📦 Card: Docker Engine (Otimização SRE data-root)

> Instala o Docker e redireciona a pasta de dados do root daemon para a `/home` (imune a rollback) com desativação do CoW e regras de segurança do SELinux.

```bash
# [instalar]
sudo dnf5 install -y moby-engine

# [configurar data-root na home]
sudo mkdir -p /home/docker-data
sudo chattr +C /home/docker-data
sudo chmod 711 /home/docker-data

# Criar a config do daemon
sudo mkdir -p /etc/docker
cat << 'EOF' | sudo tee /etc/docker/daemon.json
{
  "data-root": "/home/docker-data"
}
EOF

# Aplicar contexto SELinux
sudo semanage fcontext -a -t container_var_lib_t "/home/docker-data(/.*)?" 2>/dev/null || true
sudo restorecon -R -v /home/docker-data 2>/dev/null || true

# [ativar]
sudo systemctl enable --now docker

# [validar]
sudo docker info | grep "Docker Root Dir"  # Deve retornar: /home/docker-data
```

---

#### 📦 Card: Antigravity CLI — settings (modelo, fonte)

```bash
# [restaurar config]
cd ~/Projects/dotfiles && make agy
# Cria symlink: ~/.config/Antigravity/User/settings.json
# Conteúdo: { "editor.fontSize": 18, "antigravity.modelSelection": "Gemini 3.5 Flash (High)" }

# [validar]
cat ~/.config/Antigravity/User/settings.json
```

---

### TIER 5 — Aplicativos pessoais

---

#### 📦 Card: Floorp (browser principal)

```bash
# [instalar]
flatpak install flathub one.ablaze.floorp -y

# [validar]
# Abrir Floorp — login manual nos sites necessários por agora

# [restaurar perfil — SOMENTE se não quiser fazer login manualmente]
sudo mount /dev/sda1 /mnt/bak
rsync -avh /mnt/bak/flatpak_data/one.ablaze.floorp/ ~/.var/app/one.ablaze.floorp/
# Impacto: restaura perfil, cookies, logins, extensões, favoritos
```

---

#### 📦 Card: Obsidian

```bash
# [instalar]
flatpak install flathub md.obsidian.Obsidian -y

# [validar]
# Abrir Obsidian — vault vazio por enquanto

# [restaurar vault e config]
sudo mount /dev/sda1 /mnt/bak
rsync -avh /mnt/bak/flatpak_data/md.obsidian.Obsidian/ ~/.var/app/md.obsidian.Obsidian/
```

---

#### 📦 Card: Authenticator (2FA) ⚠️ CRÍTICO

```bash
# [instalar]
flatpak install flathub com.belmoussaoui.Authenticator -y

# [restaurar dados — OBRIGATÓRIO, sem isso perde os códigos 2FA]
sudo mount /dev/sda1 /mnt/bak
rsync -avh /mnt/bak/flatpak_data/com.belmoussaoui.Authenticator/ \
    ~/.var/app/com.belmoussaoui.Authenticator/

# [validar]
# Abrir Authenticator — seus códigos TOTP devem aparecer
```

---

#### 📦 Card: Bitwarden

> [!IMPORTANT]
> **Não instalar via Flatpak.** O Bitwarden Flatpak tem integração quebrada com extensão de browser no Wayland (native messaging bloqueado pelo sandbox). Instalar via **RPM oficial** para integração funcionar nativamente.

```bash
# [instalar] — RPM direto do site oficial
wget https://vault.bitwarden.com/download/?app=desktop&platform=linux&variant=rpm \
     -O bitwarden.rpm
sudo dnf5 install -y ./bitwarden.rpm
rm bitwarden.rpm

# [validar]
bitwarden --version
# Login com email/master password
# Ativar: Settings → App Settings → Browser Integration
# Na extensão do Floorp: conectar ao desktop app para biometria/autopreenchimento
```

---

#### 📦 Card: Telegram

```bash
# [instalar]
flatpak install flathub-beta org.telegram.desktop -y

# [validar]
# Login via QR code ou número

# [restaurar cache/config]
sudo mount /dev/sda1 /mnt/bak
rsync -avh /mnt/bak/flatpak_data/org.telegram.desktop/ ~/.var/app/org.telegram.desktop/
```

---

#### 📦 Card: Steam

```bash
# [instalar]
flatpak install flathub com.valvesoftware.Steam -y

# [validar]
# Login com conta Steam — biblioteca sincroniza da nuvem

# [restaurar dados locais — só saves e configs que não sincronizam na nuvem]
sudo mount /dev/sda1 /mnt/bak
rsync -avh /mnt/bak/flatpak_data/com.valvesoftware.Steam/ ~/.var/app/com.valvesoftware.Steam/
```

---

#### 📦 Card: Heroic Games Launcher

```bash
# [instalar]
flatpak install flathub com.heroicgameslauncher.hgl -y

# [restaurar configurações e biblioteca]
sudo mount /dev/sda1 /mnt/bak
rsync -avh /mnt/bak/flatpak_data/com.heroicgameslauncher.hgl/ \
    ~/.var/app/com.heroicgameslauncher.hgl/
```

---

### TIER 6 — GNOME: Interface e Extensões

---

#### 📦 Card: Extensões GNOME (instalar e testar defaults primeiro)

```bash
# [instalar — gext via pipx]
# Por que pipx? O gext não tem pacote DNF oficial. pipx isola cada tool
# em venv próprio — sem poluir o Python do sistema, sem conflitos de deps.
sudo dnf5 install -y pipx
pipx install gnome-extensions-cli

# Auto Move Windows — CRÍTICO para o cockpit de workspaces
gext install auto-move-windows@gnome-shell-extensions.gcampax.github.com

# Blur my Shell
gext install blur-my-shell@aunetx

# Caffeine
gext install caffeine@patapon.info

# Hot Edge
gext install hotedge@jonathan.jdoda.ca

# Just Perfection
gext install just-perfection-desktop@just-perfection

# Notification Configurator
gext install notification-configurator@exposedcat

# Quick Settings Audio Devices Hider
gext install quicksettings-audio-devices-hider@marcinjahn.com

# System Monitor
gext install system-monitor@gnome-shell-extensions.gcampax.github.com

# [validar]
gext list    # todas listadas como 🔵 ativas
```

---

#### 📦 Card: Auto Move Windows — restaurar regras de workspace

```bash
# [testar default primeiro]
# Abrir apps e ver se vão para os workspaces errados

# [restaurar config — somente se os workspaces não estiverem certos]
dconf load /org/gnome/shell/extensions/auto-move-windows/ << 'EOF'
[/]
application-list=['code-insiders.desktop:2', 'one.ablaze.floorp.desktop:3', 'org.telegram.desktop.desktop:5', 'com.stremio.Stremio.desktop:7', 'com.github.wwmm.easyeffects.desktop:8', 'com.mitchellh.ghostty.desktop:1', 'mpv.desktop:7']
EOF

# [validar]
# Abrir Ghostty → deve ir para Workspace 1
# Abrir VS Code → Workspace 2
# Abrir Floorp → Workspace 3
```

---

#### 📦 Card: Just Perfection — restaurar layout do painel

```bash
# [testar default primeiro]
# O painel padrão do GNOME funciona mas tem tamanho/espaçamentos diferentes

# [restaurar config — somente se o layout do painel parecer errado]
dconf load /org/gnome/shell/extensions/just-perfection/ << 'EOF'
[/]
accent-color-icon=true
activities-button=false
animation=0
dash=true
dash-icon-size=48
events-button=false
keyboard-layout=false
panel=true
panel-icon-size=18
panel-indicator-padding-size=25
panel-size=36
power-icon=true
workspace=true
workspace-switcher-size=12
workspace-thumbnail-to-main-view=true
workspace-wrap-around=true
workspaces-in-app-grid=false
window-demands-attention-focus=true
EOF
```

---

#### 📦 Card: Quick Settings Audio Devices Hider

```bash
# [restaurar config — somente se Easy Effects Source aparecer no quick panel]
dconf load /org/gnome/shell/extensions/quicksettings-audio-devices-hider/ << 'EOF'
[/]
excluded-input-names=['Easy Effects Source']
excluded-output-names=['Easy Effects Sink']
EOF
```

---

#### 📦 Card: Notification Configurator

```bash
# [restaurar config — somente se as notificações parecerem erradas]
dconf write /org/gnome/shell/extensions/notification-configurator/global \
  '"{\"enabled\":true,\"notificationCenter\":{\"disableGrouping\":false,\"maximumPerSource\":2},\"rateLimiting\":{\"enabled\":false},\"timeout\":{\"enabled\":true,\"notificationTimeout\":2000,\"ignoreIdle\":true},\"urgency\":{\"alwaysNormalUrgency\":true},\"display\":{\"enableFullscreen\":false,\"notificationPosition\":\"center\",\"verticalPosition\":\"top\",\"hideAppTitleRow\":true}}"'
```

---

#### 📦 Card: Atalhos GNOME (keybindings)

> O `setup_keys.sh` configura **tudo de uma vez**: switch-to-application (Super+Return/c/b/t/s/e), atalhos de energia zero-acidente (Ctrl+Pause, Ctrl+Shift+Pause, Ctrl+Alt+Delete, Ctrl+Alt+End), Ulauncher (Ctrl+Space), img_to_path (Super+i), dock favorites, e instala o NoAnnoyance. Um script resolve o cockpit inteiro.

```bash
# [restaurar via script — primeira opção]
bash ~/.local/bin/setup_keys.sh

# [validar]
# Super+Return → Ghostty (Workspace 1)
# Super+c      → VS Code (Workspace 2)
# Super+b      → Floorp (Workspace 3)
# Super+t      → Telegram (Workspace 5)
# Super+s      → Stremio (Workspace 7)
# Super+e      → EasyEffects (Workspace 8)
# Ctrl+Space   → Ulauncher
# Ctrl+Pause   → Suspend
# Ctrl+Alt+Del → Reboot
# Ctrl+Alt+End → Poweroff

# [restaurar via dconf — bomba atômica, só se setup_keys.sh não resolver]
dconf load / < /mnt/bak/configs/dconf/user.dconf
```

---

#### 📦 Card: Ulauncher

```bash
# [instalar]
sudo dnf5 install -y ulauncher

# [validar]
# Ctrl+Space para abrir — funciona com config padrão

# [restaurar config]
cd ~/Projects/dotfiles && make config-apps
# Restaura settings.json, shortcuts.json, extensions.json do Ulauncher
```

---

### TIER 7 — Snapper + GRUB Rollback (snapshots)

---

#### 📦 Card: Snapper (DNF triggers + Snapshots Diários/Semanais)

> Automatiza backups em atualizações do sistema e gerencia backups agendados (timeline) em uma única ferramenta nativa.

```bash
# [instalar]
sudo dnf5 install -y snapper python3-dnf-plugin-snapper

# Criar config para root
sudo snapper -c root create-config /

# [configurar agendamento de timeline]
# 1. Ativar os serviços do snapper no systemd
sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer

# 2. Ajustar limites de limpeza no arquivo de configuração do root
# Edite o arquivo /etc/snapper/configs/root e garanta estas chaves de limite:
# TIMELINE_LIMIT_HOURLY="0"   # Desativa de hora em hora
# TIMELINE_LIMIT_DAILY="5"    # Mantém os últimos 5 diários
# TIMELINE_LIMIT_WEEKLY="2"   # Mantém os últimos 2 semanais
# TIMELINE_LIMIT_MONTHLY="0"  # Desativa mensais
# TIMELINE_LIMIT_YEARLY="0"   # Desativa anuais

# [validar]
sudo snapper list
sudo systemctl list-timers | grep snapper
```

---

#### 📦 Card: grub-btrfs (Rollback direto no GRUB)

> Cria entradas de boot no menu do GRUB para cada snapshot do Snapper, permitindo recuperar o sistema mesmo se a interface gráfica ou o TTY quebrarem.

```bash
# [instalar]
sudo dnf5 install -y grub-btrfs

# [ativar monitoramento automático de snapshots]
# O daemon do grub-btrfs reconstrói o menu do GRUB instantaneamente toda vez que o Snapper cria um snapshot
sudo systemctl enable --now grub-btrfsd.service

# [validar]
# Criar um snapshot de teste
sudo snapper create --description "teste-grub-btrfs"
# Reiniciar o sistema e verificar se o submenu "Fedora Snapshots" aparece no menu do GRUB
```

---

#### 📦 Card: Btrfsmaintenance (Scrub e Balance auto)

> SRE File System Healing: automatiza a checagem de bits corrompidos (scrub) e o desfragmentamento livre (balance) para o btrfs rodar saudável para sempre.

```bash
# [instalar]
sudo dnf5 install -y btrfsmaintenance

# [ativar e validar]
sudo systemctl enable --now btrfs-scrub.timer
sudo systemctl enable --now btrfs-balance.timer
sudo systemctl list-timers | grep btrfs
```

---

### TIER 8 — linux-tkg kernel customizado

> [!NOTE]
> Usar o kernel padrão do Fedora por pelo menos uma semana antes de rebuildar o tkg.
> O sistema base precisa estar estável antes de adicionar o kernel customizado.

---

#### 📦 Card: linux-tkg rebuild

> **Nota:** O `linux-tkg.cfg` em `~/.config/frogminer/` estava vazio — suas configurações reais estão 100% no `customization.cfg` e `custom_config.myfrag` que vêm do backup. O `install.sh` faz `source linux-tkg.cfg` como override opcional — se não existir, usa `customization.cfg` direto.

```bash
# [pré-requisitos]
sudo dnf5 install -y gcc gcc-c++ make patch flex bison openssl-devel \
    elfutils-libelf-devel bc perl dwarves rpm-build

# [clonar o repo limpo]
git clone https://github.com/Frogging-Family/linux-tkg.git ~/Projects/linux-tkg

# [restaurar suas customizações do sda1]
sudo mount /dev/sda1 /mnt/bak
cp /mnt/bak/projects/linux_tkg_config/customization.cfg     ~/Projects/linux-tkg/
cp /mnt/bak/projects/linux_tkg_config/custom_config.myfrag  ~/Projects/linux-tkg/
cp /mnt/bak/projects/linux_tkg_config/ntsync.conf           ~/Projects/linux-tkg/
cp /mnt/bak/projects/linux_tkg_config/kernelconfig.new      ~/Projects/linux-tkg/
cp /mnt/bak/projects/linux_tkg_config/minimal-modprobed.db  ~/Projects/linux-tkg/
cp /mnt/bak/projects/linux_tkg_config/current_env           ~/Projects/linux-tkg/

# [build — ~60-90 min com iGPU Intel, 12GB RAM]
cd ~/Projects/linux-tkg
./install.sh install

# [validar]
rpm -qa | grep tkg
# Reiniciar e selecionar no GRUB
```

---

## 8. Checklist de validação final

### Pré-install
- [ ] `git -C ~/Projects/dotfiles log --oneline -1` → commit dos gaps presente
- [ ] `git -C ~/Projects/SRE remote -v` → github.com listado
- [ ] `git -C ~/Projects/atlas_bot remote -v` → github.com listado
- [ ] `ls /mnt/bak/secrets/` → `ssh/`, `gnupg/`, `zshrc.local` presentes
- [ ] `ls /mnt/bak/flatpak_data/` → Floorp, Obsidian, Authenticator, Steam, Heroic presentes
- [ ] `ls /mnt/bak/projects/linux_tkg_config/` → `customization.cfg`, `custom_config.myfrag` presentes
- [ ] `sync && sudo umount /mnt/bak` → desmontado com segurança

### Anaconda Installer
- [ ] `nvme0n1p1` (`/boot/efi`) → **reusado sem formatar**
- [ ] `nvme0n1p2`, `p3`, `p4` → **intocados** (Windows preservado)
- [ ] `nvme0n1p5` (`/boot`) → formatado ext4
- [ ] `nvme0n1p6` → Btrfs com subvolumes: `@`, `@home`, `@flatpak`, `@var_log`, `@snapshots`
- [ ] GRUB detectou Windows no menu de boot

### Pós-install (Tier por Tier)
- [ ] **T1:** `echo $SHELL` → `/usr/bin/zsh` | `.aliases` carregando
- [ ] **T2:** `ssh -T git@github.com` → autenticado | `gpg --list-secret-keys` → chaves presentes
- [ ] **T3:** Ghostty abre com paleta correta | Tmux carrega sessão Development | `make agy` → settings.json linkado
- [ ] **T4:** EasyEffects com AgyBaseClean ativo | MPV reproduz vídeo | Bitwarden RPM instalado e browser integration ativo
- [ ] **T5:** Authenticator mostra códigos 2FA ← confirmar ANTES de qualquer outra coisa
- [ ] **T6:** `gext list` → 8 extensões ativas | Ghostty vai para Workspace 1
- [ ] **T7:** `sudo snapper list` → Snapper ativo com timers do timeline e grub-btrfsd habilitados
- [ ] **T8:** *(quando estiver pronto)* `uname -r` → kernel tkg
