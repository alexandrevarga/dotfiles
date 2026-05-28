# =====================================================================
# AGY WORKFLOW - ENVIRONMENT VARIABLES
# =====================================================================
# This file is sourced on all zsh invocations (interactive and scripts).
# Keep it strictly for PATH and environment variables.

# Standard user binary paths
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Node/NPM global paths
export PATH="$PATH:$HOME/.npm-global/bin"


