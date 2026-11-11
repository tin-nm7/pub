ZSHPLUGINDIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
ZSHPLUGINLOCK="${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/plugins.lock"

# Commands:
#   zsh-plugin-add <author/repo | github url>  Resolve latest commit, pin it in the lock file, install
#   zsh-plugin-install                         Install missing plugins, pin bare `author/repo` lines
#   zsh-plugin-update [plugin...]              Review upstream changes and re-pin on confirmation

_zsh_plugin_lock_read() {
	repos=() shas=()
	[[ -r $ZSHPLUGINLOCK ]] || {
		print -u2 "plugins: lock file not found: $ZSHPLUGINLOCK"
		return 1
	}

	local line
	local -a w
	for line in "${(@f)$(<$ZSHPLUGINLOCK)}"; do
		w=( ${=line%%\#*} )
		(( $#w )) || continue
		if (( $#w > 2 )) || [[ $w[1] != */* ]] ||
			{ (( $#w == 2 )) && ! _zsh_plugin_is_sha "$w[2]" }; then
			print -u2 "plugins: invalid lock entry: $line"
			continue
		fi
		repos+=( "$w[1]" )
		shas+=( "${w[2]-}" )
	done
}

_zsh_plugin_lock_pin() {
	local repo=$1 sha=$2 line comment
	local -a out w
	for line in "${(@f)$(<$ZSHPLUGINLOCK)}"; do
		w=( ${=line%%\#*} )
		if [[ $w[1] == "$repo" ]]; then
			comment=
			[[ $line == *\#* ]] && comment=" #${line#*\#}"
			printf -v line '%-42s %s%s' "$repo" "$sha" "$comment"
		fi
		out+=( "$line" )
	done
	print -rl -- "${out[@]}" >| "$ZSHPLUGINLOCK"
}

_zsh_plugin_is_sha() {
	[[ ${#1} -eq 40 && $1 != *[^0-9a-f]* ]]
}

_zsh_plugin_remote_head() {
	# No credential prompt: a typo'd/private repo fails instead of hanging.
	REPLY=$(GIT_TERMINAL_PROMPT=0 git ls-remote "https://github.com/${1}.git" HEAD 2>/dev/null)
	REPLY=${REPLY%%[[:space:]]*}
	_zsh_plugin_is_sha "$REPLY"
}

_zsh_plugin_head() {
	[[ -f $1/.git/HEAD ]] && REPLY=$(<$1/.git/HEAD)
}

_zsh_plugin_entry() {
	local plugin_path=$1 name=${1:t} file
	for file in \
		"$plugin_path/${name}.plugin.zsh" \
		"$plugin_path/${name}.zsh" \
		"$plugin_path/init.zsh"
	do
		[[ -f $file ]] && { REPLY=$file; return 0 }
	done
	return 1
}

_zsh_plugin_source() {
	local plugin_path=$1 REPLY

	fpath=("$plugin_path" "${fpath[@]}")

	_zsh_plugin_entry "$plugin_path" || {
		print -u2 "plugins: no entry point found for ${plugin_path:t} in ${plugin_path}"
		return 1
	}
	source "$REPLY" || {
		print -u2 "plugins: failed to load ${plugin_path:t}"
		return 1
	}
}

_zsh_plugin_checkout() {
	local repo=$1 sha=$2 dir=$3

	if [[ ! -d $dir/.git ]]; then
		mkdir -p "$dir" &&
			git -C "$dir" init -q &&
			git -C "$dir" remote add origin "https://github.com/${repo}.git" || return 1
	fi
	git -C "$dir" cat-file -e "${sha}^{commit}" 2>/dev/null ||
		GIT_TERMINAL_PROMPT=0 git -C "$dir" fetch -q --filter=blob:none origin "$sha" || return 1

	git -C "$dir" -c advice.detachedHead=false checkout -q "$sha"
}

# Normalises <author/repo | github url> to `author/repo` in REPLY.
# Accepts:	author/repo
# 			github.com/author/repo
#			http(s)://github.com/author/repo[.git][/tree/...]
#          	git@github.com:author/repo[.git]
_zsh_plugin_parse() {
	setopt local_options extended_glob
	local spec=${1%%[?#]*}
	spec=${spec#git@github.com:}
	spec=${spec#http(s|)://}
	spec=${spec#www.}
	spec=${spec#github.com/}
	if [[ $spec == *://* || $spec == *@* || $spec == *.*/*/* ]]; then
		print -u2 "plugins: only github.com repositories are supported: $1"
		return 1
	fi

	local -a parts=( ${(s:/:)spec} )
	(( $#parts >= 2 )) || {
		print -u2 "plugins: expected <author/repo> or a github url: $1"
		return 1
	}
	REPLY="${parts[1]}/${parts[2]%.git}"
	[[ $REPLY == [[:alnum:]._-]##/[[:alnum:]._-]## ]] || {
		print -u2 "plugins: invalid repository name: $REPLY"
		return 1
	}
}

zsh-plugin-add() {
	(( $+commands[git] )) || { print -u2 "plugins: git not found"; return 1 }
	(( $# == 1 )) || { print -u2 "usage: zsh-plugin-add <author/repo | github url>"; return 1 }

	local REPLY repo sha dir i
	_zsh_plugin_parse "$1" || return 1
	repo=$REPLY

	local -a repos shas
	_zsh_plugin_lock_read || return 1
	for (( i = 1; i <= $#repos; i++ )); do
		if [[ ${(L)repos[i]} == ${(L)repo} ]]; then
			print "plugins: ${repos[i]} is already in ${ZSHPLUGINLOCK:t}"
			return 0
		fi
		if [[ ${(L)repos[i]:t} == ${(L)repo:t} ]]; then
			print -u2 "plugins: ${repo:t} would clash with ${repos[i]} (same install directory)"
			return 1
		fi
	done

	_zsh_plugin_remote_head "$repo" || {
		print -u2 "plugins: cannot resolve ${repo} (check the name / network / that it is public)"
		return 1
	}
	sha=$REPLY

	dir="$ZSHPLUGINDIR/${repo:t}"
	print "plugins: ${repo} -> ${sha:0:12}"
	_zsh_plugin_checkout "$repo" "$sha" "$dir" || {
		print -u2 "plugins: failed to install ${repo}"
		rm -rf -- "$dir"
		return 1
	}

	local -a lines=( "${(@f)$(<$ZSHPLUGINLOCK)}" )
	printf -v REPLY '%-42s %s' "$repo" "$sha"
	print -rl -- "${lines[@]}" "$REPLY" >| "$ZSHPLUGINLOCK"

	_zsh_plugin_entry "$dir" ||
		print -u2 "plugins: warning: no ${repo:t}.plugin.zsh, ${repo:t}.zsh or init.zsh - it will not load"

	print "plugins: added ${repo} to ${ZSHPLUGINLOCK:t} (loads last; move the line to change order)"
	print "plugins: review and commit ${ZSHPLUGINLOCK:t}, then 'exec zsh'"
}
# In case URLs contain `?`/`#`
alias zsh-plugin-add='noglob zsh-plugin-add'

zsh-plugin-install() {
	(( $+commands[git] )) || { print -u2 "plugins: git not found"; return 1 }

	local -a repos shas
	_zsh_plugin_lock_read || return 1

	local i dir REPLY
	for (( i = 1; i <= $#repos; i++ )); do
		dir="$ZSHPLUGINDIR/${repos[i]:t}"

		if [[ -z $shas[i] ]]; then
			_zsh_plugin_remote_head "$repos[i]" || {
				print -u2 "plugins: cannot resolve ${repos[i]} (check the name / network)"
				continue
			}
			shas[i]=$REPLY
			_zsh_plugin_lock_pin "$repos[i]" "$shas[i]"
			print "plugins: pinned ${repos[i]} to ${shas[i]:0:12} in ${ZSHPLUGINLOCK:t}"
		fi

		REPLY=
		_zsh_plugin_head "$dir"
		[[ $REPLY == $shas[i] ]] && continue

		print "plugins: ${repos[i]} -> ${shas[i]:0:12}"
		_zsh_plugin_checkout "$repos[i]" "$shas[i]" "$dir" ||
			print -u2 "plugins: failed to install ${repos[i]}"
	done

	print "plugins: OK - restart with 'exec zsh' to load changes"
}

zsh-plugin-update() {
	(( $+commands[git] )) || { print -u2 "plugins: git not found"; return 1 }

	local -a repos shas only=("$@")
	_zsh_plugin_lock_read || return 1

	local i name dir new updated=0
	for (( i = 1; i <= $#repos; i++ )); do
		name=${repos[i]:t}
		(( $#only )) && (( ! ${only[(Ie)$name]} )) && continue

		dir="$ZSHPLUGINDIR/$name"
		[[ -n $shas[i] && -d $dir/.git ]] || {
			print -u2 "plugins: ${name} not installed/pinned (run zsh-plugin-install)"
			continue
		}

		GIT_TERMINAL_PROMPT=0 git -C "$dir" fetch -q --filter=blob:none origin HEAD &&
			new=$(git -C "$dir" rev-parse FETCH_HEAD) || {
			print -u2 "plugins: failed to fetch ${name}"
			continue
		}

		if [[ $new == $shas[i] ]]; then
			print "plugins: ${name} up to date"
			continue
		fi

		print "\n== ${repos[i]}  ${shas[i]:0:12} -> ${new:0:12}"
		git -C "$dir" --no-pager log --oneline --no-decorate "${shas[i]}..${new}"
		git -C "$dir" --no-pager diff --stat "${shas[i]}" "${new}"
		print "   full diff: git -C ${(q)dir} diff ${shas[i]:0:12} ${new:0:12}"

		if ! read -q "?Pin ${name} to ${new:0:12}? [y/N] "; then
			print
			continue
		fi
		print

		git -C "$dir" -c advice.detachedHead=false checkout -q "$new" || continue

		_zsh_plugin_lock_pin "$repos[i]" "$new"
		shas[i]=$new
		(( updated++ ))
	done

	(( updated )) && print "plugins: ${updated} pin(s) changed - review and commit ${ZSHPLUGINLOCK:t}, then 'exec zsh'"
}

() {
	local -a repos shas missing
	_zsh_plugin_lock_read || return

	local i dir REPLY
	for (( i = 1; i <= $#repos; i++ )); do
		dir="$ZSHPLUGINDIR/${repos[i]:t}"
		REPLY=
		if [[ -z $shas[i] ]] || ! _zsh_plugin_head "$dir"; then
			missing+=${repos[i]:t}
			continue
		fi
		[[ $REPLY == $shas[i] ]] ||
			print -u2 "plugins: ${repos[i]:t} is not at its locked commit (run zsh-plugin-install)"
		_zsh_plugin_source "$dir"
	done

	(( $#missing )) && print -u2 "plugins: not installed: ${missing} (run zsh-plugin-install)"
}
