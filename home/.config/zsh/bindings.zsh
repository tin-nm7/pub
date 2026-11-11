source "$ZDOTDIR/fzf.zsh"

ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK

ZVM_VI_HIGHLIGHT_BACKGROUND=default
ZVM_VI_HIGHLIGHT_FOREGROUND=default
ZVM_VI_HIGHLIGHT_EXTRASTYLE=default

zvm_after_init() {
	_fzf_load_bindings

	bindkey '^[[1;5C' forward-word
	bindkey '^[[1;5D' backward-word

	bindkey '^F' _fzf_file_no_hidden

	bindkey '^\' autosuggest-toggle

	bindkey '^[[A' history-substring-search-up
	bindkey '^[[B' history-substring-search-down
	bindkey '^[OA' history-substring-search-up
	bindkey '^[OB' history-substring-search-down
	if [[ -n "$terminfo[kcuu1]" ]]; then
		bindkey "$terminfo[kcuu1]" history-substring-search-up
	fi
	if [[ -n "$terminfo[kcud1]" ]]; then
		bindkey "$terminfo[kcud1]" history-substring-search-down
	fi

	bindkey -M vicmd 'k' history-substring-search-up
	bindkey -M vicmd 'j' history-substring-search-down
}
