# =====================================================================
# AGY WORKFLOW - ZSH INTERACTIVE CONFIGURATION
# =====================================================================

# 1. Prompt Initialization (Oh-My-Posh)
eval "$(oh-my-posh init zsh --config ~/.poshthemes/paradox.omp.json)"

# 2. History Settings
HISTFILE=~/.zhistory
HISTSIZE=1000
SAVEHIST=1000

setopt APPEND_HISTORY           # Adiciona comandos ao histórico, não sobrescreve
setopt SHARE_HISTORY            # Compartilha histórico entre sessões
setopt HIST_EXPIRE_DUPS_FIRST   # Remove duplicatas antigas primeiro
setopt EXTENDED_HISTORY         # Salva data/hora de cada comando
setopt HIST_IGNORE_DUPS         # Ignora duplicatas consecutivas
setopt HIST_IGNORE_ALL_DUPS     # Remove todas duplicatas do histórico
setopt HIST_FIND_NO_DUPS        # Não mostra duplicatas ao buscar

# 3. Autocomplete & Correction
autoload -Uz compinit
compinit
setopt CORRECT

# 4. Keybindings
bindkey '\e[A' history-search-backward
bindkey '\e[B' history-search-forward

# 5. Environment Variables (Interactive specific)
export EDITOR=nano
force_color_prompt=yes

# 6. Aliases
export LS_COLORS="fi=38;5;251"
alias ls='lsd --color=auto'
alias ll='lsd -lah --color=auto'
alias la='lsd -A --color=auto'
alias gemini-debug='type -a gemini'
alias go_atomic='setfont latarcyrheb-sun32 && sudo systemctl isolate multi-user.target'
alias exit_atomic='sudo systemctl isolate graphical.target'

# 7. Plugins (Fail-Safe Loading)
if [ -f "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [ -f "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# 7.1 Zsh Brightness Hack (Decoupling from Ghostty)
# Force autosuggestions to be a legible muted blue/grey instead of terminal dim grey
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#9ca3af"
# Force default typed text to be bright crisp grey instead of terminal dim grey
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]="fg=#d1d5db"
ZSH_HIGHLIGHT_STYLES[command]="fg=#4ade80,bold"
ZSH_HIGHLIGHT_STYLES[alias]="fg=#4ade80,bold"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=#4ade80,bold"


# 8. Tmux Wayland Sync
tmux() {
    if [ -n "$WAYLAND_DISPLAY" ]; then
        command tmux set-environment -g WAYLAND_DISPLAY "$WAYLAND_DISPLAY" 2>/dev/null
    fi
    if [ -n "$DBUS_SESSION_BUS_ADDRESS" ]; then
        command tmux set-environment -g DBUS_SESSION_BUS_ADDRESS "$DBUS_SESSION_BUS_ADDRESS" 2>/dev/null
    fi
    if [ -n "$XDG_RUNTIME_DIR" ]; then
        command tmux set-environment -g XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR" 2>/dev/null
    fi
    command tmux "$@"
}

if [ -n "$TMUX" ]; then
    eval $(tmux show-environment -s WAYLAND_DISPLAY 2>/dev/null)
    eval $(tmux show-environment -s DBUS_SESSION_BUS_ADDRESS 2>/dev/null)
    eval $(tmux show-environment -s XDG_RUNTIME_DIR 2>/dev/null)
fi
