##############################################################################
#                                                                            #
# ░█▀█░█░█░█▀▄░█▀▀░█░█░█▀▄░░░░█▀▀░█░█                                        #
# ░█▀▀░█░█░█▀▄░▀▀█░█░█░█▀▄░░░░▀▀█░█▀█                                        #
# ░▀░░░▀▀▀░▀▀░░▀▀▀░▀▀▀░▀▀░░▀░░▀▀▀░▀░▀                                        #
#                                                                            #
#                                                                            #
# Mechanism for callbacks subscribing to events and publishing events.       #
#                                                                            #
##############################################################################


if [[ -z "$__DOT_PUBSUB__" ]]; then
readonly __DOT_PUBSUB__="__DOT_PUBSUB__"

source "$DOT_SCRIPT_DIR/lib/include.sh"
source "$DOT_OUTPUT_SH"


DOT_PUBSUB_EVENTS=()
DOT_PUBSUB_CLEANUP_EVENT="DOT_PUBSUB_CLEANUP_EVENT"

#######################################
# Adds a callback to the event queue
#
# Globals:
#   DOT_PUBSUB_EVENTS
# Arguments:
#   Event subscribing to
#   Callback
#   Extension (default is extension script filename)
#######################################
dot_subscribe() {
  DOT_PUBSUB_EVENTS+=("${1};${2};${3}")
}

#######################################
# Remoces a callback from the event queue
#
# Globals:
#   DOT_PUBSUB_EVENTS
# Arguments:
#   Event
#   Callback
#######################################
dot_unsubscribe() {
  local readonly event="$1"
  local readonly callback="$2"

  local unaffected_events=()
  for pubsub_event in "${DOT_PUBSUB_EVENTS[@]}"; do
    local readonly IFS=";"
    local pubsub_event_array
    read -a pubsub_event_array <<< "$pubsub_event"
    local readonly event_name="${pubsub_event_array[0]}"
    local readonly event_callback="${pubsub_event_array[1]}"
    if [[ "$event" != "$event_name" ||
          "$callback" != "$event_callback" ]]; then
      unaffected_events+=( "$pubsub_event" )
    fi
  done
  DOT_PUBSUB_EVENTS=( "${unaffected_events[@]}" )
}

#######################################
# Called inside a loop with a given event and pubsub event item to execute it
# if necessary
#
# Arguments:
#   Event published
#   Item from DOT_PUBSUB_EVENTS
#######################################
dot_pubsub_event_handler() {
  local readonly IFS=";"
  local readonly published_event="$1"
  local readonly pubsub_event="$2"
  shift
  shift
  local pubsub_event_array
  read -a pubsub_event_array <<< "$pubsub_event"
  local readonly event_name="${pubsub_event_array[0]}"
  local readonly callback="${pubsub_event_array[1]}"
  local readonly extension="${pubsub_event_array[2]}"
  if [[ "$event_name" == "$event" ]]; then
    dot_output_push_context "$extension"
    ${callback} "$@"
    dot_output_pop_context
  fi
}

#######################################
# Iterates through DOT_PUBSUB_EVENTS executing callbacks if necessary based on
# the event published
#
# Globals:
#   DOT_PUBSUB_EVENTS
# Arguments:
#   Event
#   ... arguments for calllback
#######################################
dot_publish() {
  local readonly event="$1"
  shift
  for pubsub_event in "${DOT_PUBSUB_EVENTS[@]}"; do
    dot_pubsub_event_handler "$event" "$pubsub_event"
  done
}


#######################################
# Iterates through DOT_PUBSUB_EVENTS in reverse executing callbacks if
# necessary based on the event published
#
# Globals:
#   DOT_PUBSUB_EVENTS
# Arguments:
#   Event
#   ... arguments for calllback
#######################################
dot_rpublish() {
  local readonly event="$1"
  shift
  local readonly events_indices=( ${!DOT_PUBSUB_EVENTS[@]} )
  for ((i=${#events_indices[@]} - 1; i >= 0; --i)) ; do
    local pubsub_event="${DOT_PUBSUB_EVENTS[events_indices[i]]}"
    dot_pubsub_event_handler "$event" "$pubsub_event"
  done
}

fi
