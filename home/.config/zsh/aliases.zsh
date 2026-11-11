alias python=python3

if (( $+commands[nvim] )); then
	alias vim=nvim
fi

if (( $+commands[eza] )); then
	alias ls='eza --icons --group'
	alias ll='eza -lh --icons --group'
	alias llg='eza -lh --icons --group --git'
	alias la='eza -lah --icons --group'
	alias lag='eza -lah --icons --group --git'
	alias tree='eza --tree --icons'
	compdef eza=ls
fi

if (( $+commands[bat] )); then
	alias cat=bat
elif (( $+commands[batcat] )); then
	alias bat=batcat
	alias cat=batcat
fi

(( $+commands[fdfind] )) && alias fd=fdfind

alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias df='df -h'
alias l='ls -l'
