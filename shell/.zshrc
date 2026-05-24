# Created by newuser for 5.9
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/home/alexandre/.local/bin"
eval "$(oh-my-posh init zsh --config ~/.poshthemes/paradox.omp.json)"

source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#autoload -Uz compinit
#compinit

# Caminho do arquivo de histórico
HISTFILE=~/.zhistory
# Quantidade de comandos mantidos na memória
HISTSIZE=1000
# Quantidade de comandos salvos no arquivo
SAVEHIST=1000

# Opções de histórico
setopt APPEND_HISTORY           # Adiciona comandos ao histórico, não sobrescreve
setopt SHARE_HISTORY            # Compartilha histórico entre sessões
setopt HIST_EXPIRE_DUPS_FIRST   # Remove duplicatas antigas primeiro
setopt EXTENDED_HISTORY         # Salva data/hora de cada comando
setopt HIST_IGNORE_DUPS         # Ignora duplicatas consecutivas
setopt HIST_IGNORE_ALL_DUPS     # Remove todas duplicatas do histórico
setopt HIST_FIND_NO_DUPS        # Não mostra duplicatas ao buscar

# Autocomplete
autoload -Uz compinit
compinit

# Correção ortográfica para comandos
setopt CORRECT

# Atalhos de busca no histórico (setas para cima/baixo)
bindkey '\e[A' history-search-backward
bindkey '\e[B' history-search-forward

# Tema padrão (altere conforme desejar)
#ZSH_THEME="robbyrussell"

# Plugins (caso use Oh My Zsh, descomente e ajuste conforme necessário)
# plugins=(git)

# Alias úteis
alias ls='lsd --color=auto'
alias ll='lsd -lah --color=auto'
alias la='lsd -A --color=auto'

# Export de variáveis de ambiente (exemplo)
export EDITOR=nano

# Prompt básico (pode ser customizado)
#PROMPT='%n@%m:%~%# '

# Fonte de comandos adicionais (caso queira)
# source ~/.aliases

# Mensagem de boas-vindas
#echo "Bem-vindo ao Zsh no Fedora 42!"

force_color_prompt=yes

export PATH="$PATH:/home/alexandre/.npm-global/bin"

# opencode
export PATH=/home/alexandre/.opencode/bin:$PATH

alias gemini-debug='type -a gemini'
alias exit_atomic='sudo systemctl isolate graphical.target'
alias go_atomic='setfont latarcyrheb-sun32 && sudo systemctl isolate multi-user.target'


# Added by Antigravity CLI installer
export PATH="/home/alexandre/.local/bin:$PATH"

# =====================================================================
# AGY WORKFLOW - SINCRONIZAÇÃO DE CLIPBOARD WAYLAND NO TMUX
# =====================================================================
# 1. Função que envia as variáveis de tela ao iniciar/anexar o tmux
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

# 2. Importa as variáveis de tela para os terminais rodando dentro do Tmux
if [ -n "$TMUX" ]; then
    eval $(tmux show-environment -s WAYLAND_DISPLAY 2>/dev/null)
    eval $(tmux show-environment -s DBUS_SESSION_BUS_ADDRESS 2>/dev/null)
    eval $(tmux show-environment -s XDG_RUNTIME_DIR 2>/dev/null)
fi
