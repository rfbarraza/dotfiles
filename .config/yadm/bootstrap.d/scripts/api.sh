##############################################################################
#                                                                            #
# ░█▀█░█▀█░▀█▀░░░░█▀▀░█░█                                                    #
# ░█▀█░█▀▀░░█░░░░░▀▀█░█▀█                                                    #
# ░▀░▀░▀░░░▀▀▀░▀░░▀▀▀░▀░▀                                                    #
#                                                                            #
#                                                                            #
# Extension API for dotfiles installation                                    #
#                                                                            #
##############################################################################

# ---
# TOC
# ---
#
# ## Constants
# ## Output
# ## Installation
# ## Events
#

if [[ -z "$__API__" ]]; then
readonly __API__=="__API__"
readonly API_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


source "$API_DIR/lib/include.sh"
source "$DOT_BOOL_SH"
source "$DOT_FILE_SH"
source "$DOT_OUTPUT_SH"
source "$DOT_PUBSUB_SH"


## Constants
readonly DOT_EXT_TRUE="$DOT_TRUE"
readonly DOT_EXT_FALSE="$DOT_FALSE"


## Output

#######################################
# Formats a line of output for extension execution
#
# Arguments
#   Message to print
# Outputs:
#   $1 followed by newline
#######################################
dot_ext_puts() {
  dot_puts "$1"
}

#######################################
# Formats a line of stderr output for extension execution
#
# Arguments
#   Message to print as a warning to stdeer
# Outputs:
#   $1 followed by newline
#######################################
dot_ext_warn() {
  dot_warn "$1"
}

#######################################
# Formats a line or command for dryrun output
#
# Arguments
#   Command or line to print
# Outputs:
#   $1 followed by newline
#######################################
dot_ext_dryrun() {
  if [[ $DOT_IS_DRYRUN == $DOT_TRUE ]]; then
    dot_dryrun $@
  fi
}

#######################################
# Formats a line of informative output for extension execution
#
# Arguments
#   Info level message to print
# Outputs:
#   $1 followed by newline
#######################################
dot_ext_puts_info() {
  dot_puts_info "$1"
}


## Installation

#######################################
# Prints dryrun status (if the install run will or will not alter the system)
#
# Outputs:
#   $DOT_EXT_TRUE if in dryrun, $DOT_EXT_FALSE otherwise
#######################################
dot_ext_is_dryrun() {
  echo $DOT_IS_DRYRUN
}

#######################################
# Prints force status. (if the install witl force system changes with backups)
#
# Outputs:
#   $DOT_EXT_TRUE if in force mode, $DOT_EXT_FALSE otherwise
#######################################
dot_ext_is_force() {
  echo $DOT_IS_FORCE
}

#######################################
# Backsup a file to the next open backup file, N, with ~N for N > 1
#
# Arguments:
#   Path to file to back up
#   Backup directory (default is the directory of the file being backed up)
# Outputs:
#   Path to backup file
######################################
dot_ext_backup() {
  dot_file_backup "$1"
}

#######################################
# Restores a file from the given backup
#
# Arguments:
#   Path to file to back up
#   Backup directory (default is the directory of the file being backed up)
# Returns:
#   0 if successful, 1 otherwise
######################################
dot_ext_restore() {
  dot_file_restore_backup "$1" "$2"
}

#######################################
# Creates a symlink to a target file or dir
#
# Arguments:
#   Path to symlink
#   Path to target for symlink
######################################
dot_ext_symlink() {
  local readonly symlink="$1"
  local readonly target="$2"

  if [[ -d "$target" ]]; then
    dot_dir_ensure_symlink_installed "$symlink" "$target"
  else
    dot_file_ensure_symlink_installed "$symlink" "$target"
  fi
}


## Events

# Software packages
readonly DOT_WILL_INSTALL_APT_PACKAGES_EVENT="DOT_WILL_INSTALL_APT_PACKAGES_EVENT"
readonly DOT_DO_INSTALL_APT_PACKAGES_EVENT="DOT_DO_INSTALL_APT_PACKAGES_EVENT"
readonly DOT_DID_INSTALL_APT_PACKAGES_EVENT="DOT_DID_INSTALL_APT_PACKAGES_EVENT"
readonly DOT_WILL_INSTALL_PACMAN_PACKAGES_EVENT="DOT_WILL_INSTALL_PACMAN_PACKAGES_EVENT"
readonly DOT_DO_INSTALL_PACMAN_PACKAGES_EVENT="DOT_DO_INSTALL_PACMAN_PACKAGES_EVENT"
readonly DOT_DID_INSTALL_PACMAN_PACKAGES_EVENT="DOT_DID_INSTALL_PACMAN_PACKAGES_EVENT"
readonly DOT_WILL_INSTALL_YAY_PACKAGES_EVENT="DOT_WILL_INSTALL_YAY_PACKAGES_EVENT"
readonly DOT_DO_INSTALL_YAY_PACKAGES_EVENT="DOT_DO_INSTALL_YAY_PACKAGES_EVENT"
readonly DOT_DID_INSTALL_YAY_PACKAGES_EVENT="DOT_DID_INSTALL_YAY_PACKAGES_EVENT"
readonly DOT_WILL_INSTALL_BREW_FORMULAE_EVENT="DOT_WILL_INSTALL_BREW_FORMULAE_EVENT"
readonly DOT_DO_INSTALL_BREW_FORMULAE_EVENT="DOT_DO_INSTALL_BREW_FORMULAE_EVENT"
readonly DOT_DID_INSTALL_BREW_FORMULAE_EVENT="DOT_DID_INSTALL_BREW_FORMULAE_EVENT"

# Software setup
readonly DOT_WILL_SETUP_SOFTWARE_EVENT="DOT_WILL_SETUP_SOFTWARE_EVENT"
readonly DOT_DO_SETUP_SOFTWARE_EVENT="DOT_DO_SETUP_SOFTWARE_EVENT"
readonly DOT_DID_SETUP_SOFTWARE_EVENT="DOT_DID_SETUP_SOFTWARE_EVENT"

# Cleanup (when the script receives a signal and must terminate)
readonly DOT_WILL_CLEANUP_EVENT="$DOT_PUBSUB_CLEANUP_EVENT"


#######################################
# Subcribe callback to event. Callbacks will be executed on a FIFO queue.
#
# Arguments
#   Event (see lists above)
#   Callback function from extension
#   Extension (default is the filename of the extension script)
#######################################
dot_ext_subscribe() {
  local extension="$(basename "${BASH_SOURCE[1]}")"
  if [[ $# -gt 2 ]]; then
    extension="$3"
  fi

  dot_subscribe "$1" "$2" "$extension"
}

#######################################
# Unsubcribe callback from event. Callbacks will no longer be executed.
#
# Arguments
#   Event (see lists above)
#   Callback function from extension
#######################################
dot_ext_unsubscribe() {
  local event="$1"
  local callback=""
  if [[ $# -gt 1 ]]; then
    callback="$2"
  else
    event="${FUNCNAME[1]}"
  fi
  dot_unsubscribe "$event" "$callback"
}

fi
