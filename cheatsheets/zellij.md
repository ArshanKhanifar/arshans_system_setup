# Zellij

Prefix: **Ctrl+Space** or **F12** (same as Byobu/tmux)

## Session helpers

| Command | Action |
|---------|--------|
| `zat` | fzf pick session → attach |
| `znew <name>` | create + attach new named session |
| `zmv` | fzf pick session → rename |
| `zejrm` | fzf multiselect → kill sessions |
| `cheatsheet zellij` | show this sheet |

## Prefix commands (Ctrl+Space → key)

| Key | Action |
|-----|--------|
| `c` | new tab |
| `n` | next tab |
| `p` | previous tab |
| `s` | horizontal split (pane down) |
| `v` | vertical split (pane right) |
| `d` | detach (leave session running) |
| `r` | rename tab |
| `w` | rename pane |
| `[` | scroll / copy mode |
| `z` | toggle pane frames |
| `f` | toggle fullscreen |
| `Esc` / `Enter` | exit prefix mode |

## Navigate (no prefix)

| Key | Action |
|-----|--------|
| `Ctrl+h/j/k/l` | move between panes |
| `Ctrl+\` | toggle last pane |

## Resize (prefix + Alt)

| Key | Action |
|-----|--------|
| `Alt+h/l` | resize left / right |
| `Alt+j/k` | resize down / up |
| `Alt+Up/Down` | resize up / down |

Use **Alt+h/l** for horizontal resize in iTerm (Option+Left/Right is word-jump).

## Mouse

- drag pane borders to resize (frames must be visible — `prefix+z` toggles)
- click to focus panes / tabs

## Scroll / copy mode (`prefix + [`)

### Mouse

- click + drag to select (pane-aware)
- then **`y`** to copy (because `copy_on_select` is off)

### Keyboard (vim-style)

Zellij has no tmux-style in-pane copy cursor. Use scrollback editor instead:

| Key | Action |
|-----|--------|
| `v` or `e` | open scrollback in `$EDITOR` (vim) → select + yank there |
| `j/k` or arrows | scroll down / up |
| `h/l` | page up / down |
| `d/u` | half page down / up |
| `f/b` | page down / up |
| `g/G` | top / bottom |
| `y` / `Y` | copy current mouse selection to clipboard |
| `Esc` / `Enter` | exit scroll mode |

In **Byobu/tmux**, use `prefix + [` then `v` → move → `y` (see `cheatsheet byobu`).

## Rename prompts

After `prefix+r` (tab) or `prefix+w` (pane): type name → **Enter**. **Esc** cancels.

## Reload config

Zellij reads config at session start:

```bash
Ctrl+Space → d
zellij kill-all-sessions
zellij
```
