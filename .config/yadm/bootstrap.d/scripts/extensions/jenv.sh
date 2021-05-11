##############################################################################
#                                                                            #
# ░▀▀█░█▀▀░█▀█░█░█░░░░█▀▀░█░█                                                #
# ░░░█░█▀▀░█░█░▀▄▀░░░░▀▀█░█▀█                                                #
# ░▀▀░░▀▀▀░▀░▀░░▀░░▀░░▀▀▀░▀░▀                                                #
#                                                                            #
##############################################################################


# ---
# TOC
# ---
#
# ## Script Extension
# ## Extension Functionality
# ## Installation
#

if [[ -z "$__JENV_EXTENSION__" ]]; then
readonly __JENV_EXTENSION__="__JENV_EXTENSION__"

## Script Extension
readonly JENV_SCRIPT="$(basename "${BASH_SOURCE[0]}")"
readonly JENV_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly JENV_NAME="jenv"
readonly JENV_VERSION="0.1.0"

jenv_print_version() {
  echo "$jenv_VERSION"
}

jenv_print_usage() {
  cat << USAGE
Usage: $JENV_SCRIPT [-V VERSION] [-v] [-h]
  -V  VERSION of dotfiles to verify this extension will work with
  -v  Print the version of this extension
  -h  Print usage and help
USAGE
}

jenv_verify_version() {
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

jenv_parse_args() {
  while getopts :V:vh opt; do
    case "$opt" in
      V)
        jenv_verify_version "$OPTARG"
        ;;
      v)
        jenv_print_version
        ;;
      h)
        jenv_print_usage
        ;;
      [?])
        jenv_print_usage
        exit 1
        ;;
    esac
  done
}

jenv_main() {
  jenv_parse_args "$@"
}

if [[ "$(basename "$0")" == "$JENV_SCRIPT" ]]; then
  jenv_main "$@"
  exit 0
fi


## Extension Functionality
JENV_DIR="$HOME/.jenv"
JENV_URL="https://github.com/jenv/jenv.git"

jenv_loader() {
  dot_ext_subscribe "$DOT_WILL_SETUP_SOFTWARE_EVENT" jenv_install "$JENV_NAME"
}


## Installation
jenv_install_jenv() {
  if [[ -d "$JENV_DIR" ]]; then
    return 0
  fi

  dot_ext_puts_info "Installing jenv..."
  dot_ext_dryrun git clone "$JENV_URL" "$JENV_DEST"
  if [[ "$(dot_ext_is_dryrun)" != $DOT_EXT_TRUE ]]; then
    if git clong "$JENV_URL" "$JENV_DEST"; then
      dot_ext_puts "jenv installed at $JENV_DIR"
    else
      dot_ext_warn "jenv installation failed."
      return 1
    fi
  fi
  dot_ext_puts_info "Done installing jenv."

  return 0
 }

jenv_install() {
  dot_ext_puts "Performing jenv installation..."
  if [[ ! -d "$JENV_DIR" ]]; then
    dot_ext_warn "$JENV_DIR is not a directory"
    return
  fi
  jenv_install_jenv
  dot_ext_puts_info "Done performing jenv installation."

  dot_ext_unsubscribe "$DOT_WILL_SETUP_SOFTWARE_EVENT"
}

fi
