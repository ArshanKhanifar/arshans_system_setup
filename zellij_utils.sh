#!/bin/bash

function zat() {
  if ! command -v zellij >/dev/null 2>&1; then
    echo "zellij not found"
    return 1
  fi

  local session
  session="$(zellij list-sessions -s -n 2>/dev/null | tail -1)"
  if [ -z "$session" ]; then
    echo "No zellij sessions found"
    return 1
  fi

  zellij attach "$session"
}

function zejrm() {
  if ! command -v zellij >/dev/null 2>&1; then
    echo "zellij not found"
    return 1
  fi

  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf not found"
    return 1
  fi

  local sessions
  sessions="$(zellij list-sessions -s -n 2>/dev/null | fzf -m --prompt="kill zellij sessions> ")"
  if [ -z "$sessions" ]; then
    return 0
  fi

  while IFS= read -r session; do
    [ -z "$session" ] && continue
    zellij kill-session "$session"
    echo "killed: $session"
  done <<< "$sessions"
}
