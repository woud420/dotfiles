# Make sure autocomplete works properly
autoload -Uz compinit
compinit

# Load colors
autoload -Uz colors && colors
setopt prompt_subst

# Git branch info setup
autoload -Uz vcs_info
precmd() { 
  vcs_info
  # Set tab title to show current directory (last 2 path components)
  print -Pn "\e]0;%2~\a"
}

# Show running command in tab title
preexec() {
  # Show command being executed (first word only for simplicity)
  print -Pn "\e]0;%2~ ▶ ${1%% *}\a"
}

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' %b'

ROSEWATER='%F{#f5e0dc}'
MAUVE='%F{#cba6f7}'
TEAL='%F{#94e2d5}'
PEACH='%F{#fab387}'
SOFT_GRAY='%F{#6c7086}'
RESET='%f%k'

BUBBLE_BG='%{%K{#f5e0dc}%}'
BUBBLE_FG='%{%F{#1e1e2e}%}'

function kube_prompt() {
  local context=$(kubectl config current-context 2>/dev/null)
  if [ -n "$context" ]; then
    echo "(k8s:$context)"
  fi
}
 
function pretty_git() {
  # Don't forget the space at the end of the echo
  [[ -n "${vcs_info_msg_0_}" ]] && echo "${vcs_info_msg_0_} "
}

# Custom function to show 🏡 if in home
function pretty_pwd() {
  case "$PWD" in
    "$HOME")
      echo "🏡"
      ;;
    "$HOME/Documents")
      echo "📄"
      ;;
    "$HOME/Downloads")
      echo "📁"
      ;;
    "$HOME/Pictures")
      echo "🖼️"
      ;;
    "$HOME/Music")
      echo "🎵"
      ;;
    "$HOME/Desktop")
      echo "🖥️"
      ;;
    "$HOME/workspace")
      echo "💻"
      ;;
    *)
      echo "%~"
      ;;
  esac
  #if [[ "$PWD" == "$HOME" ]]; then
  #  echo "🏡"
  #else
  #  echo "%~"
  #fi
}

# Dynamic time color based on hour
function dynamic_time_prompt() {
  local hour=$(date +%H)
  local color icon

  if (( hour >= 6 && hour < 12 )); then
    color=$PEACH
    icon='☀️'
  elif (( hour >= 12 && hour < 18 )); then
    color=$TEAL
    icon='☀️'
  elif (( hour >= 18 && hour < 21 )); then
    color=$MAUVE
    icon='🌙'
  else
    color=$SOFT_GRAY
    icon='🌙'
  fi

  echo "%{$color%}%*%{$RESET%}"
}

function build_prompt() {
  local GIT_INFO="$(pretty_git)"
  local PWD_INFO="$(pretty_pwd)"

  PROMPT="⭐ ${MAUVE}[${ROSEWATER}%n${MAUVE}@${TEAL}${PWD_INFO}${MAUVE}] ${PEACH}${GIT_INFO}${RESET}➔ "
}

precmd_functions+=(build_prompt)

function build_rprompt() {
  RPROMPT="$(dynamic_time_prompt)"
}

precmd_functions+=(build_rprompt)

source ~/.gnu_aliases

# Soft pastel fzf colors
export FZF_DEFAULT_OPTS="
  --color=fg:#cdd6f4,bg:#1e1e2e,hl:#f38ba8
  --color=fg+:#f5e0dc,bg+:#313244,hl+:#fab387
  --color=info:#89b4fa,prompt:#94e2d5,pointer:#f5c2e7
  --color=marker:#a6e3a1,spinner:#b4befe,header:#cba6f7
  --layout=reverse
  --border
"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Load custom shell functions
for f in ~/.config/shell-functions/*.sh; do
  [[ -r "$f" ]] && source "$f"
done

function kctx() {
  local selected
  selected=$(kubectl config get-contexts -o name | \
    fzf --prompt="Select context > " \
        --height=40% \
        --layout=reverse \
        --border \
        --ansi)

  if [[ -n "$selected" ]]; then
    kubectl config use-context "$selected"
  else
    echo "No context selected."
  fi
}

# Source local secrets (if exists)
[[ -f ~/.env.secrets ]] && source ~/.env.secrets

export PATH="/opt/homebrew/bin:$PATH"
. "$HOME/.local/bin/env"
