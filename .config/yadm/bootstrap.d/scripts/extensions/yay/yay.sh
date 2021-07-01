#!/usr/bin/env bash

##############################################################################
#                                                                            #
# ░█░█░█▀█░█░█░░░░█▀▀░█░█                                                    #
# ░░█░░█▀█░░█░░░░░▀▀█░█▀█                                                    #
# ░░▀░░▀░▀░░▀░░▀░░▀▀▀░▀░▀                                                    #
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

if [[ -z "$__YAY_EXTENSION__" ]]; then
readonly __YAY_EXTNSION__="__YAY_EXTNSION__"

## Script Extension
readonly YAY_SCRIPT="$(basename "${BASH_SOURCE[0]}")"
readonly YAY_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly YAY_NAME="yay"
readonly YAY_VERSION="0.1.0"

yay_print_version() {
  echo "$YAY_VERSION"
}

yay_print_usage() {
  cat << USAGE
Usage: $YAY_SCRIPT [-V VERSION] [-v] [-h]
  -V  VERSION of dotfiles to verify this extension will work with
  -v  Print the version of this extension
  -h  Print usage and help
USAGE
}

yay_verify_version() {
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

yay_parse_args() {
  while getopts :V:vh opt; do
    case "$opt" in
      V)
        yay_verify_version "$OPTARG"
        ;;
      v)
        yay_print_version
        ;;
      h)
        yay_print_usage
        ;;
      [?])
        yay_print_usage
        exit 1
        ;;
    esac
  done
}

yay_main() {
  yay_parse_args "$@"
}

if [[ "$(basename "$0")" == "$YAY_SCRIPT" ]]; then
  yay_main "$@"
  exit 0
fi


## Extension functionality
readonly YAY_CMD="yay"
readonly YAY_UPDATE="-Syy"
readonly YAY_INSTALL="-Syu"
readonly YAY_NO_CONFIRM="--noconfirm"
readonly YAY_PACMAN_CMD="pacman"
readonly YAY_PACMAN_LIST="-Q"
readonly YAY_PKG_DIR="$API_DIR/extensions/yay/packages/"

yay_loader() {
  dot_ext_subscribe "$DOT_DO_INSTALL_YAY_PACKAGES_EVENT" yay_install_all \
    "$YAY_NAME"

}

## Update
yay_update() {
  dot_ext_puts_info "Updating..."
  dot_ext_dryrun sudo ${YAY_CMD} ${YAY_UPDATE} ${YAY_NO_CONFIRM}
  if [[ "$(dot_ext_is_dryrun)" != $DOT_EXT_TRUE ]]; then
    sudo ${YAY_CMD} ${YAY_UPDATE} ${YAY_NO_CONFIRM}
  fi
  dot_ext_puts_info "Done updating."
  return 0
}


## Install
yay_is_package_installed() {
  local readonly pkg="$1"
  local cache=""
  if [[ $# -gt 1 ]]; then
    cache="$2"
  fi

  if [[ -n "$cache" ]]; then
    grep -o "^$pkg/" "$cache" > /dev/null 2>&1
  else
    ${YAY_PACMAN_CMD} ${YAY_PACMAN_LIST} 2> /dev/null | grep -o "^$pkg/"
  fi
}

yay_filter_not_installed_packages() {
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
    if ! yay_is_package_installed "$pkg" "$cache"; then
      not_installed_pkgs+=( "$pkg" )
    fi
  done

  echo "${not_installed_pkgs[@]}"
}

yay_filter_not_installed_packages_file() {
  local readonly pkg_file="$1"

  local cache=""
  if [[ $# -gt 1 ]]; then
    cache="$2"
  fi

  local readonly pkgs="$(cat "$pkg_file" | xargs)"

  if [[ -z "$cache" ]]; then
    cache="$(mktemp)"
    ${PACMAN_CMD} ${PACMAN_LIST} > "$cache" 2> /dev/null
  fi

  local readonly not_installed="$(yay_filter_not_installed_packages \
    "$pkgs" "$cache")"

  if [[ $# -lt 2 ]]; then
    rm "$cache"
  fi

  echo "$not_installed"
}

yay_install_packages() {
  local readonly pkgs="$1"
  local readonly pkgs_label="$2"

  dot_ext_puts_info "Installing $pkgs_label packages..."
  dot_ext_puts_info "( ${pkgs[@]} )"
  local pkgs_array
  local IFS=' '
  read -r -a pkgs_array <<< "$pkgs"

  dot_ext_dryrun sudo ${YAY_CMD} ${YAY_INSTALL} ${YAY_NO_CONFIRM} "${pkgs_array[@]}"
  if [[ "$(dot_ext_is_dryrun)" != $DOT_EXT_TRUE ]]; then
    sudo ${YAY_CMD} ${YAY_INSTALL} ${YAY_NO_CONFIRM} "${pkgs_array[@]}"
  fi
  dot_ext_puts_info "Done installing $pkgs_label."
}

yay_install_packages_file() {
  local readonly pkg_file="$1"
  local readonly label="$2"
  local cache=""
  if [[ $# -gt 2 ]]; then
    cache="$3"
  fi
  local readonly not_installed_pkgs="$(yay_filter_not_installed_packages_file \
    "$pkg_file" "$cache")"

  if [[ -z "$not_installed_pkgs" ]]; then
    dot_ext_puts_info "$label packages already installed."
    return 1
  fi

  yay_install_packages "$not_installed_pkgs" "$label"
  return 0
}

yay_install_packages_dir() {
  local readonly pkg_dir="$1"
  local readonly pkg_files=( "$(ls -1 "$pkg_dir" | sort)" )

  dot_ext_puts_info "Installing packages in \"$pkg_dir\"..."
  local IFS=$'\n'
  local pkg_files_array=()
  read -r -d '' -a pkg_files_array <<< "$pkg_files"
  local cache="$(mktemp)"
  ${PACMAN_CMD} ${PACMAN_LIST} > "$cache" 2> /dev/null
  for pkg_file in ${pkg_files_array[@]}; do
    local readonly file="$pkg_dir/$pkg_file"
    local readonly label="$(echo $pkg_file | sed 's/[0-9]*_//g')"
    if yay_install_packages_file "$file" "$label" "$cache"; then
      rm "$cache"
      local cache="$(mktemp)"
      ${PACMAN_CMD} ${PACMAN_LIST} > "$cache" 2> /dev/null
    fi
  done
  rm "$cache"
  dot_ext_puts_info "Done installing packages in \"$pkg_dir\"."
}

## Callbacks
yay_install_all() {
  dot_ext_puts "Performing yay installation..."
  if [[ ! -d "$YAY_PKG_DIR" ]]; then
    dot_ext_warn "$YAY_PKG_DIR is not a directory"
    return
  fi
  if yay_update; then
    yay_install_packages_dir "$YAY_PKG_DIR"
  fi
  dot_ext_puts "Done performing yay installation."

  dot_ext_unsubscribe "$DOT_DO_INSTALL_YAY_PACKAGES_EVENT"
}

fi

