#################################################################################
#                                                                               #
# install-scripts.sh                                                            #
# Script to install/setup different packages for my OS X Setup / iTerm2         #
# vim and powerline.                                                            #
# Requires :                                                                    #
#           - Ruby                                                              #
#           - Internet connection                                               #
#           - xcode installed if you want macvim                                #
#                                                                               #
#   Copyright 2014 - 2019 - Jean-Michel Bouchard                                #
#   https://github.com/woud420                                                  #
#                                                                               #
#################################################################################

WORKSPACE=~/workspace
SHELL=`echo $SHELL`
# GDB and VIM integration
#Conque GDB

# Check if homebrew is installed
installed=`which brew`
if [[ -z $installed ]]; then
    # We need to install brew
    echo -e "[Install] Brew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew upgrade > /dev/null
    # Modify path to include brew directory
    # Only supports bash or zsh .. if you use a different shell.. well you're smart enough to figure this out
    if [[ $SHELL == *"bash"* ]]; then
        echo "export PATH=/usr/local/bin:/usr/local/sbin:$PATH" >> ~/.bashrc
    elif [[ $SHELL == *zsh* ]]; then
        echo "export PATH=/usr/local/bin:/usr/local/sbin:$PATH" >> ~/.zshrc
    fi
else
    echo -e "[Skipping] Brew is installed."
fi

# Check for wget
installed=`which wget`
if [[ -z $installed ]]; then
    # We need to install wget
    echo -e "[Install] wget"
    brew install wget
else
    echo -e "[Skipping] wget is installed."
fi

# Check for grc
installed=`which grc`
if [[ -z $installed ]]; then
    # We need to install grc
    echo -e "[Install] grc"
    brew install grc
else
    echo -e "[Skipping] grc is installed."
fi

# Install python brew
installed=`which python2`
if [[ -z $installed ]]; then
    echo -e "[Install] python2"
    brew install python@2
else
    echo -e "[Skipping] python2 is installed."
fi

installed=`which python3`
if [[ -z $installed ]]; then
    echo -e "[Install] python3"
    brew install python3
else
  echo -e "[Skipping] python3 is installed."  
fi

# Install fonts for powerline
if [ -d "~/workspace/fonts" ]; then
    echo -e "[Creating] ~/workspace/fonts"
    mkdir -p ~/workspace/fonts
    git clone https://github.com/powerline/fonts
    cd $WORKSPACE/fonts && exec ./install.sh
    cd ~
else
    echo -e "[Skipping] powerline fonts are installed."
fi

# Install 8.1 version of vim and link it to vim
installed=`which vim`
if [[ $installed != "/usr/local/bin/vim" ]]; then
    brew install vim # Installs in /usr/local/bin/vim
    #mv /usr/bin/vim /usr/bin/vim72 # Move original mac vim to vim72.. incase we need it one day
    #ln -s /usr/local/bin/vim /usr/bin/vim
else
    echo -e "[Skipping] vim 8.1 is installed."
fi

# brew cask install alacritty

# Install Rust Code

cd ~
