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

# XDG Clean Home Enforcement
export GOPATH="$XDG_DATA_HOME/go"
export GOCACHE="$XDG_CACHE_HOME/go-build"
export GOENV="$XDG_CONFIG_HOME/go/env"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export CONDARC="$XDG_CONFIG_HOME/conda/condarc"
export CONDA_ENVS_PATH="$XDG_DATA_HOME/conda/envs"
export CONDA_PKGS_DIRS="$XDG_CACHE_HOME/conda/pkgs"
export OLLAMA_MODELS="$XDG_DATA_HOME/ollama/models"
export DOTNET_CLI_HOME="$XDG_DATA_HOME/dotnet"

# Node/NPM global paths
export PATH="$PATH:$HOME/.npm-global/bin"


