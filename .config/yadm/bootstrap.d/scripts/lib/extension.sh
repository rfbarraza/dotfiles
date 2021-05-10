#!/usr/bin/env bash

##############################################################################
#                                                                            #
# ░█▀▀░█░█░▀█▀░█▀▀░█▀█░█▀▀░▀█▀░█▀█░█▀█░░░░█▀▀░█░█                            #
# ░█▀▀░▄▀▄░░█░░█▀▀░█░█░▀▀█░░█░░█░█░█░█░░░░▀▀█░█▀█                            #
# ░▀▀▀░▀░▀░░▀░░▀▀▀░▀░▀░▀▀▀░▀▀▀░▀▀▀░▀░▀░▀░░▀▀▀░▀░▀                            #
#                                                                            #
#                                                                            #
# Management for extension scripts for the installation process              #
#                                                                            #
##############################################################################


if [[ -z "$__DOT_EXTENSION__" ]]; then
readonly __DOT_EXTENSION__="__DOT_EXTENSION__"

source "$DOT_SCRIPT_DIR/lib/include.sh"
source "$DOT_OUTPUT_SH"
source "$DOT_PUBSUB_SH"


DOT_EXTENSIONS=()

#######################################
# Parse script from extensions string
#
# Arguments:
#   Item from DOT_EXTENSIONS
# Outputs:
#   Path to script
#######################################
dot_extensionparse_script() {
  echo "$1" | sed -r 's/:.*$//'
}

#######################################
# Parse loading function from extensions string
#
# Arguments:
#   Item from DOT_EXTENSIONS
# Outputs:
#   The name of the loading function in the extension
#######################################
dot_extensionparse_function() {
  echo "$1" | grep -o ":.*$" | sed -r 's/://'
}

#######################################
# Enqueue extension with specified loading function for lazy loading
#
# Globals:
#   DOT_EXTENSIONS
# Arguments:
#   "Path to script:loading function"
# Outputs:
#   Status messages regarding validity of extension
# Returns:
#   0 if extension is enqueued for loading
#######################################
dot_extension_add() {
  local readonly script_path="$(dot_extensionparse_script "$1")"
  local readonly loading_fn="$(dot_extensionparse_function "$1" \
    "$script_path")"

  if [[ -z "$script_path" || -z "$loading_fn" ]]; then
    dot_warn "Extension AND loading function required for '$1'"
    dot_warn "script_path = $script_path"
    dot_warn "loading_fn = $loading_fn"
    return 1
  fi

  if [[ ! -f "$script_path" ]]; then
    dot_warn "Extension not found at $script_path"
    return 2
  fi

  DOT_EXTENSIONS+=($1)
}

#######################################
# Load enqueued extensions via their loading functions.
#
# Globals:
#   DOT_VERSION
#   DOT_EXTENSION
# Outputs:
#   Warning output when an extension is incompatible with this version of
#   dotfiles or when the specified loading function cannot be found
#######################################
dot_extension_load() {
  for ext in ${DOT_EXTENSIONS[@]}; do
    local readonly script_path="$(dot_extensionparse_script "$ext")"
    local readonly loading_fn="$(dot_extensionparse_function "$ext" \
      "$script_path")"
    source "$script_path"
    type "$loading_fn" > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
      dot_warn "Loading function not found: $ext"
     else
      ${script_path} -V "$DOT_VERSION" > /dev/null 2>&1
      if [[ $? -ne 0 ]]; then
        dot_warn \
          "Extension '$script_path' incompatible with dotfiles $DOT_VERSION"
      else
        ${loading_fn}
      fi
    fi
  done
}

fi
