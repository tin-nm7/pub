HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT

source "$ZDOTDIR/fzf.zsh"
source "$ZDOTDIR/plugins.zsh"
source "$ZDOTDIR/bindings.zsh"
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/prompt.zsh"

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list \
    'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
    'r:|=*' \
    'l:|=* r:|=*'

autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
export PATH="$HOME/.cargo/bin:$PATH"

# ghcup
[ -f "/home/tin/.ghcup/env" ] && . "/home/tin/.ghcup/env"

# npm
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

. "$HOME/.local/share/../bin/env"
