#!/bin/bash

servers=("24.144.108.118" "146.190.217.21" "143.198.161.218")

for server in "${servers[@]}"
do
    echo "Checking server: $server"
    ssh -o ConnectTimeout=3 devops@$server "df -h | grep /dev"
done







Optimized script: 

#!/bin/bash
# Use Bash server IP addresses# Use Bash shell to execute this script
servers=(
    "24.144.108.118"
    "146.190.217.21"
    "143.198.161.218"
)

# Function to check a single server
check_server() {

    # Store the first function argument (server IP) in a local variable
    local server=$1

    # Print separator for better readability
    echo "================================="

    # Display currently processed server
    echo "Checking: $server"

    # Print separator for better readability
    echo "================================="

    # Connect to server using SSH and execute remote commands
    ssh \
        # Timeout SSH connection attempt after 3 seconds
        -o ConnectTimeout=3 \
        # Disable password prompts (non-interactive mode)
        -o BatchMode=yes \
        # Automatically accept unknown host keys
        -o StrictHostKeyChecking=no \
        # Login as devops user to target server
        devops@"$server" \
        # Run hostname and disk usage commands remotely
        "hostname && df -h | grep '^/dev'" \
        # Suppress SSH error messages
        2>/dev/null

    # Check exit status of previous SSH command
    if [ $? -ne 0 ]; then

        # Print error message if connection failed
        echo "❌ Unable to connect to $server"
    fi

    # Print blank line for cleaner output
    echo
}

# Export function so child bash processes can access it
export -f check_server

# Print each server on a new line and send to xargs
printf "%s\n" "${servers[@]}" |

# Run checks in parallel using xargs
xargs -I {} -P 5 bash -c '

# Call check_server function for current server
check_server "$@"

' _ {}




Thanks 
