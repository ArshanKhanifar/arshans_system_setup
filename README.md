# Arshan's System Setup

This repo contains the rc files that I use with my machines. Contains Vim shortcuts, tmux
shortcuts, etc.

## One-liners

**Docker:**

```
url="https://raw.githubusercontent.com/ArshanKhanifar/arshans_system_setup/master/dist/docker_setup.sh"
curl -fsSL $url | bash
```

**Nvidia:**

```
url="https://raw.githubusercontent.com/ArshanKhanifar/arshans_system_setup/master/dist/nvidia_setup.sh"
curl -fsSL $url | bash
```

**Python:**

```
url="https://raw.githubusercontent.com/ArshanKhanifar/arshans_system_setup/master/dist/python_setup.sh"
curl -fsSL $url | bash
```

**Profile Setup:**

```
url="https://raw.githubusercontent.com/ArshanKhanifar/arshans_system_setup/master/dist/profile_setup.sh"
curl -fsSL $url | bash -s -- hello
```

**Run with named arguments:**

```
url="https://raw.githubusercontent.com/ArshanKhanifar/arshans_system_setup/master/dist/profile_setup.sh"
curl -fsSL $url | bash -s -- --stage=<stage_name> --username=<username>
```

Available stages:
- `all` - Run all stages (default)
- `installPackages` - Install basic packages
- `installUV` - Install uv package manager
- `installZoxide` - Install zoxide directory jumper
- `installBat` - Install bat (improved cat)
- `installOhMyZsh` - Install Oh My Zsh
- `installFoundry` - Install Foundry
- `cloneRepo` - Clone the repository
- `setupVim` - Set up Vim configuration
- `setupByobu` - Set up Byobu terminal multiplexer
- `installZellij` - Install Zellij terminal multiplexer and config
- `setupITerm` - Install iTerm2 profile and key bindings (macOS only)
- `configurePromptAndRcfiles` - Configure shell prompt and rc files
- `interactiveCommands` - Run interactive commands

## What gets installed on a new machine

Running `profile_setup.sh` (all stages) installs and configures:

**Package managers / CLI tools**
- git, zsh, vim, byobu, make, jq, silver searcher (`ag` / `the_silver_searcher`)
- Homebrew (macOS only, if missing)
- uv (Python package manager)
- zoxide (smart cd)
- bat (better cat; macOS via Homebrew, Linux via apt where supported)
- oh-my-zsh
- Foundry (forge/cast/anvil)
- zellij (terminal multiplexer)

**Dotfiles / config**
- Clones `arshans_system_setup` into `$HOME`
- Vim: Vundle + vim-plug plugins, `.vimrc`, IdeaVim config
- Byobu/tmux keybindings from `keybindings.tmux`
- Zellij config at `~/.config/zellij/config.kdl`
- iTerm2 dynamic profile + keymap preset (macOS only)
- Shell rc (always applied on every run, idempotent): `.bash_profile` sources `.bashrc`; `.bashrc`/`.zshrc` get `.arshrc`, `bash_prompt.sh`, fzf, zoxide init, Foundry on PATH, and `$HOME/.local/bin`

**Optional / interactive stage**
- ctags + silver searcher aliases (macOS, when `INTERACTIVE=true`)

**Vim plugins installed**
- Vundle: vim-tmux-navigator, dracula theme
- vim-plug: fzf, fzf.vim

**Not changed**
- Default login shell is not switched to zsh (bash remains default if already set)

Examples:

```
# Only install Zellij
url="https://raw.githubusercontent.com/ArshanKhanifar/arshans_system_setup/master/dist/profile_setup.sh"
curl -fsSL $url | bash -s -- --stage=installZellij

# Run all stages with a username
url="https://raw.githubusercontent.com/ArshanKhanifar/arshans_system_setup/master/dist/profile_setup.sh"
curl -fsSL $url | bash -s -- --username=hello

# Run a specific stage with a username
url="https://raw.githubusercontent.com/ArshanKhanifar/arshans_system_setup/master/dist/profile_setup.sh"
curl -fsSL $url | bash -s -- --stage=setupVim --username=hello
```

**Note:** For backward compatibility, you can still use the first unnamed parameter as username:

```
url="https://raw.githubusercontent.com/ArshanKhanifar/arshans_system_setup/master/dist/profile_setup.sh"
curl -fsSL $url | bash -s -- hello
```

**Note:** system script isn't really idempotent, if u wanna re-run it:

```
rm -rf .vim .vimrc .oh-my-zsh .fzf arshans_system_setup .tmux/plugins/tpm
```

**Full Setup:**

```
url="https://raw.githubusercontent.com/ArshanKhanifar/arshans_system_setup/master/dist/full_setup.sh"
curl -fsSL $url | bash -s -- hello
```

## Ubuntu Pre-requisites

I forgot vanilla Ubuntu misses `git` and `curl`!

```
sudo apt install git curl
```

## Automated Setup Script:

Installs

* oh_my_zsh
* fzf
* fzf.vim
* my vimrc files
* my vundle plugins
* my vim.plug plugins

```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ArshanKhanifar/arshans_system_setup/master/system_setup.sh)" 
```

If you want interactive mode (asks for passwords), set the `INTERACTIVE` variable
to `true`:

```
INTERACTIVE=true bash -c "$(curl -fsSL https://raw.githubusercontent.com/ArshanKhanifar/arshans_system_setup/master/system_setup.sh)" 
```

### Macbooks with Apple CPU's

**Update (2024-04-02):** Homebrew is now supported on Macs so the automated script above
should work just fine.
`Homebrew` is not yet supported on ARM macs, so you'd have to install it using Rosetta:

```
arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

And to install packages:

```
arch -x86_64 brew install <package>
```

* [source link](https://stackoverflow.com/questions/64882584/how-to-run-the-homebrew-installer-under-rosetta-2-on-m1-macbook)

### Byobu Config

The configuration currently has the following stuff:

* `prefix + v` vertical split
* `prefix + s` horizontal split
* `ctrl + hjkl` selects panes while respecting vim's panes.

### Byobu Cheatsheet

* `prefix` is `ctrl a`
* **new tab**: `prefix + c`
* **next tab**: `prefix + n`
* **previous tab**: `prefix + p`
* **select between panes**: `ctrl + hkjl`

### Zellij

Zellij is a modern terminal multiplexer (alternative to tmux/byobu) with a more intuitive interface. It has been configured to use the same key bindings as Byobu for a consistent experience.

#### Zellij Cheatsheet

* `prefix` is `Ctrl Space` (same as Byobu)
* **new tab**: `prefix + c`
* **next tab**: `prefix + n`
* **previous tab**: `prefix + p`
* **horizontal split**: `prefix + s`
* **vertical split**: `prefix + v`
* **select between panes**: `Ctrl + hjkl` (same as Byobu)
* **enter copy mode**: `prefix + [`
* **toggle pane frames**: `prefix + z`
* **toggle fullscreen**: `prefix + f`


