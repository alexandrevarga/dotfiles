#!/bin/bash
# =====================================================================
# AGY WORKFLOW - SETUP DE ATALHOS ERGONÔMICOS GNOME (WAYLAND FOCUS EDITION)
# =====================================================================

echo "🚀 [AGY] Iniciando otimização de Foco Nativo para Wayland..."

# 1. Liberação de atalhos de layout e favoritos antigos
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "[]"

# Limpa o custom0 antigo para evitar duplicatas ou conflitos
# Limpa o custom antigo para evitar conflitos
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[]"

# 2. Configura os atalhos customizados do Gnome (Necessário para Wayland)
# custom0: Ulauncher (Ctrl+Space)
# custom1: Clipboard Image to Text Path Converter (Super+I)
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/']"

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "Launch Ulauncher"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "ulauncher-toggle"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "<Primary>space"

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name "Convert Clipboard Image to Path"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command "/home/alexandre/.local/bin/img_to_path.sh"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding "<Super>i"

# 3. Rearranjo do Dock para respeitar o limite de 9 favoritos do Gnome
# Movemos o EasyEffects da posição 12 para a posição 8 (Obsidian vai para a 12ª)
gsettings set org.gnome.shell favorite-apps "['org.gnome.Ptyxis.desktop', 'code-insiders.desktop', 'one.ablaze.floorp.desktop', 'org.telegram.desktop.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.TextEditor.desktop', 'org.gnome.Software.desktop', 'com.github.wwmm.easyeffects.desktop', 'com.todoist.Todoist.desktop', 'com.heroicgameslauncher.hgl.desktop', 'com.stremio.Stremio.desktop', 'md.obsidian.Obsidian.desktop']"

# 4. Mapeamento Nativo 'switch-to-application' (Foco + Troca de Workspace Automática)
# [Favorito 1] Terminal ➔ Super+Enter (Workspace 1)
gsettings set org.gnome.shell.keybindings switch-to-application-1 "['<Super>Return']"

# [Favorito 2] VS Code ➔ Super+C (Workspace 2)
gsettings set org.gnome.shell.keybindings switch-to-application-2 "['<Super>c']"

# [Favorito 3] Floorp Browser ➔ Super+B (Workspace 3)
gsettings set org.gnome.shell.keybindings switch-to-application-3 "['<Super>b']"

# [Favorito 4] Telegram ➔ Super+T (Workspace 5)
gsettings set org.gnome.shell.keybindings switch-to-application-4 "['<Super>t']"

# [Favorito 8] EasyEffects ➔ Super+E (Workspace 8)
gsettings set org.gnome.shell.keybindings switch-to-application-8 "['<Super>e']"

# 5. Instalação e ativação da extensão NoAnnoyance v2 via GitHub (Wayland/Gnome 50 Native)
echo "📦 [AGY] Instalando extensão Gnome: NoAnnoyance v2 (BjoernDaase)..."
EXT_UUID="noannoyance@daase.net"
EXT_DIR="$HOME/.local/share/gnome-shell/extensions/$EXT_UUID"

# Limpa instalações antigas e cria o diretório de destino limpo
rm -rf "$EXT_DIR"
mkdir -p "$EXT_DIR"

# Baixa o zip da branch master oficial direto do GitHub do desenvolvedor
wget -q -O /tmp/noannoyance.zip "https://github.com/BjoernDaase/noannoyance/archive/refs/heads/master.zip"

# Extrai os arquivos em /tmp
unzip -q -o /tmp/noannoyance.zip -d /tmp/

# Copia o conteúdo interno da pasta descompactada para o diretório correto
cp -r /tmp/noannoyance-master/* "$EXT_DIR/"

# Habilita a extensão nativamente no Gnome Shell
gnome-extensions enable "$EXT_UUID"

# Limpa os arquivos temporários
rm -rf /tmp/noannoyance.zip /tmp/noannoyance-master

# 6. Configura o Ulauncher para usar o monitor principal (Evita bugs do Wayland)
echo "🔧 [AGY] Configurando Ulauncher para usar o monitor principal..."
mkdir -p "$HOME/.config/ulauncher"
python3 -c "
import json, os
path = os.path.expanduser('~/.config/ulauncher/settings.json')
data = {}
if os.path.exists(path):
    try:
        with open(path, 'r') as f:
            data = json.load(f)
    except Exception:
        pass
data['render-on-screen'] = 'default-monitor'
with open(path, 'w') as f:
    json.dump(data, f, indent=4)
"

# 7. Garante que o Ulauncher está reiniciado e ativo
systemctl --user restart ulauncher

echo -e "\n🔥 [AGY] Setup de Foco Nativo e Extensão concluídos com sucesso!"
echo "👉 Super+Enter ➔ Foca o Terminal (Workspace 1)"
echo "👉 Super+C     ➔ Foca o VS Code (Workspace 2)"
echo "👉 Super+B     ➔ Foca o Floorp Browser (Workspace 3)"
echo "👉 Super+T     ➔ Foca o Telegram (Workspace 5)"
echo "👉 Super+E     ➔ Foca o EasyEffects (Workspace 8)"
echo "👉 Ctrl+Space  ➔ Ulauncher"
echo "👉 Super+I     ➔ Prepara Imagem do Clipboard (Dê Ctrl+V depois no Tmux)"
