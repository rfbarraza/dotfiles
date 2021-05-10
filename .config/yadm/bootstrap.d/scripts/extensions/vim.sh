#!/usr/bin/env bash

##############################################################################
#                                                                            #
# ░█░█░▀█▀░█▄█░░░░█▀▀░█░█                                                    #
# ░▀▄▀░░█░░█░█░░░░▀▀█░█▀█                                                    #
# ░░▀░░▀▀▀░▀░▀░▀░░▀▀▀░▀░▀                                                    #
#                                                                            #
##############################################################################


# ---
# TOC
# ---
#
# ## Script Execution
# ## Extension Functionality
# ## vim plug
#

if [[ -z "$__VIM_EXTENSION__" ]]; then
readonly __VIM_EXTENSION__="$__VIM_EXTENSION__"


## Script Extension
readonly VIM_SCRIPT="$(basename "${BASH_SOURCE[0]}")"
readonly VIM_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly VIM_NAME="vim"
readonly VIM_VERSION="0.1.0"

vim_print_version() {
  echo "$VIM_VERSION"
}

vim_print_usage() {
  cat << USAGE
Usage: $VIM_SCRIPT [-V VERSION] [-v] [-h]
  -V  VERSION of dotfiles to verify this extension will work with
  -v  Print the version of this extension
  -h  Print usage and help
USAGE
}

vim_verify_version() {
  local version="$1"
  local major_version="$(echo "$version" | grep -o "^[1-9][0-9]*" )"
  local minor_version="$(echo "$version" | sed -r "s/^$major_version.//" | \
    grep -o "^[1-9][0-9]*" )"
  if [[ major_version -lt 1 && minor_version -lt 2 ]]; then
    exit 0
  else
    exit 1
  fi
}

vim_parse_args() {
  while getopts :V:vh opt; do
    case "$opt" in
      V)
        vim_verify_version "$OPTARG"
        ;;
      v)
        vim_print_version
        ;;
      h)
        vim_print_usage
        ;;
      [?])
        vim_print_usage
        exit 1
        ;;
    esac
  done
}

vim_main() {
  vim_parse_args "$@"
}

if [[ "$(basename "$0")" == "$VIM_SCRIPT" ]]; then
  vim_main "$@"
  exit 0
fi


## Extension Functionality
readonly VIM_DEST_DIR="$HOME"
readonly VIM_DOT_DIR="$VIM_DEST_DIR/.vim"
readonly VIM_AUTOLOAD_DIR="$VIM_DOT_DIR/autoload"
readonly VIM_PLUG="$VIM_AUTOLOAD_DIR/plug.vim"
readonly VIM_PLUG_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

vim_loader() {
  dot_ext_subscribe "$DOT_DO_SETUP_SOFTWARE_EVENT" vim_plug_install "$VIM_NAME"
 }


 ## vim plug

VIM_PLUG_BACKUP=""

vim_plug_backup() {
  if [[ -d "$VIM_AUTOLOAD_DIR" ]]; then
    if [[ "$(dot_ext_is_force)" == $DOT_EXT_TRUE ]]; then
      dot_ext_puts "Backing up $VIM_AUTOLOAD_DIR"
      if [[ "$(dot_ext_is_dryrun)" != $DOT_EXT_TRUE ]]; then
        VIM_PLUG_BACKUP="$(dot_ext_backup "$VIM_AUTOLOAD_DIR")"
      fi
    else
      dot_ext_warn "$VIM_AUTOLOAD_DIR already exists."
      if [[ -f "$VIM_PLUG" ]]; then
        dot_ext_warn "$VIM_PLUG already exists."
        return 1
      fi
    fi
  fi
  return 0
}

vim_plug_restore_backup() {
  if [[ -n "$VIM_PLUG_BACKUP" && -d "$VIM_PLUG_BACKUP" ]]; then
    dot_ext_puts "Restoring $VIM_AUTOLOAD_DIR from $VIM_PLUG_BACKUP"
    dot_ext_restore "$VIM_AUTOLOAD_DIR" "$VIM_PLUG_BACKUP"
  fi
}

vim_plug_download() {
  dot_ext_dryrun "curl -fLo $VIM_PLUG --create-dirs $VIM_PLUG_URL"
  if [[ "$(dot_ext_is_dryrun)" != $DOT_EXT_TRUE ]]; then
    curl -fLo "$VIM_PLUG" --create-dirs "$VIM_PLUG_URL"
  fi
}

vim_plug_init() {
  dot_puts "Installing plugins..."
  dot_ext_dryrun "vim +'PlugInstall --sync' +qa"
  if [[ "$(dot_ext_is_dryrun)" != $DOT_EXT_TRUE ]]; then
     vim +'PlugInstall --sync' +qa
  fi
}

vim_plug_install() {
  dot_ext_puts "Installing vim-plug..."

  local should_restore=$DOT_EXT_FALSE
  if vim_plug_backup; then
    if vim_plug_download && vim_plug_init; then
      dot_ext_puts "vim-plug installed."
    else
      dot_ext_warn "vim-plug was not installed."
      should_restore=$DOT_EXT_TRUE
    fi
  else
    dot_ext_unsubscribe "$DOT_DO_SETUP_SOFTWARE_EVENT"
    return
  fi

  if [[ "$should_restore" == $DOT_EXT_TRUE ]]; then
    vim_plug_restore_backup
  fi

  dot_ext_unsubscribe "$DOT_DO_SETUP_SOFTWARE_EVENT"
  dot_ext_subscribe "$DOT_WILL_CLEANUP_EVENT" vim_plug_cleanup "$VIM_NAME"
}

vim_plug_cleanup() {
  dot_ext_warn "Leaving vim-plug installed."
  dot_ext_unsubscribe "$DOT_WILL_CLEANUP_EVENT"
}

fi
