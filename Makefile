.PHONY: all help install install-minimal install-no-packages install-dry-run install-copy install-git-hooks check test-install check-editor brew-sync clean-backup
.ONESHELL:

SHELL		= /bin/bash
DOTFILE_DIR	:= $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
OS			:= $(shell uname -s | tr '[:upper:]' '[:lower:]')

# Main install targets using the universal installer
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

check: test-install
	bash -n $(DOTFILE_DIR)/install.sh
	bash -n $(DOTFILE_DIR)/scripts/check-editor-parity.sh
	bash -n $(DOTFILE_DIR)/scripts/test-install.sh

test-install:
	$(DOTFILE_DIR)/scripts/test-install.sh

check-editor:
	$(DOTFILE_DIR)/scripts/check-editor-parity.sh

install-git-hooks:
	mkdir -p $(HOME)/.config/git/hooks
	for hook in $(DOTFILE_DIR)/common/git/hooks/*; do \
		if [[ -f "$$hook" && "$$(basename "$$hook")" != "README.md" ]]; then \
			cp -f "$$hook" "$(HOME)/.config/git/hooks/$$(basename "$$hook")"; \
			chmod +x "$(HOME)/.config/git/hooks/$$(basename "$$hook")"; \
		fi; \
	done
	git config --global core.hooksPath "~/.config/git/hooks"

brew-sync:
	brew bundle dump --force --file=$(DOTFILE_DIR)/darwin/Brewfile

# Cleanup
clean-backup:
	@echo "Removing old backup directories..."
	find $(HOME) -maxdepth 1 -name ".dotfiles-backup-*" -type d -mtime +30 -exec rm -rf {} \;

# Help
help:
	@echo "Dotfiles Installation Options:"
	@echo ""
	@echo "  make install            # Full installation with regular file copies"
	@echo "  make install-minimal    # Minimal config for servers/containers"
	@echo "  make install-no-packages # Install configs only, skip packages"
	@echo "  make install-dry-run    # Show what would be installed"
	@echo "  make install-git-hooks  # Install personal global Git hooks only"
	@echo ""
	@echo "Checks:"
	@echo "  make check              # Lint installer scripts + run smoke test"
	@echo "  make test-install       # Run the installer against a temp HOME"
	@echo "  make check-editor       # Verify vim/nvim behavior parity"
	@echo ""
	@echo "Maintenance:"
	@echo "  make brew-sync          # Update Brewfile with current packages"
	@echo "  make clean-backup       # Remove old backup directories (30+ days)"
	@echo ""
	@echo "Direct script usage:"
	@echo "  ./install.sh --help  # Show all script options"
