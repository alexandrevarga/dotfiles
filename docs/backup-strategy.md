# Estratégia de Backup (Desacoplada do DR Plan)

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

