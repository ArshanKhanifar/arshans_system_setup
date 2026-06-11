# Cursor Agents

Named cursor-agent sessions live in `~/cursor-sessions.txt` (`name chat_id`).

## Commands

| Command | Action |
|---------|--------|
| `curagent <name>` | create chat, save name → id, launch agent |
| `ldcuragent` | fzf pick saved session → resume |
| `ldcuragent <name>` | resume session by name |

## Examples

```bash
curagent my-feature      # create + launch
ldcuragent               # fzf pick
ldcuragent my-fea        # fuzzy match "my-feature"
```

## Session file

```
myproject 74a6dbfe-ace7-47b7-8cf3-04ef82a3cb9a
```

Reusing a name replaces the old mapping with a new chat.
