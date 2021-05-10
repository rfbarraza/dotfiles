##############################################################################
#                                                                            #
# ░█▀▀░▀█▀░█▀█░█▀▀░█░█░░░░█▀▀░█░█                                            #
# ░▀▀█░░█░░█▀█░█░░░█▀▄░░░░▀▀█░█▀█                                            #
# ░▀▀▀░░▀░░▀░▀░▀▀▀░▀░▀░▀░░▀▀▀░▀░▀                                            #
#                                                                            #
#                                                                            #
# Simple stack implementation for global arrays.                             #
#                                                                            #
##############################################################################


if [[ -z "$__DOT_STACK_SH__" ]]; then
readonly __DOT_STACK_SH__="__DOT_STACK_SH__"

source "$DOT_SCRIPT_DIR/lib/include.sh"
source "$DOT_OUTPUT_SH"


#######################################
# Prints the size of the global stack
#
# Arguments:
#   Name of global array to be used as a stack
# Outputs:
#   The number of elements in the stack
#######################################
dot_stack_size() {
  if [[ $# -lt 1 ]]; then
    dot_warn "${FUNCNAME[0]}: no array provided"
    return
  fi

  local readonly stack_name="$1"
  eval local readonly stack=\( \${${stack_name}[@]} \)
  echo "${#stack[@]}"
}

#######################################
# Pushes an item onto the end of the global stack
#
# Arguments:
#   Name of global array to be used as a stack
#   Item to push onto the stack
# Outputs:
#   Warnings if arguments are invalids
#######################################
dot_stack_push() {
  if [[ $# -lt 1 ]]; then
    dot_warn "${FUNCNAME[0]}: no array provided"
    return
  elif [[ $# -lt 2 ]]; then
    dot_warn "${FUNCNAME[0]}: no item provided"
    return
  fi

  local readonly stack_name="$1"
  eval local readonly stack=\( \${${stack_name}[@]} \)
  eval ${stack_name}+=\( "$2" \)
}

#######################################
# Prints the item at the top of the global stack
#
# Arguments:
#   Name of global array to be used as a stack
# Outputs:
#   Prints the item at the top of the global stack or the empty string if
#   there aren't any elements in the stack
#######################################
dot_stack_peek() {
  if [[ $# -lt 1 ]]; then
    dot_warn "${FUNCNAME[0]}: no array provided"
    return
  fi

  local readonly stack_name="$1"
  eval local readonly stack=\( \${${stack_name}[@]} \)
  local readonly size=$(dot_stack_size "$stack_name")
  if [[ $size -gt 0 ]]; then
    local index=$((size-1))
    echo "${stack[$index]}"
  else
    echo ""
  fi
}

#######################################
# Prints the item at the top of the global stack and removes it from the stack
#
# Arguments:
#   Name of global array to be used as a stack
# Outputs:
#   Prints the item at the top of the global stack or the empty string if
#   there aren't any elements in the stack
#######################################
dot_stack_pop() {
  if [[ $# -lt 1 ]]; then
    dot_warn "${FUNCNAME[0]}: no array provided"
    return
  fi

  local readonly stack_name="$1"
  eval local readonly popstack=\( \${${stack_name}[@]} \)
  dot_stack_peek "$stack_name"
  local readonly size=$(dot_stack_size "$stack_name")
  if [[ $size -gt 0 ]]; then
    local i=0
    local popped_array=()
    while [[ i -lt $(($size-1)) ]]; do
      popped_array+=("${popstack[$i]}")
      i=$((i+1))
    done
    eval ${stack_name}=\( \${popped_array[@]} \)
  fi
}

fi
