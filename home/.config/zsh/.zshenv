export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Debian/Ubuntu
skip_global_compinit=1

# macOS
SHELL_SESSIONS_DISABLE=1

export STARSHIP_CONFIG="${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}/starship.toml"

typeset -U path PATH
