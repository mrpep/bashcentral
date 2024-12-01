#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
CONFIG_PATH=$SCRIPT_DIR/config
LOCAL_LOG_DIR=$(grep "^LOG_DIR:" "$CONFIG_PATH" | cut -d':' -f2 | xargs)
HOSTNAME=$(hostname)  # Get the system's hostname
LOCAL_LOG_FILE="$LOCAL_LOG_DIR/$HOSTNAME.log.json"

log_command() {
    local timestamp=$(date "+%Y-%m-%dT%H:%M:%S")
    local user=$(whoami)
    local cwd=$(pwd)
    local command=$(history 1 | sed 's/^[ ]*[0-9]*[ ]*//')

    # Create a JSON entry
    local json_entry=$(printf '{"timestamp": "%s", "user": "%s", "cwd": "%s", "command": "%s"}\n' \
        "$timestamp" "$user" "$cwd" "$command")

    # Append to the local log file
    echo "$json_entry" >> "$LOCAL_LOG_FILE"
}

export -f log_command
