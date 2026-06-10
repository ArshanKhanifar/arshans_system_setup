# Shell & SSH

## Cheatsheets

| Command | Action |
|---------|--------|
| `cheatsheet` | fzf all cheatsheets |
| `cheatsheet <pat>` | fuzzy open (e.g. `cheatsheet zel`) |
| `cheatsheet --help` | usage + list |

## Navigation

| Command | Action |
|---------|--------|
| `z <dir>` | zoxide jump to frecent directory |
| `cd` | normal cd (zoxide learns paths) |

## SSH / remote machines (`~/remote-machines.txt`)

| Command | Action |
|---------|--------|
| `sshh` | fzf pick machine → SSH |
| `sshh <pat>` | grep machine name → SSH |
| `scpull <remote> <local>` | rsync from remote |
| `scpush <local> <remote>` | rsync to remote |

## Python (uv)

| Command | Action |
|---------|--------|
| `suv` | activate `.venv` in cwd |
| `snuv [3.11]` | create venv + activate |
| `upip` | alias for `uv pip` |

## Sync arshans_system_setup on a VM

```bash
cd ~/arshans_system_setup && git pull
source ~/.bashrc
```

Profile setup also redeploys zellij config + shell rc on every run.
