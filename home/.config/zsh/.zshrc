[[ -d $XDG_CACHE_HOME/zsh ]] || mkdir -p "$XDG_CACHE_HOME/zsh"
[[ -d $XDG_DATA_HOME/zsh ]] || mkdir -p "$XDG_DATA_HOME/zsh"
[[ -d $XDG_STATE_HOME/zsh ]] || mkdir -p "$XDG_STATE_HOME/zsh"

HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
# setopt HIST_EXPIRE_DUPS_FIRST # Enable if HISTSIZE > SAVEHIST
setopt HIST_FIND_NO_DUPS

setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT

export GPG_TTY=$TTY

source "$ZDOTDIR/plugins.zsh"
autoload -Uz compinit
() {
	setopt local_options extended_glob
	local zcd="$XDG_CACHE_HOME/zsh/zcompdump"
	local -a stale=( ${^fpath}(N/e:'[[ $REPLY -nt $zcd ]]':) )
	if [[ ! -s $zcd || -n $zcd(#qN.mh+24) || $#stale -gt 0 ]]; then
		compinit -d "$zcd"
		touch "$zcd"
	else
		compinit -C -d "$zcd"
	fi
}

source "$ZDOTDIR/bindings.zsh"

source "$ZDOTDIR/prompt.zsh"

source "$ZDOTDIR/aliases.zsh"

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list \
		'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
		'r:|=*' \
		'l:|=* r:|=*'

# nvm
# DEPRECATED: use mise instead
# export NVM_DIR="$XDG_CONFIG_HOME/nvm"
# if [[ -s $NVM_DIR/nvm.sh ]]; then
# 	nvm node npm npx() {
# 		unset -f nvm node npm npx
# 		. "$NVM_DIR/nvm.sh"; "$0" "$@"
# 	}
# fi

# zoxide - disabled by default
# (( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
