#!/bin/bash
# Minimal, lightweight bash prompt styling.

export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

if [ -t 1 ]; then
  _BP_GREEN='\[\033[32m\]'
  _BP_BLUE='\[\033[34m\]'
  _BP_CYAN='\[\033[36m\]'
  _BP_RESET='\[\033[0m\]'
else
  _BP_GREEN=''
  _BP_BLUE=''
  _BP_CYAN=''
  _BP_RESET=''
fi

if [ -f /etc/bash_completion ]; then
  # shellcheck disable=SC1091
  source /etc/bash_completion
elif [ -f /opt/homebrew/etc/bash_completion ]; then
  # shellcheck disable=SC1091
  source /opt/homebrew/etc/bash_completion
elif [ -f /usr/local/etc/bash_completion ]; then
  # shellcheck disable=SC1091
  source /usr/local/etc/bash_completion
fi

if declare -F __git_ps1 >/dev/null 2>&1; then
  GIT_PS1_SHOWDIRTYSTATE=1
  GIT_PS1_SHOWUPSTREAM=auto
  PS1="${_BP_GREEN}\u${_BP_RESET}@${_BP_BLUE}\h${_BP_RESET}:${_BP_CYAN}\w${_BP_RESET}\$(__git_ps1 ' (%s)')\$ "
else
  PS1="${_BP_GREEN}\u${_BP_RESET}@${_BP_BLUE}\h${_BP_RESET}:${_BP_CYAN}\w${_BP_RESET}\$ "
fi

if [ "$(uname -s)" = "Darwin" ]; then
  alias ls='ls -G'
else
  alias ls='ls --color=auto'
fi
