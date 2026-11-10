if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
    source /usr/share/doc/fzf/examples/completion.zsh
elif command -v brew >/dev/null 2>&1; then
    BREW_PREFIX=$(brew --prefix)
    if [[ -f "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ]]; then
        source "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
        source "$BREW_PREFIX/opt/fzf/shell/completion.zsh"
    fi
fi

if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix'
elif command -v fdfind >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --strip-cwd-prefix'
fi

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

_fzf_file_no_hidden() {
    local cmd result
    cmd="${FZF_DEFAULT_COMMAND/--hidden /}"
    result=$(eval "${cmd:-find . -type f} | fzf") && LBUFFER+="$result"
    zle reset-prompt
}
zle -N _fzf_file_no_hidden
