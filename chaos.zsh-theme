# chaos.zsh-theme

MODE_INDICATOR="%{$fg_bold[red]%}❮%{$reset_color%}%{$fg[red]%}❮❮%{$reset_color%}"
local return_status="%{$fg[red]%}%(?..⏎)%{$reset_color%} "

# Git statuses
ZSH_THEME_GIT_PROMPT_PREFIX="|%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg_bold[red]%}⚡%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg_bold[red]%}!%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}✓%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%} ✚"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[blue]%} ✹"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%} ✖"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%} ➜"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[yellow]%} ═"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%} ✭"

# Format for git_prompt_long_sha() and git_prompt_short_sha()
ZSH_THEME_GIT_PROMPT_SHA_BEFORE="➤ %{$fg_bold[yellow]%}"
ZSH_THEME_GIT_PROMPT_SHA_AFTER="%{$reset_color%}"

# Colors vary depending on time lapsed.
ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT="%{$fg[green]%}"
ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM="%{$fg[yellow]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG="%{$fg[red]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL="%{$fg[cyan]%}"

# Left side prompt
PROMPT='%{$fg_bold[green]%}%n@%m%{$reset_color%} $(virtualenv_prompt)%{$fg_bold[blue]%} 𓅨 %{$fg[cyan]%}% ~ %{$reset_color%}$(git_prompt_short_sha)$(git_prompt_info)
%{$fg[cyan]%}%!%{$reset_color%} $(prompt_char) '

# Right side prompt
RPROMPT='${return_status}$(git_time_since_commit)$(git_prompt_status)%{$reset_color%}'

# Time the execution of a command and display a message if it took too long.
preexec() { precmd_timer=$(date +%s) }
precmd() { elapsed=$(( $(date +%s) - $precmd_timer ))
           if [[ $elapsed -gt 3 ]]; then
               echo "Execution time: $elapsed seconds"
           fi }

# Prompt character
function prompt_char() {
  if [[ $? -ne 0 ]]; then
    echo "%{$fg[red]%}➜%{$reset_color%}"
  else
    command git branch &>/dev/null 2>&1 && echo "%{$fg[green]%}±%{$reset_color%}" && return
    command hg root &>/dev/null 2>&1 && echo "%{$fg_bold[red]%}☿%{$reset_color%}" && return
    command darcs show repo &>/dev/null 2>&1 && echo "%{$fg_bold[green]%}❉%{$reset_color%}" && return
    echo "➜"
  fi
}

# Show number of running background jobs
function job_indicator() {
  num_jobs=$(jobs -l | wc -l)
  if [[ num_jobs -gt 0 ]]; then
    echo "[$num_jobs jobs]"
  fi
}

# Python virtual environment indicator
function virtualenv_prompt() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    echo "%{$fg_bold[magenta]%}($(basename $VIRTUAL_ENV))%{$reset_color%}"
  fi
}

RPROMPT='${return_status}$(git_time_since_commit)$(git_prompt_status)$(job_indicator)%{$reset_color%}'
