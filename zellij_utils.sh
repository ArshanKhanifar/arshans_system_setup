#!/bin/bash

function _zellij_require() {
  if ! command -v zellij >/dev/null 2>&1; then
    echo "zellij not found"
    return 1
  fi
}

function _zellij_require_fzf() {
  _zellij_require || return 1
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf not found"
    return 1
  fi
}

function zat() {
  _zellij_require_fzf || return 1

  local session
  session="$(zellij list-sessions -s -n 2>/dev/null | fzf --prompt="attach to session> ")"
  if [ -z "$session" ]; then
    return 0
  fi

  zellij attach "$session"
}

function znew() {
  _zellij_require || return 1

  local name="$1"
  if [ -z "$name" ]; then
    echo "usage: znew <name>"
    return 1
  fi

  zellij -s "$name"
}

function zmv() {
  _zellij_require_fzf || return 1

  local session new_name
  session="$(zellij list-sessions -s -n 2>/dev/null | fzf --prompt="session to rename> ")"
  if [ -z "$session" ]; then
    return 0
  fi

  new_name="$(printf '' | fzf --print-query --prompt="new name> " --query="$session")"
  if [ -z "$new_name" ]; then
    echo "no new name provided"
    return 1
  fi

  if [ "$new_name" = "$session" ]; then
    echo "name unchanged"
    return 0
  fi

  ZELLIJ_SESSION_NAME="$session" zellij action rename-session "$new_name"
  echo "renamed: $session -> $new_name"
}

function zejrm() {
  _zellij_require_fzf || return 1

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
