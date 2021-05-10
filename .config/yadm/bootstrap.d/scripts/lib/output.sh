##############################################################################
#                                                                            #
# ░█▀█░█░█░▀█▀░█▀█░█░█░▀█▀░░░░█▀▀░█░█                                        #
# ░█░█░█░█░░█░░█▀▀░█░█░░█░░░░░▀▀█░█▀█                                        #
# ░▀▀▀░▀▀▀░░▀░░▀░░░▀▀▀░░▀░░▀░░▀▀▀░▀░▀                                        #
#                                                                            #
#                                                                            #
# Output for installation scripts                                            #
#                                                                            #
##############################################################################


if [[ -z $__DOT_OUTPUT__ ]]; then
readonly __DOT_OUTPUT__="__DOT_OUTPUT__"

source "$DOT_SCRIPT_DIR/lib/include.sh"
source "$DOT_BOOL_SH"
source "$DOT_KILL_SH"
source "$DOT_STACK_SH"


DOT_OUTPUT_CONTEXT=()
DOT_OUTPUT_INSTALL_CONTEXT="DOT_OUTPUT_INSTALL_CONTEXT"
DOT_IS_DRYRUN="$DOT_FALSE"


#######################################
# Pushes a context string to the top of the context stack
#
# Globals:
#   DOT_OUTPUT_CONTEXT
# Arguments:
#   context to push
# Outputs:
#   None
#######################################
dot_output_push_context() {
  local readonly context="$1"
  dot_stack_push DOT_OUTPUT_CONTEXT "$context"
}

#######################################
# Prints the number of contexts in the context stack
#
# Globals:
#   DOT_OUTPUT_CONTEXT
# Outputs:
#   The number of conterxts in the conterxt stack
#######################################
dot_output_num_contexts() {
  dot_stack_size DOT_OUTPUT_CONTEXT
}

#######################################
# Prints the context at the top of the context stack
#
# Globals:
#   DOT_OUTPUT_CONTEXT
# Outputs:
#   The context at the top of the context stack
#######################################
dot_output_current_context() {
  dot_stack_peek DOT_OUTPUT_CONTEXT
}

#######################################
# Prints the context at the top of the context stack and removes it from the
# stack
#
# Globals:
#   DOT_OUTPUT_CONTEXT
# Outputs:
#   The context at the top of the current stack
#######################################
dot_output_pop_context() {
  dot_stack_pop DOT_OUTPUT_CONTEXT > /dev/null 2>&1
}

#######################################
# Prints $DOT_TRUE if the current context is the default install context;
# $DOT_FALSE otherwise
#
# Globals:
#   DOT_OUTPUT_INSTALL_CONTEXT
# Outputs:
#   $DOT_TRUE if the cunrrent context is the default install context;
#   $DOT_FALSE otherwise
#######################################
dot_output_is_in_install_context() {
  local readonly context="$(dot_output_current_context)"
  if [[ "$context" == "$DOT_OUTPUT_INSTALL_CONTEXT" ]]; then
    echo $DOT_TRUE
  else
    echo "$DOT_FALSE"
  fi
}

#######################################
# Primes the context stack for installation output. Call before installation.
#######################################
dot_output_begin_install() {
  dot_output_push_context "$DOT_OUTPUT_INSTALL_CONTEXT"
}

#######################################
# Empties the context stack for the end of installation output. Call at end of
# installation.
#######################################
dot_output_end_install() {
  while [[ $(dot_output_num_contexts) -gt 0 &&
          "$(dot_output_is_in_install_context)" == "$DOT_FALSE" ]]; do
    dot_output_pop_context > /dev/null 2>&1
  done
  dot_output_pop_context > /dev/null 2>&1
}

#######################################
# Politely wait and sleep for the output buffer to flush.
#######################################
dot_output_sleep() {
  sleep 0.05
}

#######################################
# Formats and prints a string message for installation output if not in quiet
# mode.
#
# Arguments:
#   Message to output
#   DOT_TRUE or DOT_FALSE to include newline (default DOT_TRUE)
# Outputs:
#   Formatted message
#######################################
dot_puts() {
  dot_output_sleep
  local readonly message="$1"

  local newline=$DOT_TRUE
  if [[ $# -gt 1 ]]; then
    newline=$2
  fi

  local printbar=$DOT_TRUE
  if [[ $# -gt 2 ]]; then
    printbar=$3
  fi

  local label=""
  if [[ $# -gt 3 ]]; then
    label="$4"
  fi

  local prefix=""
  local num_context="$(dot_output_num_contexts)"

  if [[ $num_context -gt 0 ]]; then
    prefix+="|"
    num_context=$((num_context-1))
  fi

  while [[ $num_context -gt 0 ]]; do
    prefix+=" |"
    num_context=$((num_context-1))
  done

  local label=""
  if [[ ! -z "$prefix" ]]; then
    label=" "
  fi

  local readonly context="$(dot_output_current_context)"
  if [[ ! -z "$context" &&
        "$context" != "$DOT_OUTPUT_INSTALL_CONTEXT" ]]; then
    label="\e[1;7m $context \e[0m "
  fi

  local suffix="$([[ $newline == $DOT_TRUE ]] && echo "\n" || echo "")"

  local out="${prefix}${label}${message}${suffix}"
  printf "$out"
}

#######################################
# Formats and prints a string message to stderr as a dot_warning for
# installation
#
# Arguments:
#   Message to output
# Outputs:
#   Warning message on stderr
#######################################
dot_warn() {
  dot_output_sleep
  printf "\e[1;7m WARNING \e[0m $1\n" >&2
}

#######################################
# Formats and prints a string message to stderr as an dot_error for
# installation. Installation is halted
#
# Arguments:
#   Message to output
# Outputs:
#   Error message on stderr
#######################################
dot_error() {
  dot_output_sleep
  printf "\e[1;7m ERROR \e[0m $1\n" >&2
  dot_kill
}

#######################################
# Given two files containing all output and just stdout, iterate through the
# lines for formatted output printing dot_warnings for stderr when
# appropriate
#
# Arguments:
#   Path to file with both stdout and stderr output
#   Path to file with just stdout
# Outputs:
#   Warning message on stderr
#######################################
dot_print_cmd_output() {
  dot_output_sleep
  local tempoutnerr="$1"
  local tempout="$2"

  while read -r line; do
    if [[ $(grep "$line" "$tempout") ]]; then
      dot_puts "$line"
    else
      dot_warn "$line"
    fi
  done <"$tempoutnerr"
}

#######################################
# Prints a warning that the script is performing a dryrun where the system
# will not be altered.
#
# Globals:
#   DOT_IS_DRYRUN
# Arguments:
#   Command interpretted as a string
# Outputs:
#   Warning statement containing the command without executing it
#######################################
dot_dryrun() {
  dot_output_push_context "DRYRUN"
  if [[ ! -t 0 ]]; then
    cat
  fi
  printf -v cmd_str '%q ' "$@"
  dot_puts "$cmd_str"
  dot_output_pop_context
}

#######################################
# Formats and prints a string message to stdout that is at an informative level
#
# Arguments:
#   Informative message to output
# Outputs:
#   Informative message on stdout
#######################################
dot_puts_info() {
  if [[ "$DOT_IS_DRYRUN" == $DOT_TRUE || "$DOT_IS_INFO" == $DOT_TRUE ]]; then
    dot_puts "$1"
  fi
}

fi
