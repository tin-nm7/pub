# Requirements

## System zshenv (`/etc/zshenv` | `/etc/zsh/zshenv`)
```zsh
# /etc/zshenv | /etc/zsh/zshenv: system-wide .zshenv file for zsh(1).
#
# This file is sourced on all invocations of the shell.
# If the -f flag is present or if the NO_RCS option is
# set within this file, all other initialization files
# are skipped.
#
# This file should contain commands to set the command
# search path, plus other important environment variables.
# This file should not contain commands that produce
# output or assume the shell is attached to a tty.
#
# Global Order: zshenv, zprofile, zshrc, zlogin

if [[ -z "$PATH" || "$PATH" == "/bin:/usr/bin" ]]
then
    export PATH="/usr/local/bin:/usr/bin:/bin:/usr/games"
fi

if [[ -z "$XDG_CONFIG_HOME" ]]
then
    export XDG_CONFIG_HOME="$HOME/.config"
fi

if [[ -d "$XDG_CONFIG_HOME/zsh" ]]
then
    export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
fi
```

Fail-back $HOME/.zshenv in case system zshenv is not read
```zsh
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
[[ -r $ZDOTDIR/.zshenv ]] && source "$ZDOTDIR/.zshenv"
```

Note:
* $ZDOTDIR/.zprofile is loaded assuming terminal is run as login shell
  Non-login and non-interactive shells will lose brew, cargo, go, etc


## Commands Replacement Candidates
```md
`->`    Substitutes
`<>`    Alternative
`++`    Complementary Tools
```

### Files & Directory
```md
* ls    -> eza
* tree  -> eza --tree
* du    -> dust
* df    -> duf
* find  <> fd | fdfind
* cp    -> xcp
* rm    -> rip
* cat   -> bat | batcat
* less  -> moor (formerly: moar)
* wc    ++ tokei
```

### Text Processing & Search
```md
* grep  <> rg | ripgrep
* sed   -> sd
* cut   -> choose
* sort  -> gsort
* jq    -> jaq
* diff  -> difftastic
* _     ++ qsv # Adding tool for CSV
```

### Dev
```md
* make  -> just
* time  ++ hyperfine
* man   ++ tldr
```

### Monitoring
```md
* top   -> btop
* ps    -> procs
* lsof  <> procs
* htop  -> btm | bottom
* ping  -> gping
* ncdu  -> dua
```

### Misc
```md
* cd      ++ zoxide
* history -> atuin
* env     ++ mise
* ssh     <> mosh
* hexdump -> hexyl
```
