##############################################################################
#                                                                            #
# ░█▀█░█▀█░▀█▀░░░░█▀▀░█░█                                                    #
# ░█▀█░█▀▀░░█░░░░░▀▀█░█▀█                                                    #
# ░▀░▀░▀░░░░▀░░▀░░▀▀▀░▀░▀                                                    #
#                                                                            #
##############################################################################


# ---
# TOC
# ---
#
# ## Script Extension
# ## Extension functionality
# ## Update
# ## Install
# ## Callbacks
#

if [[ -z "$__APT_EXTENSION__" ]]; then
readonly __APT_EXTNSION__="__APT_EXTNSION__"

## Script Extension
readonly APT_SCRIPT="$(basename "${BASH_SOURCE[0]}")"
readonly APT_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly APT_NAME="apt"
readonly APT_VERSION="0.1.0"

apt_print_version() {
  echo "$APT_VERSION"
}

apt_print_usage() {
  cat << USAGE
Usage: $APT_SCRIPT [-V VERSION] [-v] [-h]
  -V  VERSION of dotfiles to verify this extension will work with
  -v  Print the version of this extension
  -h  Print usage and help
USAGE
}

apt_verify_version() {
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

apt_parse_args() {
  while getopts :V:vh opt; do
    case "$opt" in
      V)
        apt_verify_version "$OPTARG"
        ;;
      v)
        apt_print_version
        ;;
      h)
        apt_print_usage
        ;;
      [?])
        apt_print_usage
        exit 1
        ;;
    esac
  done
}

apt_main() {
  apt_parse_args "$@"
}

if [[ "$(basename "$0")" == "$APT_SCRIPT" ]]; then
  apt_main "$@"
  exit 0
fi


## Extension functionality
readonly APT_GET="apt-get"
readonly APT_LIST="$APT_GET list"
readonly APT_UPDATE="$APT_GET update"
readonly APT_UPGRADE="$APT_GET upgrade"
readonly APT_INSTALL="$APT_GET install"
readonly APT_ASSUME_YES="--assume-yes"
readonly APT_INSTALLED="--installed"
readonly APT_PKG_DIR="$API_DIR/extensions/apt/packages/"

apt_loader() {
  dot_ext_subscribe "$DOT_DO_INSTALL_APT_PACKAGES_EVENT" apt_install_all \
    "$APT_NAME"
}


## Update
apt_update() {
  dot_ext_puts_info "Updating..."
  dot_ext_dryrun sudo ${APT_UPDATE} ${APT_ASSUME_YES}
  if [[ "$(dot_ext_is_dryrun)" != $DOT_EXT_TRUE ]]; then
    sudo ${APT_UPDATE} ${APT_ASSUME_YES}
  fi
  dot_ext_puts_info "Done updating."
  return 0
}


## Install
apt_is_package_installed() {
  local readonly pkg="$1"
  local cache=""
  if [[ $# -gt 1 ]]; then
    cache="$2"
  fi

  if [[ -n "$cache" ]]; then
    grep -o "^$pkg/" "$cache" > /dev/null 2>&1
  else
    ${APT_LIST} ${APT_INSTALLED} 2> /dev/null | grep -o "^$pkg/"
  fi
}

apt_filter_not_installed_packages() {
  local readonly pkgs="$1"
  local cache=""
  if [[ $# -gt 1 ]]; then
    cache="$2"
  fi

  local IFS=' '
  local pkgs_array=()
  read -r -a pkgs_array <<< "$pkgs"
  local not_installed_pkgs=()
  for pkg in ${pkgs_array[@]}; do
    if ! apt_is_package_installed "$pkg" "$cache"; then
      not_installed_pkgs+=( "$pkg" )
    fi
  done

  echo "${not_installed_pkgs[@]}"
}

apt_filter_not_installed_packages_file() {
  local readonly pkg_file="$1"

  local cache=""
  if [[ $# -gt 1 ]]; then
    cache="$2"
  fi

  local readonly pkgs="$(cat "$pkg_file" | xargs)"

  if [[ -z "$cache" ]]; then
    cache="$(mktemp)"
    ${APT_LIST} ${APT_INSTALLED} > "$cache" 2> /dev/null
  fi

  local readonly not_installed="$(apt_filter_not_installed_packages \
    "$pkgs" "$cache")"

  if [[ $# -lt 2 ]]; then
    rm "$cache"
  fi

  echo "$not_installed"
}

apt_install_packages() {
  local readonly pkgs="$1"
  local readonly pkgs_label="$2"

  dot_ext_puts_info "Installing $pkgs_label packages..."
  dot_ext_puts_info "( ${pkgs[@]} )"
  local pkgs_array
  local IFS=' '
  read -r -a pkgs_array <<< "$pkgs"

  dot_ext_dryrun sudo ${APT_INSTALL} ${APT_ASSUME_YES} "${pkgs_array[@]}"
  if [[ "$(dot_ext_is_dryrun)" != $DOT_EXT_TRUE ]]; then
    sudo ${APT_INSTALL} ${APT_ASSUME_YES} "${pkgs_array[@]}"
  fi
  dot_ext_puts_info "Done installing $pkgs_label."
}

apt_install_packages_file() {
  local readonly pkg_file="$1"
  local readonly label="$2"
  local cache=""
  if [[ $# -gt 2 ]]; then
    cache="$3"
  fi
  local readonly not_installed_pkgs="$(apt_filter_not_installed_packages_file \
    "$pkg_file" "$cache")"

  if [[ -z "$not_installed_pkgs" ]]; then
    dot_ext_puts_info "$label packages already installed."
    return 1
  fi

  apt_install_packages "$not_installed_pkgs" "$label"
  return 0
}

apt_install_packages_dir() {
  local readonly pkg_dir="$1"
  local readonly pkg_files=( "$(ls -1 "$pkg_dir" | sort)" )

  dot_ext_puts_info "Installing packages in \"$pkg_dir\"..."
  local IFS=$'\n'
  local pkg_files_array=()
  read -r -d '' -a pkg_files_array <<< "$pkg_files"
  local cache="$(mktemp)"
  ${APT_LIST} ${APT_INSTALLED} > "$cache" 2> /dev/null
  for pkg_file in ${pkg_files_array[@]}; do
    local readonly file="$pkg_dir/$pkg_file"
    local readonly label="$(echo $pkg_file | sed 's/[0-9]*_//g')"
    if apt_install_packages_file "$file" "$label" "$cache"; then
      rm "$cache"
      local cache="$(mktemp)"
      ${APT_LIST} ${APT_INSTALLED} > "$cache" 2> /dev/null
    fi
  done
  rm "$cache"
  dot_ext_puts_info "Done installing packages in \"$pkg_dir\"."
}


## Callbacks

apt_install_all() {
  dot_ext_puts_info "Performing apt installation..."
  if [[ ! -d "$APT_PKG_DIR" ]]; then
    dot_ext_warn "$APT_PKG_DIR is not a directory"
    return
  fi
  if apt_update; then
    apt_install_packages_dir "$APT_PKG_DIR"
  fi
  dot_ext_puts_info "Done performing apt installation."
}

fi
