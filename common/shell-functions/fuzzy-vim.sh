# Smart fuzzy vim wrapper (Bash + Zsh compatible)
vim() {
  if [[ $# -eq 0 ]]; then
    # Check if fzf exists
    if ! command -v fzf >/dev/null 2>&1; then
      echo "fzf not found, opening normal vim..." >&2
      command vim
      return
    fi

    # List of directories to ignore
    local ignore_dirs=(".git" "node_modules" "vendor" "venv" ".cache")

    # If fd exists, use it. Otherwise fallback to find
    if command -v fd >/dev/null 2>&1; then
      local fd_cmd="fd --type f"
      for dir in "${ignore_dirs[@]}"; do
        fd_cmd+=" --exclude $dir"
      done
      local file=$(eval "$fd_cmd" | fzf --height 40% --reverse --border)
    else
      local find_cmd="find ."
      for dir in "${ignore_dirs[@]}"; do
        find_cmd+=" -path \"*/$dir/*\" -prune -o"
      done
      find_cmd+=" -type f -print"
      local file=$(eval "$find_cmd" 2>/dev/null | fzf --height 40% --reverse --border)
    fi

    if [[ -n "$file" ]]; then
      command vim "$file"
    fi
  else
    command vim "$@"
  fi
}

# 🛡 Fix: Preserve vim autocompletion behavior
if [[ -n "$ZSH_VERSION" ]]; then
  compdef _vim vim
elif [[ -n "$BASH_VERSION" ]]; then
  complete -o default -o bashdefault vim
fi

