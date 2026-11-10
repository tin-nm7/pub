alias python=python3

alias vim=nvim

alias ls='eza --icons'
alias la='eza -lah --icons'
alias ll='eza -lh --icons --git'
alias tree='eza --tree --icons'
compdef eza=ls

if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
    alias bat=batcat
fi
command -v bat >/dev/null 2>&1 && alias cat=bat

if command -v fdfind >/dev/null 2>&1; then
        alias fd='fdfind'
fi

alias grep='rg --color=auto'
alias diff='diff --color=auto'
alias df='df -h'
alias l='ls -l'
