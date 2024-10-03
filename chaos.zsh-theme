# Optimized chaos.zsh-theme, based on dogenpunk and smt
# Includes performance improvements and error code emojis

# Precompute static parts of the prompt
_CHAOS_USER_HOST="%F{green}%B%n@%m%b%f"
_CHAOS_PATH="%F{cyan}%~%f"
_CHAOS_PROMPT_CHAR="𓅨"

# Git status symbols (precomputed for performance)
_CHAOS_GIT_DIRTY="%F{red}%B⚡%b%f"
_CHAOS_GIT_CLEAN="%F{green}%B✓%b%f"
_CHAOS_GIT_AHEAD="%F{red}%B!%b%f"
_CHAOS_GIT_ADDED="%F{green}✚%f"
_CHAOS_GIT_MODIFIED="%F{blue}✹%f"
_CHAOS_GIT_DELETED="%F{red}✖%f"
_CHAOS_GIT_RENAMED="%F{magenta}➜%f"
_CHAOS_GIT_UNMERGED="%F{yellow}═%f"
_CHAOS_GIT_UNTRACKED="%F{cyan}✭%f"

# Git time colors
_CHAOS_GIT_TIME_SHORT="%F{green}"
_CHAOS_GIT_TIME_MEDIUM="%F{yellow}"
_CHAOS_GIT_TIME_LONG="%F{red}"
_CHAOS_GIT_TIME_NEUTRAL="%F{cyan}"

# Error code to emoji mapping
typeset -A _CHAOS_ERROR_EMOJIS
_CHAOS_ERROR_EMOJIS=(
  1 "💥"    # General errors
  2 "🚫"    # Misuse of shell builtins
  126 "🔒"  # Command invoked cannot execute
  127 "🤷"  # Command not found
  128 "⚠️"   # Invalid exit argument
  129 "🚦"  # SIGHUP
  130 "🛑"  # SIGINT
  131 "🧨"  # SIGQUIT
  132 "🔬"  # SIGILL
  133 "🪤"  # SIGTRAP
  134 "💣"  # SIGABRT
  135 "🧮"  # SIGBUS
  136 "🔥"  # SIGFPE
  137 "💀"  # SIGKILL
  139 "🐛"  # SIGSEGV
  141 "📡"  # SIGPIPE
  143 "🔪"  # SIGTERM
)

_chaos_error_emoji() {
  local code=$1
  echo "${_CHAOS_ERROR_EMOJIS[$code]:-🔴}"
}

# Efficient git information functions
_chaos_git_info() {
  git symbolic-ref HEAD 2> /dev/null | sed 's/^refs\/heads\///'
}

_chaos_git_status() {
  [[ -n "$(git status --porcelain 2> /dev/null)" ]] && echo "$_CHAOS_GIT_DIRTY" || echo "$_CHAOS_GIT_CLEAN"
}

_chaos_git_prompt_status() {
  local STATUS=""
  local -a FLAGS
  FLAGS=('--porcelain')
  
  if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" != "1" ]]; then
    FLAGS+='--branch'
  fi
  
  local git_status="$(command git status ${FLAGS} 2> /dev/null | tail -n1)"
  
  if [[ -n $git_status ]]; then
    STATUS="$ZSH_THEME_GIT_PROMPT_DIRTY"
  else
    STATUS="$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi
  
  if $(echo "$git_status" | grep '^## [^ ]\+ .*ahead' &> /dev/null); then
    STATUS="$STATUS$_CHAOS_GIT_AHEAD"
  fi
  
  echo "$git_status" | while IFS= read -r line; do
    if [[ $line == " M "* ]]; then STATUS="$STATUS$_CHAOS_GIT_MODIFIED"; fi
    if [[ $line == "?? "* ]]; then STATUS="$STATUS$_CHAOS_GIT_UNTRACKED"; fi
    if [[ $line == " D "* ]]; then STATUS="$STATUS$_CHAOS_GIT_DELETED"; fi
    if [[ $line == "R  "* ]]; then STATUS="$STATUS$_CHAOS_GIT_RENAMED"; fi
    if [[ $line == "A  "* ]]; then STATUS="$STATUS$_CHAOS_GIT_ADDED"; fi
    if [[ $line == "UU "* ]]; then STATUS="$STATUS$_CHAOS_GIT_UNMERGED"; fi
  done
  
  echo $STATUS
}

_chaos_git_prompt() {
  local branch=$(_chaos_git_info)
  [[ -n "$branch" ]] && echo "|$branch$(_chaos_git_status)"
}

_chaos_git_sha() {
  local sha
  sha=$(git rev-parse --short HEAD 2> /dev/null) || return
  echo "➤ %F{yellow}%B$sha%b%f"
}

_chaos_git_time_since_commit() {
  local last_commit now seconds_since_last_commit minutes hours days color
  last_commit=$(git log -1 --pretty=format:%at 2> /dev/null) || return
  now=$(date +%s)
  seconds_since_last_commit=$((now - last_commit))
  minutes=$((seconds_since_last_commit / 60))
  hours=$((minutes / 60))
  days=$((hours / 24))

  if [[ -z "$(git status --porcelain 2>/dev/null)" ]]; then
    color="$_CHAOS_GIT_TIME_NEUTRAL"
  elif [[ $minutes -gt 30 ]]; then
    color="$_CHAOS_GIT_TIME_LONG"
  elif [[ $minutes -gt 10 ]]; then
    color="$_CHAOS_GIT_TIME_MEDIUM"
  else
    color="$_CHAOS_GIT_TIME_SHORT"
  fi

  if [[ $hours -gt 24 ]]; then
    echo "[${color}${days}d$((hours % 24))h$((minutes % 60))m%f]"
  elif [[ $minutes -gt 60 ]]; then
    echo "[${color}${hours}h$((minutes % 60))m%f]"
  else
    echo "[${color}${minutes}m%f]"
  fi
}

_chaos_venv_prompt() {
  [[ -n "$VIRTUAL_ENV" ]] && echo "%F{magenta}%B(${VIRTUAL_ENV:t})%b%f"
}

_chaos_job_count() {
  local job_count="${(%):-%j}"
  [[ "$job_count" -gt 0 ]] && echo "[$job_count jobs]"
}

_chaos_prompt_char() {
  git branch &>/dev/null 2>&1 && echo "%F{green}±%f" && return
  hg root &>/dev/null 2>&1 && echo "%F{red}%B☿%b%f" && return
  darcs show repo &>/dev/null 2>&1 && echo "%F{green}%B❉%b%f" && return
  echo "🕸"
}

_chaos_prompt() {
  local exit_code=$?
  local mode_indicator="${${KEYMAP/vicmd/"%F{red}%Bn❮%b%f"}:-"%F{green}%Bi❯%b%f"}"
  
  PROMPT="$mode_indicator $_CHAOS_USER_HOST $(_chaos_venv_prompt)%F{blue}%B$_CHAOS_PROMPT_CHAR%b%f $_CHAOS_PATH $(_chaos_git_sha)$(_chaos_git_prompt)
%F{cyan}%!%f $(_chaos_prompt_char) "

  RPROMPT="%(?..$(_chaos_error_emoji $exit_code) )$(_chaos_git_time_since_commit)$(_chaos_git_prompt_status)$(_chaos_job_count)%f"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _chaos_prompt

function zle-keymap-select zle-line-init {
  zle reset-prompt
  zle -R
}

zle -N zle-keymap-select
zle -N zle-line-init
