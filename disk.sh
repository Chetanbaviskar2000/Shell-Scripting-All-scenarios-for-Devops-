#!/bin/bash

# Remote server IP
SERVER="209.38.201.69"

# Alert threshold percentage
THRESHOLD=90

# Get root filesystem usage from remote server
usage=$(ssh devops@$SERVER "df / | awk 'NR==2 {print \$5}' | sed 's/%//'")

# Display current usage
echo "Disk usage on $SERVER: $usage%"

# Compare with threshold
if [ "$usage" -gt "$THRESHOLD" ]; then
    echo "WARNING: Disk usage on $SERVER is above $THRESHOLD%!"
else
    echo "Disk usage on $SERVER is within acceptable limits."
fi