# ~/.bash_profile - Executed for login shells
# Source .bashrc if it exists

if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# User specific environment and startup programs
if command -v nvim >/dev/null 2>&1; then
    export EDITOR=nvim
    export VISUAL=nvim
else
    export EDITOR=vim
    export VISUAL=vim
fi

[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
