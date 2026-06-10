#!/bin/bash

function _cheatsheet_dir() {
  echo "$ARSH_RC_DIR/cheatsheets"
}

function _cheatsheet_list() {
  local dir="$1"
  find "$dir" -maxdepth 1 -name '*.md' -print 2>/dev/null | sort | while IFS= read -r file; do
    basename "$file" .md
  done
}

function _cheatsheet_show() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "cheatsheet not found: $file"
    return 1
  fi

  if command -v bat >/dev/null 2>&1; then
    bat --paging=always --style=header,grid,numbers --language=markdown "$file"
  else
    less -R "$file"
  fi
}

function _cheatsheet_help() {
  local dir="$(_cheatsheet_dir)"
  cat <<EOF
cheatsheet — browse markdown cheatsheets from arshans_system_setup

Usage:
  cheatsheet              fzf picker over all cheatsheets
  cheatsheet <pattern>    fuzzy-find by name (e.g. zel, git, docker)
  cheatsheet --help       show this help

Cheatsheets live in:
  $dir

Available:
EOF
  _cheatsheet_list "$dir" | sed 's/^/  - /'
}

function cheatsheet() {
  local dir pattern selected file

  case "${1:-}" in
    -h|--help|help)
      _cheatsheet_help
      return 0
      ;;
  esac

  dir="$(_cheatsheet_dir)"
  if [ ! -d "$dir" ]; then
    echo "cheatsheets directory not found: $dir"
    return 1
  fi

  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf not found"
    _cheatsheet_list "$dir"
    return 1
  fi

  pattern="$1"
  if [ -z "$pattern" ]; then
    selected="$(_cheatsheet_list "$dir" | fzf --prompt="cheatsheet> ")"
  else
    selected="$(_cheatsheet_list "$dir" | fzf --filter "$pattern" -1)"
  fi

  if [ -z "$selected" ]; then
    if [ -n "$pattern" ]; then
      echo "no cheatsheet matching: $pattern"
      return 1
    fi
    return 0
  fi

  file="$dir/${selected}.md"
  _cheatsheet_show "$file"
}
