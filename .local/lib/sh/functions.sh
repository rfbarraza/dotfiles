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

#####################################
# Monitors Arduino serial
# Globals:
#   minicom
# Arguments:
#   None
# Outputs:
#   None
# Returns:
#   None
####################################
console() {
  modem=`ls -1 /dev/cu.* | grep -vi bluetooth | tail -1`
  baud=${1:-9600}
  if [ ! -z "$modem" ]; then
    minicom -D $modem  -b $baud
  else
    echo "No USB modem device found in /dev"
  fi
}

