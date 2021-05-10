##############################################################################
#                                                                            #
# ░█▀▀░█▀▄░▀█▀░█▀█░░░░█▀▀░█░█                                                #
# ░▀▀█░█▀▄░░█░░█░█░░░░▀▀█░█▀█                                                #
# ░▀▀▀░▀▀░░▀▀▀░▀░▀░▀░░▀▀▀░▀░▀                                                #
#                                                                            #
##############################################################################


# ---
# TOC
# ---
#
# ## Script Extension
# ## Extension Functionality
#

if [[ -z "$__SBIN_EXTENSION__" ]]; then
readonly __SBIN_EXTENSION__="__SBIN_EXTENSION__"

## Script Extension
readonly SBIN_SCRIPT="$(basename "${BASH_SOURCE[0]}")"
readonly SBIN_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SBIN_NAME="sbin"
readonly SBIN_VERSION="0.1.0"

sbin_print_version() {
  echo "$SBIN_VERSION"
}

sbin_print_usage() {
  cat << USAGE
Usage: $SBIN_SCRIPT [-V VERSION] [-v] [-h]
  -V  VERSION of dotfiles to verify this extension will work with
  -v  Print the version of this extension
  -h  Print usage and help
USAGE
}

sbin_verify_version() {
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

sbin_parse_args() {
  while getopts :V:vh opt; do
    case "$opt" in
      V)
        sbin_verify_version "$OPTARG"
        ;;
      v)
        sbin_print_version
        ;;
      h)
        sbin_print_usage
        ;;
      [?])
        sbin_print_usage
        exit 1
        ;;
    esac
  done
}

sbin_main() {
  sbin_parse_args "$@"
}

if [[ "$(basename "$0")" == "$SBIN_SCRIPT" ]]; then
  sbin_main "$@"
  exit 0
fi


## Extension Functionality
sbin_loader() {
  dot_ext_subscribe "$DOT_DID_SETUP_SOFTWARE_EVENT" sbin_link "$SBIN_NAME"
}

sbin_link() {
  local readonly dirs=( "sh" "zsh" )

  mkdir -p "$HOME/.local/sbin"
  for dir in ${dirs[@]}; do
    local readonly dir_path="$HOME/.local/lib/$dir"
    local readonly found="$(find "$dir_path" -maxdepth 1 \( -type f -o -type l \) | sort )"
    local IFS=$'\n'
    local scripts=()
    read -r -d '' -a scripts <<< "$found"
    for script in ${scripts[@]}; do
      if [[ -x "$script" ]]; then
        local readonly script_name="$(basename "$script")"
        dot_ext_symlink "$HOME/.local/sbin/$script_name" "$script"
      fi
    done
  done
}

fi
