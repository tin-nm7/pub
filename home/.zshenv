export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export EDITOR="nvim"
export VISUAL="nvim"

export GPG_TTY=$(tty)

export PATH="$HOME/.local/bin:$PATH"

if command -v batcat >/dev/null 2>&1; then
    export MANPAGER="batcat -l man -p"
elif command -v bat >/dev/null 2>&1; then
    export MANPAGER="bat -l man -p"
fi

export STARSHIP_CONFIG="$ZDOTDIR/starship.toml"
. "$HOME/.cargo/env"
