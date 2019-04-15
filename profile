# Set CLICOLOR if you want Ansi Colors in iTerm2 
export CLICOLOR=1

# Set colors to match iTerm2 Terminal Colors
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
fi

