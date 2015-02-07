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
#   Copyright 2014 - Jean-Michel Bouchard                                       #
#   https://github.com/woud420                                                  #
#                                                                               #
#################################################################################


# GDB and VIM integration
#Conque GDB

# Check if homebrew is installed
installed=`which brew`
if [[$installed == *"not found"*]]; then
    # We need to install brew
    echo -e "[Install] Brew"
    exec ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    exec brew upgrade > /dev/null
fi

# Check for wget
installed=`which wget`
if [[$installed == *"not found"*]]; then
    # We need to install wget
    exec brew install wget
fi

# Install python brew
exec brew install python

# Install fonts for powerline
#wget https://github.com/Lokaltog/powerline/raw/develop/font/PowerlineSymbols.otf
#wget https://github.com/Lokaltog/powerline/raw/develop/font/10-powerline-symbols.conf


# Install Pathogen
#if [ -d "~/.vim/autoload" ]
 #   mkdir -p ~/.vim/autoload
#fi
#curl -LSso ~/.vim/autoload/pathogen.vim https://github.com/tpope/vim-pathogen/raw/master/autoload/pathogen.vim

# Install the bundles before running vim
if [ -d "~/.vim/bundle" ]
    mkdir -p ~/.vim/bundle
fi

cd ~/.vim/bundle

# Install Vundle
if [ ! -a  "~/.vim/bundle/Vundle.vim" ]
    git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

# Install solarized if using pathogen
if [ ! -d  "~/.vim/bundle/" ]
    git clone git://github.com/altercation/vim-colors-solarized.git
fi

cd ~
