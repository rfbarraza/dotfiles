##############################################################################
#                                                                            #
# ░█▀▀░█▀█░▀█▀░█▀█░█▀█░█▀▀░█▀▄░░░░█▀▀░█░█                                    #
# ░▀▀█░█▀▀░░█░░█░█░█░█░█▀▀░█▀▄░░░░▀▀█░█▀█                                    #
# ░▀▀▀░▀░░░▀▀▀░▀░▀░▀░▀░▀▀▀░▀░▀░▀░░▀▀▀░▀░▀                                    #
#                                                                            #
#                                                                            #
# A CUI progress indicator                                                   #
#                                                                            #
##############################################################################

if [[ -z "$__DOT_SPINNER__" ]]; then
readonly __DOT_SPINNER__="__DOT_SPINNER__"

source "$DOT_SCRIPT_DIR/lib/include.sh"
source "$DOT_BOOL_SH"
source "$DOT_OUTPUT_SH"


#######################################
# Prints an output message and animates a spinning progress indicator while a
# given process executes in the background. Upon completion, the terminal is
# no longer blocked and a period is drawn in the spinner's place (followed by
# a linebreak.)
#
# WARNING: !!!DO NOT USE SPINNER WITH SUDO COMMANDS!!!!
# If the command requires user input (like a password or confirmation), this
# mechanism will destory the output.
#
# Arguments:
#   pid of background process
#   Message to print before spinner
# Outputs:
#   Formatted message followed by a spinner and, eventually, a period.
#######################################
dot_spinner() {
  local pid="$1"
  local message="$2"
  local delay=0.75
  local spinstr='|/-\'

  if [[ $DOT_IS_QUIET == $DOT_FALSE ]]; then
    tput civis
    dot_puts "${message}..." $DOT_FALSE
    while [[ "$(ps a | awk '{print $1}' | grep -e "$pid$")" ]]; do
      local temp=${spinstr#?}
      printf " %c " "$spinstr"
      local spinstr=$temp${spinstr%"$temp"}
      sleep $delay
      printf "\b\b\b"
    done
    printf "\b\b\b.    \n"
    tput cnorm
  fi
  wait $pid
}

fi
