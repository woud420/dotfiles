# Make sure autocomplete works properly
autoload -Uz compinit
compinit

# Load colors
autoload -Uz colors && colors
setopt prompt_subst

# Git branch info setup
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' %b'

ROSEWATER=$'%{\e[38;2;245;224;220m%}'
MAUVE=$'%{\e[38;2;203;166;247m%}'
TEAL=$'%{\e[38;2;148;226;213m%}'
PEACH=$'%{\e[38;2;250;179;135m%}'
SOFT_GRAY=$'%{\e[38;2;108;112;134m%}'

BUBBLE_BG=$'%{\e[48;2;245;224;220m%}'
BUBBLE_FG=$'%{\e[38;2;30;30;46m%}'

RESET=$'%{\e[0m%}'

function pretty_git() {
  # Don't forget the space at the end of the echo
  [[ -n "${vcs_info_msg_0_}" ]] && echo "${vcs_info_msg_0_} "
}

# Custom function to show 🏡 if in home
function pretty_pwd() {
  if [[ "$PWD" == "$HOME" ]]; then
    echo "🏡"
  else
    echo "%~"
  fi
}

# Dynamic time color based on hour
function dynamic_time_prompt() {
  local hour=$(date +%H)
  local icon=""
  if (( hour >= 6 && hour < 12 )); then
    # Morning: Peach
    icon="☀️"
    echo "${PEACH}%*${RESET} ${icon}"
  elif (( hour >= 12 && hour < 18 )); then
    # Afternoon: Teal
    icon="☀️"
    echo "${TEAL}%*${RESET} ${icon}"
  elif (( hour >= 18 && hour < 21 )); then
    # Evening: Mauve
    icon="🌙"
    echo "${MAUVE}%*${RESET} ${icon}"
  else
    # Night: Soft Gray
    icon="🌙"
    echo "${SOFT_GRAY}%*${RESET} ${icon}"
  fi
}

# One-line cute prompt with correct escapes
# PROMPT="${PEACH}🌸 ${MAUVE}[${ROSEWATER}%n${MAUVE}@${TEAL}\$(pretty_pwd)${MAUVE}] \$(pretty_git)${RESET} ➔ "
#PROMPT="⭐ ${MAUVE}[${ROSEWATER}%n${MAUVE}@${TEAL}\$(pretty_pwd)${MAUVE}] ${PEACH}\$(pretty_git)${RESET}➔"
#PROMPT='⭐ ${MAUVE}[${ROSEWATER}%n${MAUVE}@${TEAL}%{$(pretty_pwd)%}${MAUVE}] ${PEACH}%{$(pretty_git)%}${RESET}➔ '
#RPROMPT="${SOFT_GRAY}%*${RESET}"
#RPROMPT='$(dynamic_time_prompt)'

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
  source "$f"
done

export PATH="/opt/homebrew/bin:$PATH"
