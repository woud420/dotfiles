# Set CLICOLOR if you want Ansi Colors in iTerm2 
export CLICOLOR=1

export TERM=xterm-256color

export PATH=/usr/local/bin:/usr/local/sbin:~/bin:$PATH

export PATH="$HOME/.cargo/bin:$PATH"

source ~/.bash/prompt

case "$(uname -s)" in
    Darwin)
        eval "$(gdircolors -b "$HOME/.dircolors")"
        # GNU utils installed via brew use a 'g' prefix
        alias ls="gls --color=always"
        alias less="less -r"
        alias more="more -r"
        alias sed="gsed"
        alias cut="gcut"
        alias sort="gsort"
        alias uniq="guniq"
        ;;
    Linux)
        if command -v dircolors >/dev/null; then
            eval "$(dircolors -b "$HOME/.dircolors")"
        fi
        alias ls="ls --color=auto"
        ;;
esac

alias python="python3"

alias unix_mr='f(){ cat "$1" | sort | uniq; unset -f f;}; f'

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if hash pyenv 2>/dev/null; then
    eval "$(pyenv init -)"
fi


# stupid stuff for bloop / scala
JAVA_HOME="/Library/Java/JavaVirtualMachines/openjdk-11.0.2.jdk/Contents/Home/"
# Launch tmux automatically

TMUX_DEV=dev
if [ ! "$TMUX" ]; then
    tmux new-session -A -s $TMUX_DEV
fi
