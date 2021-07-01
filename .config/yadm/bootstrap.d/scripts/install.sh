#!/usr/bin/env bash

##############################################################################
#                                                                            #
# ░▀█▀░█▀█░█▀▀░▀█▀░█▀█░█░░░█░░░░░░█▀▀░█░█                                    #
# ░░█░░█░█░▀▀█░░█░░█▀█░█░░░█░░░░░░▀▀█░█▀█                                    #
# ░▀▀▀░▀░▀░▀▀▀░░▀░░▀░▀░▀▀▀░▀▀▀░▀░░▀▀▀░▀░▀                                    #
#                                                                            #
#                                                                            #
# Usage:                                                                     #
#   install.sh [--no-root]                                                   #
#                                                                            #
# Install dotfiles and necessary scripts and functions for interactive shell #
# use on *nix systems.                                                       #
#                                                                            #
##############################################################################


DOT_SCRIPT="$(basename "${BASH_SOURCE[0]}")"
DOT_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOT_VERSION="0.1.0"


source "$DOT_SCRIPT_DIR/lib/include.sh"
source "$DOT_API_SH"
source "$DOT_BOOL_SH"
source "$DOT_EXTENSION_SH"
source "$DOT_OUTPUT_SH"
source "$DOT_PUBSUB_SH"


#######################################
# Outputs usage
#
# Outputs:
#   Usage
#######################################
dot_print_usage() {
  cat << USAGE
Usage: $DOT_SCRIPT [-F] [-E EXTENSION:LOAD_FUNCTION] [-d] [-i] [-v] [-h]
  -F  force script to install new files and backup existing ones
  -E  External extension script and loader function
  -d  dry run, do not execute commands with persistent side effects
  -i  print informative level of output
  -v  print version
  -h  print help and usage
USAGE
}

#######################################
# Set global defaults that have not already been set
#
# Globals:
#   DOT_IS_ADMIN
#   DOT_IS_FORCE
#   DOT_IS_DRYRUN
#   DOT_IS_QUIET
#######################################
dot_set_defaults() {
  readonly DOT_IS_ADMIN=${_DOT_IS_ADMIN:-$DOT_FALSE}
  readonly DOT_IS_FORCE=${_DOT_IS_FORCE:-$DOT_FALSE}
  readonly DOT_IS_DRYRUN=${_DOT_IS_DRYRUN:-$DOT_FALSE}
  readonly DOT_IS_INFO=${_DOT_IS_INFO:-$DOT_FALSE}
}

#######################################
# Parse arguments from invocation on command line
#
# Globals:
#   DOT_VERSION
# Outputs:
#   Possibly help and extension adding status
#######################################
dot_parse_args() {
  while getopts :FE:divh opt; do
    case "$opt" in
      F)
        _DOT_IS_FORCE=$DOT_TRUE
        ;;
      E)
        dot_extension_add "$OPTARG"
        ;;
      d)
        _DOT_IS_DRYRUN=$DOT_TRUE
        ;;
      i)
        _DOT_IS_INFO=$DOT_TRUE
        ;;
      v)
        echo "$DOT_VERSION"
        exit 0
        ;;
      h)
        dot_print_usage
        exit 0
        ;;
      [?])
        dot_print_usage
        exit 1
        ;;
    esac
  done
}

#######################################
# Trap function. Triggers cleanup actions and invokes explicit exit
#
# Outputs:
#   Status messages foe cleanup and warning that script is terrminating early
#######################################
dot_cleanup() {
  # Fix cursor & output
  tput cnorm
  dot_puts ""

  dot_warn "install.sh terminating early"

  # Call extensions for possible cleanup
  dot_rpublish "$DOT_WILL_CLEANUP_EVENT"
  dot_exit 1
}

#######################################
# Explicit exit.
#
# Arguments:
#   Exit code
# Outputs:
#   Status messages and fin.
#######################################
dot_exit() {
  # Flush contexts
  local n=$(dot_output_num_contexts)
  while [[ n -gt 0 ]]; do
    dot_output_pop_context > /dev/null
    n=$((n-1))
  done

  dot_puts "Done Bootstrapping."
  exit $1
}

#######################################
# Publishes events for marshalled installation
#
# Outputs:
#   Installation status
#######################################
dot_install() {
  dot_puts_info "Installing software."
  dot_publish "$DOT_WILL_INSTALL_APT_PACKAGES_EVENT"
  dot_publish "$DOT_DO_INSTALL_APT_PACKAGES_EVENT"
  dot_publish "$DOT_DID_INSTALL_APT_PACKAGES_EVENT"

  dot_publish "$DOT_WILL_INSTALL_PACMAN_PACKAGES_EVENT"
  dot_publish "$DOT_DO_INSTALL_PACMAN_PACKAGES_EVENT"
  dot_publish "$DOT_DID_INSTALL_PACMAN_PACKAGES_EVENT"

  dot_publish "$DOT_WILL_INSTALL_YAY_PACKAGES_EVENT"
  dot_publish "$DOT_DO_INSTALL_YAY_PACKAGES_EVENT"
  dot_publish "$DOT_DID_INSTALL_YAY_PACKAGES_EVENT"

  dot_publish "$DOT_WILL_INSTALL_BREW_FORMULAE_EVENT"
  dot_publish "$DOT_DO_INSTALL_BREW_FORMULAE_EVENT"
  dot_publish "$DOT_DID_INSTALL_BREW_FORMULAE_EVENT"
  dot_puts_info "Done installing software."

  dot_puts_info "Setting up software."
  dot_publish "$DOT_WILL_SETUP_SOFTWARE_EVENT"
  dot_publish "$DOT_DO_SETUP_SOFTWARE_EVENT"
  dot_publish "$DOT_DID_SETUP_SOFTWARE_EVENT"
  dot_puts_info "Done setting up software."
}

#######################################
# Main driver for redability
#
# Arguments:
#   Script arguments
# Outputs:
#   Installation status
#######################################
dot_main () {
  local welcome_banner="$(cat << DOTFILES
Now Bootstrapping...
░█▀▄░█▀█░▀█▀░█▀▀░▀█▀░█░░░█▀▀░█▀▀
░█░█░█░█░░█░░█▀▀░░█░░█░░░█▀▀░▀▀█
░▀▀░░▀▀▀░░▀░░▀░░░▀▀▀░▀▀▀░▀▀▀░▀▀▀
DOTFILES
)"

  trap dot_cleanup SIGHUP SIGINT SIGTERM

  dot_parse_args "$@"
  dot_set_defaults

  dot_puts "$welcome_banner"
  sleep 1

  dot_output_begin_install
  dot_puts_info "Loading extensions..."
  dot_extension_load
  dot_install
  dot_output_end_install

  dot_exit 0
}

dot_main "$@"
