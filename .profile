# Set CLICOLOR if you want Ansi Colors in iTerm2 
export CLICOLOR=1

export TERM=xterm-256color

export PATH=/usr/local/bin:/usr/local/sbin:~/bin:$PATH

export PATH="$HOME/.cargo/bin:$PATH"

source ~/.bash/prompt

if [[ $(uname) -eq "Darwin" ]]; then
    eval $(gdircolors -b $HOME/.dircolors)

    # Include mac to gnu alias
    alias ls="gls --color=always"
    # Repaint colors if passed through a pipe
    alias less="less -r"
    alias more="more -r"
    alias sed="gsed"
    alias cut="gcut"
    alias sort="gsort"
    alias uniq="guniq"
fi

alias python="python3"

alias unix_mr='f(){ cat "$1" | sort | uniq; unset -f f;}; f'

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if hash pyenv 2>/dev/null; then
    eval "$(pyenv init -)"
fi

# virtualenvwrapper start
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/workspace
export VIRTUALENVWRAPPER_PYTHON=python
if [ -f "$HOME/.local/bin/virtualenvwrapper.sh" ]; then
    # Linux
    source "$HOME/.local/bin/virtualenvwrapper.sh";
elif [ -f "/usr/local/bin/virtualenvwrapper.sh" ]; then
    # Darwin
    source /usr/local/bin/virtualenvwrapper.sh
    #export PATH="$HOME/Library/Python/3.7/bin:$PATH"
else
    echo "W: Coudn't find virtualenvwrapper.sh"
fi
# virtualenvwrapper end

# stupid stuff for bloop / scala
JAVA_HOME="/Library/Java/JavaVirtualMachines/openjdk-11.0.2.jdk/Contents/Home/"
# Launch tmux automatically

TMUX_DEV=dev
if [ ! "$TMUX" ]; then
    tmux new-session -A -s $TMUX_DEV
fi
