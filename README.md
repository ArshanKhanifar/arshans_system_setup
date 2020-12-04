# Arshan's System Setup
This repo contains the rc files that I use with my machines. Contains Vim shortcuts, tmux shortcuts, etc.

## Ubuntu Pre-requisites
I forgot vanilla Ubuntu misses `git` and `curl`!
```
sudo apt install git curl
```

## Automated Mac OSX Script: 
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

### Macbooks with Apple CPU's
`Homebrew` is not yet supported on ARM macs, so you'd have to install it using Rosetta:
```
arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```
And to install packages:
```
arch -x86_64 brew install <package>
```
* [source link](https://stackoverflow.com/questions/64882584/how-to-run-the-homebrew-installer-under-rosetta-2-on-m1-macbook)



