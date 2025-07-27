# Shell Functions & Aliases

This directory contains organized shell functions and aliases grouped by tool and purpose.

## 📂 Files Overview

### Core Function Files
- **`fuzzy-vim.sh`** - Enhanced vim wrapper with fuzzy file selection
- **`ssh.sh`** - SSH and remote connection helpers
- **`git.sh`** - Advanced git workflow functions  
- **`k8s.sh`** - Kubernetes management functions
- **`docker.sh`** - Docker container management functions
- **`utils.sh`** - General utility functions

### Alias Files  
- **`kubectl-aliases.sh`** - Kubectl short aliases (`k get p`, `kgpw`, etc.)
- **`git-aliases.sh`** - Git short aliases (`g`, `gs`, `gc`, etc.)
- **`docker-aliases.sh`** - Docker short aliases (`d`, `dc`, `dr`, etc.)
- **`system-aliases.sh`** - System and file operation aliases
- **`modern-tools-aliases.sh`** - Modern CLI tool replacements

## 🚀 Key Features

### Git Integration
**Git Config Aliases** (in `.gitconfig`):
```bash
git ch          # Fuzzy branch checkout with preview
git flog        # Interactive log browser  
git fadd        # Select files to stage with preview
git llog        # Fuzzy search through commits
```

**Shell Aliases** (complement git config):
```bash
g               # git
gs              # git status
gaa             # git add .
gcm "message"   # git commit -m "message"
gp              # git push
```

### Kubectl Power Aliases
```bash
# Resource shortcuts
k get p          # kubectl get pods
kgpw            # kubectl get pods -o wide
kgpy            # kubectl get pods -o yaml
kdp             # kubectl describe pod
klf             # kubectl logs -f

# Quick operations
kshp pattern    # Shell into first pod matching pattern
klp pattern     # Logs from first pod matching pattern
krestart deploy # Restart deployment
```

Your dotfiles are now fully updated with:

## ✅ **Updated Structure:**

**Git Config (.gitconfig):**
- ✅ Added `git ch` - Fuzzy branch checkout with fzf fallback
- ✅ Added `git flog` - Interactive log browser  
- ✅ Added `git fadd` - Fuzzy file staging
- ✅ Added `git llog` - Fuzzy commit search
- ✅ Kept all your existing aliases (`st`, `lg`, `cm`, etc.)

**Shell Functions (shell-functions/):**
- ✅ All functions moved to `~/.config/shell-functions/` as you wanted
- ✅ Kubectl aliases (`k get p`, `kgpw`, etc.)
- ✅ Git shell aliases (`g`, `gs`, `gp`, etc.) 
- ✅ Docker aliases (`d`, `dc`, `dr`, etc.)
- ✅ SSH helpers (`sshdot`, `ssht`, etc.)
- ✅ System utilities and modern tool replacements

**Installation Scripts:**
- ✅ Updated to copy all shell-functions
- ✅ Remote installation handles new structure

## 🎯 **Usage:**

```bash
# Git workflows
git ch          # Fuzzy branch select
git fadd        # Interactive file staging  
git flog        # Browse commits
g st            # Quick status (shell alias)

# Kubernetes  
k get p         # kubectl get pods
kgpw           # kubectl get pods -o wide
kctx           # Switch context with fzf

# Remote servers
sshdot user@host    # SSH with dotfiles auto-install
```

Everything is backward compatible and your existing workflow stays the same!