# Vim (fzf + ripgrep + tags)

Leader key is `,` (comma).

## Find & search

| Key / command | Action |
|---------------|--------|
| `,t` | Fuzzy find file by path (`:Files`) |
| `,a` | Search file contents — ripgrep + fzf (`:Rg!`) |
| `,r` | Jump to symbol via ctags tags (`:Tags` picker) |
| `Alt-k` / `Esc-k` | Search for word under cursor |
| `;` | Fuzzy open buffers |

## Quickfix (search results)

| Key | Action |
|-----|--------|
| `[q` | Previous quickfix entry |
| `]q` | Next quickfix entry |

(vim-unimpaired)

## Tags / ctags

| Command | Action |
|---------|--------|
| `tagit` | Generate `tags` from cwd (gitignore-aware excludes) |
| `tagit -b` | Same, background — don't block the shell |
| `tagit -n` | Print the ctags command (dry run) |
| `:Tagit` | Regenerate tags inside Vim (background job) |
| `:MakeTags` | Alias for `:Tagit` |

`,r` prompts once if no tags file exists, then runs `tagit` in the background and opens the symbol picker when done.

`tagit` reads all `.gitignore` files in the repo plus defaults for JS/TS, Python, C/C++, and Rust (`node_modules`, `target`, `__pycache__`, `.venv`, etc.).

## Splits

| Key | Action |
|-----|--------|
| `,v` | Vertical split |
| `,s` | Horizontal split |

## Shell fzf

`Ctrl-T` / `Alt-C` in the shell use `FZF_DEFAULT_COMMAND` (`fd` or `rg --files`) and respect `.gitignore`.

## Sync config on a VM

```bash
cd ~/arshans_system_setup && git pull && source ~/.bashrc
```
