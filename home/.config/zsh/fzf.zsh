_fzf_load_bindings() {
	local init
	if init=$(fzf --zsh 2>/dev/null); then
		eval "$init"
	elif [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
		source /usr/share/doc/fzf/examples/key-bindings.zsh
		source /usr/share/doc/fzf/examples/completion.zsh
	fi
}

if (( $+commands[fd] )); then
	export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix --exclude .git'
elif (( $+commands[fdfind] )); then
	export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --strip-cwd-prefix --exclude .git'
fi

[[ -n $FZF_DEFAULT_COMMAND ]] && export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

_fzf_list_files_no_hidden() {
	if (( $+commands[fd] )); then
		fd --type f --strip-cwd-prefix
	elif (( $+commands[fdfind] )); then
		fdfind --type f --strip-cwd-prefix
	else
		find . -type f -not -path '*/.*' | sed 's|^\./||'
	fi
}
_fzf_file_no_hidden() {
	local result
	result=$(_fzf_list_files_no_hidden | FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" fzf)
	if [[ -n $result ]]; then
		[[ -n $LBUFFER && $LBUFFER != *' ' ]] && LBUFFER+=' '
		LBUFFER+=${(q)result}
	fi
	zle reset-prompt
}
zle -N _fzf_file_no_hidden
