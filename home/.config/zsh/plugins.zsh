ZPLUGINDIR="${ZDOTDIR:-$HOME/.config/zsh}/plugins"

_zplugin_load() {
        local author="${1}"
        local plugin="${2}"
        local plugin_path="${ZPLUGINDIR}/${plugin}"

        command -v git >/dev/null || {
                print -u2 "git not found"
                return 1
        }

        if [[ ! -d "$plugin_path" ]]; then
                mkdir -p "$ZPLUGINDIR" || return 1
                print "Installing ${plugin}..."
                git clone --depth=1 "https://github.com/${author}/${plugin}.git" "$plugin_path" \
                        || { print -u2 "ERROR: failed to install ${plugin}"; return 1; }
        fi

        fpath=("$plugin_path" "${fpath[@]}")

        local file
        for file in \
                "$plugin_path/${plugin}.plugin.zsh" \
                "$plugin_path/${plugin}.zsh" \
                "$plugin_path/init.zsh"
        do
                [[ -f $file ]] && {
                        source "${file}" || {
                                print -u2 "Failed to load ${plugin}"
                                return 1
                        }
                        return 0
                }
        done

        print -u2 "No entry point found for ${plugin} in ${plugin_path}"
        return 1
}

zplugin-update() {
        local dir

        setopt local_options null_glob

        for dir in "$ZPLUGINDIR"/*(/); do
                git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1 || continue
                print "Updating ${dir:t}..."
                git -C "$dir" pull --ff-only --quiet || print -u2 "WARNING: failed to update ${dir:t}"
        done
}

_zplugin_load zsh-users zsh-completions
_zplugin_load zsh-users zsh-autosuggestions
_zplugin_load zsh-users zsh-history-substring-search
_zplugin_load Aloxaf fzf-tab
_zplugin_load jeffreytse zsh-vi-mode
_zplugin_load zdharma-continuum fast-syntax-highlighting
