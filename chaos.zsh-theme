# chaos.zsh-theme, based on dogenpunk and smt.

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
PROMPT='${MODE_INDICATOR} %{$fg_bold[green]%}%n@%m%{$reset_color%} $(virtualenv_prompt)%{$fg_bold[blue]%} 𓅨 %{$fg[cyan]%}% ~ %{$reset_color%}$(git_prompt_short_sha)$(git_prompt_info)
%{$fg[cyan]%}%!%{$reset_color%} $(prompt_char) '

# Right side prompt
RPROMPT='${return_status}$(git_time_since_commit)$(git_prompt_status)$(job_indicator)%{$reset_color%}'

# Prompt character
function prompt_char() {
  command git branch &>/dev/null 2>&1 && echo "%{$fg[green]%}±%{$reset_color%}" && return
  command hg root &>/dev/null 2>&1 && echo "%{$fg_bold[red]%}☿%{$reset_color%}" && return
  command darcs show repo &>/dev/null 2>&1 && echo "%{$fg_bold[green]%}❉%{$reset_color%}" && return
  echo "🕸"
}

# Determine the time since last commit. If branch is clean,
# use a neutral color, otherwise colors will vary according to time.
function git_time_since_commit() {
    local COLOR MINUTES HOURS DAYS SUB_HOURS SUB_MINUTES
    local last_commit seconds_since_last_commit

    # Only proceed if there is actually a commit
    if ! last_commit=$(command git -c log.showSignature=false log --pretty=format:'%at' -1 2>/dev/null); then
        echo "[$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL~%{$reset_color%}]"
        return
    fi

    # Totals
    seconds_since_last_commit=$(( EPOCHSECONDS - last_commit ))
    MINUTES=$(( seconds_since_last_commit / 60 ))
    HOURS=$(( MINUTES / 60 ))

    # Sub-hours and sub-minutes
    DAYS=$(( HOURS / 24 ))
    SUB_HOURS=$(( HOURS % 24 ))
    SUB_MINUTES=$(( MINUTES % 60 ))

    if [[ -z "$(command git status -s 2>/dev/null)" ]]; then
        COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL"
    else
        if [[ "$MINUTES" -gt 30 ]]; then
            COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG"
        elif [[ "$MINUTES" -gt 10 ]]; then
            COLOR="$ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM"
        else
            COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT"
        fi
    fi

    if [[ "$HOURS" -gt 24 ]]; then
        echo "[${COLOR}${DAYS}d${SUB_HOURS}h${SUB_MINUTES}m%{$reset_color%}]"
    elif [[ "$MINUTES" -gt 60 ]]; then
        echo "[${COLOR}${HOURS}h${SUB_MINUTES}m%{$reset_color%}]"
    else
        echo "[${COLOR}${MINUTES}m%{$reset_color%}]"
    fi
}

# Python virtual environment indicator
function virtualenv_prompt() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    echo "%{$fg_bold[magenta]%}($(basename $VIRTUAL_ENV))%{$reset_color%}"
  fi
}

# Show number of running background jobs
function job_indicator() {
  num_jobs=$(jobs -l | wc -l)
  if [[ num_jobs -gt 0 ]]; then
    echo "[$num_jobs jobs]"
  fi
}

function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]]; then
    MODE_INDICATOR="%{$fg_bold[red]%}n❮%{$reset_color%}"
  else
    MODE_INDICATOR="%{$fg_bold[green]%}i❯%{$reset_color%}"
  fi
  zle reset-prompt
}

function zle-line-init {
  MODE_INDICATOR="%{$fg_bold[green]%}i❯%{$reset_color%}"
  zle reset-prompt
}

zle -N zle-keymap-select
zle -N zle-line-init
