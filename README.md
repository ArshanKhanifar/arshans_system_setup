# Arshan's System Setup
This repo contains the rc files that I use with my machines. Contains Vim shortcuts, tmux shortcuts, etc.

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
If you want interactive mode (asks for passwords), set the `INTERACTIVE` variable to `true`:
```
INTERACTIVE=true bash -c "$(curl -fsSL https://raw.githubusercontent.com/ArshanKhanifar/arshans_system_setup/master/system_setup.sh)" 
```


### Macbooks with Apple CPU's
**Update (2024-04-02):** Homebrew is now supported on Macs so the automated script above should work just fine.
`Homebrew` is not yet supported on ARM macs, so you'd have to install it using Rosetta:
```
arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```
And to install packages:
```
arch -x86_64 brew install <package>
```
* [source link](https://stackoverflow.com/questions/64882584/how-to-run-the-homebrew-installer-under-rosetta-2-on-m1-macbook)



