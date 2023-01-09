#######################################
# Loops printing neofetch data for tmux.
# Globals:
#   neofetch
# Arguments:
#   Time to sleep between iterations (s)
# Outputs:
#   Logo and System info
#######################################
loopinfo() {
  while true; do
    neofetch --color_blocks off
    if [[ -nz "$1" ]]; then
      sleep "$1"
    else
      sleep 300
    fi
  done
}

#######################################
# Checks if rhe system is macOS
# Globals:
#   uname
# Arguments:
#   None
# Outputs:
#   None
# Returns:
#   Success if the system is Darwin
#######################################
darwin_check() {
  uname | grep "Darwin" > /dev/null  2>&1
}

#######################################
# Checks if the system is Linux
# Globals:
#   uname
# Arguments:
#   None
# Outputs:
#   None
# Returns:
#   Success if the system is Linux
#######################################
linux_check() {
  grep -e "^Linux" /etc/os-release > /dev/null 2>&1
}

######################################
# Stores the current working directory to a bookmark variable 
# Globals:
#   hash
# Arguments:
#   variable to store bookemark to 
# Outputs:
#   None
#####################################
hashcwd() {
  hash -d "$1"="$PWD"
}
