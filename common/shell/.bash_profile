# ~/.bash_profile - Executed for login shells
# Source .bashrc if it exists

if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# User specific environment and startup programs
export EDITOR=vim
export VISUAL=vim

# Set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

export PATH
. "$HOME/.local/bin/env"
