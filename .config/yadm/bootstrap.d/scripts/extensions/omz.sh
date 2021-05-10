##############################################################################
#                                                                            #
# ░█▀█░█▄█░▀▀█░░░░█▀▀░█░█                                                    #
# ░█░█░█░█░▄▀░░░░░▀▀█░█▀█                                                    #
# ░▀▀▀░▀░▀░▀▀▀░▀░░▀▀▀░▀░▀                                                    #
#                                                                            #
##############################################################################


# ---
# TOC
# ---
#
# ## Script Execution
# ## Extension Functionality
# ## OMZ
# ## shell change
# ## Powerlevel10k
#

if [[ -z "$__OMZ_EXTENSION__" ]]; then
readonly __OMZ_EXTENSION__="__OMZ_EXTENSION__"

## Script Extension
readonly OMZ_SCRIPT="$(basename "${BASH_SOURCE[0]}")"
readonly OMZ_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly OMZ_NAME="ohmyzsh"
readonly OMZ_VERSION="0.1.0"

omz_print_version() {
  echo "$OMZ_VERSION"
}

omz_print_usage() {
  cat << USAGE
Usage: $OMZ_SCRIPT [-V VERSION] [-v] [-h]
  -V  VERSION of dotfiles to verify this extension will work with
  -v  Print the version of this extension
  -h  Print usage and help
USAGE
}

omz_verify_version() {
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

omz_parse_args() {
  while getopts :V:vh opt; do
    case "$opt" in
      V)
        omz_verify_version "$OPTARG"
        ;;
      v)
        omz_print_version
        ;;
      h)
        omz_print_usage
        ;;
      [?])
        omz_print_usage
        exit 1
        ;;
    esac
  done
}

omz_main() {
  omz_parse_args "$@"
}

if [[ "$(basename "$0")" == "$OMZ_SCRIPT" ]]; then
  omz_main "$@"
  exit 0
fi


## Extension Functionality
omz_loader() {
  dot_ext_subscribe "$DOT_DO_SETUP_SOFTWARE_EVENT" omz_backup_zshrc "$OMZ_NAME"
  dot_ext_subscribe "$DOT_DO_SETUP_SOFTWARE_EVENT" omz_install "$OMZ_NAME"
  dot_ext_subscribe "$DOT_DO_SETUP_SOFTWARE_EVENT" omz_install_pl10k "$OMZ_NAME"
  dot_ext_subscribe "$DOT_DO_SETUP_SOFTWARE_EVENT" omz_change_shell "$OMZ_NAME"
}


## OMZ
readonly OMZ_INSTALL_URL="https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
readonly OMZ_DEST="$HOME/.oh-my-zsh"

OMZ_BACKUP=""
OMZ_ZSHRC="$HOME/.zshrc"
OMZ_ZSHRC_BACKUP=""

omz_backup_zshrc() {
  if [[ "$(dot_ext_is_force)" == $DOT_EXT_TRUE && -f "$OMZ_ZSHRC" ]]; then
    dot_ext_puts "Backing up $OMZ_ZSHRC..."
    dot_ext_warn "You will probably need to manually restore this manually."
    dot_ext_warn "Oh My Zsh tends to overwrite .zshrc when you launch a new"
    dot_ext_warn "shell for the first time after installation."
    if [[ "$(dot_ext_is_dryrun)" != $DOT_EXT_TRUE ]]; then
      OMZ_ZSHRC_BACKUP="$(dot_ext_backup "$OMZ_ZSHRC")"
    fi
  fi
}

omz_restore_zshrc() {
  if [[ -n "$OMZ_ZSHRC_BACKUP" ]]; then
    dot_ext_puts "Restoring $OMZ_ZSHRC"
    dot_ext_restore "$DOT_ZSHRC" "$DOT_ZSHRC_BACKUP"
  fi
}

omz_backup() {
  if [[ -d "$OMZ_DEST" ]]; then
    if [[ "$(dot_ext_is_force)" == $DOT_EXT_TRUE ]]; then
      dot_ext_puts "Backing up $OMZ_DEST..."
      if [[ "$(dot_ext_is_dryrun)" != $DOT_EXT_TRUE ]]; then
        OMZ_BACKUP="$(dot_ext_backup "$OMZ_DEST")"
      fi
    else
      dot_ext_warn "Oh My Zsh is already installed."
      return 1
    fi
  fi
  return 0
}

omz_restore_backup() {
  if [[ -n "$OMZ_BACKUP" && -d "$OMZ_BACKUP" ]]; then
    dot_ext_puts "Restoring Oh My Zsh from $OMZ_BACKUP."
    dot_ext_restore "$OMZ_DEST" "$OMZ_BACKUP"
  fi
  omz_restore_zshrc
}

omz_download() {
  local curl_cmd='$(curl -fsSL '
  curl_cmd+='"'
  curl_cmd+="$OMZ_INSTALL_URL"
  curl_cmd+='"'
  curl_cmd+=')'
  dot_ext_dryrun "sh -c $curl_cmd --unattended"
  if [[ "$(dot_ext_is_dryrun)" != $DOT_EXT_TRUE ]]; then
    sh -c "$(curl -fsSL "$OMZ_INSTALL_URL")" "" --unattended
  fi
}

omz_install() {
  dot_ext_puts "Installing Oh My Zsh..."

  local should_restore=$DOT_EXT_FALSE
  if omz_backup; then
    if omz_download; then
      dot_ext_puts "Oh My Zsh installed."
    else
      dot_ext_warn "Oh My Zsh installation failed."
      should_restore=$DOT_EXT_TRUE
    fi
  else
    dot_ext_unsubscribe "$DOT_DO_SETUP_SOFTWARE_EVENT"
    return
  fi

  if [[ $should_restore == $DOT_EXT_TRUE ]]; then
    omz_restore_backup
  fi

  dot_ext_unsubscribe "$DOT_DO_SETUP_SOFTWARE_EVENT"
  dot_ext_subscribe "$DOT_WILL_CLEANUP_EVENT" omz_cleanup "$OMZ_NAME"
}

omz_cleanup() {
  dot_ext_warn "Leaving Oh My Zsh installed."
  dot_ext_unsubscribe "$DOT_DO_SETUP_SOFTWARE_EVENT"
}


## change shell
omz_change_shell() {
  if [[ "$SHELL" != "/bin/zsh" ]]; then
    dot_ext_puts "Changing shell to zsh.."
    dot_ext_dryrun chsh -s "\$(which zsh)"
    if [[ "$(dot_ext_is_dryrun)" != $DOT_TRUE ]]; then
      chsh -s "$(which zsh)"
    fi
    if [[ $? -ne 0 ]]; then
      dot_ext_warn "Could not change to zsh."
    fi
  fi

  dot_ext_unsubscribe "$DOT_DO_SETUP_SOFTWARE_EVENT"
}


## Powerlevel10k
readonly OMZ_PL10K_URL="https://github.com/romkatv/powerlevel10k.git"
readonly OMZ_PL10K_DEST="$OMZ_DEST/custom/themes/powerlevel10k"
OMZ_PL10K_BACKUP=""

omz_backup_pl10k() {
  if [[ -d "$OMZ_PL10K_DEST" ]]; then
    if [[ "$(dot_ext_is_force)" == $DOT_EXT_TRUE ]]; then
      dot_ext_puts "Backing up $OMZ_PL10K_DEST..."
      if [[ "$(dot_ext_is_dryrun)" != $DOT_EXT_TRUE ]]; then
        OMZ_PL10K_BACKUP="$(dot_ext_backup "$OMZ_PL10K_DEST")"
      fi
    else
      dot_ext_warn "Powerlevel10k is already installed."
      return 1
    fi
  fi
  return 0
}

omz_restore_pl10k() {
  if [[ -n "$OMZ_PL10K_BACKUP" ]]; then
    dot_ext_puts "Restoring Powerlevl10k"
    dot_ext_restore "$OMZ_PL10K_DEST" "$OMZ_PL10K_BACKUP"
  fi
}

omz_download_pl10k() {
  dot_ext_puts "Downloading Powerlevel10k"
  dot_ext_dryrun git clone --depth=1 "$OMZ_PL10K_URL" "$OMZ_PL10K_DEST"
  if [[ "$(dot_ext_is_dryrun)" != $DOT_EXT_TRUE ]]; then
    git clone --depth=1 "$OMZ_PL10K_URL" "$OMZ_PL10K_DEST"
  fi
}

omz_install_pl10k() {
  dot_ext_puts "Installing Powerlevel10k..."

  local should_restore=$DOT_EXT_FALSE
  if omz_backup_pl10k; then
    if omz_download_pl10k; then
      dot_ext_puts "Powerlevel10k installed."
    else
      dot_ext_warn "Powerlevel10k failed to install."
      should_restore=$DOT_EXT_TRUE
    fi
  fi

  if [[ $should_restore == $DOT_EXT_TRUE ]]; then
    omz_restore_pl10k
    dot_ext_unsubscribe "$DOT_DO_SETUP_SOFTWARE_EVENT"
    return
  fi

  dot_ext_unsubscribe "$DOT_DO_SETUP_SOFTWARE_EVENT"
  dot_ext_subscribe "$DOT_WILL_CLEANUP_EVENT" omz_pl10k_cleanup "$OMZ_NAME"
}

omz_pl10k_cleanup() {
  dot_puts_ext "Leaving Powerlevel10k installed."
  dot_ext_unsubscribe "$DOT_DO_SETUP_SOFTWARE_EVENT"
}

fi
