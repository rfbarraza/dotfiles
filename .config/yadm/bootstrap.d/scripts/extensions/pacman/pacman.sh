#!/usr/bin/env bash

##############################################################################
#                                                                            #
# ░█▀█░█▀█░█▀▀░█▄█░█▀█░█▀█░░░░█▀▀░█░█                                        #
# ░█▀▀░█▀█░█░░░█░█░█▀█░█░█░░░░▀▀█░█▀█                                        #
# ░▀░░░▀░▀░▀▀▀░▀░▀░▀░▀░▀░▀░▀░░▀▀▀░▀░▀                                        #
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

if [[ -z "$__PACMAN_EXTENSION__" ]]; then
readonly __PACMAN_EXTNSION__="__PACMAN_EXTNSION__"

## Script Extension
readonly PACMAN_SCRIPT="$(basename "${BASH_SOURCE[0]}")"
readonly PACMAN_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PACMAN_NAME="pacman"
readonly PACMAN_VERSION="0.1.0"

pacman_print_version() {
  echo "$PACMAN_VERSION"
}

pacman_print_usage() {
  cat << USAGE
Usage: $PACMAN_SCRIPT [-V VERSION] [-v] [-h]
  -V  VERSION of dotfiles to verify this extension will work with
  -v  Print the version of this extension
  -h  Print usage and help
USAGE
}

pacman_verify_version() {
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

pacman_parse_args() {
  while getopts :V:vh opt; do
    case "$opt" in
      V)
        pacman_verify_version "$OPTARG"
        ;;
      v)
        pacman_print_version
        ;;
      h)
        pacman_print_usage
        ;;
      [?])
        pacman_print_usage
        exit 1
        ;;
    esac
  done
}

pacman_main() {
  pacman_parse_args "$@"
}

if [[ "$(basename "$0")" == "$PACMAN_SCRIPT" ]]; then
  pacman_main "$@"
  exit 0
fi


## Extension functionality
readonly PACMAN_CMD="pacman"
readonly PACMAN_LIST="-Q"
readonly PACMAN_UPDATE_OPTIONS="-Syu"
readonly PACMAN_INSTALL_OPTIONS"-S"
readonly PACMAN_NO_CONFIRM="--noconfirm"
readonly PACMAN_PKG_DIR="$API_DIR/extensions/pacman/packages/"


pacman_loader() {
  dot_ext_subscribe "$DOT_DO_INSTALL_PACMAN_PACKAGES_EVENT" pacman_install_all \
    "$PACMAN_NAME"
}


## Update
pacman_update() {
  dot_ext_puts_info "Updating..."
  dot_ext_dryrun sudo ${PACMAN_CMD} ${PACMAN_UPDATE_OPTIONS} ${PACMAN_NO_CONFIRM}
  if [[ "$(dot_ext_is_dryrun)" != $DOT_EXT_TRUE ]]; then
    sudo ${PACMAN_CMD} ${PACMAN_UPDATE_OPTIONS} ${PACMAN_NO_CONFIRM}
  fi
  dot_ext_puts_info "Done updating."
  return 0
}


## Install
pacman_is_package_installed() {
  local readonly pkg="$1"
  local cache=""
  if [[ $# -gt 1 ]]; then
    cache="$2"
  fi

  if [[ -n "$cache" ]]; then
    grep -o "^$pkg/" "$cache" > /dev/null 2>&1
  else
    ${PACMAN_CMD} ${PACMAN_LIST} 2> /dev/null | grep -o "^$pkg/"
  fi
}

pacman_filter_not_installed_packages() {
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
    if ! pacman_is_package_installed "$pkg" "$cache"; then
      not_installed_pkgs+=( "$pkg" )
    fi
  done

  echo "${not_installed_pkgs[@]}"
}

pacman_filter_not_installed_packages_file() {
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

  local readonly not_installed="$(pacman_filter_not_installed_packages \
    "$pkgs" "$cache")"

  if [[ $# -lt 2 ]]; then
    rm "$cache"
  fi

  echo "$not_installed"
}

pacman_install_packages() {
  local readonly pkgs="$1"
  local readonly pkgs_label="$2"

  dot_ext_puts_info "Installing $pkgs_label packages..."
  dot_ext_puts_info "( ${pkgs[@]} )"
  local pkgs_array
  local IFS=' '
  read -r -a pkgs_array <<< "$pkgs"

  dot_ext_dryrun sudo ${PACMAN_CMD} ${PACMAN_INSTALL} ${PACMAN_NO_CONFIRM} "${pkgs_array[@]}"
  if [[ "$(dot_ext_is_dryrun)" != $DOT_EXT_TRUE ]]; then
    sudo ${PACMAN_CMD} ${PACMAN_INSTALL} ${PACMAN_NO_CONFIRM} "${pkgs_array[@]}"
  fi
  dot_ext_puts_info "Done installing $pkgs_label."
}

pacman_install_packages_file() {
  local readonly pkg_file="$1"
  local readonly label="$2"
  local cache=""
  if [[ $# -gt 2 ]]; then
    cache="$3"
  fi
  local readonly not_installed_pkgs="$(pacman_filter_not_installed_packages_file \
    "$pkg_file" "$cache")"

  if [[ -z "$not_installed_pkgs" ]]; then
    dot_ext_puts_info "$label packages already installed."
    return 1
  fi

  pacman_install_packages "$not_installed_pkgs" "$label"
  return 0
}

pacman_install_packages_dir() {
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
    if pacman_install_packages_file "$file" "$label" "$cache"; then
      rm "$cache"
      local cache="$(mktemp)"
      ${PACMAN_CMD} ${PACMAN_LIST} > "$cache" 2> /dev/null
    fi
  done
  rm "$cache"
  dot_ext_puts_info "Done installing packages in \"$pkg_dir\"."
}

## Callbacks
pacman_install_all() {
  dot_ext_puts "Performing pacman installation..."
  if [[ ! -d "$PACMAN_PKG_DIR" ]]; then
    dot_ext_warn "$PACMAN_PKG_DIR is not a directory"
    return
  fi
  if pacman_update; then
    pacman_install_packages_dir "$PACMAN_PKG_DIR"
  fi
  dot_ext_puts "Done performing pacman installation."

  dot_ext_unsubscribe "$DOT_DO_INSTALL_PACMAN_PACKAGES_EVENT"
}

fi

