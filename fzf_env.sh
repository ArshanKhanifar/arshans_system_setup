# fzf file finder: respect .gitignore via fd, rg, or ag
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
elif command -v fdfind >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
elif command -v rg >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow -g "!.git/*"'
elif command -v ag >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='ag --nocolor -g ""'
fi

if [ -n "${FZF_DEFAULT_COMMAND:-}" ]; then
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"
fi
