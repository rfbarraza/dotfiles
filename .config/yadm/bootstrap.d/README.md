# README: Bootstrapping

## TLDR
Bootstrapping is a post-installation step when using [yadm](https://yadm.io) that can be done automatically or separately from installing dotfiles. For this repository, you must **first** install the dotfiles via the clone command, subsequently decrypt yadm files via the decrypt command and ***then*** run the bootstrap scripts.

This can be done by executing:
> `yadm bootstrap`

***
## Overview
### The Process
Bootstrapping consists of several phases. Presently, they are:
1. Install system software
	1. Install [apt](#apt) packages
	2. Instal [pacman](#pacman)packages
	4. Install [yay](#yay) packages
	5. Install [Homebrew](#homebrew)
2. Configure system
	1. For development
		1. [Java](#java) Environments
		3. [Python](#python) Environments
		4. 
	2. [Scripts](#scripts)
	4. Applications
		1. [Vim](#vim)
		2. [Oh My Zsh](#oh-my-zsh)
3. [Clean Up](#clean-up)

### The Script
Bootstrapping is done in two passes: (1) build a list of subscripts to run and (2) execute that list in FIFO order. See [script architecture](#script-architecture) for a more in-depth explanation.

***
## System Software
### Apt
Primarily for Debian-based Linux systems:
- Debian (x86_64 and aarch64)
- Raspbian (outdated)
- Ubuntu
- Linux Mint --> Ubuntu

### Pacman
For Arch Linux

### Yay
For Arch Linux, primarily for Sway

### Homebrew
Primarily for macOS but also the preferred method for user-specific utilities on some Linux installations in `~/.homebrew.` Including:
- Arch
- Linux Mint
- Windows System Linux
- Raspbian

***
## Configuration
### Java
##### [jEnv](https://www.jenv.be)
For legacy installations whose package manager does not offer jenv-- git clone of [jenv](https://github.com/jenv/jenv.git") for managing multiple Java environments.

### Python
##### pyenv
For legacy installations whose package manager does not offer pyenv-- git clone of [pyenv](https://github.com/pyenv/pyenv.git) for managing multiple Python environments.
### Scripts
Shell scripts are in `.local/lib` sorted in subdirectories according to their runtime environments. Symlinks are made to them in the `.local/sbin` directory which is part of the path specified in `.zshrc`.

#### Vim
Installs [vim-plug](https://junegunn.github.io/vim-plug/) via [git](https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim). A command is subsequently run via vim to install plugins listed in the `.vimrc` file.

#### Oh My Zsh
[Oh my zsh](https://ohmyz.sh) and [powerlevel10k](https://github.com/romkatv/powerlevel10k) are installed via git.  Sometimes `.zshrc` is overwritten, but it is backed up and can be replaced after installation.

***
## Clean Up
Post-decryption, a script called `clean_decrypt` will be in `~/.config/yadm/bootstrap.d`. This script will remove files unpacked from the decryption process that are not pertinent to the installation for security reasons.

***
## Script Architecture
### bootstrap
Each machine has a unique bootstrap script as an entry point. Yadm's own bootstrap script is called in `~/.config/yadm`. It will look for all executable scripts in bootstrap.d, where *this* bootstrap script will be called.

### install.sh
Each bootstrap script has a unique invocation of `~/.config/yadm/bootstrap.d/scripts/install.sh`

For example, on macOS, the invocation might be:
> `install.sh \`
> `	-E ~/.config/yadm/bootstrap.d/scripts/extensions/vim:vim_loader \`
> `	-E ~/.config/yadm/bootstrap.d/scripts/extensions/omz/sh:omz_loader \`
> `	-E ~/.config/yadm/bootstrap.d/scripts/extensions/sbin.sh:sbin_loader \`
> `	-E ~/.config/yadm/bootstrap.d/scripts/extensions/brew/brew.sh:brew_loader \`
> `	...`

The -E option will use `~/.config/yadm/bootstrap.d/scripts/lib/extension.sh` to:
1. `source` the specified script into the installation process so that the proper install function can be called later.
2. call the loader function for the specified script, which will have the installation subscribe to a "[notification](#notifications)". When that notification is published, each script's install function (as specified in their respective loader functions) will execute. In the order they registered.

**BEFORE** this queue of scripts is executed, `install.sh` will attempt to install software packages in the following order by publishing their notifications.
1. Apt
2. Pacman
3. Yay
4. Brew

It doesn't matter which order *these* extensions are specified by the `install.sh` invocation.

#### Notifications
There are three types of notifications:
- WILL_INSTALL
- DO_INSTALL
- DID_INSTALL
which, if published, should always be published in this order.

For the non-package manager extension scripts, the will notification prioritizes extensions over the standard do notification. This is reserved for the dev environment extensions like jenv and pyenv in legacy installations.

### lib
Contains utility functions for driving installation and manipulating the CLI.

### extensions
Contains the driver scripts for installing and configuring particular subcomponents of the system.

Package manager scripts have another subdirectory containing files whose lines correspond to the packages to be installed. There are multiple lists of files in case one package fails to ensure the system has a stable configuration before investigating the issue.

