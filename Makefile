.PHONY: all help install install-minimal install-no-packages backup-bash brew-sync clean-backup legacy
.ONESHELL:

SHELL		= /bin/bash
DOTFILE_DIR	:= $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
OS			:= $(shell uname -s | tr '[:upper:]' '[:lower:]')

# Main install targets using new universal installer
all: install
install:
	$(DOTFILE_DIR)/install.sh

install-minimal:
	$(DOTFILE_DIR)/install.sh --minimal

install-no-packages:
	$(DOTFILE_DIR)/install.sh --no-packages

install-dry-run:
	$(DOTFILE_DIR)/install.sh --dry-run

install-copy:
	$(DOTFILE_DIR)/install.sh --copy

# Legacy OS-specific targets (kept for compatibility)
legacy: $(OS)
linux: apt flatpak git-init stow-linux git-installs profile-source font-cache
darwin: brew brew-upgrade git-init stow-darwin git-installs profile-source


apt:
	$(info You may be prompted for super-user privleges:)
	xargs -a linux/debian/packages.list sudo apt-get install -y

darwin: brew
	softwareupdate -aiR

brew: /usr/local/Homebrew/bin/brew
	-brew bundle --file=$(DOTFILE_DIR)/darwin/Brewfile

brew-sync:
	brew bundle dump --force --file=$(DOTFILE_DIR)/darwin/Brewfile

brew-upgrade:
	if brew upgrade ; then brew cleanup ; fi;

/usr/local/Homebrew/bin/brews:
	{ \
	set -e ;\
	if hash brew 2> /dev/null; then \
		echo "Brew is already installed."; \
	else \
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"; \
	fi ;\
	}

flatpak:
	sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

font-cache:
	$(info Resetting system font-cache)
	$(shell fc-cache -f)

git-init:
	git submodule update --init --recursive

git-installs: python-dev nodejs-dev

python-dev: $(HOME)/.pyenv venv-wrapper
nodejs-dev: $(HOME)/.nodenv $(HOME)/.nodenv/plugins/node-build

$(HOME)/.nodenv:
	git clone https://github.com/nodenv/nodenv.git $(HOME)/.nodenv
	$(shell cd $HOME/.nodenv && src/configure && make -C src)

$(HOME)/.nodenv/plugins/node-build:
	git clone https://github.com/nodenv/node-build.git $(HOME)/.nodenv/plugins/node-build

$(HOME)/.pyenv:
	git clone https://github.com/pyenv/pyenv.git $(HOME)/.pyenv

venv-wrapper:
	pip3 install --user -U virtualenvwrapper virtualenv

profile-source:
	source $(HOME)/.bash_profile

backup-bash:
	$(DOTFILE_DIR)/bash_backup.sh

stow-common: backup-bash
	stow -d common -t ~ bash
	stow -d common -t ~ shell
	stow -d common -t ~ git
	stow -d common -t ~/.config htop
	stow -d common -t ~/.config shell-functions

stow-darwin: stow-common
	stow -d darwin -t ~/.config kitty

stow-linux: stow-common
	stow -d linux/common -t ~/.config kitty

stow: stow-$(OS)

link: backup-bash
	ln -fs bash/.bash_aliases $(HOME)/.bash_aliases
	ln -fs bash/.bash_logout $(HOME)/.bash_logout
	ln -fs bash/.bash_profile $(HOME)/.bash_profile
	ln -fs bash/.bashrc $(HOME)/.bashrc
	ln -fs bash/.curlrc $(HOME)/.curlrc
	ln -fs bin/bin $(HOME)/bin

unlink:
	unlink $(HOME)/.bash_aliases
	unlink $(HOME)/.bash_logout
	unlink $(HOME)/.bash_profile
	unlink $(HOME)/.bashrc
	unlink $(HOME)/.curlrc

# Cleanup
clean-backup:
	@echo "Removing old backup directories..."
	find $(HOME) -maxdepth 1 -name ".dotfiles-backup-*" -type d -mtime +30 -exec rm -rf {} \;

# Help
help:
	@echo "Dotfiles Installation Options:"
	@echo ""
	@echo "  make install          # Full installation with symlinks (recommended)"
	@echo "  make install-minimal  # Minimal config for servers/containers"
	@echo "  make install-no-packages # Install configs only, skip packages"
	@echo "  make install-copy     # Copy files instead of symlinks"
	@echo "  make install-dry-run  # Show what would be installed"
	@echo ""
	@echo "Advanced:"
	@echo "  make legacy          # Use legacy OS-specific installation"
	@echo "  make clean-backup    # Remove old backup directories (30+ days)"
	@echo "  make brew-sync       # Update Brewfile with current packages"
	@echo ""
	@echo "Direct script usage:"
	@echo "  ./install.sh --help  # Show all script options"

