#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <process_name>"
    exit 1
fi

PROCESS_NAME="$1"

# Get the oldest PID matching the process name/pattern
PARENT_PID=$(pgrep -o -f "$PROCESS_NAME")

if [ -z "$PARENT_PID" ]; then
    echo "No process found matching '$PROCESS_NAME'"
    exit 1
fi

# Get the tree of PIDs
PID_LIST=$(pstree -p $PARENT_PID | perl -ne 'push @t, /\((\d+)\)/g; END { print join ",", @t }')

if [ -z "$PID_LIST" ]; then
    echo "No PIDs found in the process tree"
    exit 1
fi

# Run htop with the PID list
htop -p $PID_LIST
