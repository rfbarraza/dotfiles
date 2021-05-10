##############################################################################
#                                                                            #
# ░▀█▀░█▀█░█▀▀░█░░░█░█░█▀▄░█▀▀░░░░█▀▀░█░█                                    #
# ░░█░░█░█░█░░░█░░░█░█░█░█░█▀▀░░░░▀▀█░█▀█                                    #
# ░▀▀▀░▀░▀░▀▀▀░▀▀▀░▀▀▀░▀▀░░▀▀▀░▀░░▀▀▀░▀░▀                                    #
#                                                                            #
#                                                                            #
# Globals for sourcing and including files.                                  #
#                                                                            #
##############################################################################


if [[ -z "$__DOT_INCLUDE__" ]]; then

readonly __DOT_INCLUDE__="__DOT_INCLUDE__"

# SCRIPT and DOT_SCRIPT_DIR -must- be defined!

readonly DOT_LIB_DIR="$DOT_SCRIPT_DIR/lib"
readonly DOT_INCLUDE_SH="$DOT_LIB_DIR/include.sh"

readonly DOT_API_SH="$DOT_SCRIPT_DIR/api.sh"
readonly DOT_BOOL_SH="$DOT_LIB_DIR/bool.sh"
readonly DOT_EXTENSION_SH="$DOT_LIB_DIR/extension.sh"
readonly DOT_FILE_SH="$DOT_LIB_DIR/file.sh"
readonly DOT_KILL_SH="$DOT_LIB_DIR/kill.sh"
readonly DOT_OS_SH="$DOT_LIB_DIR/os.sh"
readonly DOT_OUTPUT_SH="$DOT_LIB_DIR/output.sh"
readonly DOT_PUBSUB_SH="$DOT_LIB_DIR/pubsub.sh"
readonly DOT_STACK_SH="$DOT_LIB_DIR/stack.sh"

fi
