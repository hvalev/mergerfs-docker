#!/bin/sh

# Function to clean up on script exit
cleanup() {
    echo "Unmounting mergerfs..."
    umount /merged
    echo "Unmounted mergerfs."
}

# Set debugging options
# set -e  # Exit immediately if a command exits with a non-zero status
# set -x  # Print commands and their arguments as they are executed

# Define the default parameters file
PARAMETERS_FILE="/config/parameters.conf"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Determine source of parameters
if [ -n "$MERGERFS_PARAMS" ]; then
    log "Using parameters from MERGERFS_PARAMS environment variable."
    PARAMS="$MERGERFS_PARAMS"
else
    if [ ! -f "$PARAMETERS_FILE" ]; then
        log "Error: /config/parameters.conf not found and MERGERFS_PARAMS is not set."
        exit 1
    fi

    # Merge parameters from the file into a single line without comments or empty lines
    PARAMS=$(grep -v '^\s*#' "$PARAMETERS_FILE" | sed '/^\s*$/d' | sed 's/^[ \t]*//;s/[ \t]*$//' | paste -sd ',' -)

    if [ -z "$PARAMS" ]; then
        log "Error: No valid parameters found in $PARAMETERS_FILE."
        exit 1
    else
        log "Collecting parameters from configuration file found at /config/parameters.conf"
    fi
fi


# Prepare the mergerfs command
COMMAND="mergerfs -o $PARAMS /disks/*: /merged"

# Print the command being executed
echo "Executing: $COMMAND"

# Mount using mergerfs
$COMMAND

# Trap SIGTERM signal of docker daemon
trap cleanup SIGTERM

# Trap exit signals to ensure cleanup
trap cleanup EXIT INT

# Wait for mergerfs process to finish
while [[ $(ps -eo 'comm' | grep mergerfs -c) -gt 0 ]]; do
    sleep 1
done

echo "mergerfs terminated"
