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
# ## Jump Around
# ## Inline VIM
# ## Theme
# ## Java
# ## Ruby
# ## Python
# ## Bashhub
# ## Aliases
# ## Variables
#


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
  HOMEBREW_PREFIX="$HOME/.homebrew"
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

# User Homebrew
PATH="$HOME/.homebrew/Cellar:$PATH"
PATH="$HOME/.homebrew/bin:$PATH"

# dotfiles (assumes local location)
PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/.local/sbin:$PATH"

# ... and finally, pwd
PATH="./:$PATH"


## Keybindings
bindkey '^R' history-incremental-search-backward


## Functions
source "$HOME/.local/lib/sh/functions.sh"

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
if command -v brew >/dev/null 2>&1; then
  source "$HOME/.homebrew/opt/powerlevel10k/powerlevel10k.zsh-theme"
else
  ZSH_THEME="powerlevel10k/powerlevel10k"
  source "$HOME/.oh-my-zsh/custom/themes/$ZSH_THEME.zsh-theme"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


## Java
JENV__HOME="$HOME/.jenv"
if command -v brew >/dev/null 2>&1; then
  JENV__LAST_VERS="$(ls -1 $HOME/.homebrew/Cellar/jenv | sort |  tail -1)"  
  JENV__HOME="$HOME/.homebrew/Cellar/jenv/$JENV__LAST_VERS/libexec" # no, that's right
fi
PATH="$HOME/.jenv/bin:$PATH"
PATH="$HOME/.jenv/shims:${PATH}"
JENV_SHELL=zsh
JENV_LOADED=1
unset JAVA_HOME
source "$JENV__HOME/libexec/../completions/jenv.zsh"
jenv rehash 2>/dev/null
jenv refresh-plugins
jenv() {
  typeset command
  command="$1"
  if [ "$#" -gt 0 ]; then
    shift
  fi

  case "$command" in
  enable-plugin|rehash|shell|shell-options)
    eval `jenv "sh-$command" "$@"`;;
  *)
    command jenv "$command" "$@";;
  esac
}


## Ruby
RBENV__HOME="/usr/lib/rbenv"
if command -v brew >/dev/null 2>&1; then
  RBENV__LAST_VERS="$(ls -1 $HOME/.homebrew/Cellar/rbenv | sort |  tail -1)"
  RBENV__HOME="$HOME/.homebrew/Cellar/rbenv/$RBENV__LAST_VERS"
fi
PATH="$HOME/.rbenv/bin:$PATH"
PATH="$HOME/.rbenv/shims:${PATH}"
RBENV_SHELL=zsh
source "$RBENV__HOME/libexec/../completions/rbenv.zsh"
command rbenv rehash 2>/dev/null
rbenv() {
  local command
  command="${1:-}"
  if [ "$#" -gt 0 ]; then
    shift
  fi

  case "$command" in
  rehash|shell)
    eval "$(rbenv "sh-$command" "$@")";;
  *)
    command rbenv "$command" "$@";;
  esac
}


## Python
PYENV__HOME="$HOME/.pyenv"
if command -v brew >/dev/null 2>&1; then
  PYENV__LAST_VERS="$(ls -1 $HOME/.homebrew/Cellar/pyenv | sort |  tail -1)"
  PYENV__HOME="$HOME/.homebrew/Cellar/pyenv/$PYENV__LAST_VERS"
fi
PATH="$HOME/.pyenv/shims:${PATH}"
PYENV_SHELL=zsh
source "$PYENV__HOME/libexec/../completions/pyenv.zsh"
command pyenv rehash 2>/dev/null
pyenv() {
  local command
  command="${1:-}"
  if [ "$#" -gt 0 ]; then
    shift
  fi

  case "$command" in
  rehash|shell)
    eval "$(pyenv "sh-$command" "$@")";;
  *)
    command pyenv "$command" "$@";;
  esac
}


## Bashhub
if [ -f "$HOME/.bashhub/bashhub.zsh" ]; then
    source "$HOME/.bashhub/bashhub.zsh"
fi


## Aliases
source "$HOME/.local/lib/sh/aliases.sh"


## Variables
source "$HOME/.local/lib/sh/variables.sh"

