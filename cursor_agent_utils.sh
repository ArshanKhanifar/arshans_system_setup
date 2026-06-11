#!/bin/bash

CURSOR_SESSIONS_FILE="$HOME/cursor-sessions.txt"

function _cursor_agent_require() {
  if ! command -v cursor-agent >/dev/null 2>&1; then
    echo "cursor-agent not found"
    return 1
  fi
}

function _cursor_sessions_store() {
  local name="$1"
  local chat_id="$2"

  touch "$CURSOR_SESSIONS_FILE"
  awk -v n="$name" -v id="$chat_id" '
    $1 != n { print }
    END { print n, id }
  ' "$CURSOR_SESSIONS_FILE" > "${CURSOR_SESSIONS_FILE}.tmp"
  mv "${CURSOR_SESSIONS_FILE}.tmp" "$CURSOR_SESSIONS_FILE"
}

function _cursor_sessions_lookup() {
  local name="$1"
  awk -v n="$name" '$1 == n { print $2; exit }' "$CURSOR_SESSIONS_FILE"
}

function curagent() {
  _cursor_agent_require || return 1

  local name="$1"
  if [ -z "$name" ]; then
    echo "usage: curagent <name>"
    return 1
  fi
  if [[ "$name" == *" "* ]]; then
    echo "name cannot contain spaces"
    return 1
  fi

  local chat_id
  chat_id="$(cursor-agent create-chat)"
  if [ -z "$chat_id" ]; then
    echo "failed to create chat"
    return 1
  fi

  _cursor_sessions_store "$name" "$chat_id"
  echo "saved $name -> $chat_id in $CURSOR_SESSIONS_FILE"
  cursor-agent --resume "$chat_id"
}

function ldcuragent() {
  _cursor_agent_require || return 1

  if [ ! -f "$CURSOR_SESSIONS_FILE" ] || [ ! -s "$CURSOR_SESSIONS_FILE" ]; then
    echo "no saved sessions in $CURSOR_SESSIONS_FILE"
    echo "create one with: curagent <name>"
    return 1
  fi

  local name="$1"
  if [ -z "$name" ]; then
    if command -v fzf >/dev/null 2>&1; then
      name="$(awk '{ print $1 }' "$CURSOR_SESSIONS_FILE" | fzf --prompt="load cursor agent> ")"
      if [ -z "$name" ]; then
        return 0
      fi
    else
      echo "usage: ldcuragent <name>"
      cat "$CURSOR_SESSIONS_FILE"
      return 1
    fi
  elif command -v fzf >/dev/null 2>&1; then
    name="$(awk '{ print $1 }' "$CURSOR_SESSIONS_FILE" | fzf --filter "$name" -1)"
  else
    name="$(awk -v n="$name" '$1 == n { print $1; exit }' "$CURSOR_SESSIONS_FILE")"
  fi

  if [ -z "$name" ]; then
    echo "session not found: ${1:-}"
    return 1
  fi

  local chat_id
  chat_id="$(_cursor_sessions_lookup "$name")"
  if [ -z "$chat_id" ]; then
    echo "session not found: $name"
    return 1
  fi

  echo "loading $name ($chat_id)"
  cursor-agent --resume "$chat_id"
}
