# Git helpers

## Identity switching

| Command | Action |
|---------|--------|
| `gitpersonal` | personal GitHub identity + SSH config |
| `gitritual` | ritual work identity |
| `gitorigin` | origin identity |

## Quick commit

| Command | Action |
|---------|--------|
| `qcom "msg"` | `git commit -am` |
| `qcomp "msg"` | commit + push |

## Branches

| Command | Action |
|---------|--------|
| `gb` | pretty branch list (recent first) |
| `gbv` | visual branch graph |
| `gbs` | fzf pick branch → checkout |

## arshans_system_setup repo

```bash
ensure_arshans_system_setup_git   # local identity + hooks + SSH key for this repo
```
