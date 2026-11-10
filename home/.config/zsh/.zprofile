if command -v batcat >/dev/null 2>&1; then
    export MANPAGER="batcat -l man -p"
elif command -v bat >/dev/null 2>&1; then
    export MANPAGER="bat -l man -p"
fi
