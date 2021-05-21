#!/usr/bin/env sh

##############################################################################
#                                                                            #
# ░█▀▄░█▀▄░█▀▀░█░█░░░░█▀▀░█░█                                                #
# ░█▀▄░█▀▄░█▀▀░█▄█░░░░▀▀█░█▀█                                                #
# ░▀▀░░▀░▀░▀▀▀░▀░▀░▀░░▀▀▀░▀░▀                                                #
#                                                                            #
##############################################################################


# ---
# TOC
# ---
#
# ## Script Extension
# ## Extension functionality
# ## Install Brew
# ## Update
# ## Install Formulae
# ## Callbacks
#

if [[ -z "$__BREW_EXTENSION__" ]]; then
readonly __BREW_EXTENSION__="__BREW_EXTENSION__"


## Script Extension
readonly BREW_SCRIPT="$(basename "${BASH_SOURCE[0]}")"
readonly BREW_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BREW_NAME="brew"
readonly BREW_VERSION="0.1.0"

brew_print_version() {
  echo "$BREW_VERSION"
}

brew_print_usage() {
  cat << USAGE
Usage: $BREW_SCRIPT [-V VERSION] [-v] [-h]
  -V  VERSION of dotfiles to verify this extension will work with
  -v  Print the version of this extension
  -h  Print usage and help
USAGE
}

brew_verify_version() {
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

brew_parse_args() {
  while getopts :V:vh opt; do
    case "$opt" in
      V)
        brew_verify_version "$OPTARG"
        ;;
      v)
        brew_print_version
        ;;
      h)
        brew_print_usage
        ;;
      [?])
        brew_print_usage
        exit 1
        ;;
    esac
  done
}

brew_main() {
  brew_parse_args "$@"
}

if [[ "$(basename "$0")" == "$BREW_SCRIPT" ]]; then
  brew_main "$@"
  exit 0
fi


## Extension functionality
BREW_DEST=""  # OS dependent
BREW_BIN_DIR=""
BREW=""

readonly BREW_CMD="brew"
readonly BREW_UPDATE="update"
readonly BREW_INSTALL="install"
readonly BREW_LIST="list"
readonly BREW_FORMULAE_DIR="$API_DIR/extensions/brew/formulae"
readonly BREW_URL="https://github.com/Homebrew/brew.git"

brew_loader() {
  dot_ext_subscribe "$DOT_DO_INSTALL_BREW_FORMULAE_EVENT" brew_install_all \
    "$BREW_NAME"
}

brew_init() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    BREW_DEST="$HOME/.homebrew"
  else
    BREW_DEST="$HOME/.linuxbrew"
  fi
  BREW_BIN_DIR="$BREW_DEST/bin"
  BREW="$BREW_BIN_DIR/brew"
}


## Install Brew
brew_install_brew() {
  if command -v "$BREW_CMD" > /dev/null 2>&1 || [[ -d "$BREW_DEST" ]]; then
    return 0
  fi

  dot_ext_puts_info "Installing Homebrew..."
  dot_ext_dryrun git clone "$BREW_URL" "$BREW_DEST"
  if [[ "$(dot_ext_is_dryrun)" != $DOT_EXT_TRUE ]]; then
    if git clone "$BREW_URL" "$BREW_DEST"; then
      dot_ext_puts_info "Homebrew installed at $BREW_DEST"
    else
      dot_ext_warn "Homebrew installation failed."
      return 1
    fi
  fi
  dot_ext_puts_info "Done installing Homebrew."

  return 0
}


## Update
brew_update() {
  dot_ext_puts_info "Updating..."
  dot_ext_dryrun ${BREW} ${BREW_UPDATE}
  if [[ "$(dot_ext_is_dryrun)" != $DOT_EXT_TRUE ]]; then
    ${BREW} ${BREW_UPDATE}
  fi
  dot_ext_puts_info "Done updating."
  return 0
}


## Install Formulae
brew_install_pl10k() {
  local readonly formula="romkatv/powerlevel10k/powerlevel10k"
  local readonly label="powerlevel10k"

  if ${BREW} ${BREW_LIST} | grep "$label" > /dev/null 2>&1; then
    return
  fi

  dot_ext_puts_info "Installing Powerlevel10k..."
  dot_ext_dryrun ${BREW} ${BREW_INSTALL} "$formula"
  if [[ "$(dot_ext_is_dryrun)" != $DOT_EXT_TRUE ]]; then
    ${BREW} ${BREW_INSTALL} "$formula"
  fi
  dot_ext_puts_info "Done installing Powerlevel10k."
}

brew_is_formula_installed() {
  local readonly formula="$1"
  local cache=""
  if [[ $# -gt 1 ]]; then
    cache="$2"
  fi

  if [[ -n "$cache" ]]; then
    grep -o "^${formula}$" "$cache" > /dev/null 2>&1
  else
    ${BREW} ${BREW_LIST} | tr -s ' ' '\n' 2> /dev/null | grep -o "^${formula}$"
  fi
}

brew_filter_not_installed_formulae() {
  local readonly formulae="$1"
  local cache=""
  if [[ $# -gt 1 ]]; then
    cache="$2"
  fi

  local IFS=' '
  local formulae_array=()
  read -r -a formulae_array <<< "$formulae"
  local not_installed_formulae=()
  for formula in ${formulae_array[@]}; do
    if ! brew_is_formula_installed "$formula" "$cache"; then
      not_installed_formulae+=( "$formula" )
    fi
  done

  echo "${not_installed_formulae[@]}"
}

brew_filter_not_installed_formulae_file() {
  local readonly formulae_file="$1"
  local cache=""
  if [[ $# -gt 1 ]]; then
    cache="$2"
  fi

  local readonly formulae="$(cat "$formulae_file" | xargs)"

  if [[ -z "$cache" ]]; then
    cache="$(mktemp)"
    ${BREW} ${BREW_LIST} | tr -s ' ' '\n' > "$cache" 2> /dev/null
  fi

  local readonly not_installed="$(brew_filter_not_installed_formulae \
    "$formulae" "$cache")"

  if [[ $# -lt 2 ]]; then
    rm "$cache"
  fi
  echo "$not_installed"
}

brew_install_formulae() {
  local readonly formulae="$1"
  local readonly formulae_label="$2"

  dot_ext_puts_info "Installing $formulae_label formulae..."
  dot_ext_puts_info "( ${formulae[@]} )"
  local formulae_array
  local IFS=' '
  read -r -a formulae_array <<< "$formulae"

  dot_ext_dryrun ${BREW} ${BREW_INSTALL} "${formulae_array[@]}"
  if [[ "$(dot_ext_is_dryrun)" != $DOT_EXT_TRUE ]]; then
    ${BREW} ${BREW_INSTALL} "${formulae_array[@]}"
  fi
  dot_ext_puts_info "Done installing $formulae_label."
}

brew_install_formulae_file() {
  local readonly formulae_file="$1"
  local readonly label="$2"
  local cache=""
  if [[ $# -gt 2 ]]; then
    cache="$3"
  fi
  local readonly not_installed_formulae="$(brew_filter_not_installed_formulae_file \
    "$formulae_file" "$cache")"

  if [[ -z "$not_installed_formulae" ]]; then
    dot_ext_puts_info "$label formulae already installed."
    return 1
  fi

  brew_install_formulae "$not_installed_formulae" "$label"
  return 0
}


brew_install_formulae_dir() {
  local readonly formulae_dir="$1"
  local readonly formulae_files=( "$(ls -1 "$formulae_dir" | sort)" )

  dot_ext_puts_info "Installing formulae in \"$formulae_dir\"..."
  local IFS=$'\n'
  local formulae_files_array=()
  read -r -d '' -a formulae_files_array <<< "$formulae_files"
  local cache="$(mktemp)"
  ${BREW} ${BREW_LIST} | tr -s ' ' '\n' > "$cache" 2> /dev/null
  for formulae_file in ${formulae_files_array[@]}; do
    local readonly file="$formulae_dir/$formulae_file"
    local readonly label="$(echo $formulae_file | sed 's/[0-9]*_//g')"
    if brew_install_formulae_file "$file" "$label" "$cache"; then
      rm "$cache"
      cache="$(mktemp)"
      ${BREW} ${BREW_LIST} | tr -s ' ' '\n' > "$cache" 2> /dev/null
    fi
  done
  rm "$cache"
  dot_ext_puts_info "Done installing formulae in \"$formulae_dir\"."
}


## Callbacks
brew_install_all() {
  dot_ext_puts "Performing Homebrew installation..."
  brew_init
  if [[ ! -d "$BREW_FORMULAE_DIR" ]]; then
    dot_ext_warn "$BREW_FORMULAE_DIR is not a directory"
    return
  fi
  if brew_install_brew && brew_update; then
    brew_install_pl10k
    brew_install_formulae_dir "$BREW_FORMULAE_DIR"
  fi
  dot_ext_puts "Done performing Homebrew installation."

  dot_ext_unsubscribe "$DOT_DO_INSTALL_BREW_FORMULAE_EVENT"
}

fi
