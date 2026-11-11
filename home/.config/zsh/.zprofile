if [[ -x /opt/homebrew/bin/brew ]]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
	eval "$(/usr/local/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if (( $+commands[nvim] )); then
	export EDITOR=nvim
elif (( $+commands[vim] )); then
	export EDITOR=vim
else
	export EDITOR=vi
fi
export VISUAL=$EDITOR

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
	export PATH="$HOME/.local/bin:$PATH"
fi

# Cargo (overrides ~/.local/bin and brew similar bins)
[[ -d "$HOME/.cargo/bin" ]] && export PATH="$HOME/.cargo/bin:$PATH"

# ghcup
[[ -f "$HOME/.ghcup/env" ]] && . "$HOME/.ghcup/env"

# Go
if (( $+commands[go] )); then
	export GOPATH="${GOPATH:-$HOME/go}"
	if [[ ":$PATH:" != *":$GOPATH/bin:"* ]]; then
		export PATH="$PATH:$GOPATH/bin"
	fi
fi

# Man Pages
if (( $+commands[bat] )); then
	export MANPAGER="sh -c 'col -bx | bat -l man -p'"
	export MANROFFOPT="-c"
elif (( $+commands[batcat] )); then
	export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
	export MANROFFOPT="-c"
fi

if (( $+commands[moor] )); then
	export PAGER=moor
	export MOOR='--quit-if-one-screen'
elif (( $+commands[moar] )); then
	export PAGER=moar
	export MOAR='--quit-if-one-screen'
fi
