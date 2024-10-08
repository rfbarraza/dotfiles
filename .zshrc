##############################################################################
#                                                                            #
# ░░░░▀▀█░█▀▀░█░█░█▀▄░█▀▀                                                    #
# ░░░░▄▀░░▀▀█░█▀█░█▀▄░█░░                                                    #
# ░▀░░▀▀▀░▀▀▀░▀░▀░▀░▀░▀▀▀                                                    #
#                                                                            #
##############################################################################

# ---
# TOC
# ---
#
# ## zsh
# ## gpg
# ## Homebrew
# ## Powerlevel10k Initialization
# ## Path
# ## Keybindings
# ## Functions
# ## The F
# ## fzf
# ## zmv
# ## Jump Around
# ## Inline VIM
# ## Theme
# ## Java
# ## Ruby
# ## Python
# ## Bashhub
# ## Plugins
# ## Aliases
# ## Variables
#

GITSTATUS_LOG_LEVEL=DEBUG

## zsh
ZSH="$HOME/.oh-my-zsh"
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000


## gpg
export GPG_TTY=$(tty)


## Homebrew
HOMEBREW_PREFIX=""
if [[ "$(uname)" == "Darwin" ]]; then
  # Legacy macOS systems
  if [[ $(hostname -s) == "greyfox" ]]; then
    HOMEBREW_PREFIX="$HOME/.homebrew"
  else
    HOMEBREW_PREFIX="/opt/homebrew"
  fi
else
  HOMEBREW_PREFIX="$HOME/.linuxbrew"
fi
HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar";
HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX";
MANPATH="$HOMEBREW_PREFIX/share/man${MANPATH+:$MANPATH}:";
INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}";


## Powerlevel10k Initialization

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


## Path
# In ascending order of precedence

# System Hombrew
PATH="/opt/local/sbin:$PATH"
PATH="/opt/local/bin:$PATH"

# GNU Utilities Homebrew
if [ -d "$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin" ]; then
    PATH="$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin:$PATH"
fi

# User Homebrew
PATH="$HOMEBREW_PREFIX/Cellar:$PATH"
PATH="$HOMEBREW_PREFIX/bin:$PATH"

# dotfiles (assumes local location)
PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/.local/sbin:$PATH"

# ... and finally, pwd
PATH="./:$PATH"


## Keybindings
bindkey '^R' history-incremental-search-backward


## Functions
source "$HOME/.local/lib/sh/functions.sh"

## The F
eval $(thefuck --alias)

## fzf
if command -v fzf > /dev/null 2>&1; then
  source <(fzf --zsh)
fi

## zmv
autoload zmv

## Jump Around
# AKA - z DIR
if command -v brew >/dev/null 2>&1; then
	# Load rupa's z if installed
	[ -f $(brew --prefix)/etc/profile.d/z.sh ] && source $(brew --prefix)/etc/profile.d/z.sh
elif [[ -f "$HOME/.local/lib/sh/z.sh" ]]; then
  source "$HOME/.local/lib/sh/z.sh"
fi


## Inline VIM
# Enable Ctrl-x-e to edit command line
autoload -U edit-command-line
# Emacs style invocation
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line


## Theme
#if command -v brew >/dev/null 2>&1; then
#  source "$HOMEBREW_PREFIX/opt/powerlevel10k/powerlevel10k.zsh-theme"
#else
ZSH_THEME="powerlevel10k/powerlevel10k"
source "$HOME/.oh-my-zsh/custom/themes/$ZSH_THEME.zsh-theme"
#fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


## Java
JENV__HOME="$HOME/.jenv"
if command -v brew >/dev/null 2>&1; then
  JENV__LAST_VERS="$(ls -1 $HOMEBREW_PREFIX/Cellar/jenv | sort |  tail -1)"  
  JENV__HOME="$HOMEBREW_PREFIX/Cellar/jenv/$JENV__LAST_VERS/libexec" # no, that's right
fi
PATH="$JENV__HOME/bin:$PATH"
eval "$(jenv init -)"

## Ruby
RBENV__HOME="/usr/lib/rbenv"
if command -v brew >/dev/null 2>&1; then
  RBENV__LAST_VERS="$(ls -1 $HOMEBREW_PREFIX/Cellar/rbenv | sort |  tail -1)"
  RBENV__HOME="$HOMEBREW_PREFIX/Cellar/rbenv/$RBENV__LAST_VERS"
fi
PATH="$RBENV__HOME/bin:$PATH"
eval "$(rbenv init -)"

## Python
PYENV__HOME="$HOME/.pyenv"
if command -v brew >/dev/null 2>&1; then
  PYENV__LAST_VERS="$(ls -1 $HOMEBREW_PREFIX/Cellar/pyenv | sort |  tail -1)"
  PYENV__HOME="$HOMEBREW_PREFIX/Cellar/pyenv/$PYENV__LAST_VERS"
fi
PATH="$PYENV__HOME/bin:$PATH"
eval "$(pyenv init -)"

# virtualenv
WORKON_HOME=$HOME/.virtualenvs
# source $HOME/.pyenv/shims/virtualenvwrapper.sh

## Bashhub
if [ -f "$HOME/.bashhub/bashhub.zsh" ]; then
    source "$HOME/.bashhub/bashhub.zsh"
fi


## Plugins
plugins=(sudo npm git)

## Aliases
source "$HOME/.local/lib/sh/aliases.sh"


## Variables
source "$HOME/.local/lib/sh/variables.sh"


## Bashhub.com Installation
if [ -f ~/.bashhub/bashhub.zsh ]; then
    source ~/.bashhub/bashhub.zsh
fi

## Z (jumparound)
if [ -d ~/.local/lib/zsh-z ]; then
    source ~/.local/lib/zsh-z/zsh-z.plugin.zsh
fi

## NVM
export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
alias nvm="unalias nvm; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; nvm $@"

