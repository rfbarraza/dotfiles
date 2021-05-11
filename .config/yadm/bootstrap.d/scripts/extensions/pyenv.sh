##############################################################################
#                                                                            #
# ░█▀█░█░█░█▀▀░█▀█░█░█░░░░█▀▀░█░█                                            #
# ░█▀▀░░█░░█▀▀░█░█░▀▄▀░░░░▀▀█░█▀█                                            #
# ░▀░░░░▀░░▀▀▀░▀░▀░░▀░░▀░░▀▀▀░▀░▀                                            #
#                                                                            #
##############################################################################


# ---
# TOC
# ---
#
# ## Script Extension
# ## Extension Functionality
#

if [[ -z "$__PYENV_EXTENSION__" ]]; then
readonly __PYENV_EXTENSION__="__PYENV_EXTENSION__"

## Script Extension
readonly PYENV_SCRIPT="$(basename "${BASH_SOURCE[0]}")"
readonly PYENV_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PYENV_NAME="pyenv"
readonly PYENV_VERSION="0.1.0"

pyenv_print_version() {
  echo "$pyenv_VERSION"
}

pyenv_print_usage() {
  cat << USAGE
Usage: $PYENV_SCRIPT [-V VERSION] [-v] [-h]
  -V  VERSION of dotfiles to verify this extension will work with
  -v  Print the version of this extension
  -h  Print usage and help
USAGE
}

pyenv_verify_version() {
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

pyenv_parse_args() {
  while getopts :V:vh opt; do
    case "$opt" in
      V)
        pyenv_verify_version "$OPTARG"
        ;;
      v)
        pyenv_print_version
        ;;
      h)
        pyenv_print_usage
        ;;
      [?])
        pyenv_print_usage
        exit 1
        ;;
    esac
  done
}

pyenv_main() {
  pyenv_parse_args "$@"
}

if [[ "$(basename "$0")" == "$PYENV_SCRIPT" ]]; then
  pyenv_main "$@"
  exit 0
fi


## Extension Functionality
PYENV_DIR="$HOME/.PYENV"
JENV_URL="https://github.com/pyenv/pyenv.git"

pyenv_loader() {
  dot_ext_subscribe "$DOT_WILL_SETUP_SOFTWARE_EVENT" pyenv_install "$PYENV_NAME"
}


## Installation
pyenv_install_pyenv() {
  if [[ -d "$PYENV_DIR" ]]; then
    return 0
  fi

  dot_ext_puts_info "Installing pyenv..."
  dot_ext_dryrun git clone "$PYENV_URL" "$PYENV_DIR"
  if [[ "$(dot_ext_is_dryrun)" != $DOT_EXT_TRUE ]]; then
    if git clone "$PYENV_URL" "$PYENV_DIR"; then
      dot_ext_puts "pyenv installed at $PYENV_DIR"
    else
      dot_ext_warn "pyenv installation failed."
      return 1
    fi
  fi
  dot_ext_puts_info "Done installing pyenv."

  return 0
 }

pyenv_install() {
  dot_ext_puts "Performing pyenv installation..."
  if [[ -d "$PYENV_DIR" ]]; then
    dot_ext_puts_info "Already installed."
    return
  fi
  pyenv_install_pyenv
  dot_ext_puts_info "Done performing pyenv installation."

  dot_ext_unsubscribe "$DOT_WILL_SETUP_SOFTWARE_EVENT"
}



fi
