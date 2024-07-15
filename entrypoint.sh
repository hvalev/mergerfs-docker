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

# Check if MERGERFS_PARAMS is set, override PARAMETERS_FILE if it is
if [ -n "$MERGERFS_PARAMS" ]; then
    echo "Using parameters from MERGERFS_PARAMS environment variable."
    echo "$MERGERFS_PARAMS" > "$PARAMETERS_FILE"
fi

# Merge parameters from the file into a single line without comments or empty lines
PARAMS=$(grep -v '^#' "$PARAMETERS_FILE" | sed '/^\s*$/d' | sed 's/^[ \t]*//;s/[ \t]*$//' | paste -sd ',' -)

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
