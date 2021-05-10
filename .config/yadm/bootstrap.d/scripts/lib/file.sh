##############################################################################
#                                                                            #
# ░█▀▀░▀█▀░█░░░█▀▀░░░░█▀▀░█░█                                                #
# ░█▀▀░░█░░█░░░█▀▀░░░░▀▀█░█▀█                                                #
# ░▀░░░▀▀▀░▀▀▀░▀▀▀░▀░░▀▀▀░▀░▀                                                #
#                                                                            #
#                                                                            #
# Functions and constants for testing conditions about the filesystem.       #
#                                                                            #
##############################################################################


# ---
# TOC
# ---
#
# ## Utilities
# ## Files
# ## Directories
#

if [[ -z "$__DOT_FILE__" ]]; then
readonly __DOT_FILE__="__DOT_FILE__"

source "$DOT_SCRIPT_DIR/lib/include.sh"
source "$DOT_BOOL_SH"
source "$DOT_OUTPUT_SH"


## Utilities

#######################################
# Prints "device ID:inode" of file for *nix systems
#
# Arguments:
#   Path to file
# Outputs:
#   "device ID:inode"
dot_file_link_stat() {
  local os="$(uname)"
  if [[ "$os" == "Darwin" ]]; then
    stat -L -f %d:%i "$1"
  else
    stat -L -c %d:%i "$1"
  fi
}

#######################################
# Backsup a file to the next open backup file, N, with ~N for N > 1
#
# Arguments:
#   Path to file to back up
#   Backup directory (default is the directory of the file being backed up)
# Outputs:
#   Path to backup file
#######################################
dot_file_backup() {
  local readonly file="$1"
  local dest="$(dirname "$file")"
  if [[ $# -gt 1 ]]; then
    dest="$2"
  fi
  local readonly file_name="$(basename "$file")"
  local readonly last_file="$(basename "$(find "$dest" -maxdepth 1 -name \
    "$file_name~*" | sort | tail -1)")"
  local next_backup_name=""
  if [[  ! -z "$last_file" ]]; then
    local readonly last_number="$(echo "$last_file" | grep -o "[0-9]\+$")"
    if [[ ! -z "$last_number" ]]; then
      local readonly next_number=$((last_number+1))
      local readonly last_file_sans_number="$(echo "$last_file" | \
        sed -r 's/[0-9]+$//')"
      next_backup_name="${last_file_sans_number}${next_number}"
    else
      next_backup_name="${last_file}2"
    fi
  else
    next_backup_name="${file_name}~"
  fi
  local next_backup="${dest}/${next_backup_name}"
  mv "$file" "$next_backup"
  echo "$next_backup"
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
dot_file_restore_backup() {
  local readonly dest="$1"
  local readonly src="$2"

  if [[ -d "$dest" ]]; then
    rm -Rf "$dest"
    mv "$src" "$dest"
  elif [[ -f "$dest" ]]; then
    rm "$dest"
    mv "$src" "$dest"
  else
    return 1
  fi
  return 0
}


## Files

#######################################
# Returns 0 if file is symlinked to target
#
# Arguments:
#   Path to file
#   Target path
# Outputs:
#   None
# Returns:
#   0 if file is symlinked to target
#######################################
dot_file_is_symlink() {
    if [[ -f  "$1" && -L "$1" ]]; then
    local file_stat="$(dot_file_link_stat "$1")"
    local target_stat="$(dot_file_link_stat "$2")"
    [[ "$file_stat" == "$target_stat" ]]
  else
    return 1
  fi
}

#######################################
# Checks if a file is symlinked to a target and returns one of several
# results
#
# Arguments:
#   Path to file
#   Link target
# Returns:
#   0 if file exists and links to target
#   1 if file exists but does not link to target
#   2 if file is a directory
#   3 if file does not exist
#######################################
dot_file_check_symlink() {
  if [[ -f "$1" ]]; then
    dot_file_is_symlink "$1" "$2"
  elif [[ -d "$1" ]]; then
    return 2
  else
    return 3
  fi
}

#######################################
# Installs symlink to target at the specified path
#
# Globals:
#   DOT_IS_DRYRUN
# Arguments:
#   Target
#   Path to symlink
# Outputs:
#   Installation status for dot_dryruns and failures
#######################################
dot_file_install_symlink() {
  if [[ $DOT_IS_DRYRUN == $DOT_TRUE ]]; then
    dot_dryrun ln -s "$1" "$2"
  else
    ln -s "$1" "$2"
  fi
}

#######################################
# Ensures that a symlink to the dotfiles file path is installed or outputs the
# appropriate status message
#
# Arguments:
#   Path to fie
#   Link target
#   Is the file a directory (default DOT_FALSE)
# Outputs:
#   Status messages including failures
#######################################
dot_file_ensure_symlink_installed() {
  local readonly symlink="$1"
  local readonly target="$2"
  local isDirectory="$DOT_FALSE"
  if [[ $# -gt 2 ]]; then
    isDirectory="$3"
  fi

  if [[ "$isDirectory" == "$DOT_TRUE" ]]; then
    dir_check_symlink "$symlink" "$target"
  else
    dot_file_check_symlink "$symlink" "$target"
  fi
  case $? in
    0)
      dot_puts "$symlink is already linked to dotfiles installation."
      ;;
    1)
      if [[ $DOT_IS_FORCE == $DOT_TRUE ]]; then
        local readonly backup="$(dot_file_backup "$symlink")"
        local readonly backup_result="$?"
        if [[ $? ]]; then
          dot_puts "Backing up $symlink to $backup."
          dot_puts "Linking $target via $symlink."
          dot_file_install_symlink "$target" "$symlink"
          if [[ ! $? ]]; then
            dot_warn "Link failed."
          fi
        else
          dot_warn "$symlink is not a part of dotfiles installation."
          dot_warn "Could not backup $symlink."
          dot_warn "$symlink could NOT be updated."
        fi
      else
        dot_warn "$symlink is pointing outside of dotfiles installation."
      fi
      ;;
    2)
      if [[ "$isDirectory" == "$DOT_TRUE" ]]; then
        dot_warn "$symlink is a file when a directory was expected."
      else
        dot_warn "$symlink is a directory when a file was expected."
      fi
      ;;
    3)
      dot_puts "Linking $target via $symlink."
      dot_file_install_symlink "$target" "$symlink"
      if [[ ! $? ]]; then
        dot_warn "Link failed."
      fi
      ;;
    *)
      dot_warn "Symbolic link check returned an unexpected value: $?"
      ;;
  esac
}


## Directories

#######################################
# Returns 0 if directory is symlinked to target
#
# Arguments:
#   Path to directory
#   Target
# Returns:
#   0 if directory is symlinked to target
#######################################
dir_is_symlink() {
  if [[ -d "$1" && -L "$1" ]]; then
    local dir_stat="$(dot_file_link_stat "$1")"
    local target_stat="$(dot_file_link_stat "$2")"
    [[ "$dir_stat" == "$target_stat" ]]
  else
    return 1
  fi
}

#######################################
# Checks if a directory is symlinked to a target and returns one of several
#
# Arguments:
#   Path to directory
#   Link target
# Returns:
#   0 if directory exists and links to target
#   1 if directory exists but does not link to target
#   2 if directory is a file
#   3 if directory does not exist
#######################################
dir_check_symlink() {
  if [[ -d "$1" ]]; then
    dir_is_symlink "$1" "$2"
  elif [[ -f "$1" ]]; then
    return 2
  else
    return 3
  fi
}

#######################################
# Ensures that a symlink to the dotfiles directory path is installed or
# outputs the appropriate status message
#
# Arguments:
#   Path to directory
#   Link target
# Outputs:
#   Status messages including failures
#######################################
dot_dir_ensure_symlink_installed() {
  dot_file_ensure_symlink_installed "$1" "$2" "$DOT_TRUE"
}

fi
