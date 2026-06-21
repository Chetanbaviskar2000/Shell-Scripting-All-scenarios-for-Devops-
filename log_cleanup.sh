#!/bin/bash

SERVER=${1:-"209.38.201.69"}
LOGFILE="/tmp/log_cleanup_$(date +%F_%H-%M-%S).log"

echo "================================="
echo "Starting Log Cleanup"
echo "Server : $SERVER"
echo "Time   : $(date)"
echo "================================="

ssh -o ConnectTimeout=10 devops@$SERVER '
find /home/devops/ -type f -size +200M -print
' > "$LOGFILE"

if [ $? -ne 0 ]; then
    echo "ERROR: Unable to connect to $SERVER"
    exit 1
fi

echo "Large files found:"
cat "$LOGFILE"

echo "Deleting files..."

ssh devops@$SERVER '
find /home/devops/ -type f -size +200M -delete -print
'

echo "Cleanup completed successfully."